# Kubex Package Manager — Full Tutorial

This tutorial covers everything you need to know about `kubex`, the Kubexic package manager — from creating your first project to publishing packages to the registry.

---

## 1. Installation

### Install kxc (the compiler)

```bash
git clone https://github.com/kubexic/kubexic.git
cd kubexic
./build.sh
mkdir -p ~/.local/bin
ln -s "$(pwd)/build/kxc" ~/.local/bin/kxc
```

### Install kubex (the package manager)

kubex is built alongside kxc by `build.sh`:

```bash
ln -s "$(pwd)/build/kubex" ~/.local/bin/kubex
```

### Verify

```bash
kxc --version    # kxc 0.1.0
kubex --version  # kubex 0.1.0
```

---

## 2. Creating Your First Project

```bash
kubex init my-game
cd my-game
```

This creates:

```
my-game/
  .kxconf    # project manifest
  main.kx    # entry point
```

### The .kxconf file

```ini
// .kxconf — Kubexic project manifest

[package]
name = "my-game"
version = "0.1.0"
description = ""
license = "MIT"

[target]
kind = "binary"
entry = "main.kx"
output = "my-game"

[build]
optimization = "release"
```

### The main.kx file

```csharp
int main() {
    std.println("Hello from my-game!");
    return 0;
}
```

---

## 3. Building and Running

```bash
kubex build              # build the project
kubex run                # build and run
kubex build --debug      # build with debug symbols
kubex build --verbose    # show kxc commands being run
kubex build --shared     # build as shared library (.so)
kubex build --static     # build as static library (.a)
kubex build --target aarch64-linux-gnu  # cross-compile
```

---

## 4. The .kxconf Format

### Sections

| Section | Purpose |
|---|---|
| `[package]` | Package metadata (name, version, description, license) |
| `[target]` | What this project produces (binary or library) |
| `[build]` | Build configuration (target triple, optimization) |
| `[features]` | Optional compile-time features |
| `[dependencies]` | Kubexic packages from the registry |
| `[dev-dependencies]` | Dependencies only for tests |
| `[native]` | C library linking (include dirs, link dirs, libraries) |

### Version Requirements

| Syntax | Meaning |
|---|---|
| `"1.2.3"` | Exact version |
| `"^1.2.3"` | Compatible (>=1.2.3, <2.0.0) |
| `"~1.2.3"` | Approximate (>=1.2.3, <1.3.0) |
| `">=1.2.0"` | Minimum version |

### Example: Full .kxconf

```ini
[package]
name = "my-game"
version = "1.0.0"
description = "A 2D platformer"
license = "MIT"
author = "Your Name <you@email.com>"
repository = "https://github.com/user/my-game"

[target]
kind = "binary"
entry = "main.kx"
output = "my-game"

[build]
optimization = "release"
target = "x86_64-linux-gnu"

[features]
default = ["rendering"]

[dependencies]
kx-spatial = "^0.3.0"
kx-math = "^0.2.0"

[native]
libs = ["SDL2", "GL"]
include_dirs = ["/usr/include/SDL2"]
link_dirs = ["/usr/lib/x86_64-linux-gnu"]
```

---

## 5. Managing Dependencies

### Add a dependency

```bash
kubex add kx-spatial@^0.3.0
```

### Add a local dependency

```bash
kubex add ../kx-spatial
```

### Remove a dependency

```bash
kubex remove kx-math
```

### View dependency tree

```bash
kubex tree
```

### Manage cache

```bash
kubex cache list     # list cached packages
kubex cache clean    # remove all cached packages
kubex cache path     # show cache directory (~/.kubex/cache/)
```

---

## 6. Building Libraries

### Create a library

```ini
[target]
kind = "library"
libtype = "shared"     # "shared" (.so) or "static" (.a)
output = "libmylib"
```

### Build

```bash
kubex build --shared    # produces libmylib.so
kubex build --static    # produces libmylib.a
```

### Use from another project

```ini
[native]
libs = ["mylib"]
link_dirs = ["path/to/my-lib"]
```

```csharp
extern int add(int a, int b);

int main() {
    var result = add(2, 3);
    std.println($"2 + 3 = {result}");
    return 0;
}
```

---

## 7. Cross-Compilation

```bash
kubex build --target aarch64-linux-gnu     # Linux ARM64
kubex build --target arm-linux-gnueabihf   # Linux ARM 32-bit
kubex build --target x86_64-apple-darwin   # macOS Intel
kubex build --target aarch64-apple-darwin  # macOS Apple Silicon
kubex build --target x86_64-pc-windows-msvc # Windows
```

Install cross-compilers:

```bash
sudo apt install gcc-aarch64-linux-gnu    # ARM64
sudo apt install gcc-arm-linux-gnueabihf  # ARM 32-bit
sudo apt install gcc-mingw-w64-x86-64     # Windows
```

---

## 8. Authentication and Publishing

