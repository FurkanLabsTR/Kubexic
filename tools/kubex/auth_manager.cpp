#include "auth_manager.h"

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <sstream>

namespace kubex {

static std::string getHomeDir() {
  const char* home = std::getenv("HOME");
  if (!home) home = std::getenv("USERPROFILE");
  return home ? std::string(home) : ".";
}

static std::string getKubexDir() {
  return getHomeDir() + "/.kubex";
}

std::string authFilePath() {
  return getKubexDir() + "/auth.json";
}

// Minimal JSON helpers (no external dependency)
static std::string jsonEscape(const std::string& s) {
  std::string out;
  for (char c : s) {
    if (c == '"') out += "\\\"";
    else if (c == '\\') out += "\\\\";
    else if (c == '\n') out += "\\n";
    else if (c == '\r') out += "\\r";
    else if (c == '\t') out += "\\t";
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
      else if (s[i + 1] == 'r') { out += '\r'; i++; }
      else if (s[i + 1] == 't') { out += '\t'; i++; }
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

bool saveAuthToken(const std::string& token, const std::string& username) {
  namespace fs = std::filesystem;
  fs::path dir = getKubexDir();
  if (!fs::exists(dir)) {
    fs::create_directories(dir);
  }

  std::ofstream out(authFilePath(), std::ios::trunc);
  if (!out) return false;
  out << "{ \"token\": \"" << jsonEscape(token)
      << "\", \"username\": \"" << jsonEscape(username) << "\" }\n";
  return out.good();
}

AuthInfo loadAuthToken() {
  AuthInfo auth;
  std::ifstream in(authFilePath());
  if (!in) return auth;

  std::ostringstream ss;
  ss << in.rdbuf();
  std::string json = ss.str();

  auth.token = extractJsonString(json, "token");
  auth.username = extractJsonString(json, "username");
  return auth;
}

bool clearAuthToken() {
  namespace fs = std::filesystem;
  std::error_code ec;
  fs::remove(authFilePath(), ec);
  return !ec;
}

bool isLoggedIn() {
  return !loadAuthToken().token.empty();
}

}  // namespace kubex
