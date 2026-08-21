#include "project.h"

#include <algorithm>
#include <fstream>
#include <sstream>

namespace kubex {

ProjectInfo findProject(const std::filesystem::path& startDir) {
  namespace fs = std::filesystem;
  fs::path dir = fs::absolute(startDir);

  for (;;) {
    fs::path kxconf = dir / ".kxconf";
    if (fs::exists(kxconf)) {
      std::ifstream in(kxconf);
      if (!in) {
        ProjectInfo info;
        info.root = dir;
        info.conf.errors.push_back(
            {kxconf.string(), 0, "cannot read " + kxconf.string()});
        return info;
      }
      std::ostringstream ss;
      ss << in.rdbuf();
      KxConf conf = parseKxConf(ss.str(), kxconf.string());

      ProjectInfo info;
      info.root = dir;
      info.conf = std::move(conf);
      info.name = info.conf.getString("package", "name");
      info.version = info.conf.getString("package", "version");
      return info;
    }

    fs::path parent = dir.parent_path();
    if (parent == dir) break;
    dir = parent;
  }

  ProjectInfo info;
  info.conf.errors.push_back(
      {"", 0, "no .kxconf found (searched from " + fs::absolute(startDir).string() + " upward)"});
  return info;
}

std::vector<std::filesystem::path> collectKxFiles(const std::filesystem::path& dir) {
  std::vector<std::filesystem::path> files;
  if (!std::filesystem::exists(dir)) return files;

  // If it's a single file, return just that file
  if (std::filesystem::is_regular_file(dir)) {
    if (dir.extension() == ".kx") {
      files.push_back(dir);
    }
    return files;
  }

  for (const auto& entry : std::filesystem::recursive_directory_iterator(dir)) {
    if (!entry.is_regular_file()) continue;
    if (entry.path().extension() != ".kx") continue;

    // skip hidden dirs and build dirs
    auto rel = std::filesystem::relative(entry.path(), dir);
    std::string relStr = rel.string();
    if (relStr.find(".kubex") != std::string::npos) continue;
    if (relStr.find("build") != std::string::npos) continue;
    if (relStr.find("vendor") != std::string::npos) continue;

    files.push_back(entry.path());
  }

  std::sort(files.begin(), files.end());
  return files;
}

std::vector<std::filesystem::path> collectSourceFiles(const std::filesystem::path& projectRoot) {
  return collectKxFiles(projectRoot);
}

}  // namespace kubex
