#pragma once

#include <string>

namespace kubex {

struct KeyPair {
  std::string privateKeyPath;
  std::string publicKey;
};

// Get the path to the keys directory (~/.kubex/keys/)
std::string keysDir();

// Generate an Ed25519 keypair for a package/username
// Saves private key to ~/.kubex/keys/<name>_ed25519
// Returns the public key as hex
std::string generateSigningKey(const std::string& name);

// Load an existing private key from disk
// Returns empty string on failure
std::string loadPrivateKey(const std::string& name);

// Sign data with Ed25519 private key
// Returns signature as hex string
std::string signData(const std::string& privateKeyHex, const std::string& data);

// Verify Ed25519 signature
// Returns true if signature is valid
bool verifySignature(const std::string& publicKeyHex, const std::string& data,
                     const std::string& signatureHex);

// Compute SHA-256 hash of data
std::string sha256Hash(const std::string& data);

// Check if signing key exists for a name
bool hasSigningKey(const std::string& name);

}  // namespace kubex
