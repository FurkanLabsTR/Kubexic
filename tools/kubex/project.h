#pragma once

#include "kxconf.h"

#include <filesystem>
#include <string>
#include <vector>

namespace kubex {

struct ProjectInfo {
  std::filesystem::path root;
  KxConf conf;
  std::string name;
  std::string version;

  bool ok() const { return conf.ok() && !name.empty(); }
};

ProjectInfo findProject(const std::filesystem::path& startDir = std::filesystem::current_path());

std::vector<std::filesystem::path> collectKxFiles(const std::filesystem::path& dir);

std::vector<std::filesystem::path> collectSourceFiles(const std::filesystem::path& projectRoot);

}  // namespace kubex
