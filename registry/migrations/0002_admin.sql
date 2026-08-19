-- Admin system migration

-- Add is_admin column to users
ALTER TABLE users ADD COLUMN is_admin INTEGER NOT NULL DEFAULT 0;

-- Add status column to packages (active, archived, suspended)
ALTER TABLE packages ADD COLUMN status TEXT NOT NULL DEFAULT 'active';

-- Add moderation notes
ALTER TABLE packages ADD COLUMN admin_notes TEXT NOT NULL DEFAULT '';

-- Create audit log for admin actions
CREATE TABLE admin_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    admin_id INTEGER NOT NULL,
    action TEXT NOT NULL,
    target_type TEXT NOT NULL,
    target_id TEXT NOT NULL,
    details TEXT NOT NULL DEFAULT '',
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (admin_id) REFERENCES users(id)
);
CREATE INDEX idx_admin_log_admin ON admin_log(admin_id);
CREATE INDEX idx_admin_log_target ON admin_log(target_type, target_id);
