import { sha256, generateSalt, hashPassword, verifyPassword, generateApiToken } from './crypto';

export interface User {
  id: number;
  username: string;
  email: string;
  api_token: string | null;
  is_admin: number;
  created_at: string;
}

export interface AuthResult {
  user: User | null;
  error: string | null;
}

export async function register(
  db: D1Database,
  username: string,
  email: string,
  password: string
): Promise<{ data?: { token: string; user: Omit<User, 'api_token'> }; error?: string }> {
  if (!username || username.length < 3 || username.length > 32) {
    return { error: 'Username must be 3-32 characters' };
  }
  if (!email || !email.includes('@')) {
    return { error: 'Invalid email address' };
  }
  if (!password || password.length < 8) {
    return { error: 'Password must be at least 8 characters' };
  }

  const existing = await db
    .prepare('SELECT id FROM users WHERE username = ? OR email = ?')
    .bind(username, email)
    .first<{ id: number }>();

  if (existing) {
    return { error: 'Username or email already taken' };
  }

  const salt = generateSalt();
  const passwordHash = await hashPassword(password, salt);
  const apiToken = generateApiToken();
  const expiresAt = new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString();

  const result = await db
    .prepare(
      'INSERT INTO users (username, email, password_hash, password_salt, api_token) VALUES (?, ?, ?, ?, ?)'
    )
    .bind(username, email, passwordHash, salt, apiToken)
    .run();

  if (!result.success) {
    return { error: 'Failed to create user' };
  }

  const user = await db
    .prepare('SELECT id, username, email, created_at FROM users WHERE username = ?')
    .bind(username)
    .first<Omit<User, 'api_token'>>();

  return { data: { token: apiToken, user: user! } };
}

export async function login(
  db: D1Database,
  username: string,
  password: string
): Promise<{ data?: { token: string }; error?: string }> {
  if (!username || !password) {
    return { error: 'Username and password required' };
  }

  const user = await db
    .prepare('SELECT id, password_hash, password_salt, api_token FROM users WHERE username = ?')
    .bind(username)
    .first<{ id: number; password_hash: string; password_salt: string; api_token: string | null }>();

  if (!user) {
    return { error: 'Invalid credentials' };
  }

  const valid = await verifyPassword(password, user.password_salt, user.password_hash);
  if (!valid) {
    return { error: 'Invalid credentials' };
  }

  if (user.api_token) {
    return { data: { token: user.api_token } };
  }

  const apiToken = generateApiToken();
  await db
    .prepare('UPDATE users SET api_token = ? WHERE id = ?')
    .bind(apiToken, user.id)
    .run();

  return { data: { token: apiToken } };
}

export async function authenticate(
  db: D1Database,
  request: Request
): Promise<AuthResult> {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader) {
    return { user: null, error: 'Authorization header required' };
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return { user: null, error: 'Invalid authorization format. Use: Bearer <token>' };
  }

  const token = parts[1];

  const tokenRecord = await db
    .prepare(
      `SELECT u.id, u.username, u.email, u.api_token, u.is_admin, u.created_at
       FROM api_tokens t
       JOIN users u ON t.user_id = u.id
       WHERE t.token = ? AND t.expires_at > datetime('now')`
    )
    .bind(token)
    .first<User>();

  if (tokenRecord) {
    return { user: tokenRecord, error: null };
  }

  const user = await db
    .prepare(
      'SELECT id, username, email, api_token, is_admin, created_at FROM users WHERE api_token = ?'
    )
    .bind(token)
    .first<User>();

  if (!user) {
    return { user: null, error: 'Invalid or expired token' };
  }

  return { user, error: null };
}

export async function requireAuth(
  db: D1Database,
  request: Request
): Promise<{ user: User | null; error: Response | null }> {
  const { user, error } = await authenticate(db, request);
  if (error || !user) {
    return {
      user: null,
      error: jsonResponse(401, { error: error || 'Authentication required' }),
    };
  }
  return { user, error: null };
}

export function jsonResponse(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Kubexic-Deps, X-Kubexic-Description',
      'Access-Control-Max-Age': '86400',
    },
  });
}
