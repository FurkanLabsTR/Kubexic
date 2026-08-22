# Self-Hosting Kubexic: Unified Compiler + Package Manager Plan

> **Goal**: Single `kubexic` binary that is BOTH compiler AND package manager,
> written in Kubexic itself (self-hosting), bootstrapped from the existing C++ toolchain.

---

## Current State Summary (Aug 22, 2026)

### ✅ What Works Today

| Component | Status | Details |
|-----------|--------|---------|
| C++ compiler (`kxc`) | ✅ Complete | pub, namespaces, library output, cross-compile, 80 unit tests pass |
| C++ package manager (`tools/kubex/`) | ✅ Complete | 27 files, ~3,300 lines, registry/auth/archive/signing/SBOM/audit, zero stubs |
| Cloudflare registry (`registry/`) | ✅ Code complete | Workers + D1 + R2, auth, admin, rate limiting; NOT deployed |
| **Self-hosted kubex.kx** | ✅ **Works** | 3,583-line monolith: lexer→parser→checker→IR text codegen + CLI dispatch |
| Self-host samples | ✅ Work | parser.kx (62KB), checker.kx (116KB), codegen.kx (138KB) — byte-for-byte parity with C++ |
| E2E parity infra | ⚠️ Partial | 11 checks, 8 pass, dies at #9 on missing std.listDir |

### ❌ Blocking Defects

| # | Issue | Impact | Difficulty |
|---|-------|--------|------------|
| B1 | `std.listDir` not implemented | E2E dies at check 9/11; build.sh exits non-zero | Trivial |
| B2 | `std.parseInt`, `std.parseDouble`, `std.system` missing | semver.kx, codegen.kx, registry/client.kx broken | Trivial |
| B3 | `--library` flag mismatch | kubex build.cpp sends `--library` → kxc doesn't recognize → treats as input path | Trivial |
| B4 | deploy.sh skips migrations 0003/0004 | Signing + SBOM tables never created | Trivial |
| B5 | codegen_tests.cpp not wired into build.sh | Codegen untested | Easy |

### 🔧 Known Bugs in kubex.kx (self-hosted)

| Bug | Location | Effect |
|-----|----------|--------|
| Missing `/` separator | CmdBuild line 3370 | Reads wrong .kxconf path |
| Wrong key lookup | CmdBuild line 3372 | `conf.Has("entry")` but keys stored as `section.key` |
| Output path mismatch | CmdBuild writes `{base}.build/`, CmdRun expects `{dir}/build/` | `kubex run` can't find binary |
| Registry commands are stubs | publish/install/search/login | Print "requires registry connection" |

---

## Architecture: Target State

```
                    ┌─────────────────────────┐
                    │   kubexic (single bin)  │
                    │                         │
   .kx files ──────▶│  Compiler (lexer→sema→  │──────▶ native binary / .so / .a
                    │  codegen→linker)        │
                    │                         │
   .kxconf ────────▶│  Package Manager        │◀─────▶ registry.kubexic.furkanlabs.tr
                    │  (resolve→fetch→build)  │         (Cloudflare Workers + R2 + D1)
                    │                         │
                    │  Written in Kubexic     │
                    │  (self-hosting)         │
                    └─────────────────────────┘
```

**Bootstrap chain:**
```
Phase 0: C++ kxc compiles kubex.kx ──▶ kubexic binary (self-hosted)
Phase 1: kubexic compiles itself ────▶ kubexic v2 (fully self-hosted)
Phase 2: kubexic publishes itself ───▶ registry (dogfooding)
```

---

## Implementation Plan

### Phase 1: Fix Blockers (Day 1)

**Goal**: Make `build.sh` pass green, unblock e2e suite.

#### Step 1.1: Add missing stdlib functions
Files to modify: `src/sema/checker.cpp`, `src/codegen/codegen.cpp`, `runtime/runtime.c`

| Function | Signature | Runtime impl |
|----------|-----------|--------------|
| `std.listDir(path)` | `(string) -> List<string>` | `opendir/readdir/closedir` |
| `std.parseInt(s)` | `(string) -> int?` | `strtol` wrapper |
| `std.parseDouble(s)` | `(string) -> double?` | `strtod` wrapper |
| `std.system(cmd)` | `(string) -> int` | `system()` |