### Register an account

```bash
kubex register
```

Prompts for username, email, and password. Creates an account on the registry.

### Login

```bash
kubex login
```

Prompts for username and password. Saves an API token to `~/.kubex/auth.json`.

### Logout

```bash
kubex logout
```

Removes the saved token.

### Publish a package

```bash
kubex publish
```

This will:
1. Check that you're logged in
2. Read the .kxconf for package name and version
3. Build a .kxpkg archive from the project
4. Compute SHA-256 checksums
5. Upload to the registry

**Before publishing**, make sure your .kxconf has:

```ini
[package]
name = "my-lib"
version = "0.1.0"
description = "A useful library"
license = "MIT"
```

### Install a package

```bash
kubex install kx-spatial
```

Downloads the package binary (if available) to `~/.kubex/bin/`.

### Search for packages

```bash
kubex search spatial
```

Searches the registry for packages matching the query.

### Get package info

```bash
kubex info kx-spatial
```

Shows package metadata, versions, and dependencies.

---

## 9. Security

### Password Storage

- Passwords are hashed with SHA-256 + random salt before storage
- The registry never sees plaintext passwords
- Salt is stored alongside the hash

### API Tokens

- Generated as random 64-character hex strings
- Stored locally in `~/.kubex/auth.json`
- Sent as `Authorization: Bearer <token>` header
- Tokens can be revoked via the registry

### Package Checksums

- Every published package has a SHA-256 checksum
- Checksums are verified on download
- Stored in the registry database alongside the package

### Package Signing (Future)

- Ed25519 keypairs for package signing
- Public keys registered with the registry
- Signatures verified on download

### Transport Security

- All registry communication uses HTTPS (enforced by Cloudflare)
- No plaintext credentials over the wire

---

## 10. Admin System

The registry has a built-in admin system for managing users, packages, and moderation.

### Bootstrap the First Admin

After deploying the registry, the first user to call the init endpoint becomes the admin:

```bash
# Register your account first
kubex register

# Then initialize as admin (one-time only)
curl -X POST https://your-registry/v1/admin/init \
  -H "Authorization: Bearer YOUR_TOKEN"
```

This only works when no admin users exist. Once an admin is set, this endpoint returns 403.

### Admin API Endpoints

All admin endpoints require `Authorization: Bearer <admin-token>`.

| Endpoint | Description |
|---|---|
| `POST /v1/admin/init` | Bootstrap first admin (one-time) |
| `GET /v1/admin/users` | List all users |
| `GET /v1/admin/users/:id` | Get user details |
| `PUT /v1/admin/users/:id/admin` | Promote/demote user |
| `DELETE /v1/admin/users/:id` | Delete user |
| `GET /v1/admin/packages` | List all packages |
| `DELETE /v1/admin/packages/:name` | Delete package |
| `PUT /v1/admin/packages/:name/archive` | Archive package |
| `PUT /v1/admin/packages/:name/suspend` | Suspend package |
| `PUT /v1/admin/packages/:name/notes` | Set admin notes |
| `DELETE /v1/admin/versions/:name/:version` | Delete version |
| `GET /v1/admin/log` | View audit log |

### Admin Workflow

1. Register an account: `kubex register`
2. Bootstrap as admin: `POST /v1/admin/init` with your token
3. Manage users: promote/demote, delete accounts
4. Manage packages: delete, archive, suspend packages
5. Moderate versions: delete problematic versions
6. View audit log: all admin actions are recorded

### Package Status

Packages can have one of three statuses:
- **active** — visible and downloadable (default)
- **archived** — visible but not downloadable
- **suspended** — hidden from search, not downloadable

### Audit Trail

Every admin action is logged in the `admin_log` table with:
- Admin user ID
- Action performed
- Target type and ID
- Additional details
- Timestamp

---

## 11. Registry Architecture

The registry runs on Cloudflare Workers + R2 + D1.

### Components

| Component | Purpose |
|---|---|
| Cloudflare Worker | HTTP API server (TypeScript) |
| R2 Bucket | Package file storage (.kxpkg archives) |
| D1 Database | Package metadata (SQLite) |
| Cloudflare CDN | Global content delivery |

### API Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/v1/auth/register` | No | Create account |
| `POST` | `/v1/auth/login` | No | Get API token |
| `GET` | `/v1/packages?q=<term>` | No | Search packages |
| `GET` | `/v1/packages/:name` | No | Package info |
| `GET` | `/v1/packages/:name/versions` | No | List versions |
| `GET` | `/v1/packages/:name/:version` | No | Version info |
| `GET` | `/v1/packages/:name/:version/download` | No | Download package |
| `PUT` | `/v1/packages/:name` | Yes | Create package |
| `PUT` | `/v1/packages/:name/:version` | Yes | Publish version |
| `DELETE` | `/v1/packages/:name/:version` | Yes | Yank version |
| `POST` | `/v1/admin/init` | Yes | Bootstrap first admin |
| `GET` | `/v1/admin/users` | Admin | List users |
| `PUT` | `/v1/admin/users/:id/admin` | Admin | Promote/demote |
| `DELETE` | `/v1/admin/users/:id` | Admin | Delete user |
| `DELETE` | `/v1/admin/packages/:name` | Admin | Delete package |
| `PUT` | `/v1/admin/packages/:name/suspend` | Admin | Suspend package |
| `GET` | `/v1/admin/log` | Admin | Audit log |

