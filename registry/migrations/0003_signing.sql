-- Migration 0003: Add package signing support

CREATE TABLE IF NOT EXISTS signing_keys (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    public_key TEXT NOT NULL UNIQUE,
    key_type TEXT NOT NULL DEFAULT 'ed25519',
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS idx_signing_keys_user_id ON signing_keys(user_id);
CREATE INDEX IF NOT EXISTS idx_signing_keys_public_key ON signing_keys(public_key);

ALTER TABLE versions ADD COLUMN signature TEXT NOT NULL DEFAULT '';
ALTER TABLE versions ADD COLUMN public_key TEXT NOT NULL DEFAULT '';
