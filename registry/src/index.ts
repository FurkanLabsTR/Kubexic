import { register, login, jsonResponse } from './auth';
import { handlePackages } from './packages';
import { checkRateLimit, rateLimitResponse } from './ratelimit';
import {
  requireAdmin,
  listUsers,
  getUser,
  setUserAdmin,
  deleteUser,
  listPackages,
  deletePackage,
  archivePackage,
  suspendPackage,
  setPackageNotes,
  unyankVersion,
  deleteVersion,
  logAdminAction,
  getAdminLog,
} from './admin';

interface Env {
  DB: D1Database;
  BUCKET: R2Bucket;
}

const CORS_HEADERS: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Kubexic-Deps, X-Kubexic-Description, X-Request-Id',
  'Access-Control-Max-Age': '86400',
};

function generateRequestId(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(16));
  return Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

function structuredError(status: number, code: string, message: string, requestId: string): Response {
  return new Response(
    JSON.stringify({
      error: { code, message },
      request_id: requestId,
    }),
    {
      status,
      headers: {
        'Content-Type': 'application/json',
        ...CORS_HEADERS,
      },
    }
  );
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: CORS_HEADERS });
    }

    const requestId = request.headers.get('X-Request-Id') || generateRequestId();
    const url = new URL(request.url);
    const path = url.pathname;

    try {
      if (path === '/v1/auth/register' && request.method === 'POST') {
        const rl = checkRateLimit('auth', request);
        if (!rl.allowed) return rateLimitResponse(rl.retryAfter);

        const body = await request.json<{ username: string; email: string; password: string }>();
        const result = await register(env.DB, body.username, body.email, body.password);
        if (result.error) {
          return structuredError(400, 'VALIDATION_ERROR', result.error, requestId);
        }
        const res = jsonResponse(201, { data: result.data });
        res.headers.set('X-Request-Id', requestId);
        return res;
      }

      if (path === '/v1/auth/login' && request.method === 'POST') {
        const rl = checkRateLimit('auth', request);
        if (!rl.allowed) return rateLimitResponse(rl.retryAfter);

        const body = await request.json<{ username: string; password: string }>();
        const result = await login(env.DB, body.username, body.password);
        if (result.error) {
          return structuredError(401, 'AUTH_ERROR', result.error, requestId);
        }
        const res = jsonResponse(200, { data: result.data });
        res.headers.set('X-Request-Id', requestId);
        return res;
      }

      // Admin bootstrap: first admin initialization
      if (path === '/v1/admin/init' && request.method === 'POST') {
        const existingAdmin = await env.DB
          .prepare('SELECT id FROM users WHERE is_admin = 1')
          .first<{ id: number }>();

        if (existingAdmin) {
          return structuredError(403, 'FORBIDDEN', 'Admin already initialized', requestId);
        }

        const authHeader = request.headers.get('Authorization');
        if (!authHeader) {
          return structuredError(401, 'AUTH_ERROR', 'Authorization header required', requestId);
        }

        const parts = authHeader.split(' ');
        if (parts.length !== 2 || parts[0] !== 'Bearer') {
          return structuredError(401, 'AUTH_ERROR', 'Invalid authorization format', requestId);
        }

        const token = parts[1];
        const user = await env.DB
          .prepare('SELECT id, username FROM users WHERE api_token = ?')
          .bind(token)
          .first<{ id: number; username: string }>();

        if (!user) {
          return structuredError(401, 'AUTH_ERROR', 'Invalid or expired token', requestId);
        }

        await env.DB
          .prepare('UPDATE users SET is_admin = 1 WHERE id = ?')
          .bind(user.id)
          .run();

        await logAdminAction(env.DB, user.id, 'init_admin', 'user', String(user.id), 'First admin initialized');

        const res = jsonResponse(200, { data: { message: 'Admin initialized', user: user.username } });
        res.headers.set('X-Request-Id', requestId);
        return res;
      }

      // Admin routes
      if (path.startsWith('/v1/admin')) {
        const adminAuth = await requireAdmin(env.DB, request);
        if (adminAuth.error) {
          adminAuth.error.headers.set('X-Request-Id', requestId);
          return adminAuth.error;
        }
        const adminUser = adminAuth.user!;

        // GET /v1/admin/users
        if (path === '/v1/admin/users' && request.method === 'GET') {
          const page = Math.max(1, parseInt(url.searchParams.get('page') || '1', 10));
          const perPage = Math.min(100, Math.max(1, parseInt(url.searchParams.get('per_page') || '20', 10)));
          const { users, total } = await listUsers(env.DB, page, perPage);
          const res = jsonResponse(200, {
            data: {
              users,
              pagination: { page, per_page: perPage, total, total_pages: Math.ceil(total / perPage) },
            },
          });
          res.headers.set('X-Request-Id', requestId);
          return res;
        }

        // GET /v1/admin/users/:id
        const userMatch = path.match(/^\/v1\/admin\/users\/(\d+)$/);
        if (userMatch && request.method === 'GET') {
          const userId = parseInt(userMatch[1], 10);
          const user = await getUser(env.DB, userId);
          if (!user) {
            return structuredError(404, 'NOT_FOUND', 'User not found', requestId);
          }
          const res = jsonResponse(200, { data: user });
          res.headers.set('X-Request-Id', requestId);
          return res;
        }

        // PUT /v1/admin/users/:id/admin
        const adminMatch = path.match(/^\/v1\/admin\/users\/(\d+)\/admin$/);
        if (adminMatch && request.method === 'PUT') {
          const userId = parseInt(adminMatch[1], 10);
          const targetUser = await getUser(env.DB, userId);
          if (!targetUser) {
            return structuredError(404, 'NOT_FOUND', 'User not found', requestId);
          }
          const body = await request.json<{ is_admin: boolean }>();
          await setUserAdmin(env.DB, userId, body.is_admin);
          await logAdminAction(env.DB, adminUser.id, body.is_admin ? 'promote_user' : 'demote_user', 'user', String(userId), `User ${targetUser.username} ${body.is_admin ? 'promoted to' : 'demoted from'} admin`);
          const res = jsonResponse(200, { data: { message: `User ${body.is_admin ? 'promoted to' : 'demoted from'} admin` } });
          res.headers.set('X-Request-Id', requestId);
          return res;
        }

        // DELETE /v1/admin/users/:id
        const deleteUserMatch = path.match(/^\/v1\/admin\/users\/(\d+)$/);
        if (deleteUserMatch && request.method === 'DELETE') {
          const userId = parseInt(deleteUserMatch[1], 10);
          if (userId === adminUser.id) {
            return structuredError(400, 'VALIDATION_ERROR', 'Cannot delete yourself', requestId);
          }
          const targetUser = await getUser(env.DB, userId);
          if (!targetUser) {
            return structuredError(404, 'NOT_FOUND', 'User not found', requestId);
          }
          await deleteUser(env.DB, userId);
          await logAdminAction(env.DB, adminUser.id, 'delete_user', 'user', String(userId), `Deleted user ${targetUser.username}`);
          const res = jsonResponse(200, { data: { message: 'User deleted' } });
          res.headers.set('X-Request-Id', requestId);
          return res;
        }

        // GET /v1/admin/packages
        if (path === '/v1/admin/packages' && request.method === 'GET') {
          const page = Math.max(1, parseInt(url.searchParams.get('page') || '1', 10));
          const perPage = Math.min(100, Math.max(1, parseInt(url.searchParams.get('per_page') || '20', 10)));
          const { packages, total } = await listPackages(env.DB, page, perPage);
          const res = jsonResponse(200, {
            data: {
              packages,
              pagination: { page, per_page: perPage, total, total_pages: Math.ceil(total / perPage) },
            },
          });
          res.headers.set('X-Request-Id', requestId);
          return res;
        }

        // DELETE /v1/admin/packages/:name
        const deletePkgMatch = path.match(/^\/v1\/admin\/packages\/([^/]+)$/);
        if (deletePkgMatch && request.method === 'DELETE') {
          const pkgName = decodeURIComponent(deletePkgMatch[1]);
          const deleted = await deletePackage(env.DB, pkgName);
          if (!deleted) {
            return structuredError(404, 'NOT_FOUND', 'Package not found', requestId);
          }
          await logAdminAction(env.DB, adminUser.id, 'delete_package', 'package', pkgName, '');
          const res = jsonResponse(200, { data: { message: 'Package deleted' } });
          res.headers.set('X-Request-Id', requestId);
          return res;
        }

        // PUT /v1/admin/packages/:name/archive
        const archiveMatch = path.match(/^\/v1\/admin\/packages\/([^/]+)\/archive$/);
        if (archiveMatch && request.method === 'PUT') {
          const pkgName = decodeURIComponent(archiveMatch[1]);
          const archived = await archivePackage(env.DB, pkgName);
          if (!archived) {
            return structuredError(404, 'NOT_FOUND', 'Package not found', requestId);
          }
          await logAdminAction(env.DB, adminUser.id, 'archive_package', 'package', pkgName, '');
          const res = jsonResponse(200, { data: { message: 'Package archived' } });
          res.headers.set('X-Request-Id', requestId);
          return res;
        }

        // PUT /v1/admin/packages/:name/suspend
        const suspendMatch = path.match(/^\/v1\/admin\/packages\/([^/]+)\/suspend$/);
        if (suspendMatch && request.method === 'PUT') {
          const pkgName = decodeURIComponent(suspendMatch[1]);
          const body = await request.json<{ reason: string }>();
          const suspended = await suspendPackage(env.DB, pkgName, body.reason);
          if (!suspended) {
            return structuredError(404, 'NOT_FOUND', 'Package not found', requestId);
          }
          await logAdminAction(env.DB, adminUser.id, 'suspend_package', 'package', pkgName, body.reason);
          const res = jsonResponse(200, { data: { message: 'Package suspended' } });
          res.headers.set('X-Request-Id', requestId);
          return res;
        }

        // PUT /v1/admin/packages/:name/notes
        const notesMatch = path.match(/^\/v1\/admin\/packages\/([^/]+)\/notes$/);
        if (notesMatch && request.method === 'PUT') {
          const pkgName = decodeURIComponent(notesMatch[1]);
          const body = await request.json<{ notes: string }>();
          const updated = await setPackageNotes(env.DB, pkgName, body.notes);
          if (!updated) {
            return structuredError(404, 'NOT_FOUND', 'Package not found', requestId);
          }
          await logAdminAction(env.DB, adminUser.id, 'set_package_notes', 'package', pkgName, body.notes);
          const res = jsonResponse(200, { data: { message: 'Notes updated' } });
          res.headers.set('X-Request-Id', requestId);
          return res;
        }

        // PUT /v1/admin/versions/:name/:version/unyank
        const unyankMatch = path.match(/^\/v1\/admin\/versions\/([^/]+)\/([^/]+)\/unyank$/);
        if (unyankMatch && request.method === 'PUT') {
          const pkgName = decodeURIComponent(unyankMatch[1]);
          const version = decodeURIComponent(unyankMatch[2]);
          const result = await unyankVersion(env.DB, pkgName, version);
          if (!result) {
            return structuredError(404, 'NOT_FOUND', 'Package or version not found', requestId);
          }
          await logAdminAction(env.DB, adminUser.id, 'unyank_version', 'version', `${pkgName}@${version}`, '');
          const res = jsonResponse(200, { data: { message: 'Version unyanked' } });
          res.headers.set('X-Request-Id', requestId);
          return res;
        }

        // DELETE /v1/admin/versions/:name/:version
        const deleteVerMatch = path.match(/^\/v1\/admin\/versions\/([^/]+)\/([^/]+)$/);
        if (deleteVerMatch && request.method === 'DELETE') {
          const pkgName = decodeURIComponent(deleteVerMatch[1]);
          const version = decodeURIComponent(deleteVerMatch[2]);
          const result = await deleteVersion(env.DB, pkgName, version);
          if (!result) {
            return structuredError(404, 'NOT_FOUND', 'Package or version not found', requestId);
          }
          await logAdminAction(env.DB, adminUser.id, 'delete_version', 'version', `${pkgName}@${version}`, '');
          const res = jsonResponse(200, { data: { message: 'Version deleted' } });
          res.headers.set('X-Request-Id', requestId);
          return res;
        }

        // GET /v1/admin/log
        if (path === '/v1/admin/log' && request.method === 'GET') {
          const page = Math.max(1, parseInt(url.searchParams.get('page') || '1', 10));
          const perPage = Math.min(100, Math.max(1, parseInt(url.searchParams.get('per_page') || '50', 10)));
          const { logs, total } = await getAdminLog(env.DB, page, perPage);
          const res = jsonResponse(200, {
            data: {
              logs,
              pagination: { page, per_page: perPage, total, total_pages: Math.ceil(total / perPage) },
            },
          });
          res.headers.set('X-Request-Id', requestId);
          return res;
        }

        return structuredError(404, 'NOT_FOUND', 'Admin endpoint not found', requestId);
      }

      if (path.startsWith('/v1/packages')) {
        const rl = checkRateLimit('read', request);
        if (!rl.allowed) return rateLimitResponse(rl.retryAfter);

        const res = await handlePackages(request, env);
        res.headers.set('X-Request-Id', requestId);
        return res;
      }

      if (path === '/' || path === '/health') {
        const res = jsonResponse(200, {
          data: {
            status: 'ok',
            service: 'kubex-registry',
            version: '0.1.0',
            uptime: Math.floor(Date.now() / 1000),
          },
        });
        res.headers.set('X-Request-Id', requestId);
        return res;
      }

      return structuredError(404, 'NOT_FOUND', 'Endpoint not found', requestId);
    } catch (err) {
      const timestamp = new Date().toISOString();
      const message = err instanceof Error ? err.message : 'Internal server error';
      console.error(`[${timestamp}] [${requestId}] ${request.method} ${path}: ${message}`);

      return structuredError(500, 'INTERNAL_ERROR', message, requestId);
    }
  },
};
