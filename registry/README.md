# Kubex Registry

A Cloudflare Workers-based package registry for Kubexic packages (.kxpkg).

## Architecture

- **Runtime**: Cloudflare Workers
- **Database**: Cloudflare D1 (SQLite)
- **Storage**: Cloudflare R2 (object storage)
- **Auth**: API tokens (hashed)

## API Documentation

Base URL: `https://<your-worker>.workers.dev/v1`

### Authentication

```
POST /auth/register   { username, email, password }  →  { token, user }
POST /auth/login      { username, password }          →  { token }
```

### Packages

```
GET    /packages?q=<query>&page=1&per_page=20&sort=relevance
GET    /packages/:name
PUT    /packages/:name              { description, license }  (auth required)
GET    /packages/:name/versions
GET    /packages/:name/:version
PUT    /packages/:name/:version     (auth required, body = .kxpkg archive)
DELETE /packages/:name/:version     (auth required)  → yank
GET    /packages/:name/:version/download
```

### Admin (admin token required)

```
POST   /admin/init                      Bootstrap first admin (one-time)
GET    /admin/users                     List users
GET    /admin/users/:id                 Get user details
PUT    /admin/users/:id/admin           Promote/demote user
DELETE /admin/users/:id                 Delete user
GET    /admin/packages                  List all packages
DELETE /admin/packages/:name            Delete package
PUT    /admin/packages/:name/archive    Archive package
PUT    /admin/packages/:name/suspend    Suspend package
PUT    /admin/packages/:name/notes      Set admin notes
DELETE /admin/versions/:name/:version   Delete version
GET    /admin/log                       Audit log
```

### Health

```
GET /  or  GET /health
```

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `REGISTRY_SECRET` | Secret for API token signing | — |
| `DATABASE_ID` | D1 database ID | — |
| `BUCKET_NAME` | R2 bucket name | `kubex-registry-bucket` |

## Local Development

```bash
# Install deps
npm install

# Run locally (uses miniflare)
npm run dev

# Or use the helper script
./dev.sh
```

The local server runs at `http://localhost:8787`.

## Deployment

### Prerequisites

- Node.js 18+
- Wrangler CLI (`npm install -g wrangler`)
- Cloudflare account with Workers, D1, and R2 enabled

### Deploy

```bash
# Using the deploy script (recommended)
./deploy.sh

# Or manually
wrangler d1 create kubex-registry-db
# Update database_id in wrangler.toml
wrangler r2 bucket create kubex-registry-bucket
wrangler d1 execute kubex-registry-db --file=./migrations/0001_initial.sql
wrangler d1 execute kubex-registry-db --file=./migrations/0002_admin.sql
wrangler deploy
```

### Configure kubex client

```bash
# Set the registry URL
export KUBEX_REGISTRY_URL=https://kubex-registry.<subdomain>.workers.dev/v1

# Or pass it per command
kubex --registry https://kubex-registry.<subdomain>.workers.dev/v1 search math
```

## Database Schema

See `migrations/0001_initial.sql` and `migrations/0002_admin.sql` for the full schema.

Key tables:
- `users` — user accounts with password hashes and admin flag
- `packages` — package metadata, ownership, and status
- `versions` — published versions with checksums
- `version_deps` — dependency relationships
- `api_tokens` — authentication tokens
- `admin_log` — audit trail for admin actions

## Project Structure

```
registry/
├── src/
│   ├── index.ts       Worker entry point and routing
│   ├── auth.ts        Registration, login, token auth
│   ├── admin.ts       Admin management and audit logging
│   ├── packages.ts    Package CRUD and version management
│   ├── storage.ts     R2 upload/download
│   ├── search.ts      Package search with pagination
│   ├── ratelimit.ts   In-memory rate limiting
│   └── crypto.ts      SHA-256 hashing and token generation
├── migrations/
│   ├── 0001_initial.sql
│   └── 0002_admin.sql
├── wrangler.toml
├── package.json
├── deploy.sh
├── dev.sh
├── .env.example
└── README.md
```
