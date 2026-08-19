#pragma once

#include <cstdint>
#include <string>

namespace kubex {

struct SemVer {
  int major = 0;
  int minor = 0;
  int patch = 0;

  bool operator==(const SemVer& o) const {
    return major == o.major && minor == o.minor && patch == o.patch;
  }
  bool operator!=(const SemVer& o) const { return !(*this == o); }
  bool operator<(const SemVer& o) const {
    if (major != o.major) return major < o.major;
    if (minor != o.minor) return minor < o.minor;
    return patch < o.patch;
  }
  bool operator>(const SemVer& o) const { return o < *this; }
  bool operator<=(const SemVer& o) const { return !(o < *this); }
  bool operator>=(const SemVer& o) const { return !(*this < o); }

  std::string str() const;
};

SemVer parseSemVer(const std::string& s);

enum class VersionReqKind {
  Exact,
  Caret,   // ^1.2.3
  Tilde,   // ~1.2.3
  Gte,     // >=1.2.3
  Star,    // *
};

struct VersionReq {
  VersionReqKind kind = VersionReqKind::Exact;
  SemVer version;
};

VersionReq parseVersionReq(const std::string& s);
bool matchesVersionReq(const SemVer& ver, const VersionReq& req);

}  // namespace kubex
