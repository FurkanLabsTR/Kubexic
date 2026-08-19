#pragma once

#include "project.h"

#include <string>
#include <vector>

namespace kubex {

struct BuildOptions {
  std::string targetTriple;
  bool debug = false;
  bool shared = false;
  bool library = false;
  bool verbose = false;
  std::string output;
  std::vector<std::string> extraLinkDirs;
  std::vector<std::string> extraLibs;
};

std::string findKxc();
bool runBuild(const ProjectInfo& project, const BuildOptions& opts);

}  // namespace kubex
