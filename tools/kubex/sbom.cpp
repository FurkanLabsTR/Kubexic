#include "sbom.h"
#include "lockfile.h"

#include <fstream>
#include <sstream>

namespace kubex {

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

Sbom generateSbom(const std::string& projectRoot) {
  Sbom sbom;

  // Read project info from .kxconf
  std::ifstream confIn(projectRoot + "/.kxconf");
  if (confIn) {
    std::string line;
    bool inPackage = false;
    while (std::getline(confIn, line)) {
      size_t start = line.find_first_not_of(" \t");
      if (start == std::string::npos) continue;
      line = line.substr(start);

      if (line == "[package]") { inPackage = true; continue; }
      if (line[0] == '[') { inPackage = false; continue; }

      if (inPackage) {
        size_t eq = line.find('=');
        if (eq != std::string::npos) {
          std::string key = line.substr(0, eq);
          std::string val = line.substr(eq + 1);
          key.erase(key.find_last_not_of(" \t") + 1);
          key.erase(0, key.find_first_not_of(" \t"));
          val.erase(val.find_last_not_of(" \t") + 1);
          val.erase(0, val.find_first_not_of(" \t"));
          if (val.size() >= 2 && val.front() == '"' && val.back() == '"') {
            val = val.substr(1, val.size() - 2);
          }
          if (key == "name") sbom.projectName = val;
          else if (key == "version") sbom.projectVersion = val;
        }
      }
    }
  }

  // Read lock file for dependencies
  std::string lockPath = lockFilePath(projectRoot);
  LockFile lockfile = loadLockFile(lockPath);

  // Add main package entry
  SbomEntry mainEntry;
  mainEntry.name = sbom.projectName;
  mainEntry.version = sbom.projectVersion;
  mainEntry.checksum = "";
  for (const auto& [name, entry] : lockfile.packages) {
    mainEntry.dependencies.push_back(name);
  }
  sbom.packages.push_back(mainEntry);

  // Add dependency entries
  for (const auto& [name, entry] : lockfile.packages) {
    SbomEntry depEntry;
    depEntry.name = entry.name;
    depEntry.version = entry.version;
    depEntry.checksum = entry.checksum;
    depEntry.license = "";
    sbom.packages.push_back(depEntry);
  }

  return sbom;
}

std::string sbomToJson(const Sbom& sbom) {
  std::ostringstream out;
  out << "{\n";
  out << "  \"format\": \"" << sbom.format << "\",\n";
  out << "  \"specVersion\": \"" << sbom.specVersion << "\",\n";
  out << "  \"project\": {\n";
  out << "    \"name\": \"" << jsonEscape(sbom.projectName) << "\",\n";
  out << "    \"version\": \"" << jsonEscape(sbom.projectVersion) << "\"\n";
  out << "  },\n";
  out << "  \"packages\": [\n";

  for (size_t i = 0; i < sbom.packages.size(); i++) {
    const auto& pkg = sbom.packages[i];
    out << "    {\n";
    out << "      \"name\": \"" << jsonEscape(pkg.name) << "\",\n";
    out << "      \"version\": \"" << jsonEscape(pkg.version) << "\",\n";
    if (!pkg.checksum.empty()) {
      out << "      \"checksum\": \"" << jsonEscape(pkg.checksum) << "\",\n";
    }
    if (!pkg.license.empty()) {
      out << "      \"license\": \"" << jsonEscape(pkg.license) << "\",\n";
    }
    if (!pkg.dependencies.empty()) {
      out << "      \"dependencies\": [";
      for (size_t j = 0; j < pkg.dependencies.size(); j++) {
        if (j > 0) out << ", ";
        out << "\"" << jsonEscape(pkg.dependencies[j]) << "\"";
      }
      out << "]\n";
    } else {
      out << "      \"dependencies\": []\n";
    }
    out << "    }";
    if (i < sbom.packages.size() - 1) out << ",";
    out << "\n";
  }

  out << "  ]\n";
  out << "}\n";
  return out.str();
}

bool saveSbom(const std::string& path, const Sbom& sbom) {
  std::ofstream out(path, std::ios::trunc);
  if (!out) return false;
  out << sbomToJson(sbom);
  return out.good();
}

}  // namespace kubex
