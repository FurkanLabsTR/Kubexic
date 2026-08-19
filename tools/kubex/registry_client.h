#pragma once

#include <string>

namespace kubex {

struct RegistryPackage {
  std::string name;
  std::string description;
  std::string latestVersion;
  std::string author;
};

struct RegistryPackageVersion {
  std::string name;
  std::string version;
  std::string description;
  std::string checksum;
  std::string author;
};

// Override the default registry URL (env KUBEX_REGISTRY_URL is also supported)
void setRegistryUrl(const std::string& url);

// Validate package name: alphanumeric, hyphens, underscores, dots
bool isValidPackageName(const std::string& name);

// Validate semver format (e.g. 1.0.0, 0.1.0-beta.1)
bool isValidSemVer(const std::string& version);

// Register a new user
bool registryRegister(const std::string& username, const std::string& email,
                      const std::string& password);

// Login and save token
bool registryLogin(const std::string& username, const std::string& password);

// Search packages
std::string registrySearch(const std::string& query);

// Get package info
std::string registryGetPackage(const std::string& name);

// Get package version info
std::string registryGetPackageVersion(const std::string& name, const std::string& version);

// Publish a package (auth required)
bool registryPublish(const std::string& name, const std::string& version,
                     const std::string& archivePath);

// Download a package
bool registryDownload(const std::string& name, const std::string& version,
                      const std::string& destPath);

// Yank a package version (auth required)
bool registryYank(const std::string& name, const std::string& version);

}  // namespace kubex
