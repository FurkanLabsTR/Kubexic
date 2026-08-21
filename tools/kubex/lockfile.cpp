#include "lockfile.h"

#include <fstream>
#include <sstream>

namespace kubex {

std::string lockFilePath(const std::string& projectRoot) {
  return projectRoot + "/.kxlock";
}

static std::string jsonEscape(const std::string& s) {
  std::string out;
  for (char c : s) {
    if (c == '"') out += "\\\"";
    else if (c == '\\') out += "\\\\";
    else if (c == '\n') out += "\\n";
    else out += c;
  }
  return out;
}

static std::string jsonUnescape(const std::string& s) {
  std::string out;
  for (size_t i = 0; i < s.size(); i++) {
    if (s[i] == '\\' && i + 1 < s.size()) {
      if (s[i + 1] == '"') { out += '"'; i++; }
      else if (s[i + 1] == '\\') { out += '\\'; i++; }
      else if (s[i + 1] == 'n') { out += '\n'; i++; }
      else out += s[i];
    } else {
      out += s[i];
    }
  }
  return out;
}

static std::string extractJsonString(const std::string& json, const std::string& key) {
  std::string search = "\"" + key + "\"";
  size_t pos = json.find(search);
  if (pos == std::string::npos) return "";
  pos = json.find(':', pos + search.size());
  if (pos == std::string::npos) return "";
  pos++;
  while (pos < json.size() && json[pos] == ' ') pos++;
  if (pos >= json.size()) return "";
  if (json[pos] == '"') {
    pos++;
    size_t end = pos;
    while (end < json.size() && json[end] != '"') {
      if (json[end] == '\\') end++;
      end++;
    }
    return jsonUnescape(json.substr(pos, end - pos));
  }
  size_t end = pos;
  while (end < json.size() && json[end] != ',' && json[end] != '}' && json[end] != '\n') end++;
  return json.substr(pos, end - pos);
}

LockFile loadLockFile(const std::string& path) {
  LockFile lockfile;
  std::ifstream in(path);
  if (!in) return lockfile;

  std::ostringstream ss;
  ss << in.rdbuf();
  std::string json = ss.str();

  lockfile.version = std::stoi(extractJsonString(json, "version") + "1");

  // Parse packages - simplified JSON parsing for lock file format
  size_t pkgStart = json.find("\"packages\"");
  if (pkgStart == std::string::npos) return lockfile;

  size_t objStart = json.find('{', pkgStart);
  if (objStart == std::string::npos) return lockfile;

  // Find each package entry
  size_t pos = objStart + 1;
  while (pos < json.size()) {
    // Find package name
    size_t nameStart = json.find('"', pos);
    if (nameStart == std::string::npos || nameStart >= json.size() - 1) break;
    nameStart++;
    size_t nameEnd = json.find('"', nameStart);
    if (nameEnd == std::string::npos) break;
    std::string pkgName = json.substr(nameStart, nameEnd - nameStart);

    // Find package object
    size_t pkgObjStart = json.find('{', nameEnd);
    if (pkgObjStart == std::string::npos) break;
    size_t pkgObjEnd = json.find('}', pkgObjStart);
    if (pkgObjEnd == std::string::npos) break;

    std::string pkgJson = json.substr(pkgObjStart, pkgObjEnd - pkgObjStart + 1);

    LockEntry entry;
    entry.name = pkgName;
    entry.version = extractJsonString(pkgJson, "version");
    entry.checksum = extractJsonString(pkgJson, "checksum");
    entry.signature = extractJsonString(pkgJson, "signature");
    entry.publicKey = extractJsonString(pkgJson, "public_key");
    entry.resolvedFrom = extractJsonString(pkgJson, "resolved_from");

    lockfile.packages[pkgName] = entry;
    pos = pkgObjEnd + 1;
  }

  return lockfile;
}

bool saveLockFile(const std::string& path, const LockFile& lockfile) {
  std::ofstream out(path, std::ios::trunc);
  if (!out) return false;

  out << "{\n";
  out << "  \"version\": " << lockfile.version << ",\n";
  out << "  \"packages\": {\n";

  bool first = true;
  for (const auto& [name, entry] : lockfile.packages) {
    if (!first) out << ",\n";
    first = false;

    out << "    \"" << jsonEscape(name) << "\": {\n";
    out << "      \"version\": \"" << jsonEscape(entry.version) << "\",\n";
    out << "      \"checksum\": \"" << jsonEscape(entry.checksum) << "\",\n";
    if (!entry.signature.empty()) {
      out << "      \"signature\": \"" << jsonEscape(entry.signature) << "\",\n";
    }
    if (!entry.publicKey.empty()) {
      out << "      \"public_key\": \"" << jsonEscape(entry.publicKey) << "\",\n";
    }
    if (!entry.resolvedFrom.empty()) {
      out << "      \"resolved_from\": \"" << jsonEscape(entry.resolvedFrom) << "\"\n";
    } else {
      out << "      \"resolved_from\": \"\"\n";
    }
    out << "    }";
  }

  out << "\n  }\n";
  out << "}\n";
  return out.good();
}

bool verifyLockEntry(const LockEntry& entry, const std::string& actualChecksum) {
  return entry.checksum == actualChecksum;
}

}  // namespace kubex
