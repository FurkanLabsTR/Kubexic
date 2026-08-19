#pragma once

#include <string>

namespace kubex {

struct AuthInfo {
  std::string token;
  std::string username;
};

// Get the path to ~/.kubex/auth.json
std::string authFilePath();

// Save token and username to ~/.kubex/auth.json
bool saveAuthToken(const std::string& token, const std::string& username);

// Load token from ~/.kubex/auth.json
AuthInfo loadAuthToken();

// Clear saved token (logout)
bool clearAuthToken();

// Check if user is logged in
bool isLoggedIn();

}  // namespace kubex
