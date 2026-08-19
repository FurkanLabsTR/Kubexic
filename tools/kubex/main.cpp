#include "archive_build.h"
#include "auth_manager.h"
#include "build.h"
#include "deps.h"
#include "init.h"
#include "kxconf.h"
#include "project.h"
#include "registry_client.h"
#include "semver.h"

#include <algorithm>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <unistd.h>
#include <vector>

namespace {

void printUsage() {
  std::cerr
    << "kubex — Kubexic package manager\n"
    << "\n"
    << "usage: kubex <command> [options] [args]\n"
    << "\n"
    << "commands:\n"
    << "  init            Create a new project\n"
    << "  add <dep>       Add a dependency\n"
    << "  remove <dep>    Remove a dependency\n"
    << "  build           Build the project\n"
    << "  run             Build and run the project\n"
    << "  tree            Show dependency tree\n"
    << "  login           Login to registry\n"
    << "  register        Register a new account\n"
    << "  logout          Logout from registry\n"
    << "  publish         Publish package to registry\n"
    << "  search <query>  Search packages in registry\n"
    << "  install <pkg>   Install a package from registry\n"
    << "  info <pkg>      Show package info from registry\n"
    << "  cache list      List cached packages\n"
    << "  cache clean     Remove all cached packages\n"
    << "  cache path      Show cache directory\n"
    << "\n"
    << "global options:\n"
    << "  --registry <url>  Override registry URL (env: KUBEX_REGISTRY_URL)\n"
    << "  --help            Show this help\n"
    << "  --version         Show version\n";
}

void printVersion() {
  std::cerr << "kubex 0.1.0\n";
}

void printTree(const kubex::ProjectInfo& project, bool includeDev) {
  std::cout << project.name << "@" << project.version << "\n";

  auto deps = project.conf.sections.find("dependencies");
  if (deps != project.conf.sections.end()) {
    std::vector<std::pair<std::string, kubex::KxValue>> sorted(deps->second.begin(),
                                                                 deps->second.end());
    for (size_t i = 0; i < sorted.size(); i++) {
      bool last = (i == sorted.size() - 1) && (!includeDev || project.conf.sections.find("dev-dependencies") == project.conf.sections.end());
      std::string prefix = last ? "└── " : "├── ";
      std::string conn = last ? "    " : "│   ";

      auto& [name, val] = sorted[i];
      std::string ver;
      if (auto* s = std::get_if<std::string>(&val)) ver = *s;
      else if (auto* v = std::get_if<int64_t>(&val)) ver = std::to_string(*v);

      std::cout << prefix << name << "@" << ver;

      // check if cached
      auto req = kubex::parseVersionReq(ver);
      if (kubex::isCached(name, req.version.str())) {
        std::cout << " [cached]";
      } else {
        std::cout << " [not cached]";
      }
      std::cout << "\n";
    }
  }

  if (includeDev) {
    auto devDeps = project.conf.sections.find("dev-dependencies");
    if (devDeps != project.conf.sections.end()) {
      std::vector<std::pair<std::string, kubex::KxValue>> sorted(devDeps->second.begin(),
                                                                   devDeps->second.end());
      for (size_t i = 0; i < sorted.size(); i++) {
        bool last = (i == sorted.size() - 1);
        std::string prefix = last ? "└── " : "├── ";

        auto& [name, val] = sorted[i];
        std::string ver;
        if (auto* s = std::get_if<std::string>(&val)) ver = *s;
        else if (auto* v = std::get_if<int64_t>(&val)) ver = std::to_string(*v);

        std::cout << prefix << name << "@" << ver << " [dev]\n";
      }
    }
  }
}

int cmdAdd(const std::string& spec, bool isDev) {
  auto project = kubex::findProject();
  if (!project.ok()) {
    for (const auto& e : project.conf.errors)
      std::cerr << e.file << ":" << e.line << ": " << e.message << "\n";
    return 1;
  }

  // parse spec: name or name@version
  std::string name = spec;
  std::string versionReq = "*";
  size_t at = spec.find('@');
  if (at != std::string::npos) {
    name = spec.substr(0, at);
    versionReq = spec.substr(at + 1);
  }

  std::string section = isDev ? "dev-dependencies" : "dependencies";
  project.conf.sections[section][name] = versionReq;

  // write back .kxconf
  std::ofstream out(project.root / ".kxconf", std::ios::trunc);
  if (!out) {
    std::cerr << "kubex: cannot write " << project.root / ".kxconf" << "\n";
    return 1;
  }

  out << "// .kxconf — Kubexic project manifest\n\n";
  out << "[package]\n";
  out << "name = \"" << project.conf.getString("package", "name") << "\"\n";
  out << "version = \"" << project.conf.getString("package", "version") << "\"\n";
  if (project.conf.has("package", "description"))
    out << "description = \"" << project.conf.getString("package", "description") << "\"\n";
  if (project.conf.has("package", "license"))
    out << "license = \"" << project.conf.getString("package", "license") << "\"\n";
  out << "\n[target]\n";
  out << "kind = \"" << project.conf.getString("target", "kind", "binary") << "\"\n";
  out << "entry = \"" << project.conf.getString("target", "entry", "main.kx") << "\"\n";
  out << "\n[build]\n";
  out << "optimization = \"" << project.conf.getString("build", "optimization", "release") << "\"\n";

  // write dependencies
  for (const auto& sec : {"dependencies", "dev-dependencies"}) {
    auto it = project.conf.sections.find(sec);
    if (it != project.conf.sections.end() && !it->second.empty()) {
      out << "\n[" << sec << "]\n";
      for (const auto& [k, v] : it->second) {
        if (auto* s = std::get_if<std::string>(&v))
          out << k << " = \"" << *s << "\"\n";
        else if (auto* n = std::get_if<int64_t>(&v))
          out << k << " = " << *n << "\n";
      }
    }
  }

  std::cout << "added " << name << " " << versionReq << "\n";
  return 0;
}

int cmdRemove(const std::string& name, bool isDev) {
  auto project = kubex::findProject();
  if (!project.ok()) {
    for (const auto& e : project.conf.errors)
      std::cerr << e.file << ":" << e.line << ": " << e.message << "\n";
    return 1;
  }

  std::string section = isDev ? "dev-dependencies" : "dependencies";
  auto it = project.conf.sections.find(section);
  if (it == project.conf.sections.end() || it->second.count(name) == 0) {
    std::cerr << "kubex: dependency '" << name << "' not found\n";
    return 1;
  }

  it->second.erase(name);

  // rewrite .kxconf (simplified)
  std::ofstream out(project.root / ".kxconf", std::ios::trunc);
  out << "// .kxconf — Kubexic project manifest\n\n";
  out << "[package]\n";
  out << "name = \"" << project.conf.getString("package", "name") << "\"\n";
  out << "version = \"" << project.conf.getString("package", "version") << "\"\n";
  out << "\n[target]\n";
  out << "kind = \"" << project.conf.getString("target", "kind", "binary") << "\"\n";
  out << "entry = \"" << project.conf.getString("target", "entry", "main.kx") << "\"\n";
  out << "\n[build]\n";
  out << "optimization = \"" << project.conf.getString("build", "optimization", "release") << "\"\n";

  for (const auto& sec : {"dependencies", "dev-dependencies"}) {
    auto sit = project.conf.sections.find(sec);
    if (sit != project.conf.sections.end() && !sit->second.empty()) {
      out << "\n[" << sec << "]\n";
      for (const auto& [k, v] : sit->second) {
        if (auto* s = std::get_if<std::string>(&v))
          out << k << " = \"" << *s << "\"\n";
      }
    }
  }

  std::cout << "removed " << name << "\n";
  return 0;
}

int cmdCache(const std::string& sub) {
  namespace fs = std::filesystem;
  auto cache = kubex::cacheDir();

  if (sub == "path") {
    std::cout << cache << "\n";
    return 0;
  }

  if (sub == "clean") {
    if (fs::exists(cache)) {
      fs::remove_all(cache);
      std::cout << "cache cleaned\n";
    } else {
      std::cout << "cache already empty\n";
    }
    return 0;
  }

  if (sub == "list") {
    if (!fs::exists(cache)) {
      std::cout << "no cached packages\n";
      return 0;
    }
    bool any = false;
    for (const auto& entry : fs::directory_iterator(cache)) {
      if (entry.is_directory()) {
        std::cout << entry.path().filename().string() << "\n";
        any = true;
      }
    }
    if (!any) std::cout << "no cached packages\n";
    return 0;
  }

  std::cerr << "kubex cache: unknown subcommand '" << sub << "'\n";
  std::cerr << "  usage: kubex cache list|clean|path\n";
  return 1;
}

int cmdLogin() {
  if (kubex::isLoggedIn()) {
    auto auth = kubex::loadAuthToken();
    std::cout << "already logged in as " << auth.username << "\n";
    std::cout << "use 'kubex logout' first to switch accounts\n";
    return 0;
  }

  std::string username, password;
  std::cout << "Username: ";
  std::getline(std::cin, username);
  std::cout << "Password: ";
  std::getline(std::cin, password);

  if (username.empty() || password.empty()) {
    std::cerr << "kubex: username and password are required\n";
    return 1;
  }

  if (kubex::registryLogin(username, password)) {
    std::cout << "logged in as " << username << "\n";
    return 0;
  } else {
    std::cerr << "kubex: login failed\n";
    return 1;
  }
}

int cmdRegister() {
  std::string username, email, password;
  std::cout << "Username: ";
  std::getline(std::cin, username);
  std::cout << "Email: ";
  std::getline(std::cin, email);
  std::cout << "Password: ";
  std::getline(std::cin, password);

  if (username.empty() || email.empty() || password.empty()) {
    std::cerr << "kubex: username, email, and password are required\n";
    return 1;
  }

  if (kubex::registryRegister(username, email, password)) {
    std::cout << "account created. You can now login with 'kubex login'\n";
    return 0;
  } else {
    std::cerr << "kubex: registration failed\n";
    return 1;
  }
}

int cmdLogout() {
  if (!kubex::isLoggedIn()) {
    std::cout << "not logged in\n";
    return 0;
  }
  kubex::clearAuthToken();
  std::cout << "logged out\n";
  return 0;
}

int cmdPublish() {
  auto project = kubex::findProject();
  if (!project.ok()) {
    for (const auto& e : project.conf.errors)
      std::cerr << e.file << ":" << e.line << ": " << e.message << "\n";
    return 1;
  }

  if (!kubex::isValidPackageName(project.name)) {
    std::cerr << "kubex: invalid package name '" << project.name << "'\n";
    std::cerr << "  names must be alphanumeric (a-z, 0-9) with hyphens, underscores, or dots\n";
    return 1;
  }

  if (!kubex::isValidSemVer(project.version)) {
    std::cerr << "kubex: invalid version '" << project.version << "'\n";
    std::cerr << "  versions must follow semver (e.g. 1.0.0, 0.2.1-beta.1)\n";
    return 1;
  }

  if (!kubex::isLoggedIn()) {
    std::cerr << "kubex: not logged in. Use 'kubex login' first.\n";
    return 1;
  }

  std::cout << "building archive...\n";
  std::string archive = kubex::buildPackageArchive(project.root);
  if (archive.empty()) {
    std::cerr << "kubex: failed to build archive\n";
    return 1;
  }

  std::cout << "publishing " << project.name << "@" << project.version << "...\n";
  if (kubex::registryPublish(project.name, project.version, archive)) {
    std::cout << "published " << project.name << "@" << project.version << "\n";
  } else {
    std::cerr << "kubex: publish failed\n";
    std::remove(archive.c_str());
    return 1;
  }

  std::remove(archive.c_str());
  return 0;
}

int cmdSearch(const std::string& query) {
  std::string result = kubex::registrySearch(query);
  if (result.empty()) {
    std::cerr << "kubex: search failed or no results\n";
    return 1;
  }
  std::cout << result << "\n";
  return 0;
}

int cmdInstall(const std::string& spec) {
  std::string name = spec;
  std::string version = "latest";
  size_t at = spec.find('@');
  if (at != std::string::npos) {
    name = spec.substr(0, at);
    version = spec.substr(at + 1);
  }

  if (!kubex::isValidPackageName(name)) {
    std::cerr << "kubex: invalid package name '" << name << "'\n";
    return 1;
  }

  if (version != "latest" && !kubex::isValidSemVer(version)) {
    std::cerr << "kubex: invalid version '" << version << "'\n";
    std::cerr << "  versions must follow semver (e.g. 1.0.0) or be 'latest'\n";
    return 1;
  }

  namespace fs = std::filesystem;
  fs::path installDir = kubex::cacheDir() / (name + "-" + version);

  if (fs::exists(installDir)) {
    std::cout << name << "@" << version << " is already installed\n";
    return 0;
  }

  std::cout << "downloading " << name << "@" << version << "...\n";
  std::string tmpArchive = "/tmp/kubex_install_" + name + ".kxpkg";
  if (!kubex::registryDownload(name, version, tmpArchive)) {
    std::cerr << "kubex: failed to download " << name << "@" << version << "\n";
    return 1;
  }

  fs::create_directories(installDir);
  std::string tarCmd = "tar -xzf '" + tmpArchive + "' -C '" + installDir.string() + "'";
  int rc = std::system(tarCmd.c_str());
  std::remove(tmpArchive.c_str());

  if (rc != 0) {
    std::cerr << "kubex: failed to extract package\n";
    fs::remove_all(installDir);
    return 1;
  }

  std::cout << "installed " << name << "@" << version << "\n";
  return 0;
}

int cmdInfo(const std::string& name) {
  std::string result = kubex::registryGetPackage(name);
  if (result.empty()) {
    std::cerr << "kubex: package '" << name << "' not found\n";
    return 1;
  }
  std::cout << result << "\n";
  return 0;
}

}  // namespace

