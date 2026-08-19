#pragma once

#include <filesystem>
#include <string>

namespace kubex {

// Build a .kxpkg archive from a project directory.
// Collects .kx files + .kxconf, computes SHA-256 checksums, creates tar.gz.
// Returns the path to the created archive, or empty string on failure.
std::string buildPackageArchive(const std::filesystem::path& projectRoot);

// Compute SHA-256 hash of a file using the system sha256sum command.
std::string computeSha256(const std::filesystem::path& filePath);

}  // namespace kubex
