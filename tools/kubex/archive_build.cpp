#include "archive_build.h"

#include <cstdlib>
#include <fstream>
#include <iostream>
#include <sstream>
#include <vector>

namespace kubex {

std::string computeSha256(const std::filesystem::path& filePath) {
  std::string cmd = "sha256sum '" + filePath.string() + "' 2>/dev/null";
  FILE* pipe = popen(cmd.c_str(), "r");
  if (!pipe) return "";

  char buffer[256];
  std::string output;
  while (fgets(buffer, sizeof(buffer), pipe)) {
    output += buffer;
  }
  pclose(pipe);

  // sha256sum output: "hash  filename"
  size_t space = output.find(' ');
  if (space != std::string::npos) {
    return output.substr(0, space);
  }
  return output;
}

std::string buildPackageArchive(const std::filesystem::path& projectRoot) {
  namespace fs = std::filesystem;

  // Read package name and version from .kxconf
  fs::path kxconfPath = projectRoot / ".kxconf";
  if (!fs::exists(kxconfPath)) {
    std::cerr << "kubex publish: no .kxconf found in " << projectRoot << "\n";
    return "";
  }

  // Parse name and version from .kxconf (simple line-by-line)
  std::string pkgName, pkgVersion;
  {
    std::ifstream in(kxconfPath);
    std::string line;
    while (std::getline(in, line)) {
      // trim
      size_t start = line.find_first_not_of(" \t");
      if (start == std::string::npos) continue;
      line = line.substr(start);

      if (line.find("name = ") == 0) {
        std::string val = line.substr(7);
        if (val.size() >= 2 && val.front() == '"' && val.back() == '"')
          pkgName = val.substr(1, val.size() - 2);
      } else if (line.find("version = ") == 0) {
        std::string val = line.substr(10);
        if (val.size() >= 2 && val.front() == '"' && val.back() == '"')
          pkgVersion = val.substr(1, val.size() - 2);
      }
    }
  }

  if (pkgName.empty() || pkgVersion.empty()) {
    std::cerr << "kubex publish: cannot read package name/version from .kxconf\n";
    return "";
  }

  std::string archiveName = pkgName + "-" + pkgVersion + ".kxpkg";
  fs::path archivePath = fs::temp_directory_path() / archiveName;

  // Create staging directory
  fs::path staging = fs::temp_directory_path() / ("kubex_staging_" + pkgName);
  if (fs::exists(staging)) {
    fs::remove_all(staging);
  }
  fs::create_directories(staging);

  // Copy .kxconf
  fs::copy_file(kxconfPath, staging / ".kxconf");

  // Collect all .kx files (skip build/vendor/.kubex dirs)
  std::vector<fs::path> kxFiles;
  for (const auto& entry : fs::recursive_directory_iterator(projectRoot)) {
    if (!entry.is_regular_file()) continue;
    if (entry.path().extension() != ".kx") continue;

    auto rel = fs::relative(entry.path(), projectRoot);
    std::string relStr = rel.string();
    if (relStr.find(".kubex") != std::string::npos) continue;
    if (relStr.find("build") != std::string::npos) continue;
    if (relStr.find("vendor") != std::string::npos) continue;

    kxFiles.push_back(entry.path());
  }

  // Copy .kx files to staging
  for (const auto& file : kxFiles) {
    auto rel = fs::relative(file, projectRoot);
    fs::path dest = staging / rel;
    fs::create_directories(dest.parent_path());
    fs::copy_file(file, dest);
  }

  // Compute checksums
  std::ofstream checksums(staging / "checksums.txt");
  for (const auto& file : kxFiles) {
    auto rel = fs::relative(file, projectRoot);
    std::string hash = computeSha256(staging / rel);
    checksums << hash << "  " << rel.string() << "\n";
  }
  // Also checksum .kxconf
  {
    std::string hash = computeSha256(staging / ".kxconf");
    checksums << hash << "  .kxconf\n";
  }
  checksums.close();

  // Create tar.gz archive
  std::string tarCmd = "tar -czf '" + archivePath.string() + "' -C '" +
                       staging.string() + "' .";
  int rc = std::system(tarCmd.c_str());

  // Clean up staging
  fs::remove_all(staging);

  if (rc != 0) {
    std::cerr << "kubex publish: failed to create archive\n";
    return "";
  }

  return archivePath.string();
}

}  // namespace kubex