Add to checker's std function table (~line 880), add codegen emission, add runtime functions.

#### Step 1.2: Fix --library flag mismatch
File: `tools/kxc/main.cpp`
- Add `--library` as alias for `--shared` (or make kubex stop sending it)
- Better: change `tools/kubex/build.cpp:46` to send `--shared` instead of `--library`

#### Step 1.3: Fix deploy.sh migrations
File: `registry/deploy.sh`
- Add `wrangler d1 execute ... --file=./migrations/0003_signing.sql`
- Add `wrangler d1 execute ... --file=./migrations/0004_sbom.sql`

#### Step 1.4: Wire codegen_tests.cpp into build.sh
File: `build.sh`
- Add codegen test build+run between mir tests and kxc build

#### Verification:
```bash
bash build.sh  # must exit 0
# All 11 e2e checks PASS
```

---

### Phase 2: Fix Self-Hosted kubex.kx Bugs (Day 1-2)

**Goal**: The self-hosted binary works correctly for its implemented commands.

#### Step 2.1: Fix path bugs in kubex.kx
- Line ~3370: `ParseKxConf("" + dir + ".kxconf")` → `ParseKxConf(dir + "/.kxconf")`
- Line ~3372: `conf.Has("entry")` → `conf.Has("target.entry")`
- Lines ~3422/3443: unify output path to `{project_root}/build/{output_name}`

#### Step 2.2: Implement real codegen in kubex.kx
Current state: generates LLVM IR text, shells out to `llc-21` + `gcc`.
This is acceptable for now — it produces working binaries. Improve later.

#### Step 2.3: Wire registry commands to actual HTTP calls
Current state: prints "requires registry connection".
Fix: use the same pattern as the C++ version — shell out to `curl`.

```kubexic
extern int kx_system(string cmd);  // already available via stdlib after Phase 1

var RegistrySearch(query) {
    var url = "https://registry.kubexic.furkanlabs.tr/v1/packages?q=" + query;
    var cmd = "curl -s '" + url + "'";
    // parse JSON response (simple string extraction)
}
```

#### Step 2.4: Fix keygen/sbom/audit
- keygen: keep shell-out to `openssl` (works)
- sbom: generate a simple JSON manifest of dependencies
- audit: shell-out to `osv-scanner` if installed, otherwise print warning

#### Verification:
```bash
./build/kxc build src/kubex/kubex.kx build/kubexic_selfhost
./build/kubexic_selfhost init test_proj
cd test_proj && ../build/kubexic_selfhost build && ./build/test_proj
```

---

### Phase 3: Language Features for Modular Layout (Week 1)

**Goal**: Enable the modular `.kx` files under `src/kubex/compiler/` and `src/kubex/package/` to work.

These features are ordered by difficulty. Each unlocks more of the modular code.

#### Step 3.1: String comparison operators (Easy)
Currently `<` on strings is forbidden but runtime has `kx_str_lt`.
- checker.cpp: allow comparison operators on String type
- codegen.cpp: emit `kx_str_lt/le/gt/ge` calls

Unblocks: `reproducible.kx`

#### Step 3.2: List.Contains method (Easy)
Add `Contains(value)` to List type in checker + codegen.
Runtime already has list iteration.

Unblocks: `mir.kx`

#### Step 3.3: Library-mode check (Easy)
When `--shared` or `--static` is passed, skip the "exactly one main" error.
Already partially done (`setRequireMain(false)`), but need to handle `check-dir` mode too.

Unblocks: individual module files to be checked independently

#### Step 3.4: Forward declarations (Medium)
Parser currently requires function body before use.
Fix: two-pass parsing or hoist function signatures.

Syntax: `var FunctionName(param1, param2);` (no body = forward decl)

Unblocks: `parser.kx` line 343

#### Step 3.5: Lambda/anonymous functions (Medium)
Parser doesn't support `var f = (a, b) -> { ... };`
This is syntactic sugar for named local functions.

