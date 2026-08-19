#include "semver.h"

#include <cstdlib>

namespace kubex {

std::string SemVer::str() const {
  return std::to_string(major) + "." + std::to_string(minor) + "." + std::to_string(patch);
}

SemVer parseSemVer(const std::string& s) {
  SemVer v;
  size_t pos = 0;

  auto next = [&](int& dest) {
    size_t end = s.find('.', pos);
    if (end == std::string::npos) end = s.size();
    std::string num = s.substr(pos, end - pos);
    char* e = nullptr;
    dest = static_cast<int>(std::strtol(num.c_str(), &e, 10));
    pos = end + 1;
  };

  next(v.major);
  if (pos <= s.size()) next(v.minor);
  if (pos <= s.size()) next(v.patch);
  return v;
}

VersionReq parseVersionReq(const std::string& s) {
  VersionReq req;
  std::string v = s;

  if (!v.empty() && v[0] == '^') {
    req.kind = VersionReqKind::Caret;
    v = v.substr(1);
  } else if (!v.empty() && v[0] == '~') {
    req.kind = VersionReqKind::Tilde;
    v = v.substr(1);
  } else if (v.size() >= 2 && v[0] == '>' && v[1] == '=') {
    req.kind = VersionReqKind::Gte;
    v = v.substr(2);
  } else if (v == "*") {
    req.kind = VersionReqKind::Star;
    return req;
  }

  req.version = parseSemVer(v);
  return req;
}

bool matchesVersionReq(const SemVer& ver, const VersionReq& req) {
  switch (req.kind) {
    case VersionReqKind::Exact:
      return ver == req.version;
    case VersionReqKind::Caret:
      if (ver < req.version) return false;
      if (req.version.major == 0) {
        return ver.major == 0 && ver.minor == req.version.minor;
      }
      return ver.major == req.version.major;
    case VersionReqKind::Tilde:
      if (ver < req.version) return false;
      return ver.major == req.version.major && ver.minor == req.version.minor;
    case VersionReqKind::Gte:
      return ver >= req.version;
    case VersionReqKind::Star:
      return true;
  }
  return false;
}

}  // namespace kubex
