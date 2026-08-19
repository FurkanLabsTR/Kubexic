#include "registry_client.h"
#include "auth_manager.h"

#include <atomic>
#include <chrono>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <regex>
#include <sstream>
#include <thread>

namespace kubex {

static std::string s_customRegistryUrl;

void setRegistryUrl(const std::string& url) {
  s_customRegistryUrl = url;
}

static std::string getRegistryUrl() {
  if (!s_customRegistryUrl.empty()) return s_customRegistryUrl;
  const char* env = std::getenv("KUBEX_REGISTRY_URL");
  return env ? std::string(env) : "https://registry.kubex.dev/v1";
}

static const int MAX_RETRIES = 3;
static const int TIMEOUT_SECONDS = 30;

bool isValidPackageName(const std::string& name) {
  if (name.empty() || name.size() > 128) return false;
  for (char c : name) {
    if (!std::isalnum(c) && c != '-' && c != '_' && c != '.') return false;
  }
  if (name.front() == '-' || name.front() == '_' || name.front() == '.') return false;
  if (name.back() == '-' || name.back() == '_' || name.back() == '.') return false;
  return true;
}

bool isValidSemVer(const std::string& version) {
  static const std::regex re(
      R"(^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$)");
  return std::regex_match(version, re);
}

// Sleep for milliseconds (no-op on error)
static void backoffSleep(int attempt) {
  int ms = 500 * (1 << attempt);  // 500, 1000, 2000
  std::this_thread::sleep_for(std::chrono::milliseconds(ms));
}

// Run curl and return {exitCode, stdout}. Returns -1 exit code on system failure.
struct CurlResult {
  int exitCode;
  std::string stdout;
};

static CurlResult execCurlRaw(const std::string& cmd) {
  std::string tmpFile = "/tmp/kubex_curl_" + std::to_string(reinterpret_cast<long>(
      reinterpret_cast<void*>(&execCurlRaw)));
  std::string fullCmd = cmd + " -o " + tmpFile + " -s -w '%{http_code}' 2>/dev/null";
  int rc = std::system(fullCmd.c_str());
  if (rc == -1) {
    return {-1, ""};
  }
  std::ifstream in(tmpFile);
  std::ostringstream ss;
  ss << in.rdbuf();
  std::string output = ss.str();
  std::remove(tmpFile.c_str());
  return {rc, output};
}

// Execute curl with retry logic, timeout, and return {body, httpStatus}
struct CurlResponse {
  std::string body;
  int status;
  bool networkError;
};

static CurlResponse curlRequestWithRetry(const std::string& method, const std::string& url,
                                          const std::string& jsonData = "",
                                          const std::string& token = "",
                                          bool showProgress = false) {
  CurlResponse resp = {"", 0, true};

  for (int attempt = 0; attempt <= MAX_RETRIES; attempt++) {
    if (attempt > 0) {
      if (showProgress) {
        std::cerr << "  retrying (" << attempt << "/" << MAX_RETRIES << ")...\n";
      }
      backoffSleep(attempt - 1);
    }

    std::string tmpFile = "/tmp/kubex_curl_resp";
    std::string cmd = "curl --connect-timeout " + std::to_string(TIMEOUT_SECONDS) +
                      " --max-time " + std::to_string(TIMEOUT_SECONDS * 3) +
                      " -X " + method + " -s -w '\\n%{http_code}'";
    if (!jsonData.empty()) {
      cmd += " -H 'Content-Type: application/json' -d '" + jsonData + "'";
    }
    if (!token.empty()) {
      cmd += " -H 'Authorization: Bearer " + token + "'";
    }
    cmd += " '" + url + "'";
    cmd += " -o " + tmpFile + " 2>/dev/null";

    std::string fullCmd = cmd;
    int rc = std::system(fullCmd.c_str());

    if (rc == -1) {
      // system() failed entirely (fork/exec problem)
      resp.networkError = true;
      continue;
    }

    // Check for curl-specific errors (exit code != 0 often means network issue)
    // curl exit codes: 6 = couldn't resolve host, 7 = connection refused,
    // 28 = timeout, 35 = SSL error, 56 = recv failure
    if (rc != 0) {
      resp.networkError = true;
      if (rc == 28) {
        std::cerr << "  timeout connecting to registry\n";
      } else if (rc == 7) {
        std::cerr << "  connection refused\n";
      } else if (rc == 6) {
        std::cerr << "  could not resolve host\n";
      }
      std::remove(tmpFile.c_str());
      continue;
    }

    std::ifstream in(tmpFile);
    std::ostringstream ss;
    ss << in.rdbuf();
    std::string body = ss.str();
    std::remove(tmpFile.c_str());

    // Get status code separately
    std::string statusCmd = "curl --connect-timeout " + std::to_string(TIMEOUT_SECONDS) +
                            " --max-time " + std::to_string(TIMEOUT_SECONDS * 3) +
                            " -X " + method + " -s -o /dev/null -w '%{http_code}'";
    if (!jsonData.empty()) {
      statusCmd += " -H 'Content-Type: application/json' -d '" + jsonData + "'";
    }
    if (!token.empty()) {
      statusCmd += " -H 'Authorization: Bearer " + token + "'";
    }
    statusCmd += " '" + url + "'";

    std::string statusFile = "/tmp/kubex_curl_status";
    std::system((statusCmd + " > " + statusFile + " 2>/dev/null").c_str());

    std::ifstream sin(statusFile);
    std::ostringstream sss;
    sss << sin.rdbuf();
    std::string statusStr = sss.str();
    std::remove(statusFile.c_str());

    int status = 0;
    for (char c : statusStr) {
      if (c >= '0' && c <= '9') status = status * 10 + (c - '0');
    }

    resp.body = body;
    resp.status = status;
    resp.networkError = false;

    // Don't retry on successful or client errors (4xx) — only retry on server errors (5xx)
    if (status >= 200 && status < 500) {
      return resp;
    }
  }

  return resp;
}

// Download with progress indicator
static bool curlDownloadWithProgress(const std::string& url, const std::string& destPath,
                                      int* statusOut) {
  for (int attempt = 0; attempt <= MAX_RETRIES; attempt++) {
    if (attempt > 0) {
      std::cerr << "  retrying download (" << attempt << "/" << MAX_RETRIES << ")...\n";
      backoffSleep(attempt - 1);
    }

    std::string cmd = "curl --connect-timeout " + std::to_string(TIMEOUT_SECONDS) +
                      " --max-time " + std::to_string(TIMEOUT_SECONDS * 6) +
                      " -s -# -o '" + destPath + "' -w '%{http_code}' '" + url + "'";

    std::string statusFile = "/tmp/kubex_curl_status";
    std::system((cmd + " > " + statusFile + " 2>/dev/null").c_str());

    std::ifstream sin(statusFile);
    std::ostringstream sss;
    sss << sin.rdbuf();
    int status = 0;
    for (char c : sss.str()) {
      if (c >= '0' && c <= '9') status = status * 10 + (c - '0');
    }
    std::remove(statusFile.c_str());

    if (statusOut) *statusOut = status;

    if (status == 200) return true;

    // Don't retry client errors
    if (status >= 400 && status < 500) {
      std::remove(destPath.c_str());
      return false;
    }
  }
  return false;
}

// Upload with progress indicator
static bool curlUploadWithProgress(const std::string& url, const std::string& token,
                                    const std::string& archivePath, int* statusOut) {
  for (int attempt = 0; attempt <= MAX_RETRIES; attempt++) {
    if (attempt > 0) {
      std::cerr << "  retrying upload (" << attempt << "/" << MAX_RETRIES << ")...\n";
      backoffSleep(attempt - 1);
    }

    std::string cmd = "curl --connect-timeout " + std::to_string(TIMEOUT_SECONDS) +
                      " --max-time " + std::to_string(TIMEOUT_SECONDS * 6) +
                      " -X PUT -s -#"
                      " -H 'Authorization: Bearer " + token + "'"
                      " -F 'archive=@" + archivePath + "'"
                      " -o /dev/null"
                      " -w '%{http_code}'"
                      " '" + url + "'";

    std::string statusFile = "/tmp/kubex_curl_status";
    std::system((cmd + " > " + statusFile + " 2>/dev/null").c_str());

    std::ifstream sin(statusFile);
    std::ostringstream sss;
    sss << sin.rdbuf();
    int status = 0;
    for (char c : sss.str()) {
      if (c >= '0' && c <= '9') status = status * 10 + (c - '0');
    }
    std::remove(statusFile.c_str());

    if (statusOut) *statusOut = status;

    if (status == 200 || status == 201) return true;
    if (status >= 400 && status < 500) return false;
  }
  return false;
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

bool registryRegister(const std::string& username, const std::string& email,
                      const std::string& password) {
  std::string url = getRegistryUrl() + "/auth/register";
  std::string json = "{\"username\":\"" + username + "\",\"email\":\"" + email +
                     "\",\"password\":\"" + password + "\"}";
  CurlResponse resp = curlRequestWithRetry("POST", url, json);
  if (resp.networkError) {
    std::cerr << "kubex: could not connect to registry at " << getRegistryUrl() << "\n";
    return false;
  }
  return resp.status == 200 || resp.status == 201;
}

bool registryLogin(const std::string& username, const std::string& password) {
  std::string url = getRegistryUrl() + "/auth/login";
  std::string json = "{\"username\":\"" + username + "\",\"password\":\"" + password + "\"}";
  CurlResponse resp = curlRequestWithRetry("POST", url, json);
  if (resp.networkError) {
    std::cerr << "kubex: could not connect to registry at " << getRegistryUrl() << "\n";
    return false;
  }
  if (resp.status != 200) return false;

  std::string token = extractJsonString(resp.body, "token");
  if (token.empty()) return false;

  return saveAuthToken(token, username);
}

std::string registrySearch(const std::string& query) {
  std::string url = getRegistryUrl() + "/packages?q=" + query;
  CurlResponse resp = curlRequestWithRetry("GET", url);
  if (resp.networkError) {
    std::cerr << "kubex: could not connect to registry at " << getRegistryUrl() << "\n";
    return "";
  }
  return resp.body;
}

std::string registryGetPackage(const std::string& name) {
  std::string url = getRegistryUrl() + "/packages/" + name;
  CurlResponse resp = curlRequestWithRetry("GET", url);
  if (resp.networkError) {
    std::cerr << "kubex: could not connect to registry at " << getRegistryUrl() << "\n";
    return "";
  }
  return resp.body;
}

std::string registryGetPackageVersion(const std::string& name, const std::string& version) {
  std::string url = getRegistryUrl() + "/packages/" + name + "/" + version;
  CurlResponse resp = curlRequestWithRetry("GET", url);
  if (resp.networkError) {
    std::cerr << "kubex: could not connect to registry at " << getRegistryUrl() << "\n";
    return "";
  }
  return resp.body;
}

bool registryPublish(const std::string& name, const std::string& version,
                     const std::string& archivePath) {
  AuthInfo auth = loadAuthToken();
  if (auth.token.empty()) return false;

  std::string url = getRegistryUrl() + "/packages/" + name + "/" + version;
  int status = 0;
  bool ok = curlUploadWithProgress(url, auth.token, archivePath, &status);
  if (!ok && status == 0) {
    std::cerr << "kubex: could not connect to registry at " << getRegistryUrl() << "\n";
    return false;
  }
  return ok;
}

bool registryDownload(const std::string& name, const std::string& version,
                      const std::string& destPath) {
  std::string url = getRegistryUrl() + "/packages/" + name + "/" + version + "/download";
  int status = 0;
  bool ok = curlDownloadWithProgress(url, destPath, &status);
  if (!ok && status == 0) {
    std::cerr << "kubex: could not connect to registry at " << getRegistryUrl() << "\n";
    return false;
  }
  return ok;
}

bool registryYank(const std::string& name, const std::string& version) {
  AuthInfo auth = loadAuthToken();
  if (auth.token.empty()) return false;

  std::string url = getRegistryUrl() + "/packages/" + name + "/" + version;
  CurlResponse resp = curlRequestWithRetry("DELETE", url, "", auth.token);
  if (resp.networkError) {
    std::cerr << "kubex: could not connect to registry at " << getRegistryUrl() << "\n";
    return false;
  }
  return resp.status == 200;
}

}  // namespace kubex