Alternative: rewrite parser.kx to avoid lambdas (use named helper functions).

Decision needed: implement lambdas OR rewrite parser.kx?

#### Step 3.6: Pointer/opaque handle types (Hard)
The type system has NO pointer types. Needed for:
- `extern void* LLVMModuleCreateWithName(...)` in llvm_bindings.kx
- `Map<string, void*>` field types in codegen.kx
- `extern int system(const char* cmd)` in client.kx

Options:
A) Add a `handle` primitive type (opaque i64, no arithmetic)
B) Allow `void*` in extern declarations only (not in user code)
C) Use `long` everywhere and cast (current workaround in kubex.kx)

Recommendation: **Option A** — add `handle` type that maps to i64 in LLVM, prevents arithmetic, allows extern usage.

Unblocks: `llvm_bindings.kx`, `codegen.kx`, `registry/client.kx`

#### Step 3.7: Import/module system (Hardest)
Currently there's no way for one .kx file to reference declarations from another.
All code must live in one file (hence the 3,583-line kubex.kx).

Design:
```kubexic
// In file: src/kubex/compiler/lexer.kx
pub struct Token { ... }
pub var LexAll(source: string) -> List<Token> { ... }

// In file: src/kubex/compiler/parser.kx
using kubex.compiler.lexer;  // imports pub declarations from lexer.kx
var ParseProgram(tokens: List<Token>) -> ProgramNode { ... }  // uses Token, LexAll
```

Implementation approach:
1. Checker already computes namespace from file path (implemented!)
2. Checker already resolves `using` directives (implemented!)
3. Need: codegen to link cross-file references (currently each file compiled independently)

Actually, looking at the explore report: "multi-file checking half-works; it's multi-file compilation/imports that's missing"

So the fix is primarily in codegen: when compiling a directory, merge ALL parsed ASTs into a single program before codegen (like the C++ checker already does).

This might be simpler than expected since `check-dir` already merges programs.

#### Verification after Phase 3:
```bash
./build/kxc check-dir src/kubex/  # passes (all modular files valid)
./build/kxc build src/kubex/ build/kubexic_modular  # builds modular version
```

---

### Phase 4: Unified Binary (Week 2)

**Goal**: Replace separate `kxc` + `kubex` with single `kubexic` command.

#### Step 4.1: Merge C++ kubex features into kubex.kx
The C++ kubex has features the self-hosted version lacks:
- Ed25519 signing (via OpenSSL)
- SBOM generation
- Audit scanning
- Proper lockfile management
- Retry logic with exponential backoff

Port these to Kubexic using `extern` declarations where needed (OpenSSL calls via C shim).

#### Step 4.2: Single entry point
```kubexic
// main() in kubex.kx handles ALL commands:
int main() {
    // Compiler commands:
    if (cmd == "build" || cmd == "compile") { return CmdBuild(args); }
    if (cmd == "check") { return CmdCheck(args); }
    if (cmd == "run") { return CmdRun(args); }
    if (cmd == "fmt") { return CmdFmt(args); }
    
    // Package manager commands:
    if (cmd == "init" || cmd == "new") { return CmdInit(args); }
    if (cmd == "add") { return CmdAdd(args); }
    if (cmd == "remove") { return CmdRemove(args); }
    if (cmd == "publish") { return CmdPublish(args); }
    if (cmd == "install") { return CmdInstall(args); }
    if (cmd == "search") { return CmdSearch(args); }
    if (cmd == "login") { return CmdLogin(args); }
    
    // Utility commands:
    if (cmd == "tree") { return CmdTree(args); }
    if (cmd == "clean") { return CmdClean(args); }
    if (cmd == "doc") { return CmdDoc(args); }
    if (cmd == "keygen") { return CmdKeygen(args); }
    if (cmd == "sbom") { return CmdSbom(args); }
    if (cmd == "audit") { return CmdAudit(args); }
}
```

