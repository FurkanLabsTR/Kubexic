import { requireAuth, jsonResponse, User } from './auth';
import { uploadPackage, downloadPackage } from './storage';
import { parseSearchParams, searchPackages } from './search';
import { checkRateLimit, rateLimitResponse } from './ratelimit';

interface Env {
  DB: D1Database;
  BUCKET: R2Bucket;
}

const MAX_PACKAGE_SIZE = 50 * 1024 * 1024;
const PACKAGE_NAME_REGEX = /^[a-z0-9][a-z0-9_-]{0,63}$/;
const SEMVER_REGEX = /^\d+\.\d+\.\d+(-[a-zA-Z0-9.]+)?(\+[a-zA-Z0-9.]+)?$/;

function validatePackageName(name: string): string | null {
  if (name.length === 0) return 'Package name is required';
  if (name.length > 64) return 'Package name must be 64 characters or fewer';
  if (!PACKAGE_NAME_REGEX.test(name)) {
    return 'Package name must be lowercase alphanumeric with hyphens or underscores (max 64 chars)';
  }
  return null;
}

export async function handlePackages(request: Request, env: Env): Promise<Response> {
  const url = new URL(request.url);
  const path = url.pathname.replace(/^\/v1\/packages/, '');

  if (request.method === 'GET' && path === '') {
    return handleListPackages(request, env);
  }

  const packageMatch = path.match(/^\/([^/]+)$/);
  if (packageMatch) {
    const name = decodeURIComponent(packageMatch[1]);

    if (request.method === 'GET') {
      return handleGetPackage(name, env);
    }
    if (request.method === 'PUT') {
      return handleCreatePackage(request, name, env);
    }
  }

  const versionMatch = path.match(/^\/([^/]+)\/versions$/);
  if (versionMatch && request.method === 'GET') {
    const name = decodeURIComponent(versionMatch[1]);
    return handleListVersions(name, request, env);
  }

  const versionDetailMatch = path.match(/^\/([^/]+)\/([^/]+)$/);
  if (versionDetailMatch) {
    const name = decodeURIComponent(versionDetailMatch[1]);
    const version = decodeURIComponent(versionDetailMatch[2]);

    if (request.method === 'GET') {
      return handleGetVersion(name, version, env);
    }
    if (request.method === 'PUT') {
      return handlePublishVersion(request, name, version, env);
    }
    if (request.method === 'DELETE') {
      return handleYankVersion(request, name, version, env);
    }
  }

  const downloadMatch = path.match(/^\/([^/]+)\/([^/]+)\/download$/);
  if (downloadMatch && request.method === 'GET') {
    const name = decodeURIComponent(downloadMatch[1]);
    const version = decodeURIComponent(downloadMatch[2]);
    return handleDownload(name, version, env);
  }

  const signatureMatch = path.match(/^\/([^/]+)\/([^/]+)\/signature$/);
  if (signatureMatch && request.method === 'GET') {
    const name = decodeURIComponent(signatureMatch[1]);
    const version = decodeURIComponent(signatureMatch[2]);
    return handleGetSignature(name, version, env);
  }

  const sbomMatch = path.match(/^\/([^/]+)\/([^/]+)\/sbom$/);
  if (sbomMatch) {
    const name = decodeURIComponent(sbomMatch[1]);
    const version = decodeURIComponent(sbomMatch[2]);
    if (request.method === 'GET') {
      return handleGetSbom(name, version, env);
    }
    if (request.method === 'PUT') {
      return handlePutSbom(request, name, version, env);
    }
  }

  return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Endpoint not found' } });
}

async function handleListPackages(
  request: Request,
  env: Env
): Promise<Response> {
  const params = parseSearchParams(new URL(request.url));
  const { results, total } = await searchPackages(env.DB, params);

  return jsonResponse(200, {
    data: {
      packages: results,
      pagination: {
        page: params.page,
        per_page: params.perPage,
        total,
        total_pages: Math.ceil(total / params.perPage),
      },
    },
  });
}

