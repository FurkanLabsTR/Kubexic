#pragma once

#include "semver.h"

#include <cstdint>
#include <filesystem>
#include <map>
#include <set>
#include <string>
#include <vector>

namespace kubex {

std::filesystem::path cacheDir();
std::filesystem::path cachedPackageDir(const std::string& name, const std::string& version);

bool isCached(const std::string& name, const std::string& version);
bool copyLocalPackageToCache(const std::filesystem::path& sourceDir,
                             const std::string& name, const std::string& version);

struct DepInfo {
  std::string name;
  std::string version;
  std::string versionReq;
  std::filesystem::path cachePath;
  std::map<std::string, std::string> transitiveDeps;
};

// Resolve direct dependencies only (original behavior)
std::vector<DepInfo> resolveDependencies(const std::map<std::string, std::string>& deps);

// Resolve all dependencies recursively (transitive)
// Returns resolved dependencies in topological order
// Detects cycles and version conflicts
std::vector<DepInfo> resolveDependenciesTransitive(
    const std::map<std::string, std::string>& deps,
    std::vector<std::string>& errors);

}  // namespace kubex