int main(int argc, char** argv) {
  if (argc < 2) {
    printUsage();
    return 1;
  }

  // Parse global flags (--registry) and find the command
  std::string cmd;
  for (int i = 1; i < argc; i++) {
    if (std::string(argv[i]) == "--registry" && i + 1 < argc) {
      kubex::setRegistryUrl(argv[i + 1]);
      i++;
    } else if (cmd.empty()) {
      cmd = argv[i];
    }
  }

  if (cmd.empty()) {
    printUsage();
    return 1;
  }

  if (cmd == "--help" || cmd == "-h") {
    printUsage();
    return 0;
  }

  if (cmd == "--version" || cmd == "-v") {
    printVersion();
    return 0;
  }

  if (cmd == "init") {
    std::string dir = (argc > 2) ? argv[2] : "";
    std::string tmpl = "binary";
    for (int i = 2; i < argc; i++) {
      if (std::string(argv[i]) == "--template" && i + 1 < argc) {
        tmpl = argv[i + 1];
        i++;
      }
    }
    return kubex::cmdInit(dir, tmpl);
  }

  if (cmd == "add") {
    if (argc < 3) {
      std::cerr << "usage: kubex add <package-spec>\n";
      return 1;
    }
    bool dev = false;
    for (int i = 3; i < argc; i++) {
      if (std::string(argv[i]) == "--dev") dev = true;
    }
    return cmdAdd(argv[2], dev);
  }

  if (cmd == "remove" || cmd == "rm") {
    if (argc < 3) {
      std::cerr << "usage: kubex remove <package-name>\n";
      return 1;
    }
    bool dev = false;
    for (int i = 3; i < argc; i++) {
      if (std::string(argv[i]) == "--dev") dev = true;
    }
    return cmdRemove(argv[2], dev);
  }

  if (cmd == "build") {
    auto project = kubex::findProject();
    if (!project.ok()) {
      for (const auto& e : project.conf.errors)
        std::cerr << e.file << ":" << e.line << ": " << e.message << "\n";
      return 1;
    }

    kubex::BuildOptions opts;
    opts.output = project.conf.getString("target", "output", project.name);
    opts.library = project.conf.getString("target", "kind", "binary") == "library";
    for (int i = 2; i < argc; i++) {
      std::string arg = argv[i];
      if (arg == "--target" && i + 1 < argc) {
        opts.targetTriple = argv[++i];
      } else if (arg == "--debug") {
        opts.debug = true;
      } else if (arg == "--verbose" || arg == "-v") {
        opts.verbose = true;
      } else if (arg == "--output" && i + 1 < argc) {
        opts.output = argv[++i];
      } else if (arg == "--shared") {
        opts.shared = true;
      } else if (arg == "--link-dir" && i + 1 < argc) {
        opts.extraLinkDirs.push_back(argv[++i]);
      } else if (arg == "-l" && i + 1 < argc) {
        opts.extraLibs.push_back(argv[++i]);
      }
    }

    return kubex::runBuild(project, opts) ? 0 : 1;
  }

  if (cmd == "run") {
    auto project = kubex::findProject();
    if (!project.ok()) {
      for (const auto& e : project.conf.errors)
        std::cerr << e.file << ":" << e.line << ": " << e.message << "\n";
      return 1;
    }

    kubex::BuildOptions opts;
    opts.output = project.conf.getString("target", "output", project.name);
    for (int i = 2; i < argc; i++) {
      std::string arg = argv[i];
      if (arg == "--target" && i + 1 < argc) {
        opts.targetTriple = argv[++i];
      } else if (arg == "--debug") {
        opts.debug = true;
      } else if (arg == "--verbose" || arg == "-v") {
        opts.verbose = true;
      }
    }

    if (!kubex::runBuild(project, opts)) return 1;

    // run the built binary
    std::string output = project.conf.getString("target", "output", project.name);
    std::string binPath = (project.root / output).string();
    if (!std::filesystem::exists(binPath)) {
      std::cerr << "kubex: binary not found: " << binPath << "\n";
      return 1;
    }

    // forward remaining args after --
    std::vector<std::string> execArgs;
    execArgs.push_back(binPath);
    bool afterDash = false;
    for (int i = 2; i < argc; i++) {
      if (std::string(argv[i]) == "--") {
        afterDash = true;
        continue;
      }
      if (afterDash) execArgs.push_back(argv[i]);
    }

    std::vector<char*> cArgs;
    for (auto& s : execArgs) cArgs.push_back(s.data());
    cArgs.push_back(nullptr);
    execvp(binPath.c_str(), cArgs.data());
    perror("kubex: exec failed");
    return 1;
  }

  if (cmd == "tree") {
    auto project = kubex::findProject();
    if (!project.ok()) {
      for (const auto& e : project.conf.errors)
        std::cerr << e.file << ":" << e.line << ": " << e.message << "\n";
      return 1;
    }

    bool includeDev = false;
    for (int i = 2; i < argc; i++) {
      if (std::string(argv[i]) == "--dev") includeDev = true;
    }

    printTree(project, includeDev);
    return 0;
  }

  if (cmd == "cache") {
    std::string sub = (argc > 2) ? argv[2] : "list";
    return cmdCache(sub);
  }

  if (cmd == "login") {
    return cmdLogin();
  }

  if (cmd == "register") {
    return cmdRegister();
  }

  if (cmd == "logout") {
    return cmdLogout();
  }

  if (cmd == "publish") {
    return cmdPublish();
  }

  if (cmd == "search") {
    if (argc < 3) {
      std::cerr << "usage: kubex search <query>\n";
      return 1;
    }
    return cmdSearch(argv[2]);
  }

  if (cmd == "install") {
    if (argc < 3) {
      std::cerr << "usage: kubex install <package[@version]>\n";
      return 1;
    }
    return cmdInstall(argv[2]);
  }

  if (cmd == "info") {
    if (argc < 3) {
      std::cerr << "usage: kubex info <package>\n";
      return 1;
    }
    return cmdInfo(argv[2]);
  }

  std::cerr << "kubex: unknown command '" << cmd << "'\n";
  printUsage();
  return 1;
}
