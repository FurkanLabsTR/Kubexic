#pragma once

#include <string>
#include <vector>

namespace kubex {

struct Vulnerability {
  std::string id;
  std::string package;
  std::string version;
  std::string severity;
  std::string summary;
  std::string fixedVersion;
};

struct AuditResult {
  bool success;
  std::vector<Vulnerability> vulnerabilities;
  std::string errorMessage;
};

// Run vulnerability scan on project dependencies
// Uses osv-scanner if available, otherwise falls back to basic check
AuditResult runAudit(const std::string& projectRoot);

// Check if osv-scanner is installed
bool hasOsvScanner();

}  // namespace kubex
