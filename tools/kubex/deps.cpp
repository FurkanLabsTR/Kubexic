#include "deps.h"

#include <algorithm>
#include <cstdlib>
#include <filesystem>

namespace kubex {

std::filesystem::path cacheDir() {
  const char* home = std::getenv("HOME");
  if (!home) home = std::getenv("USERPROFILE");
  if (!home) return ".kubex/cache";
  return std::filesystem::path(home) / ".kubex" / "cache";
}

std::filesystem::path cachedPackageDir(const std::string& name, const std::string& version) {
  return cacheDir() / (name + "-" + version);
}

bool isCached(const std::string& name, const std::string& version) {
  return std::filesystem::exists(cachedPackageDir(name, version));
}

bool copyLocalPackageToCache(const std::filesystem::path& sourceDir,
                             const std::string& name, const std::string& version) {
  namespace fs = std::filesystem;
  fs::path dest = cachedPackageDir(name, version);

  if (fs::exists(dest)) {
    fs::remove_all(dest);
  }

  std::error_code ec;
  fs::copy(sourceDir, dest, fs::copy_options::recursive, ec);
  if (ec) return false;

  return fs::exists(dest / ".kxconf");
}

std::vector<DepInfo> resolveDependencies(const std::map<std::string, std::string>& deps) {
  std::vector<DepInfo> resolved;

  for (const auto& [name, versionReqStr] : deps) {
    DepInfo info;
    info.name = name;
    info.versionReq = versionReqStr;

    auto req = parseVersionReq(versionReqStr);

    if (isCached(name, req.version.str())) {
      info.version = req.version.str();
      info.cachePath = cachedPackageDir(name, info.version);
      resolved.push_back(info);
    } else {
      if (req.kind == VersionReqKind::Exact || req.kind == VersionReqKind::Caret ||
          req.kind == VersionReqKind::Tilde || req.kind == VersionReqKind::Gte) {
        if (isCached(name, req.version.str())) {
          info.version = req.version.str();
          info.cachePath = cachedPackageDir(name, info.version);
          resolved.push_back(info);
          continue;
        }
      }
      info.version = "";
      info.cachePath = "";
      resolved.push_back(info);
    }
  }

  return resolved;
}

}  // namespace kubex
