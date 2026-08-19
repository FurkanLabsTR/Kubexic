import { User, jsonResponse } from './auth';

export interface AdminLog {
  id: number;
  admin_id: number;
  admin_username?: string;
  action: string;
  target_type: string;
  target_id: string;
  details: string;
  created_at: string;
}

async function requireAdmin(
  db: D1Database,
  request: Request
): Promise<{ user: User | null; error: Response | null }> {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader) {
    return { user: null, error: jsonResponse(401, { error: 'Authorization header required' }) };
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return { user: null, error: jsonResponse(401, { error: 'Invalid authorization format' }) };
  }

  const token = parts[1];

  const user = await db
    .prepare('SELECT id, username, email, is_admin, created_at FROM users WHERE api_token = ?')
    .bind(token)
    .first<User & { is_admin: number }>();

  if (!user) {
    return { user: null, error: jsonResponse(401, { error: 'Invalid or expired token' }) };
  }

  if (!user.is_admin) {
    return { user: null, error: jsonResponse(403, { error: 'Admin access required' }) };
  }

  return { user, error: null };
}

export async function listUsers(
  db: D1Database,
  page: number,
  perPage: number
): Promise<{ users: Omit<User, 'api_token'>[]; total: number }> {
  const offset = (page - 1) * perPage;

  const countResult = await db.prepare('SELECT COUNT(*) as total FROM users').first<{ total: number }>();
  const total = countResult?.total || 0;

  const users = await db
    .prepare('SELECT id, username, email, is_admin, created_at FROM users ORDER BY created_at DESC LIMIT ? OFFSET ?')
    .bind(perPage, offset)
    .all();

  return { users: users.results as Omit<User, 'api_token'>[], total };
}

export async function getUser(
  db: D1Database,
  userId: number
): Promise<(Omit<User, 'api_token'> & { is_admin: number }) | null> {
  return db
    .prepare('SELECT id, username, email, is_admin, created_at FROM users WHERE id = ?')
    .bind(userId)
    .first();
}

export async function setUserAdmin(
  db: D1Database,
  userId: number,
  isAdmin: boolean
): Promise<void> {
  await db
    .prepare('UPDATE users SET is_admin = ? WHERE id = ?')
    .bind(isAdmin ? 1 : 0, userId)
    .run();
}

export async function deleteUser(
  db: D1Database,
  userId: number
): Promise<void> {
  await db.prepare('DELETE FROM api_tokens WHERE user_id = ?').bind(userId).run();

  const packages = await db
    .prepare('SELECT id FROM packages WHERE owner_id = ?')
    .bind(userId)
    .all<{ id: number }>();

  for (const pkg of packages.results) {
    await db.prepare('DELETE FROM version_deps WHERE version_id IN (SELECT id FROM versions WHERE package_id = ?)').bind(pkg.id).run();
    await db.prepare('DELETE FROM versions WHERE package_id = ?').bind(pkg.id).run();
    await db.prepare('DELETE FROM packages WHERE id = ?').bind(pkg.id).run();
  }

  await db.prepare('DELETE FROM users WHERE id = ?').bind(userId).run();
}

export async function listPackages(
  db: D1Database,
  page: number,
  perPage: number
): Promise<{ packages: Record<string, unknown>[]; total: number }> {
  const offset = (page - 1) * perPage;

  const countResult = await db.prepare('SELECT COUNT(*) as total FROM packages').first<{ total: number }>();
  const total = countResult?.total || 0;

  const packages = await db
    .prepare(
      `SELECT p.id, p.name, p.description, p.status, p.admin_notes, p.download_count, p.latest_version, p.created_at, p.updated_at,
              u.username as owner
       FROM packages p
       JOIN users u ON p.owner_id = u.id
       ORDER BY p.created_at DESC
       LIMIT ? OFFSET ?`
    )
    .bind(perPage, offset)
    .all();

  return { packages: packages.results as Record<string, unknown>[], total };
}