async function handleGetPackage(
  name: string,
  env: Env
): Promise<Response> {
  const pkg = await env.DB.prepare(
    `SELECT p.*, u.username as owner
     FROM packages p
     JOIN users u ON p.owner_id = u.id
     WHERE p.name = ?`
  )
    .bind(name)
    .first();

  if (!pkg) {
    return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Package not found' } });
  }

  const versions = await env.DB.prepare(
    `SELECT v.version, v.description, v.published_at, v.checksum, v.yanked, v.yanked_reason,
            u.username as publisher
     FROM versions v
     JOIN users u ON v.publisher_id = u.id
     WHERE v.package_id = ?
     ORDER BY v.published_at DESC`
  )
    .bind(pkg.id)
    .all();

  return jsonResponse(200, {
    data: {
      ...pkg,
      versions: versions.results,
    },
  });
}

async function handleListVersions(
  name: string,
  request: Request,
  env: Env
): Promise<Response> {
  const pkg = await env.DB.prepare(
    'SELECT id FROM packages WHERE name = ?'
  )
    .bind(name)
    .first<{ id: number }>();

  if (!pkg) {
    return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Package not found' } });
  }

  const url = new URL(request.url);
  const page = Math.max(1, parseInt(url.searchParams.get('page') || '1', 10));
  const perPage = Math.min(100, Math.max(1, parseInt(url.searchParams.get('per_page') || '50', 10)));
  const offset = (page - 1) * perPage;

  const yankedFilter = url.searchParams.get('yanked');
  let whereClause = 'WHERE v.package_id = ?';
  const bindings: unknown[] = [pkg.id];

  if (yankedFilter === 'true') {
    whereClause += ' AND v.yanked = 1';
  } else if (yankedFilter === 'false') {
    whereClause += ' AND v.yanked = 0';
  }

  const countResult = await env.DB.prepare(
    `SELECT COUNT(*) as total FROM versions v ${whereClause}`
  )
    .bind(...bindings)
    .first<{ total: number }>();

  const total = countResult?.total || 0;

  const versions = await env.DB.prepare(
    `SELECT v.version, v.description, v.yanked, v.yanked_reason, v.published_at, v.checksum,
            v.download_count, u.username as publisher
     FROM versions v
     JOIN users u ON v.publisher_id = u.id
     ${whereClause}
     ORDER BY v.version DESC
     LIMIT ? OFFSET ?`
  )
    .bind(...bindings, perPage, offset)
    .all();

  return jsonResponse(200, {
    data: {
      versions: versions.results,
      pagination: {
        page,
        per_page: perPage,
        total,
        total_pages: Math.ceil(total / perPage),
      },
    },
  });
}

async function handleGetVersion(
  name: string,
  version: string,
  env: Env
): Promise<Response> {
  const pkg = await env.DB.prepare(
    'SELECT id FROM packages WHERE name = ?'
  )
    .bind(name)
    .first<{ id: number }>();

  if (!pkg) {
    return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Package not found' } });
  }

  const ver = await env.DB.prepare(
    `SELECT v.*, u.username as publisher
     FROM versions v
     JOIN users u ON v.publisher_id = u.id
     WHERE v.package_id = ? AND v.version = ?`
  )
    .bind(pkg.id, version)
    .first();

  if (!ver) {
    return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Version not found' } });
  }

  const deps = await env.DB.prepare(
    'SELECT dep_name, dep_version_req FROM version_deps WHERE version_id = ?'
  )
    .bind(ver.id)
    .all();

  return jsonResponse(200, {
    data: { ...ver, dependencies: deps.results },
  });
}

async function handleCreatePackage(
  request: Request,
  name: string,
  env: Env
): Promise<Response> {
  const rl = checkRateLimit('auth', request);
  if (!rl.allowed) return rateLimitResponse(rl.retryAfter);

  const auth = await requireAuth(env.DB, request);
  if (auth.error) return auth.error;

  const nameError = validatePackageName(name);
  if (nameError) {
    return jsonResponse(400, { error: { code: 'VALIDATION_ERROR', message: nameError } });
  }

  const body = await request.json<{
    description?: string;
    license?: string;
    repository?: string;
  }>();

  const existing = await env.DB.prepare(
    'SELECT id FROM packages WHERE name = ?'
  )
    .bind(name)
    .first<{ id: number }>();

  if (existing) {
    return jsonResponse(409, { error: { code: 'CONFLICT', message: 'Package already exists' } });
  }

  const result = await env.DB.prepare(
    `INSERT INTO packages (name, description, license, repository, owner_id)
     VALUES (?, ?, ?, ?, ?)`
  )
    .bind(
      name,
      body.description || '',
      body.license || '',
      body.repository || '',
      auth.user!.id
    )
    .run();

  if (!result.success) {
    return jsonResponse(500, { error: { code: 'INTERNAL_ERROR', message: 'Failed to create package' } });
  }

  return jsonResponse(201, {
    data: { name, message: 'Package created' },
  });
}