#### Step 4.3: Update build.sh
Replace both kxc and kubex targets with single kubexic target:
```bash
# Old:
g++ ... -o build/kxc tools/kxc/main.cpp ...
g++ ... -o build/kubex tools/kubex/*.cpp ...

# New:
./build/kxc build src/kubex/ build/kubexic  # self-hosted!
# Or during bootstrap:
g++ ... -o build/kubexic tools/kxc/main.cpp ...  # C++ bootstrap
```

#### Step 4.4: Backward compatibility symlinks
```bash
ln -sf kubexic ~/.local/bin/kxc    # old compiler command
ln -sf kubexic ~/.local/bin/kubex  # old package manager command
```

Both route through the same binary; subcommand determines behavior.

---

### Phase 5: Registry Deployment & Dogfooding (Week 2-3)

**Goal**: Deploy registry, publish packages using kubexic itself.

#### Step 5.1: Deploy Cloudflare registry
```bash
cd registry/
npm install
wrangler login
./deploy.sh  # creates D1, R2, runs all 4 migrations, deploys worker
```

Domain: `registry.kubexic.furkanlabs.tr` (Cloudflare DNS CNAME to workers.dev)

#### Step 5.2: Bootstrap admin account
```bash
curl -X POST https://registry.kubexic.furkanlabs.tr/v1/admin/init \
  -H "Authorization: Bearer <token>"
```

#### Step 5.3: Publish first packages
```bash
kubexic login
cd godot-kubexic/ && kubexic publish
cd kubexic/ && kubexic publish  # self-hosting achieved!
```

#### Step 5.4: Verify round-trip
```bash
mkdir test_download && cd test_download
kubexic init my_project
kubexic add godot-kubexic@^0.1.0
kubexic build
```

---

### Phase 6: Polish & Documentation (Week 3)

- Update DOCUMENTATION.md for unified kubexic binary
- Update docs site (GitHub Pages)
- Update VS Code extension to use kubexic instead of kxc
- Write migration guide for existing users
- Clean up stray artifacts from git (a.out, out.txt, etc.)
- Add integration test: full bootstrap cycle (C++ → self-hosted → self-hosted v2)

---

## Dependency Graph

```
Phase 1 (Blockers) ─────────────────────────────────────────── Day 1
    │
Phase 2 (kubex.kx fixes) ──────────────────────────────────── Day 1-2
    │
Phase 3 (Language features):
    ├── 3.1 String compare ────────────────────────────────── Day 2
    ├── 3.2 List.Contains ─────────────────────────────────── Day 2  
    ├── 3.3 Library-mode check ────────────────────────────── Day 2
    ├── 3.4 Forward declarations ──────────────────────────── Day 3
    ├── 3.5 Lambdas (or rewrite) ──────────────────────────── Day 3-4
    ├── 3.6 Handle type ───────────────────────────────────── Day 4-5
    └── 3.7 Import/module system ──────────────────────────── Day 5-7
    
Phase 4 (Unified binary) ──────────────────────────────────── Week 2
    │
Phase 5 (Registry deploy + dogfood) ───────────────────────── Week 2-3
    │
Phase 6 (Polish) ──────────────────────────────────────────── Week 3
```

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Module system harder than expected | Medium | High | Fall back to monolithic kubex.kx (already works) |
| Handle type design breaks existing code | Low | Medium | Use Option C fallback (long + casts) |
| Registry deployment blocked by domain setup | Low | Low | Use workers.dev subdomain temporarily |
| Self-hosted codegen quality insufficient | Medium | Medium | Keep C++ bootstrap path as fallback |
| OpenSSL extern bridging complex | Medium | Low | Shell-out to openssl CLI (keygen already does) |

---

## Success Criteria

- [ ] `bash build.sh` exits 0 (all tests pass)
- [ ] `kubexic build project/` produces working binary
- [ ] `kubexic build --shared lib/` produces .so
- [ ] `kubexic publish` uploads to registry.kubexic.furkanlabs.tr
- [ ] `kubexic add pkg@version` downloads and resolves deps
- [ ] `kubexic` can compile itself (self-hosting verified)
- [ ] Single binary handles all compiler + package manager commands
- [ ] E2E: C++ builds kubexic → kubexic builds itself → identical output
