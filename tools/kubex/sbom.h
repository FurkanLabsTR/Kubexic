#pragma once

#include <map>
#include <string>
#include <vector>

namespace kubex {

struct SbomEntry {
  std::string name;
  std::string version;
  std::string checksum;
  std::string license;
  std::vector<std::string> dependencies;
};

struct Sbom {
  std::string format = "spdx-lite";
  std::string specVersion = "1.0";
  std::string projectName;
  std::string projectVersion;
  std::vector<SbomEntry> packages;
};

// Generate SBOM for a project from its lock file
Sbom generateSbom(const std::string& projectRoot);

// Serialize SBOM to JSON string
std::string sbomToJson(const Sbom& sbom);

// Save SBOM to file
bool saveSbom(const std::string& path, const Sbom& sbom);

}  // namespace kubex