async function handlePublishVersion(
  request: Request,
  name: string,
  version: string,
  env: Env
): Promise<Response> {
  const auth = await requireAuth(env.DB, request);
  if (auth.error) return auth.error;

  const rl = checkRateLimit('write', request, auth.user!.id);
  if (!rl.allowed) return rateLimitResponse(rl.retryAfter);

  const nameError = validatePackageName(name);
  if (nameError) {
    return jsonResponse(400, { error: { code: 'VALIDATION_ERROR', message: nameError } });
  }

  if (!SEMVER_REGEX.test(version)) {
    return jsonResponse(400, {
      error: { code: 'VALIDATION_ERROR', message: 'Invalid version format. Use semver (e.g., 1.0.0)' },
    });
  }

  const pkg = await env.DB.prepare(
    'SELECT id, owner_id FROM packages WHERE name = ?'
  )
    .bind(name)
    .first<{ id: number; owner_id: number }>();

  if (!pkg) {
    return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Package not found. Create it first with PUT /v1/packages/:name' } });
  }

  if (pkg.owner_id !== auth.user!.id) {
    return jsonResponse(403, { error: { code: 'FORBIDDEN', message: 'Only package owner can publish' } });
  }

  const existingVer = await env.DB.prepare(
    'SELECT id FROM versions WHERE package_id = ? AND version = ?'
  )
    .bind(pkg.id, version)
    .first<{ id: number }>();

  if (existingVer) {
    return jsonResponse(409, { error: { code: 'CONFLICT', message: 'Version already published' } });
  }

  const contentLength = parseInt(request.headers.get('Content-Length') || '0', 10);
  if (contentLength === 0) {
    return jsonResponse(400, { error: { code: 'VALIDATION_ERROR', message: 'Request body must contain the .kxpkg file' } });
  }

  if (contentLength > MAX_PACKAGE_SIZE) {
    return jsonResponse(413, {
      error: { code: 'PAYLOAD_TOO_LARGE', message: `Package file exceeds maximum size of ${MAX_PACKAGE_SIZE / (1024 * 1024)}MB` },
    });
  }

  const arrayBuffer = await request.arrayBuffer();
  if (arrayBuffer.byteLength < 16) {
    return jsonResponse(400, { error: { code: 'VALIDATION_ERROR', message: 'Package file too small' } });
  }

  if (arrayBuffer.byteLength > MAX_PACKAGE_SIZE) {
    return jsonResponse(413, {
      error: { code: 'PAYLOAD_TOO_LARGE', message: `Package file exceeds maximum size of ${MAX_PACKAGE_SIZE / (1024 * 1024)}MB` },
    });
  }

  const { checksum } = await uploadPackage(env.BUCKET, name, version, arrayBuffer);

  let dependencies: { name: string; version_req: string }[] = [];
  const depsHeader = request.headers.get('X-Kubexic-Deps');
  if (depsHeader) {
    try {
      dependencies = JSON.parse(depsHeader);
    } catch {
      return jsonResponse(400, { error: { code: 'VALIDATION_ERROR', message: 'Invalid X-Kubexic-Deps header format' } });
    }
  }

  const description = request.headers.get('X-Kubexic-Description') || '';

  // Extract signature and public key from form data
  let signature = '';
  let publicKey = '';
  const contentType = request.headers.get('Content-Type') || '';
  if (contentType.includes('multipart/form-data')) {
    const formData = await request.formData();
    const sigField = formData.get('signature');
    const pubKeyField = formData.get('public_key');
    if (typeof sigField === 'string') signature = sigField;
    if (typeof pubKeyField === 'string') publicKey = pubKeyField;
  }

  const result = await env.DB.prepare(
    `INSERT INTO versions (package_id, version, description, publisher_id, checksum, signature, public_key)
     VALUES (?, ?, ?, ?, ?, ?, ?)`
  )
    .bind(pkg.id, version, description, auth.user!.id, checksum, signature, publicKey)
    .run();

  if (!result.success) {
    return jsonResponse(500, { error: { code: 'INTERNAL_ERROR', message: 'Failed to publish version' } });
  }

  const versionRow = await env.DB.prepare(
    'SELECT id FROM versions WHERE package_id = ? AND version = ?'
  )
    .bind(pkg.id, version)
    .first<{ id: number }>();

  if (versionRow) {
    for (const dep of dependencies) {
      await env.DB.prepare(
        'INSERT INTO version_deps (version_id, dep_name, dep_version_req) VALUES (?, ?, ?)'
      )
        .bind(versionRow.id, dep.name, dep.version_req)
        .run();
    }
  }

  await env.DB.prepare(
    `UPDATE packages SET latest_version = ?, updated_at = datetime('now') WHERE id = ?`
  )
    .bind(version, pkg.id)
    .run();

  return jsonResponse(201, {
    data: { name, version, checksum, message: 'Version published' },
  });
}

