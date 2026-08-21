#include "audit.h"
#include "lockfile.h"

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <sstream>

namespace kubex {

bool hasOsvScanner() {
  int rc = std::system("which osv-scanner > /dev/null 2>&1");
  return rc == 0;
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
    return json.substr(pos, end - pos);
  }
  size_t end = pos;
  while (end < json.size() && json[end] != ',' && json[end] != '}' && json[end] != '\n') end++;
  return json.substr(pos, end - pos);
}

AuditResult runAudit(const std::string& projectRoot) {
  AuditResult result;
  result.success = false;

  if (!hasOsvScanner()) {
    result.errorMessage = "osv-scanner not found. Install it from https://github.com/google/osv-scanner";
    return result;
  }

  // Run osv-scanner on the project
  std::string lockPath = lockFilePath(projectRoot);
  std::string cmd;
  if (std::filesystem::exists(lockPath)) {
    cmd = "osv-scanner --lockfile='" + lockPath + "' --format json 2>/dev/null";
  } else {
    cmd = "osv-scanner --directory='" + projectRoot + "' --format json 2>/dev/null";
  }

  std::string tmpFile = "/tmp/kubex_audit_result";
  std::system((cmd + " > " + tmpFile + " 2>&1").c_str());

  std::ifstream in(tmpFile);
  std::ostringstream ss;
  ss << in.rdbuf();
  std::string output = ss.str();
  std::remove(tmpFile.c_str());

  if (output.empty()) {
    // No vulnerabilities found
    result.success = true;
    return result;
  }

  // Parse osv-scanner JSON output (simplified)
  // Format: {"results": [{"packages": [{"package": {"name": "...", "version": "..."}, "vulnerabilities": [...]}]}]}
  size_t vulnPos = 0;
  while (true) {
    size_t idStart = output.find("\"id\":", vulnPos);
    if (idStart == std::string::npos) break;

    Vulnerability vuln;
    vuln.id = extractJsonString(output.substr(idStart), "id");

    // Try to find severity
    size_t sevStart = output.find("\"severity\":", idStart);
    if (sevStart != std::string::npos && sevStart < idStart + 500) {
      vuln.severity = extractJsonString(output.substr(sevStart), "severity");
    }

    // Try to find summary
    size_t sumStart = output.find("\"summary\":", idStart);
    if (sumStart != std::string::npos && sumStart < idStart + 500) {
      vuln.summary = extractJsonString(output.substr(sumStart), "summary");
    }

    if (!vuln.id.empty()) {
      result.vulnerabilities.push_back(vuln);
    }

    vulnPos = idStart + 10;
  }

  result.success = true;
  return result;
}

}  // namespace kubex
