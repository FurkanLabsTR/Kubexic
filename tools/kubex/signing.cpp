#include "signing.h"

#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <vector>

#include <openssl/evp.h>
#include <openssl/pem.h>
#include <openssl/rand.h>
#include <openssl/err.h>

namespace kubex {

static std::string getHomeDir() {
  const char* home = std::getenv("HOME");
  if (!home) home = std::getenv("USERPROFILE");
  return home ? std::string(home) : ".";
}

static std::string getKubexDir() {
  return getHomeDir() + "/.kubex";
}

std::string keysDir() {
  return getKubexDir() + "/keys";
}

static std::string bytesToHex(const unsigned char* data, size_t len) {
  std::string hex;
  hex.reserve(len * 2);
  for (size_t i = 0; i < len; i++) {
    char buf[3];
    snprintf(buf, sizeof(buf), "%02x", data[i]);
    hex += buf;
  }
  return hex;
}

static std::vector<unsigned char> hexToBytes(const std::string& hex) {
  std::vector<unsigned char> bytes;
  bytes.reserve(hex.size() / 2);
  for (size_t i = 0; i + 1 < hex.size(); i += 2) {
    unsigned int byte;
    sscanf(hex.c_str() + i, "%02x", &byte);
    bytes.push_back(static_cast<unsigned char>(byte));
  }
  return bytes;
}

std::string generateSigningKey(const std::string& name) {
  namespace fs = std::filesystem;
  std::string dirStr = keysDir();
  fs::path dir = dirStr;
  if (!fs::exists(dir)) {
    fs::create_directories(dir);
  }

  EVP_PKEY_CTX* ctx = EVP_PKEY_CTX_new_id(EVP_PKEY_ED25519, nullptr);
  if (!ctx) return "";

  if (EVP_PKEY_keygen_init(ctx) <= 0) {
    EVP_PKEY_CTX_free(ctx);
    return "";
  }

  EVP_PKEY* pkey = nullptr;
  if (EVP_PKEY_keygen(ctx, &pkey) <= 0) {
    EVP_PKEY_CTX_free(ctx);
    return "";
  }
  EVP_PKEY_CTX_free(ctx);

  std::string privPath = dirStr + "/" + name + "_ed25519";
  std::string pubPath = dirStr + "/" + name + "_ed25519.pub";

  // Save private key
  BIO* privBio = BIO_new_file(privPath.c_str(), "w");
  if (!privBio) {
    EVP_PKEY_free(pkey);
    return "";
  }
  PEM_write_bio_PrivateKey(privBio, pkey, nullptr, nullptr, 0, nullptr, nullptr);
  BIO_free(privBio);

  // Save public key in PEM format
  BIO* pubBio = BIO_new_file(pubPath.c_str(), "w");
  if (!pubBio) {
    EVP_PKEY_free(pkey);
    return "";
  }
  PEM_write_bio_PUBKEY(pubBio, pkey);
  BIO_free(pubBio);

  // Extract raw public key bytes (32 bytes for Ed25519)
  size_t pubLen = 0;
  if (EVP_PKEY_get_raw_public_key(pkey, nullptr, &pubLen) <= 0) {
    EVP_PKEY_free(pkey);
    return "";
  }
  std::vector<unsigned char> pubRaw(pubLen);
  if (EVP_PKEY_get_raw_public_key(pkey, pubRaw.data(), &pubLen) <= 0) {
    EVP_PKEY_free(pkey);
    return "";
  }

  std::string pubHex = bytesToHex(pubRaw.data(), pubLen);
  EVP_PKEY_free(pkey);
  return pubHex;
}

std::string loadPrivateKey(const std::string& name) {
  std::string privPath = keysDir() + "/" + name + "_ed25519";
  if (!std::filesystem::exists(privPath)) return "";

  BIO* bio = BIO_new_file(privPath.c_str(), "r");
  if (!bio) return "";

  EVP_PKEY* pkey = PEM_read_bio_PrivateKey(bio, nullptr, nullptr, nullptr);
  BIO_free(bio);
  if (!pkey) return "";

  size_t privLen = 0;
  if (EVP_PKEY_get_raw_private_key(pkey, nullptr, &privLen) <= 0) {
    EVP_PKEY_free(pkey);
    return "";
  }
  std::vector<unsigned char> privRaw(privLen);
  if (EVP_PKEY_get_raw_private_key(pkey, privRaw.data(), &privLen) <= 0) {
    EVP_PKEY_free(pkey);
    return "";
  }

  std::string privHex = bytesToHex(privRaw.data(), privLen);
  EVP_PKEY_free(pkey);
  return privHex;
}

std::string signData(const std::string& privateKeyHex, const std::string& data) {
  auto privBytes = hexToBytes(privateKeyHex);
  if (privBytes.size() != 32) return "";

  EVP_PKEY* pkey = EVP_PKEY_new_raw_private_key(EVP_PKEY_ED25519, nullptr,
                                                  privBytes.data(), privBytes.size());
  if (!pkey) return "";

  EVP_MD_CTX* mdctx = EVP_MD_CTX_new();
  if (!mdctx) {
    EVP_PKEY_free(pkey);
    return "";
  }

  if (EVP_DigestSignInit(mdctx, nullptr, nullptr, nullptr, pkey) <= 0) {
    EVP_MD_CTX_free(mdctx);
    EVP_PKEY_free(pkey);
    return "";
  }

  size_t sigLen = 0;
  if (EVP_DigestSign(mdctx, nullptr, &sigLen,
                     reinterpret_cast<const unsigned char*>(data.data()), data.size()) <= 0) {
    EVP_MD_CTX_free(mdctx);
    EVP_PKEY_free(pkey);
    return "";
  }

  std::vector<unsigned char> sig(sigLen);
  if (EVP_DigestSign(mdctx, sig.data(), &sigLen,
                     reinterpret_cast<const unsigned char*>(data.data()), data.size()) <= 0) {
    EVP_MD_CTX_free(mdctx);
    EVP_PKEY_free(pkey);
    return "";
  }

  std::string sigHex = bytesToHex(sig.data(), sigLen);
  EVP_MD_CTX_free(mdctx);
  EVP_PKEY_free(pkey);
  return sigHex;
}

bool verifySignature(const std::string& publicKeyHex, const std::string& data,
                     const std::string& signatureHex) {
  auto pubBytes = hexToBytes(publicKeyHex);
  if (pubBytes.size() != 32) return false;

  EVP_PKEY* pkey = EVP_PKEY_new_raw_public_key(EVP_PKEY_ED25519, nullptr,
                                                 pubBytes.data(), pubBytes.size());
  if (!pkey) return false;

  EVP_MD_CTX* mdctx = EVP_MD_CTX_new();
  if (!mdctx) {
    EVP_PKEY_free(pkey);
    return false;
  }

  if (EVP_DigestVerifyInit(mdctx, nullptr, nullptr, nullptr, pkey) <= 0) {
    EVP_MD_CTX_free(mdctx);
    EVP_PKEY_free(pkey);
    return false;
  }

  auto sigBytes = hexToBytes(signatureHex);
  int result = EVP_DigestVerify(mdctx, sigBytes.data(), sigBytes.size(),
                                reinterpret_cast<const unsigned char*>(data.data()), data.size());

  EVP_MD_CTX_free(mdctx);
  EVP_PKEY_free(pkey);
  return result == 1;
}

std::string sha256Hash(const std::string& data) {
  unsigned char hash[EVP_MAX_MD_SIZE];
  unsigned int hashLen = 0;

  EVP_MD_CTX* ctx = EVP_MD_CTX_new();
  if (!ctx) return "";

  if (EVP_DigestInit_ex(ctx, EVP_sha256(), nullptr) != 1) {
    EVP_MD_CTX_free(ctx);
    return "";
  }

  if (EVP_DigestUpdate(ctx, data.data(), data.size()) != 1) {
    EVP_MD_CTX_free(ctx);
    return "";
  }

  if (EVP_DigestFinal_ex(ctx, hash, &hashLen) != 1) {
    EVP_MD_CTX_free(ctx);
    return "";
  }

  EVP_MD_CTX_free(ctx);
  return bytesToHex(hash, hashLen);
}

bool hasSigningKey(const std::string& name) {
  std::string privPath = keysDir() + "/" + name + "_ed25519";
  return std::filesystem::exists(privPath);
}

}  // namespace kubex