async function handleYankVersion(
  request: Request,
  name: string,
  version: string,
  env: Env
): Promise<Response> {
  const auth = await requireAuth(env.DB, request);
  if (auth.error) return auth.error;

  const rl = checkRateLimit('write', request, auth.user!.id);
  if (!rl.allowed) return rateLimitResponse(rl.retryAfter);

  const pkg = await env.DB.prepare(
    'SELECT id, owner_id FROM packages WHERE name = ?'
  )
    .bind(name)
    .first<{ id: number; owner_id: number }>();

  if (!pkg) {
    return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Package not found' } });
  }

  if (pkg.owner_id !== auth.user!.id) {
    return jsonResponse(403, { error: { code: 'FORBIDDEN', message: 'Only package owner can yank versions' } });
  }

  const ver = await env.DB.prepare(
    'SELECT id, yanked FROM versions WHERE package_id = ? AND version = ?'
  )
    .bind(pkg.id, version)
    .first<{ id: number; yanked: number }>();

  if (!ver) {
    return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Version not found' } });
  }

  if (ver.yanked) {
    return jsonResponse(400, { error: { code: 'ALREADY_YANKED', message: 'Version already yanked' } });
  }

  let yankedReason = '';
  try {
    const body = await request.json<{ reason?: string }>();
    yankedReason = body.reason || '';
  } catch {
    // body may be empty
  }

  if (!yankedReason || yankedReason.trim().length === 0) {
    return jsonResponse(400, {
      error: { code: 'VALIDATION_ERROR', message: 'Yank reason is required' },
    });
  }

  await env.DB.prepare(
    `UPDATE versions SET yanked = 1, yanked_reason = ? WHERE id = ?`
  )
    .bind(yankedReason.trim(), ver.id)
    .run();

  return jsonResponse(200, {
    data: { name, version, yanked_reason: yankedReason.trim(), message: 'Version yanked' },
  });
}

async function handleDownload(
  name: string,
  version: string,
  env: Env
): Promise<Response> {
  const pkg = await env.DB.prepare(
    'SELECT id FROM packages WHERE name = ?'
  )
    .bind(name)
    .first<{ id: number }>();

  if (!pkg) {
    return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Package not found' } });
  }

  const ver = await env.DB.prepare(
    'SELECT id, yanked, checksum FROM versions WHERE package_id = ? AND version = ?'
  )
    .bind(pkg.id, version)
    .first<{ id: number; yanked: number; checksum: string }>();

  if (!ver) {
    return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Version not found' } });
  }

  if (ver.yanked) {
    return jsonResponse(410, { error: { code: 'YANKED', message: 'Version has been yanked' } });
  }

  const result = await downloadPackage(env.BUCKET, name, version, ver.checksum);
  if ('error' in result) {
    return jsonResponse(500, { error: { code: 'STORAGE_ERROR', message: result.error } });
  }

  await env.DB.prepare(
    'UPDATE packages SET download_count = download_count + 1 WHERE id = ?'
  )
    .bind(pkg.id)
    .run();

  return new Response(result.data, {
    status: 200,
    headers: {
      'Content-Type': 'application/octet-stream',
      'Content-Disposition': `attachment; filename="${name}-${version}.kxpkg"`,
      'X-Kubexic-Checksum': result.checksum,
      'Access-Control-Allow-Origin': '*',
    },
  });
}

