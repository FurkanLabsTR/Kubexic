#pragma once

#include <map>
#include <string>
#include <vector>

namespace kubex {

struct LockEntry {
  std::string name;
  std::string version;
  std::string checksum;
  std::string signature;
  std::string publicKey;
  std::string resolvedFrom;
  std::map<std::string, std::string> deps;
};

struct LockFile {
  int version = 1;
  std::map<std::string, LockEntry> packages;
};

// Load lock file from path
LockFile loadLockFile(const std::string& path);

// Save lock file to path
bool saveLockFile(const std::string& path, const LockFile& lockfile);

// Generate lock file path from project root
std::string lockFilePath(const std::string& projectRoot);

// Verify a lock file entry matches expected checksum
bool verifyLockEntry(const LockEntry& entry, const std::string& actualChecksum);

}  // namespace kubex
