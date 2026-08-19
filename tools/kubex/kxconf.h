#pragma once

#include <map>
#include <string>
#include <variant>
#include <vector>

namespace kubex {

struct KxError {
  std::string file;
  int line;
  std::string message;
};

using KxValue = std::variant<std::string, int64_t, bool, std::vector<std::string>>;

struct KxConf {
  std::map<std::string, std::map<std::string, KxValue>> sections;
  std::vector<KxError> errors;

  bool ok() const { return errors.empty(); }

  std::string getString(const std::string& section, const std::string& key,
                        const std::string& fallback = "") const;
  int64_t getInt(const std::string& section, const std::string& key,
                 int64_t fallback = 0) const;
  bool getBool(const std::string& section, const std::string& key,
               bool fallback = false) const;
  std::vector<std::string> getList(const std::string& section, const std::string& key) const;

  bool has(const std::string& section, const std::string& key) const;
};

KxConf parseKxConf(const std::string& content, const std::string& filename = "<input>");

}  // namespace kubex