async function handleGetSignature(
  name: string,
  version: string,
  env: Env
): Promise<Response> {
  const pkg = await env.DB.prepare(
    'SELECT id FROM packages WHERE name = ?'
  )
    .bind(name)
    .first<{ id: number }>();

  if (!pkg) {
    return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Package not found' } });
  }

  const ver = await env.DB.prepare(
    'SELECT signature, public_key FROM versions WHERE package_id = ? AND version = ?'
  )
    .bind(pkg.id, version)
    .first<{ signature: string; public_key: string }>();

  if (!ver) {
    return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Version not found' } });
  }

  if (!ver.signature || !ver.public_key) {
    return jsonResponse(404, { error: { code: 'NOT_SIGNED', message: 'Version is not signed' } });
  }

  return jsonResponse(200, {
    data: {
      signature: ver.signature,
      public_key: ver.public_key,
      key_type: 'ed25519',
    },
  });
}

async function handleGetSbom(
  name: string,
  version: string,
  env: Env
): Promise<Response> {
  const pkg = await env.DB.prepare(
    'SELECT id FROM packages WHERE name = ?'
  )
    .bind(name)
    .first<{ id: number }>();

  if (!pkg) {
    return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Package not found' } });
  }

  const ver = await env.DB.prepare(
    'SELECT id FROM versions WHERE package_id = ? AND version = ?'
  )
    .bind(pkg.id, version)
    .first<{ id: number }>();

  if (!ver) {
    return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Version not found' } });
  }

  const sbom = await env.DB.prepare(
    'SELECT sbom_json FROM sboms WHERE version_id = ?'
  )
    .bind(ver.id)
    .first<{ sbom_json: string }>();

  if (!sbom) {
    return jsonResponse(404, { error: { code: 'NO_SBOM', message: 'No SBOM available for this version' } });
  }

  return new Response(sbom.sbom_json, {
    status: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
  });
}

async function handlePutSbom(
  request: Request,
  name: string,
  version: string,
  env: Env
): Promise<Response> {
  const auth = await requireAuth(env.DB, request);
  if (auth.error) return auth.error;

  const pkg = await env.DB.prepare(
    'SELECT id, owner_id FROM packages WHERE name = ?'
  )
    .bind(name)
    .first<{ id: number; owner_id: number }>();

  if (!pkg) {
    return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Package not found' } });
  }

  if (pkg.owner_id !== auth.user!.id) {
    return jsonResponse(403, { error: { code: 'FORBIDDEN', message: 'Only package owner can update SBOM' } });
  }

  const ver = await env.DB.prepare(
    'SELECT id FROM versions WHERE package_id = ? AND version = ?'
  )
    .bind(pkg.id, version)
    .first<{ id: number }>();

  if (!ver) {
    return jsonResponse(404, { error: { code: 'NOT_FOUND', message: 'Version not found' } });
  }

  const sbomJson = await request.text();
  if (!sbomJson) {
    return jsonResponse(400, { error: { code: 'VALIDATION_ERROR', message: 'SBOM content required' } });
  }

  // Upsert SBOM
  const existing = await env.DB.prepare(
    'SELECT id FROM sboms WHERE version_id = ?'
  )
    .bind(ver.id)
    .first<{ id: number }>();

  if (existing) {
    await env.DB.prepare(
      'UPDATE sboms SET sbom_json = ? WHERE version_id = ?'
    )
      .bind(sbomJson, ver.id)
      .run();
  } else {
    await env.DB.prepare(
      'INSERT INTO sboms (version_id, sbom_json) VALUES (?, ?)'
    )
      .bind(ver.id, sbomJson)
      .run();
  }

  return jsonResponse(200, { data: { message: 'SBOM updated' } });
}
