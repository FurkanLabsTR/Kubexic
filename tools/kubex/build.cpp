#include "build.h"

#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <sstream>

namespace kubex {

std::string findKxc() {
  // try PATH
  const char* pathEnv = std::getenv("PATH");
  if (pathEnv) {
    std::istringstream ss(pathEnv);
    std::string dir;
    while (std::getline(ss, dir, ':')) {
      std::filesystem::path candidate = std::filesystem::path(dir) / "kxc";
      if (std::filesystem::exists(candidate)) {
        return candidate.string();
      }
    }
  }

  // try relative to kubex binary (sibling in build/)
  std::filesystem::path kubexBin = std::filesystem::canonical("/proc/self/exe");
  std::filesystem::path buildDir = kubexBin.parent_path();
  std::filesystem::path sibling = buildDir / "kxc";
  if (std::filesystem::exists(sibling)) {
    return sibling.string();
  }

  // try parent build dir
  sibling = buildDir.parent_path() / "build" / "kxc";
  if (std::filesystem::exists(sibling)) {
    return sibling.string();
  }

  return "kxc";  // hope it's on PATH
}

bool runBuild(const ProjectInfo& project, const BuildOptions& opts) {
  std::string kxc = findKxc();
  std::string cmd = kxc + " build";

  if (opts.shared) cmd += " --shared";
  if (opts.library) cmd += " --library";

  if (!opts.targetTriple.empty()) {
    cmd += " --target " + opts.targetTriple;
  }

  cmd += " " + project.root.string();

  if (!opts.output.empty()) {
    cmd += " " + opts.output;
  }

  if (opts.verbose) {
    std::cerr << "kubex: " << cmd << "\n";
  }

  int rc = std::system(cmd.c_str());
  return rc == 0;
}

}  // namespace kubex
