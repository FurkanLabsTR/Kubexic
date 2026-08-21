#include "deps.h"

#include <algorithm>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <sstream>

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

// Parse dependencies from a cached package's .kxconf file
static std::map<std::string, std::string> parsePackageDeps(const std::string& pkgDir) {
  std::map<std::string, std::string> deps;
  std::ifstream in(pkgDir + "/.kxconf");
  if (!in) return deps;

  std::string line;
  bool inDeps = false;
  while (std::getline(in, line)) {
    // Trim whitespace
    size_t start = line.find_first_not_of(" \t");
    if (start == std::string::npos) continue;
    line = line.substr(start);

    // Skip comments
    if (line.substr(0, 2) == "//") continue;

    if (line == "[dependencies]") {
      inDeps = true;
      continue;
    }
    if (line[0] == '[') {
      inDeps = false;
      continue;
    }

    if (inDeps) {
      size_t eq = line.find('=');
      if (eq != std::string::npos) {
        std::string name = line.substr(0, eq);
        std::string version = line.substr(eq + 1);
        // Trim
        name.erase(name.find_last_not_of(" \t") + 1);
        name.erase(0, name.find_first_not_of(" \t"));
        version.erase(version.find_last_not_of(" \t") + 1);
        version.erase(0, version.find_first_not_of(" \t"));
        // Remove quotes
        if (version.size() >= 2 && version.front() == '"' && version.back() == '"') {
          version = version.substr(1, version.size() - 2);
        }
        if (!name.empty() && !version.empty()) {
          deps[name] = version;
        }
      }
    }
  }
  return deps;
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

// Recursive resolver with cycle detection
struct ResolverContext {
  std::map<std::string, DepInfo> resolved;  // name -> resolved info
  std::set<std::string> visiting;           // currently being resolved (cycle detection)
  std::set<std::string> resolved_names;     // already resolved
  std::vector<std::string>& errors;
};

static void resolveTransitive(ResolverContext& ctx, const std::string& name,
                               const std::string& versionReq) {
  if (ctx.resolved_names.count(name)) return;

  if (ctx.visiting.count(name)) {
    ctx.errors.push_back("circular dependency detected: " + name);
    return;
  }

  ctx.visiting.insert(name);

  auto req = parseVersionReq(versionReq);
  if (!isCached(name, req.version.str())) {
    ctx.errors.push_back("dependency not cached: " + name + "@" + versionReq +
                         " (run 'kubex install " + name + "' first)");
    ctx.visiting.erase(name);
    return;
  }

  DepInfo info;
  info.name = name;
  info.version = req.version.str();
  info.versionReq = versionReq;
  info.cachePath = cachedPackageDir(name, info.version);

  // Parse transitive dependencies
  std::string pkgDir = info.cachePath.string();
  info.transitiveDeps = parsePackageDeps(pkgDir);

  // Recursively resolve transitive deps
  for (const auto& [depName, depVersion] : info.transitiveDeps) {
    resolveTransitive(ctx, depName, depVersion);
    if (!ctx.errors.empty()) return;
  }

  ctx.resolved[name] = info;
  ctx.resolved_names.insert(name);
  ctx.visiting.erase(name);
}

std::vector<DepInfo> resolveDependenciesTransitive(
    const std::map<std::string, std::string>& deps,
    std::vector<std::string>& errors) {
  ResolverContext ctx{ {}, {}, {}, errors };

  for (const auto& [name, versionReq] : deps) {
    resolveTransitive(ctx, name, versionReq);
    if (!errors.empty()) return {};
  }

  // Convert to vector in topological order
  std::vector<DepInfo> result;
  for (const auto& [name, info] : ctx.resolved) {
    result.push_back(info);
  }

  return result;
}

}  // namespace kubex
