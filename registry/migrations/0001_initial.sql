-- Kubexic Registry: Initial Schema

CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  password_salt TEXT NOT NULL,
  api_token TEXT UNIQUE,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS packages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  description TEXT NOT NULL DEFAULT '',
  license TEXT NOT NULL DEFAULT '',
  repository TEXT NOT NULL DEFAULT '',
  owner_id INTEGER NOT NULL,
  download_count INTEGER NOT NULL DEFAULT 0,
  latest_version TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (owner_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS versions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  package_id INTEGER NOT NULL,
  version TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  yanked INTEGER NOT NULL DEFAULT 0,
  yanked_reason TEXT NOT NULL DEFAULT '',
  published_at TEXT NOT NULL DEFAULT (datetime('now')),
  publisher_id INTEGER NOT NULL,
  checksum TEXT NOT NULL,
  download_count INTEGER NOT NULL DEFAULT 0,
  signature TEXT NOT NULL DEFAULT '',
  FOREIGN KEY (package_id) REFERENCES packages(id),
  FOREIGN KEY (publisher_id) REFERENCES users(id),
  UNIQUE(package_id, version)
);

CREATE TABLE IF NOT EXISTS version_deps (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  version_id INTEGER NOT NULL,
  dep_name TEXT NOT NULL,
  dep_version_req TEXT NOT NULL,
  FOREIGN KEY (version_id) REFERENCES versions(id)
);

CREATE TABLE IF NOT EXISTS api_tokens (
  token TEXT PRIMARY KEY,
  user_id INTEGER NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  expires_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_packages_name ON packages(name);
CREATE INDEX IF NOT EXISTS idx_packages_owner ON packages(owner_id);
CREATE INDEX IF NOT EXISTS idx_packages_downloads ON packages(download_count DESC);
CREATE INDEX IF NOT EXISTS idx_packages_updated ON packages(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_versions_package ON versions(package_id);
CREATE INDEX IF NOT EXISTS idx_versions_version ON versions(package_id, version);
CREATE INDEX IF NOT EXISTS idx_versions_published ON versions(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_version_deps_version ON version_deps(version_id);
CREATE INDEX IF NOT EXISTS idx_api_tokens_user ON api_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_api_tokens_expires ON api_tokens(expires_at);