export async function deletePackage(
  db: D1Database,
  packageName: string
): Promise<boolean> {
  const pkg = await db
    .prepare('SELECT id FROM packages WHERE name = ?')
    .bind(packageName)
    .first<{ id: number }>();

  if (!pkg) return false;

  await db.prepare('DELETE FROM version_deps WHERE version_id IN (SELECT id FROM versions WHERE package_id = ?)').bind(pkg.id).run();
  await db.prepare('DELETE FROM versions WHERE package_id = ?').bind(pkg.id).run();
  await db.prepare('DELETE FROM packages WHERE id = ?').bind(pkg.id).run();

  return true;
}

export async function archivePackage(
  db: D1Database,
  packageName: string
): Promise<boolean> {
  const result = await db
    .prepare("UPDATE packages SET status = 'archived' WHERE name = ?")
    .bind(packageName)
    .run();

  return result.meta?.changes > 0;
}

export async function suspendPackage(
  db: D1Database,
  packageName: string,
  reason: string
): Promise<boolean> {
  const result = await db
    .prepare("UPDATE packages SET status = 'suspended', admin_notes = ? WHERE name = ?")
    .bind(reason, packageName)
    .run();

  return result.meta?.changes > 0;
}

export async function setPackageNotes(
  db: D1Database,
  packageName: string,
  notes: string
): Promise<boolean> {
  const result = await db
    .prepare('UPDATE packages SET admin_notes = ? WHERE name = ?')
    .bind(notes, packageName)
    .run();

  return result.meta?.changes > 0;
}

export async function unyankVersion(
  db: D1Database,
  packageName: string,
  version: string
): Promise<boolean> {
  const pkg = await db
    .prepare('SELECT id FROM packages WHERE name = ?')
    .bind(packageName)
    .first<{ id: number }>();

  if (!pkg) return false;

  const result = await db
    .prepare("UPDATE versions SET yanked = 0, yanked_reason = '' WHERE package_id = ? AND version = ?")
    .bind(pkg.id, version)
    .run();

  return result.meta?.changes > 0;
}

export async function deleteVersion(
  db: D1Database,
  packageName: string,
  version: string
): Promise<boolean> {
  const pkg = await db
    .prepare('SELECT id FROM packages WHERE name = ?')
    .bind(packageName)
    .first<{ id: number }>();

  if (!pkg) return false;

  const ver = await db
    .prepare('SELECT id FROM versions WHERE package_id = ? AND version = ?')
    .bind(pkg.id, version)
    .first<{ id: number }>();

  if (!ver) return false;

  await db.prepare('DELETE FROM version_deps WHERE version_id = ?').bind(ver.id).run();
  await db.prepare('DELETE FROM versions WHERE id = ?').bind(ver.id).run();

  return true;
}

export async function logAdminAction(
  db: D1Database,
  adminId: number,
  action: string,
  targetType: string,
  targetId: string,
  details: string
): Promise<void> {
  await db
    .prepare(
      'INSERT INTO admin_log (admin_id, action, target_type, target_id, details) VALUES (?, ?, ?, ?, ?)'
    )
    .bind(adminId, action, targetType, targetId, details)
    .run();
}

export async function getAdminLog(
  db: D1Database,
  page: number,
  perPage: number
): Promise<{ logs: AdminLog[]; total: number }> {
  const offset = (page - 1) * perPage;

  const countResult = await db.prepare('SELECT COUNT(*) as total FROM admin_log').first<{ total: number }>();
  const total = countResult?.total || 0;

  const logs = await db
    .prepare(
      `SELECT al.*, u.username as admin_username
       FROM admin_log al
       JOIN users u ON al.admin_id = u.id
       ORDER BY al.created_at DESC
       LIMIT ? OFFSET ?`
    )
    .bind(perPage, offset)
    .all();

  return { logs: logs.results as AdminLog[], total };
}

export { requireAdmin };