### Database Schema

```sql
CREATE TABLE users (
    id TEXT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    api_token TEXT UNIQUE,
    is_admin INTEGER NOT NULL DEFAULT 0,
    created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE packages (
    id TEXT PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT DEFAULT '',
    license TEXT DEFAULT '',
    repository TEXT DEFAULT '',
    owner_id TEXT NOT NULL REFERENCES users(id),
    status TEXT NOT NULL DEFAULT 'active',
    admin_notes TEXT NOT NULL DEFAULT '',
    download_count INTEGER DEFAULT 0,
    latest_version TEXT,
    created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE versions (
    id TEXT PRIMARY KEY,
    package_id TEXT NOT NULL REFERENCES packages(id),
    version TEXT NOT NULL,
    yanked INTEGER DEFAULT 0,
    yanked_reason TEXT NOT NULL DEFAULT '',
    checksum TEXT NOT NULL,
    published_at TEXT DEFAULT (datetime('now')),
    publisher_id TEXT NOT NULL REFERENCES users(id)
);

CREATE TABLE version_deps (
    version_id TEXT NOT NULL REFERENCES versions(id),
    dep_name TEXT NOT NULL,
    dep_version_req TEXT NOT NULL
);

CREATE TABLE admin_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    admin_id INTEGER NOT NULL,
    action TEXT NOT NULL,
    target_type TEXT NOT NULL,
    target_id TEXT NOT NULL,
    details TEXT NOT NULL DEFAULT '',
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

---

## 11. Deploying the Registry

### Prerequisites

1. Cloudflare account (free tier works)
2. Node.js 18+
3. Wrangler CLI: `npm install -g wrangler`

### Setup

```bash
cd registry
npm install

# Create D1 database
wrangler d1 create kubex-registry-db
# Update wrangler.toml with the database ID

# Create R2 bucket
wrangler r2 bucket create kubex-registry
# Update wrangler.toml with the bucket name

# Run migrations (both schema and admin)
wrangler d1 execute kubex-registry-db --file=./migrations/0001_initial.sql
wrangler d1 execute kubex-registry-db --file=./migrations/0002_admin.sql

# Deploy
wrangler deploy
```

### After Deployment

1. Register your account: `kubex register`
2. Bootstrap as admin: `POST /v1/admin/init` with your token
3. You can now manage users, packages, and moderation

### Local Development

```bash
cd registry
npm install
wrangler dev
# Registry runs at http://localhost:8787
```

### Environment Variables

Set in `wrangler.toml` or via Cloudflare dashboard:

```toml
[vars]
REGISTRY_SECRET = "your-secret-key"
```

---

## 12. Writing Kubexic Code

### Components (data)

```csharp
component Health {
    var hp = 100;
    var name = "unknown";
}
```

### Systems (logic)

```csharp
system DamageSystem {
    Health.hp -= Damage.amount;
    if (Health.hp <= 0) {
        despawn self;
    } else {
        detach(self, Damage);
    }
}
```

### Tags (visibility)

```csharp
tag Combatant;

foreach (var e in others<Health>(tag: Combatant)) {
    std.println($"Found combatant with {e.Health.hp} HP");
}
```

### Spawning and the tick loop

```csharp
int main() {
    spawn { Health { hp = 100 }, tags [Combatant] };
    run(60);  // 60 ticks per second
    return 0;
}
```

---

## 13. Quick Reference

| Command | Description |
|---|---|
| `kubex init <name>` | Create new project |
| `kubex build` | Build the project |
| `kubex build --shared` | Build as shared library |
| `kubex build --static` | Build as static library |
| `kubex build --debug` | Build with debug symbols |
| `kubex build --target <triple>` | Cross-compile |
| `kubex run` | Build and run |
| `kubex add <pkg>@<version>` | Add dependency |
| `kubex remove <pkg>` | Remove dependency |
| `kubex tree` | Show dependency tree |
| `kubex register` | Register account |
| `kubex login` | Login to registry |
| `kubex logout` | Logout |
| `kubex publish` | Publish package |
| `kubex search <query>` | Search registry |
| `kubex install <pkg>` | Install binary package |
| `kubex info <pkg>` | Show package info |
| `kubex cache list` | List cached packages |
| `kubex cache clean` | Clear cache |
| `kubex cache path` | Show cache directory |
| `kubex --registry <url>` | Override registry URL |
