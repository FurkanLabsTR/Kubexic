#include "kxconf.h"

#include <cctype>
#include <charconv>
#include <sstream>

namespace kubex {

static std::string trim(const std::string& s) {
  size_t start = s.find_first_not_of(" \t\r");
  if (start == std::string::npos) return "";
  size_t end = s.find_last_not_of(" \t\r");
  return s.substr(start, end - start + 1);
}

static std::vector<std::string> splitList(const std::string& s) {
  std::vector<std::string> items;
  std::string current;
  bool inQuotes = false;
  for (char c : s) {
    if (c == '"') {
      inQuotes = !inQuotes;
    } else if (c == ',' && !inQuotes) {
      std::string t = trim(current);
      if (!t.empty()) items.push_back(t);
      current.clear();
    } else {
      current += c;
    }
  }
  std::string t = trim(current);
  if (!t.empty()) items.push_back(t);
  return items;
}

KxConf parseKxConf(const std::string& content, const std::string& filename) {
  KxConf conf;
  std::istringstream stream(content);
  std::string line;
  int lineNum = 0;
  std::string currentSection;

  while (std::getline(stream, line)) {
    lineNum++;

    // strip inline comments
    std::string trimmed = trim(line);
    if (trimmed.empty()) continue;

    // full-line comment
    if (trimmed.substr(0, 2) == "//") continue;

    // inline comment: find // not inside quotes
    {
      bool inQuotes = false;
      size_t commentPos = std::string::npos;
      for (size_t i = 0; i < trimmed.size(); i++) {
        if (trimmed[i] == '"') inQuotes = !inQuotes;
        if (!inQuotes && i + 1 < trimmed.size() && trimmed[i] == '/' && trimmed[i + 1] == '/') {
          commentPos = i;
          break;
        }
      }
      if (commentPos != std::string::npos) {
        trimmed = trim(trimmed.substr(0, commentPos));
      }
    }

    if (trimmed.empty()) continue;

    // section header
    if (trimmed.front() == '[') {
      size_t close = trimmed.find(']');
      if (close == std::string::npos) {
        conf.errors.push_back({filename, lineNum, "unclosed section header"});
        continue;
      }
      currentSection = trimmed.substr(1, close - 1);
      continue;
    }

    // key = value
    size_t eq = trimmed.find('=');
    if (eq == std::string::npos) {
      conf.errors.push_back({filename, lineNum, "expected 'key = value', got: " + trimmed});
      continue;
    }

    std::string key = trim(trimmed.substr(0, eq));
    std::string valStr = trim(trimmed.substr(eq + 1));

    if (valStr.empty()) {
      conf.errors.push_back({filename, lineNum, "empty value for key '" + key + "'"});
      continue;
    }

    // parse value
    KxValue value;
    if (valStr.front() == '"') {
      // string
      if (valStr.size() < 2 || valStr.back() != '"') {
        conf.errors.push_back({filename, lineNum, "unterminated string for key '" + key + "'"});
        continue;
      }
      value = valStr.substr(1, valStr.size() - 2);
    } else if (valStr.front() == '[') {
      // list
      if (valStr.back() != ']') {
        conf.errors.push_back({filename, lineNum, "unclosed list for key '" + key + "'"});
        continue;
      }
      std::string inner = valStr.substr(1, valStr.size() - 2);
      auto items = splitList(inner);
      // strip quotes from items
      for (auto& item : items) {
        if (item.size() >= 2 && item.front() == '"' && item.back() == '"') {
          item = item.substr(1, item.size() - 2);
        }
      }
      value = items;
    } else if (valStr == "true") {
      value = true;
    } else if (valStr == "false") {
      value = false;
    } else {
      // try integer
      char* end = nullptr;
      long long n = std::strtoll(valStr.c_str(), &end, 10);
      if (end != valStr.c_str() && *end == '\0') {
        value = static_cast<int64_t>(n);
      } else {
        // treat as bare string
        value = valStr;
      }
    }

    conf.sections[currentSection][key] = value;
  }

  return conf;
}

std::string KxConf::getString(const std::string& section, const std::string& key,
                              const std::string& fallback) const {
  auto s = sections.find(section);
  if (s == sections.end()) return fallback;
  auto v = s->second.find(key);
  if (v == s->second.end()) return fallback;
  if (auto* p = std::get_if<std::string>(&v->second)) return *p;
  return fallback;
}

int64_t KxConf::getInt(const std::string& section, const std::string& key,
                       int64_t fallback) const {
  auto s = sections.find(section);
  if (s == sections.end()) return fallback;
  auto v = s->second.find(key);
  if (v == s->second.end()) return fallback;
  if (auto* p = std::get_if<int64_t>(&v->second)) return *p;
  return fallback;
}

bool KxConf::getBool(const std::string& section, const std::string& key,
                     bool fallback) const {
  auto s = sections.find(section);
  if (s == sections.end()) return fallback;
  auto v = s->second.find(key);
  if (v == s->second.end()) return fallback;
  if (auto* p = std::get_if<bool>(&v->second)) return *p;
  return fallback;
}

std::vector<std::string> KxConf::getList(const std::string& section,
                                         const std::string& key) const {
  auto s = sections.find(section);
  if (s == sections.end()) return {};
  auto v = s->second.find(key);
  if (v == s->second.end()) return {};
  if (auto* p = std::get_if<std::vector<std::string>>(&v->second)) return *p;
  return {};
}

bool KxConf::has(const std::string& section, const std::string& key) const {
  auto s = sections.find(section);
  if (s == sections.end()) return false;
  return s->second.count(key) > 0;
}

}  // namespace kubex
