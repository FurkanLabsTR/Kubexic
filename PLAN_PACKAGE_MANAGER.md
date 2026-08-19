# Kubex Package Manager — Comprehensive Implementation Plan

> **Version**: 1.0-draft
> **Status**: Design document
> **Depends on**: Kubexic compiler M8+ (done)

---

## Table of Contents

1. [.kxconf Format Specification](#1-kxconf-format-specification)
2. [kubex CLI Commands](#2-kubex-cli-commands)
3. [Compiler Changes (C++)](#3-compiler-changes-c)
4. [Package Archive Format (.kxpkg)](#4-package-archive-format-kxpkg)
5. [Registry Architecture](#5-registry-architecture-cloudflare-workers--r2--d1)
6. [kubex Tool Implementation (in Kubexic)](#6-kubex-tool-implementation-in-kubexic)
   - [6.8 Testing Framework](#68-testing-framework)
   - [6.9 Doc Comments](#69-doc-comments)
   - [6.10 Feature Flags in Code](#610-feature-flags-in-code)
   - [6.11 Backward Compatibility](#611-backward-compatibility)
   - [6.12 How kubex Finds kxc](#612-how-kubex-finds-kxc)
   - [6.13 Error Reporting](#613-error-reporting)
   - [6.14 Cross-Compilation with Dependencies](#614-cross-compilation-with-dependencies)
   - [6.15 Version Conflict Resolution](#615-version-conflict-resolution)
   - [6.16 Package Limits](#616-package-limits)
   - [6.17 glue.c Specifics](#617-gluec-specifics)
   - [6.18 Samples to Packages](#618-samples-to-packages)
   - [6.19 Build Optimization Flags](#619-build-optimization-flags)
7. [Implementation Phases](#7-implementation-phases)

---

## 1. .kxconf Format Specification

### 1.1 Design Principles

- Custom INI-like format, NOT YAML/TOML/JSON — parsed by a hand-written Kubexic parser
- Human-readable, easy to write by hand, easy to diff in version control
- Every key is a flat identifier; values are strings, integers, booleans, or lists
- Comments with `//` (same as Kubexic source)
- No nested objects — use dotted key names for hierarchy

### 1.2 Complete Syntax Specification

```
// .kxconf — Kubexic project manifest
// Lines starting with // are comments
// Blank lines are ignored

// ============================================================
// SECTION: [package] — Required for every project
// ============================================================
[package]
name = "my-game"                    // package name (required)
version = "0.1.0"                   // semver (required)
description = "A Kubexic game"      // short description (optional)
license = "MIT"                     // SPDX identifier (optional)
author = "Your Name <you@email.com>" // optional
repository = "https://github.com/user/repo" // optional

// ============================================================
// SECTION: [target] — What this project produces
// ============================================================
[target]
kind = "binary"                     // "binary" | "library"
entry = "main.kx"                   // entry point (required for binary)
output = "my-game"                  // output binary/library name (optional)

// Library-specific options:
// kind = "library"
// libtype = "shared"               // "shared" (.so) | "static" (.a) (default: shared)

// ============================================================
// SECTION: [build] — Build configuration
// ============================================================
[build]
target = "x86_64-linux-gnu"         // target triple (default: host)
optimization = "release"            // "debug" | "release" | "size"
fast_math = false                   // default: false (IEEE-754 strict)
cores = 0                           // 0 = auto (default), or fixed box count

// Source directories to compile (default: current directory)
// Sources = ["src"]

// Directories to exclude from compilation
// exclude = ["tests", "vendor"]

// ============================================================
// SECTION: [features] — Optional compile-time features
// ============================================================
[features]
// Default feature set (enabled unless --no-default-features)
default = ["rendering", "audio"]

// Feature definitions
[features.rendering]
description = "Enable rendering support"
// Dependencies that are only pulled in when this feature is active
// deps = ["kx-gl"]

[features.audio]
description = "Enable audio support"
// deps = ["kx-audio"]

[features.networking]
description = "Multiplayer support"
// deps = ["kx-net"]

// ============================================================
// SECTION: [dependencies] — Kubexic packages from registry
// ============================================================
[dependencies]
// name = "version requirement"
// Version requirements follow semver ranges:
//   "1.2.3"    — exact version
//   "^1.2.3"   — compatible with 1.2.3 (>=1.2.3, <2.0.0)
//   "~1.2.3"   — approximately 1.2.3 (>=1.2.3, <1.3.0)
//   ">=1.2.0"  — minimum version
//   "*"        — any version (not recommended)
//   "1.x"      — major version range
kx-spatial = "^0.3.0"
kx-math = "^0.2.0"

// Conditional dependencies (only when feature is active)
[dependencies.rendering]
// kx-gl = "^1.0.0"

[dependencies.networking]
// kx-net = "^0.1.0"

// ============================================================
// SECTION: [dev-dependencies] — Only for tests, not in library output
// ============================================================
[dev-dependencies]
// kx-test = "^0.1.0"

// ============================================================
// SECTION: [native] — C/C++ dependencies to link
// ============================================================
[native]
// System libraries (adds -l flags)
// libs = ["m", "pthread", "GL"]

// Include directories (for extern declarations with custom headers)
// include_dirs = ["/usr/include/GL"]

// Library search paths
// link_dirs = ["/usr/lib/custom"]

// ============================================================
// SECTION: [workspace] — For multi-project repos (optional)
// ============================================================
[workspace]
members = ["packages/*"]
// resolver = "2"                    // future: workspace dependency resolver

// ============================================================
// SECTION: [publish] — Registry publishing configuration
// ============================================================
[publish]
registry = "https://registry.kubex.dev"  // default registry
// exclude = ["tests", "samples", ".git"]  // files excluded from .kxpkg
// include = ["src", ".kxconf", "README.md"]

// ============================================================
// SECTION: [test] — Test configuration
// ============================================================
[test]
// test_dir = "tests"                // where test files live
// test_pattern = "*_test.kx"        // file naming convention
```

### 1.3 Minimal .kxconf

The absolute minimum to create a valid project:

```
[package]
name = "hello"
version = "0.1.0"

[target]
kind = "binary"
entry = "main.kx"
```

### 1.4 .kxconf Parser Data Structures (Kubexic)

```csharp
// .kxconf data model (kxconf.kx)
struct KxConf {
    var package = PackageMeta();
    var target = TargetConfig();
    var build = BuildConfig();
    var deps = Map<string, string>();           // name -> version req
    var dev_deps = Map<string, string>();
    var native_libs = List<string>();
    var features = Map<string, FeatureDef>();
    var workspace = WorkspaceConfig();
    var publish = PublishConfig();
}

struct PackageMeta {
    var name = "";
    var version = "";
    var description = "";
    var license = "";
    var author = "";
    var repository = "";
}

struct TargetConfig {
    var kind = "binary";           // "binary" | "library"
    var entry = "main.kx";
    var output = "";
    var libtype = "shared";        // "shared" | "static"
}

struct BuildConfig {
    var target = "";               // target triple, empty = host
    var optimization = "release";
    var fast_math = false;
    var cores = 0;
}

struct FeatureDef {
    var description = "";
    var deps = List<string>();
}

struct WorkspaceConfig {
    var members = List<string>();
}

struct PublishConfig {
    var registry = "https://registry.kubex.dev";
    var exclude = List<string>();
    var include = List<string>();
}
```

### 1.5 .kxconf Parser Implementation

The parser is a simple recursive-descent parser operating on the token stream. The lexer reuses the same token kinds as the main Kubexic lexer but operates on the INI-like format.

```
Grammar (informal):
  file        = section*
  section     = '[' name ']' NL entry*
  entry       = name '=' value NL
  value       = string | integer | boolean | list
  list        = '[' (value (',' value)*)? ']'
  string      = '"' chars '"' | bareword
  bareword    = [a-zA-Z0-9_./:*\^~><=+-]+
  integer     = digit+
  boolean     = 'true' | 'false'
  name        = [a-zA-Z_][a-zA-Z0-9_.-]*
  comment     = '//' rest-of-line
  NL          = newline
```

File path: `tools/kubex/kxconf_parser.kx`

---

## 2. kubex CLI Commands

### 2.1 Command Overview

```
kubex <command> [options] [arguments]

Commands:
  init        Create a new project with .kxconf and starter files
  add         Add a dependency to .kxconf
  remove      Remove a dependency from .kxconf
  build       Compile the project (and its dependencies)
  run         Build and immediately execute
  test        Run test suite
  publish     Publish package to the registry
  install     Install a binary package from registry
  search      Search the registry
  doc         Generate documentation from source
  tree        Display dependency tree
  update      Update dependencies to latest compatible versions
  cache       Manage the local package cache
  fmt         Format source files
  check       Run semantic checks without building
  info        Show information about a package
  login       Authenticate with the registry
  logout      Deauthenticate from the registry
  publish-as  Publish under a different name (for forks)
  version     Show or bump version
  verify      Verify .kxpkg signature
```

### 2.2 Command Specifications

#### `kubex init`

```
kubex init [options] [directory]
```

Creates a new project in the given directory (or current directory).

| Option | Description |
|--------|-------------|
| `--name <name>` | Project name (default: directory name) |
| `--template <tmpl>` | Template: `binary` (default), `library`, `ecs-game` |
| `--license <spdx>` | License identifier |

Generated files for `--template binary`:

```
<directory>/
  .kxconf              # project manifest
  main.kx              # entry point
  Counter.kx           # sample component
  CountSystem.kx       # sample system
  README.md            # project readme
```

Generated `.kxconf`:

```
[package]
name = "<name>"
version = "0.1.0"
description = ""
license = "MIT"

[target]
kind = "binary"
entry = "main.kx"
output = "<name>"

[build]
optimization = "release"
```

Generated for `--template library`:

```
<directory>/
  .kxconf              # kind = "library"
  lib.kx               # placeholder
  README.md
```

#### `kubex add`

```
kubex add <package-spec> [options]
```

Adds a dependency to `[dependencies]` in `.kxconf` and resolves it.

| Argument | Format |
|----------|--------|
| `<package-spec>` | `name` or `name@version-req` (e.g. `kx-spatial`, `kx-spatial@^0.3.0`) |

| Option | Description |
|--------|-------------|
| `--dev` | Add to `[dev-dependencies]` instead |
| `--feature <name>` | Add as conditional dependency under `[dependencies.<feature>]` |
| `--registry <url>` | Use a non-default registry |
| `--no-resolve` | Add to .kxconf but don't download yet |

**Behavior:**
1. Find project root (search upward for `.kxconf`)
2. Parse `.kxconf`
3. Resolve version from registry (or use pinned version if given)
4. Add to `.kxconf` in the appropriate section
5. Download `.kxpkg` to cache
6. Extract to `.kubex/cache/<name>-<version>/`
7. Print dependency tree

#### `kubex remove`

```
kubex remove <package-name> [options]
```

| Option | Description |
|--------|-------------|
| `--dev` | Remove from dev-dependencies |
| `--feature <name>` | Remove from feature-specific dependencies |
| `--purge` | Also delete from cache |

**Behavior:**
1. Remove from `.kxconf`
2. Recalculate lock file (see `kubex.lock`)
3. Optionally purge from cache

#### `kubex build`

```
kubex build [options] [directory]
```

| Option | Description |
|--------|-------------|
| `--target <triple>` | Cross-compile for target |
| `--features <f1,f2>` | Enable specific features |
| `--no-default-features` | Disable default features |
| `--release` | Force release optimization (default) |
| `--debug` | Force debug build |
| `--lib` | Build as library (.so / .a) |
| `--output <path>` | Custom output path |
| `--verbose` | Show compiler invocation details |
| `--jobs <n>` | Parallel compilation jobs |

**Build pipeline:**

```
1.  Find project root (.kxconf)
2.  Parse .kxconf
3.  Load kubex.lock (or create if absent)
4.  Resolve dependency graph
5.  For each dependency not in cache:
      a. Download .kxpkg from registry
      b. Verify signature
      c. Extract to .kubex/cache/<name>-<version>/
6.  Compute compilation order (topological sort)
7.  For each dependency:
      a. If .so/.a exists in cache, skip (pre-compiled)
      b. If source-only, compile to .so in cache
8.  Collect source files:
      - All .kx files in project directory (recursive)
      - Exclude: .kubex/, vendor/, test dirs
9.  Compile project sources with dependency .so files on link path
10. Link: project.o + dependency .so files + runtime.o + native libs
11. Output final binary or library
```

**How `kubex build` calls `kxc`:**

```bash
kxc build <source-dir> \
  --deps-dir .kubex/cache/ \
  --dep kx-spatial:0.3.2 \
  --dep kx-math:0.2.1 \
  --link-dir .kubex/cache/kx-spatial-0.3.2/lib/ \
  --output <output-path>
```

#### `kubex run`

```
kubex run [options] [directory] [-- <args>]
```

Same as `kubex build` then execute the binary. Extra arguments after `--` are forwarded.

| Option | Description |
|--------|-------------|
| All `kubex build` options | |
| `--args <args>` | Arguments to pass to the binary (alternative to `--`) |

#### `kubex test`

```
kubex test [options] [directory]
```

| Option | Description |
|--------|-------------|
| `--filter <pattern>` | Run only tests matching pattern |
| `--list` | List available tests without running |
| `--verbose` | Show test names as they run |

**Behavior:**
1. Find all `*_test.kx` or `test_*.kx` files
2. Build with `--features test` if defined
3. Execute with test harness that collects results
4. Print pass/fail summary

**Test file convention:**

```csharp
// add_test.kx
import kx-test;  // test framework (provides test(), assert_eq(), etc.)

test("addition works") {
    assert_eq(2 + 2, 4);
}

test("string interpolation") {
    var name = "kubex";
    assert_eq($"hello {name}", "hello kubex");
}
```

The test harness is a `kx-test` library that provides:
- `test(name, body)` — register and run a test
- `assert_eq(a, b)` — equality assertion
- `assert_true(cond)` — boolean assertion
- `assert_false(cond)` — boolean assertion
- `assert_panics(body)` — expect a panic

#### `kubex publish`

```
kubex publish [options]
```

| Option | Description |
|--------|-------------|
| `--dry-run` | Show what would be published without uploading |
| `--registry <url>` | Target a specific registry |
| `--tag <tag>` | Tag this release |
| `--allow-dirty` | Publish even with uncommitted changes |
| `--token <token>` | Auth token (alternative to `kubex login`) |

**Behavior:**
1. Verify `.kxconf` has name + version
2. Verify version doesn't already exist in registry (unless `--force`)
3. Collect source files (respecting `[publish]` include/exclude)
4. Compile sources to verify they compile
5. Build `.kxpkg` archive (see Section 4)
6. Sign the archive with the user's key (see Section 4.3)
7. Upload to registry API
8. Print published URL

#### `kubex install`

```
kubex install <package> [options]
```

Installs a binary package (pre-compiled) to `~/.kubex/bin/`.

| Option | Description |
|--------|-------------|
| `--version <ver>` | Install specific version |
| `--prefix <dir>` | Install to custom directory |
| `--force` | Reinstall even if already installed |

**Behavior:**
1. Query registry for package
2. Download pre-compiled binary `.kxpkg` (or binary release)
3. Verify signature
4. Extract to `~/.kubex/bin/<package-name>`
5. Add to PATH (print instructions)

#### `kubex search`

```
kubex search <term> [options]
```

| Option | Description |
|--------|-------------|
| `--limit <n>` | Max results (default: 20) |
| `--sort <field>` | Sort by: `relevance` (default), `downloads`, `updated`, `name` |

**Output format:**

```
Found 3 packages for "spatial":

  kx-spatial ^0.3.2   Spatial queries for ECS (234 downloads)
    Grid-based spatial hashing for Kubexic. Near/Overlap queries.

  kx-collision ^0.1.0  Collision detection (89 downloads)
    AABB and sphere collision using kx-spatial.

  kx-navmesh ^0.0.3    Pathfinding (12 downloads)
    Navmesh-based pathfinding on top of kx-spatial.
```

#### `kubex doc`

```
kubex doc [options] [directory]
```

| Option | Description |
|--------|-------------|
| `--output <dir>` | Output directory (default: `doc/`) |
| `--format <fmt>` | Output format: `html` (default), `md`, `json` |
| `--private` | Include non-pub declarations |

**Behavior:**
1. Parse all `.kx` files
2. Extract doc comments (`///` lines above declarations)
3. Build documentation graph
4. Output to specified format

#### `kubex tree`

```
kubex tree [options] [directory]
```

**Output:**

```
my-game@0.1.0
├── kx-spatial@0.3.2
│   └── kx-math@0.2.0
├── kx-audio@0.1.0
│   └── (no dependencies)
└── kx-test@0.1.0 [dev]
```

| Option | Description |
|--------|-------------|
| `--depth <n>` | Maximum depth |
| `--dev` | Include dev-dependencies |

#### `kubex update`

```
kubex update [options] [package]
```

| Option | Description |
|--------|-------------|
| `--dry-run` | Show what would be updated |
| `--breaking` | Allow major version bumps |

**Behavior:**
1. If no package specified: update all dependencies
2. For each dependency, find latest compatible version
3. Update `.kxconf` version requirements
4. Download new versions to cache
5. Update `kubex.lock`

#### `kubex cache`

```
kubex cache <subcommand> [options]

Subcommands:
  list      List cached packages
  clean     Remove all cached packages
  remove    Remove a specific cached package
  size      Show cache size
  path      Show cache directory path
```

#### `kubex login`

```
kubex login [options]
```

Opens browser for OAuth flow, or accepts token directly.

| Option | Description |
|--------|-------------|
| `--token <token>` | Provide token directly |
| `--registry <url>` | Login to a specific registry |

Stores credentials in `~/.kubex/credentials.toml` (not `.kxconf`-format for security).

#### `kubex fmt`

```
kubex fmt [options] [file-or-directory]
```

| Option | Description |
|--------|-------------|
| `--check` | Exit 1 if any files would be changed |
| `--diff` | Show formatting changes |

Delegates to `kxc fmt` / `kxc fmt-dir` under the hood.

#### `kubex check`

```
kubex check [options] [directory]
```

| Option | Description |
|--------|-------------|
| `--all` | Check including dependencies |
| `--fix` | Auto-fix where possible |

Delegates to `kxc check-dir`.

#### `kubex info`

```
kubex info <package> [options]
```

**Output:**

```
kx-spatial 0.3.2
  Description: Spatial queries for ECS
  Author: slyrebula
  License: MIT
  Repository: https://github.com/slyrebula/kx-spatial
  Downloads: 234 (last 30 days)
  Dependencies: kx-math ^0.2.0
  Published: 2026-08-15
  Latest: 0.3.2
  Versions: 0.0.1, 0.0.2, ..., 0.3.2
```

#### `kubex version`

```
kubex version [options] [new-version]
```

| Subcommand | Description |
|------------|-------------|
| (no args) | Print current version from .kxconf |
| `major` | Bump major version |
| `minor` | Bump minor version |
| `patch` | Bump patch version |
| `<semver>` | Set to specific version |

### 2.3 Project Root Detection

The `kubex` CLI searches upward from the current directory for `.kxconf`:

```
fn find_project_root() -> Option<string> {
    var dir = std.current_dir();
    while (true) {
        if (std.path_exists(dir + "/.kxconf")) {
            return dir;
        }
        var parent = std.parent_dir(dir);
        if (parent == dir) {       // reached filesystem root
            return None;
        }
        dir = parent;
    }
}
```

### 2.4 Lock File (`kubex.lock`)

Generated alongside `.kxconf` after resolution. Records exact resolved versions.

```
# This file is auto-generated by kubex. Do not edit manually.
# Run `kubex update` to regenerate.

version = 1

[[package]]
name = "kx-spatial"
version = "0.3.2"
source = "registry+https://registry.kubex.dev"
checksum = "sha256:a1b2c3d4..."

[[package]]
name = "kx-math"
version = "0.2.1"
source = "registry+https://registry.kubex.dev"
checksum = "sha256:e5f6a7b8..."
```

The lock file uses the same `.kxconf`-style format (reusing the parser).

---

## 3. Compiler Changes (C++)

The C++ compiler (`kxc`) needs four major changes to support the package manager:

### 3.1 Namespace Resolution

**Current state:**
- `Program::namespaceName` is set by the parser but never used by the checker
- `Program::usings` is parsed and stored but the checker ignores them
- All declarations go into flat global maps in `Checker`

**Target state:**
- File path relative to source root becomes the namespace: `src/combat/Damage.kx` → namespace `combat`
- Declarations are stored in a namespace-qualified map: `combat.Damage`
- `using combat;` makes `combat.Damage`, `combat.DamageSystem` available unqualified
- `using combat.Damage;` makes just `Damage` available unqualified

**Changes to `src/ast/ast.h`:**

```cpp
// Program gains a source-relative path
struct Program {
  std::string file;
  std::string sourceRoot;       // NEW: the root directory from which files are collected
  std::string namespaceName;     // NOW COMPUTED: relative dir path, dots as separators
  std::vector<std::string> usings;
  std::vector<Decl> decls;
};
```

**Changes to `src/sema/checker.h`:**

```cpp
class Checker {
 public:
  void addProgram(std::unique_ptr<Program> program);
  void setSourceRoot(const std::string& root);  // NEW

 private:
  // NEW: namespace-qualified declarations
  // Key: "namespace.name" e.g. "combat.Damage"
  std::map<std::string, const Decl*> components_;
  std::map<std::string, const Decl*> systems_;
  std::map<std::string, const Decl*> tags_;
  std::map<std::string, const Decl*> structs_;
  std::map<std::string, const Decl*> enums_;
  std::map<std::string, std::vector<const Decl*>> functions_;
  std::map<std::string, ConstValue> consts_;

  // NEW: active using directives (set of imported namespace prefixes)
  std::vector<std::string> activeUsings_;

  // NEW: qualified name resolution
  std::string currentNamespace_;
  std::string resolveName(const std::string& name) const;
  void pushUsing(const std::string& ns);
  void popUsing();
};
```

**Resolution algorithm:**

```cpp
// resolveName searches in this order:
// 1. Current namespace + name (e.g. "combat.Damage")
// 2. Each active using namespace + name (e.g. "physics.Vec3")
// 3. Global scope (no namespace prefix) + name (e.g. "Damage")
std::string Checker::resolveName(const std::string& name) const {
    // 1. Qualified name in current namespace
    std::string qualified = currentNamespace_.empty()
        ? name : currentNamespace_ + "." + name;
    if (components_.count(qualified) || systems_.count(qualified) ||
        structs_.count(qualified) || /* ... */ true) {
        return qualified;
    }

    // 2. Search active usings
    for (const auto& ns : activeUsings_) {
        std::string q = ns + "." + name;
        if (components_.count(q) || systems_.count(q) ||
            structs_.count(q) || /* ... */ true) {
            return q;
        }
    }

    // 3. Global (unnamespaced)
    if (components_.count(name) || systems_.count(name) ||
        structs_.count(name) || /* ... */ true) {
        return name;
    }

    return "";  // not found
}
```

**Changes to `tools/kxc/main.cpp`:**

```cpp
// In collectKxFiles, compute namespace from relative path:
std::string pathToNamespace(const std::string& filePath,
                            const std::string& sourceRoot) {
    std::string rel = std::filesystem::relative(filePath, sourceRoot);
    std::string dir = std::filesystem::path(rel).parent_path().string();
    std::replace(dir.begin(), dir.end(), '/', '.');
    std::replace(dir.begin(), dir.end(), '\\', '.');
    if (dir == ".") return "";
    return dir;
}

// When adding programs to checker:
for (const auto& file : collectKxFiles(path)) {
    auto program = parseOne(readFile(file), file);
    if (!program) return 1;
    program->sourceRoot = path;
    program->namespaceName = pathToNamespace(file, path);
    checker.addProgram(std::move(program));
}
```

**Handling `using` in the checker:**

```cpp
void Checker::addProgram(std::unique_ptr<Program> program) {
    // Set namespace for this program's declarations
    currentNamespace_ = program->namespaceName;

    // Process using directives
    for (const auto& ns : program->usings) {
        pushUsing(ns);
    }

    // Declare all names in their namespace
    for (const auto& d : program->decls) declare(d);

    // Pop usings
    for (size_t i = 0; i < program->usings.size(); i++) popUsing();

    currentNamespace_ = "";
    programs_.push_back(std::move(program));
}
```

### 3.2 Library Output Mode (.so)

**Current state:**
- `Codegen` only has `emitObject()` and `emitExecutable()`
- No shared library support

**Target state:**
- New method `emitSharedLibrary()` that produces a `.so` file
- Symbol visibility controlled by `pub` keyword
- A symbol table file (`exports.kx`) is auto-generated for linking

**Changes to `src/codegen/codegen.h`:**

```cpp
class Codegen {
 public:
  bool emitObject(const std::string& objectPath);
  bool emitExecutable(const std::string& objectPath, const std::string& runtimeObject,
                      const std::string& outputPath, const std::string& crossCompiler = "gcc");
  // NEW: emit shared library
  bool emitSharedLibrary(const std::string& objectPath,
                         const std::string& runtimeObject,
                         const std::string& outputPath,
                         const std::string& soname,
                         const std::string& crossCompiler = "gcc");
  // NEW: emit static archive
  bool emitStaticLibrary(const std::string& objectPath,
                         const std::string& outputPath,
                         const std::string& archiver = "ar");
};
```

**Implementation of `emitSharedLibrary`:**

```cpp
bool Codegen::emitSharedLibrary(const std::string& objectPath,
                                const std::string& runtimeObject,
                                const std::string& outputPath,
                                const std::string& soname,
                                const std::string& crossCompiler) {
    if (!emitObject(objectPath)) return false;

    // Build shared library link command
    std::string cmd = crossCompiler + " -shared "
        + objectPath + " "
        + runtimeObject + " "
        + "-lpthread -lm "
        + "-Wl,-soname," + soname + " "
        + "-o " + outputPath;

    // Add dependency libraries
    for (const auto& lib : linkLibraries()) cmd += " -l" + lib;
    for (const auto& dir : linkDirs()) cmd += " -L" + dir;

    int rc = std::system(cmd.c_str());
    if (rc != 0) {
        errors_.push_back("codegen: shared library linking failed");
        return false;
    }

    // Generate export symbol list
    // (only pub symbols and their transitive dependencies)
    generateExports(outputPath + ".exports");

    return true;
}
```

### 3.3 Visibility Modifiers (`pub` keyword)

**Current state:**
- No access modifiers (spec says "everything visible project-wide in v0")
- Need `pub` for library boundaries

**Target:**
- All declarations default to `pub` for backward compatibility in binary projects
- In library projects, only `pub` declarations are exported

**Lexer change (`src/lexer/lexer.cpp`):**

```cpp
// Add to keyword map:
{"pub", TokenKind::KwPub},
```

**Parser change (`src/parser/parser.cpp`):**

```cpp
// In parseTopLevel(), before parsing declarations:
if (check(TokenKind::KwPub)) {
    advance();  // consume 'pub'
    // Parse the declaration normally, mark it as public
    Decl d = parseTopLevel();
    d.isPublic = true;
    return d;
}
```

**AST change (`src/ast/ast.h`):**

```cpp
struct Decl {
    // ... existing fields ...
    bool isPublic = true;  // NEW: default public for backward compat
};
```

**Codegen change:**

For shared libraries, non-pub declarations get `internal` linkage:

```cpp
void Codegen::emitFunction(const Decl& d,
                           const std::vector<std::shared_ptr<Type>>& paramTypes) {
    // ... existing code ...

    // NEW: visibility
    llvm::GlobalValue::LinkageTypes linkage = d.isPublic
        ? llvm::GlobalValue::ExternalLinkage
        : llvm::GlobalValue::InternalLinkage;

    auto fn = llvm::Function::Create(ft, linkage, mangledName, *module_);
    // ...
}
```

### 3.4 Dependency Linking

**Current state:**
- `emitExecutable()` links `objectPath + runtimeObject -lpthread -lm`
- No mechanism to link pre-compiled dependencies

**Target state:**
- The compiler accepts a list of `.so` / `.a` files and include paths via new CLI flags
- Pre-compiled dependency objects are linked in

**New CLI flags for `kxc`:**

```
kxc build [options] <dir> [output]
  --deps-dir <path>       Directory containing pre-compiled dependency libraries
  --dep <name>:<version>  Add a specific dependency (name and resolved version)
  --link-dir <path>       Additional library search path
  --lib-name <name>       Library to link (-l<name>)
  --include-dir <path>    Additional include search path
  --shared                Output a shared library (.so) instead of executable
  --static                Output a static library (.a)
  --soname <name>         SONAME for shared library output
```

**Changes to `tools/kxc/main.cpp`:**

```cpp
struct DepInfo {
    std::string name;
    std::string version;
    std::string libDir;  // path to .so/.a files
};

struct BuildOptions {
    std::string sourceDir;
    std::string output;
    std::string targetTriple;
    std::vector<DepInfo> deps;
    std::vector<std::string> linkDirs;
    std::vector<std::string> includeDirs;
    std::vector<std::string> libNames;
    bool sharedMode = false;
    bool staticMode = false;
    std::string soname;
};

// Parse new flags:
// --deps-dir .kubex/cache/
// --dep kx-spatial:0.3.2
// --dep kx-math:0.2.1
// --link-dir .kubex/cache/kx-spatial-0.3.2/lib/
// --shared
```

**Changes to `src/codegen/codegen.cpp` — `emitExecutable`:**

```cpp
bool Codegen::emitExecutable(const std::string& objectPath,
                             const std::string& runtimeObject,
                             const std::string& outputPath,
                             const std::string& crossCompiler) {
    if (!emitObject(objectPath)) return false;

    std::string cmd = crossCompiler + " " + objectPath + " " + runtimeObject + " -lpthread -lm";

    // Existing: link libraries from [Link] attributes
    for (const auto& lib : linkLibraries()) cmd += " -l" + lib;

    // NEW: link pre-compiled dependency .so files
    for (const auto& depObj : depObjects_) {
        cmd += " " + depObj;
    }

    // NEW: add extra link directories
    for (const auto& dir : extraLinkDirs_) {
        cmd += " -L" + dir;
    }

    // NEW: add extra library names
    for (const auto& lib : extraLibs_) {
        cmd += " -l" + lib;
    }

    cmd += " -o " + outputPath;
    int rc = std::system(cmd.c_str());
    if (rc != 0) {
        errors_.push_back("codegen: linking failed");
        return false;
    }
    return true;
}
```

### 3.5 How kubex Calls the Compiler

The `kubex` tool is written in Kubexic (see Section 6). It calls the C++ compiler (`kxc`) as a subprocess:

```csharp
// Pseudocode for kubex build
fn invoke_compiler(opts: BuildOptions) -> Result<(), string> {
    var cmd = "kxc build";

    // Source directory
    cmd += " " + opts.source_dir;

    // Output
    if (opts.output != "") {
        cmd += " " + opts.output;
    }

    // Target triple
    if (opts.target != "") {
        cmd += " --target " + opts.target;
    }

    // Dependencies
    for (var dep in opts.deps) {
        cmd += " --dep " + dep.name + ":" + dep.version;
        cmd += " --link-dir " + dep.lib_dir;
    }

    // Shared library mode
    if (opts.shared) {
        cmd += " --shared";
        cmd += " --soname " + opts.soname;
    }

    var exit_code = std.system(cmd);
    if (exit_code != 0) {
        return Err("compiler failed with exit code " + exit_code);
    }
    return Ok(());
}
```

The `extern` declarations for system calls used by kubex:

```csharp
// std.system(cmd) — run a shell command
extern int system(const char* cmd);

// std.current_dir() — get working directory
extern char* getcwd(char* buf, int size);
```

### 3.6 Summary of C++ File Changes

| File | Changes |
|------|---------|
| `src/lexer/lexer.cpp` | Add `pub` keyword |
| `src/ast/ast.h` | Add `Decl::isPublic`, `Program::sourceRoot` |
| `src/parser/parser.cpp` | Parse `pub` prefix on declarations |
| `src/sema/checker.h` | Namespace-qualified maps, `using` resolution, `resolveName()` |
| `src/sema/checker.cpp` | Implement namespace resolution, using directives |
| `src/codegen/codegen.h` | `emitSharedLibrary()`, `emitStaticLibrary()`, dep storage |
| `src/codegen/codegen.cpp` | Implement shared lib output, visibility, dep linking |
| `tools/kxc/main.cpp` | New CLI flags, namespace computation, build options struct |

---

## 4. Package Archive Format (.kxpkg)

### 4.1 Design Goals

- Self-contained: everything needed to use the package
- Deterministic: same source always produces the same archive
- Verifiable: cryptographic signatures for authenticity
- Simple: standard tar+gzip, not a custom binary format

### 4.2 .kxpkg Structure

A `.kxpkg` is a **gzip-compressed tar archive** with a specific internal layout:

```
package-name-version.kxpkg (gzip'd tar)
│
├── .kxmanifest              # Machine-readable manifest (JSON)
├── .kxchecksums             # SHA-256 checksums for all files
├── .kxsignature             # Ed25519 signature of .kxchecksums
│
├── src/                     # Source files
│   ├── main.kx
│   ├── components/
│   │   ├── Health.kx
│   │   └── Damage.kx
│   └── systems/
│       └── DamageSystem.kx
│
├── lib/                     # Pre-compiled libraries (optional, for binary pkgs)
│   ├── x86_64-linux-gnu/
│   │   └── libkx-spatial.so
│   └── aarch64-linux-gnu/
│       └── libkx-spatial.so
│
└── README.md                # Documentation (optional)
```

### 4.3 Signing and Verification

**Key types:**
- Package signing key: Ed25519 keypair, per-package
- Registry key: Ed25519 keypair, for the registry server

**Signing workflow:**

```
1. Publisher generates .kxchecksums:
   sha256(src/main.kx) = abc123...
   sha256(src/Health.kx) = def456...

2. Publisher signs .kxchecksums with their package key:
   .kxsignature = Ed25519_Sign(package_private_key, .kxchecksums_bytes)

3. Registry verifies:
   a. Fetch registry public key
   b. Verify .kxsignature against .kxchecksums
   c. Verify each file's checksum matches .kxchecksums
   d. Store the package key's public key as the package's "trusted publisher"
```

**Key management:**
- Keys stored in `~/.kubex/keys/<package-name>/`
- `~/.kubex/keys/<package-name>/key.pub` — public key (shared with registry on first publish)
- `~/.kubex/keys/<package-name>/key.priv` — private key (never leaves machine)

### 4.4 .kxmanifest Format

```json
{
  "version": 1,
  "name": "kx-spatial",
  "version_str": "0.3.2",
  "description": "Spatial queries for ECS",
  "author": "slyrebula",
  "license": "MIT",
  "repository": "https://github.com/slyrebula/kx-spatial",
  "kind": "library",
  "libtype": "shared",
  "kubexic_version": ">=0.8.0",
  "dependencies": {
    "kx-math": "^0.2.0"
  },
  "features": {},
  "native": {
    "libs": [],
    "include_dirs": [],
    "link_dirs": []
  },
  "targets": ["x86_64-linux-gnu", "aarch64-linux-gnu"],
  "published_at": "2026-08-15T12:00:00Z",
  "publisher_key": "ed25519:abc123..."
}
```

### 4.5 .kxchecksums Format

```
# kx-spatial-0.3.2 checksums
# Algorithm: SHA-256
sha256:a1b2c3d4e5f6... src/main.kx
sha256:b2c3d4e5f6a7... src/components/Pos3.kx
sha256:c3d4e5f6a7b8... src/spatial/Grid.kx
sha256:d4e5f6a7b8c9... .kxmanifest
```

### 4.6 Archive Creation (in Kubexic)

```csharp
// Build .kxpkg from a project directory
fn build_package(project_dir: string, output_path: string) -> Result<(), string> {
    var manifest = load_kxconf(project_dir);
    var files = collect_source_files(project_dir, manifest.publish.exclude);

    // 1. Compute checksums
    var checksums = Map<string, string>();
    for (var file in files) {
        var content = std.read_file(project_dir + "/" + file);
        var hash = std.sha256(content);
        checksums.Set(file, hash);
    }

    // 2. Write .kxmanifest
    var manifest_json = serialize_manifest(manifest);
    std.write_file(output_path + "/.kxmanifest", manifest_json);

    // 3. Write .kxchecksums
    var cs_content = format_checksums(checksums);
    std.write_file(output_path + "/.kxchecksums", cs_content);

    // 4. Sign
    var key = load_signing_key(manifest.package.name);
    var sig = std.ed25519_sign(key.priv, cs_content);
    std.write_file(output_path + "/.kxsignature", base64_encode(sig));

    // 5. Create tar.gz
    std.system("tar czf " + output_path + ".kxpkg -C " + output_path + " .");

    return Ok(());
}
```

### 4.7 Archive Extraction

```csharp
fn extract_package(pkg_path: string, dest_dir: string) -> Result<(), string> {
    // 1. Extract tar.gz
    std.system("tar xzf " + pkg_path + " -C " + dest_dir);

    // 2. Read checksums
    var cs = std.read_file(dest_dir + "/.kxchecksums");
    var expected = parse_checksums(cs);

    // 3. Verify each file
    for (var [file, expected_hash] in expected) {
        var actual = std.sha256(std.read_file(dest_dir + "/" + file));
        if (actual != expected_hash) {
            return Err("checksum mismatch for " + file);
        }
    }

    // 4. Verify signature
    var sig = base64_decode(std.read_file(dest_dir + "/.kxsignature"));
    var manifest = parse_manifest(std.read_file(dest_dir + "/.kxmanifest"));
    var key = lookup_publisher_key(manifest.publisher_key);
    if (!std.ed25519_verify(key, cs, sig)) {
        return Err("invalid signature");
    }

    return Ok(());
}
```

---

## 5. Registry Architecture (Cloudflare Workers + R2 + D1)

### 5.1 Overview

```
┌─────────────────────────────────────────────────────┐
│                    CDN (Cloudflare)                  │
│                                                     │
│  ┌──────────────┐    ┌──────────────────────────┐   │
│  │   Workers    │    │          R2              │   │
│  │  (API + Auth)│───▶│  .kxpkg file storage     │   │
│  │              │    │  versioned by path:       │   │
│  │              │    │  pkgs/<name>/<ver>/pkg    │   │
│  └──────┬───────┘    └──────────────────────────┘   │
│         │                                           │
│  ┌──────▼───────┐                                   │
│  │     D1       │                                   │
│  │  (SQLite)    │                                   │
│  │  packages    │                                   │
│  │  versions    │                                   │
│  │  users       │                                   │
│  │  downloads   │                                   │
│  └──────────────┘                                   │
└─────────────────────────────────────────────────────┘
```

### 5.2 API Endpoints

Base URL: `https://registry.kubex.dev/v1`

#### Package Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/packages?q=<term>&sort=<field>&limit=<n>` | Search packages |
| `GET` | `/packages/:name` | Get package info |
| `GET` | `/packages/:name/versions` | List all versions |
| `GET` | `/packages/:name/:version` | Get version info |
| `GET` | `/packages/:name/:version/download` | Download .kxpkg |
| `PUT` | `/packages/:name` | Create package (auth required) |
| `PUT` | `/packages/:name/:version` | Publish version (auth required) |
| `DELETE` | `/packages/:name/:version` | Yank version (auth required) |

#### User/Auth

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/auth/register` | Register new account |
| `POST` | `/auth/login` | Get API token |
| `GET` | `/auth/me` | Get current user info |
| `POST` | `/auth/keys` | Add a package signing key |
| `GET` | `/auth/keys` | List package signing keys |
| `DELETE` | `/auth/keys/:id` | Remove a signing key |

#### Metadata

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/packages/:name/:version/checksums` | Get checksums without downloading |
| `GET` | `/packages/:name/:version/signing-key` | Get publisher's public key |
| `GET` | `/stats` | Registry-wide statistics |

### 5.3 Database Schema (D1/SQLite)

```sql
-- Users table
CREATE TABLE users (
    id          TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    username    TEXT UNIQUE NOT NULL,
    email       TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    api_token   TEXT UNIQUE,
    created_at  TEXT DEFAULT (datetime('now')),
    updated_at  TEXT DEFAULT (datetime('now'))
);

-- Packages table
CREATE TABLE packages (
    id          TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    name        TEXT UNIQUE NOT NULL,
    description TEXT DEFAULT '',
    license     TEXT DEFAULT '',
    repository  TEXT DEFAULT '',
    owner_id    TEXT NOT NULL REFERENCES users(id),
    created_at  TEXT DEFAULT (datetime('now')),
    updated_at  TEXT DEFAULT (datetime('now')),
    download_count INTEGER DEFAULT 0,
    latest_version TEXT
);

-- Versions table
CREATE TABLE versions (
    id          TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    package_id  TEXT NOT NULL REFERENCES packages(id),
    version     TEXT NOT NULL,
    description TEXT DEFAULT '',
    yanked      INTEGER DEFAULT 0,
    yanked_reason TEXT,
    published_at TEXT DEFAULT (datetime('now')),
    publisher_id TEXT NOT NULL REFERENCES users(id),
    file_size   INTEGER DEFAULT 0,
    checksum    TEXT NOT NULL,         -- SHA-256 of .kxpkg
    manifest    TEXT NOT NULL,         -- JSON .kxmanifest content
    signing_key TEXT,                  -- publisher's public Ed25519 key

    UNIQUE(package_id, version)
);

-- Dependencies table (materialized for query performance)
CREATE TABLE version_dependencies (
    id          TEXT PRIMARY KEY,
    version_id  TEXT NOT NULL REFERENCES versions(id),
    dep_name    TEXT NOT NULL,
    dep_version TEXT NOT NULL,         -- version requirement, e.g. "^0.2.0"
    kind        TEXT DEFAULT 'normal', -- 'normal', 'dev', 'feature'
    feature     TEXT                   -- which feature triggers this dep
);

-- Features table
CREATE TABLE version_features (
    id          TEXT PRIMARY KEY,
    version_id  TEXT NOT NULL REFERENCES versions(id),
    name        TEXT NOT NULL,
    description TEXT DEFAULT '',
    deps        TEXT DEFAULT '[]'      -- JSON array of dependency names
);

-- Download log (for analytics)
CREATE TABLE downloads (
    id          TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    package_id  TEXT NOT NULL REFERENCES packages(id),
    version_id  TEXT NOT NULL REFERENCES versions(id),
    client_ip   TEXT,
    user_agent  TEXT,
    downloaded_at TEXT DEFAULT (datetime('now'))
);

-- Package signing keys
CREATE TABLE signing_keys (
    id          TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    user_id     TEXT NOT NULL REFERENCES users(id),
    package_name TEXT NOT NULL,
    public_key  TEXT NOT NULL,         -- Ed25519 public key
    fingerprint TEXT UNIQUE NOT NULL,  -- SHA-256 of public key
    created_at  TEXT DEFAULT (datetime('now'))
);

-- Indexes
CREATE INDEX idx_packages_name ON packages(name);
CREATE INDEX idx_packages_owner ON packages(owner_id);
CREATE INDEX idx_versions_package ON versions(package_id);
CREATE INDEX idx_versions_version ON versions(version);
CREATE INDEX idx_version_deps_version ON version_dependencies(version_id);
CREATE INDEX idx_version_deps_name ON version_dependencies(dep_name);
CREATE INDEX idx_downloads_package ON downloads(package_id);
CREATE INDEX idx_downloads_time ON downloads(downloaded_at);
CREATE INDEX idx_signing_keys_package ON signing_keys(package_name);
```

### 5.4 Storage Layout (R2)

```
kubex-registry/
├── packages/
│   ├── kx-spatial/
│   │   ├── 0.1.0/
│   │   │   └── kx-spatial-0.1.0.kxpkg
│   │   ├── 0.2.0/
│   │   │   └── kx-spatial-0.2.0.kxpkg
│   │   └── 0.3.2/
│   │       └── kx-spatial-0.3.2.kxpkg
│   ├── kx-math/
│   │   └── 0.2.1/
│   │       └── kx-math-0.2.1.kxpkg
│   └── ...
└── keys/
    ├── users/
    │   └── <user-id>/
    │       └── <key-id>.pub
    └── packages/
        └── <package-name>/
            └── latest.pub
```

### 5.5 Cloudflare Worker Implementation

The worker is written in TypeScript (Cloudflare Workers runtime):

```
registry/
├── wrangler.toml          # Cloudflare Worker config
├── src/
│   ├── index.ts           # Main Worker entry point
│   ├── router.ts          # Request routing
│   ├── auth.ts            # Authentication middleware
│   ├── packages.ts        # Package CRUD handlers
│   ├── versions.ts        # Version publish/download handlers
│   ├── search.ts          # Search implementation
│   ├── storage.ts         # R2 storage operations
│   ├── db.ts              # D1 database operations
│   ├── semver.ts          # Semver parsing and matching
│   ├── crypto.ts          # Ed25519 signature verification
│   └── types.ts           # Shared TypeScript types
├── migrations/
│   └── 0001_initial.sql   # D1 migration
└── test/
    └── worker.test.ts
```

**Worker entry point:**

```typescript
// src/index.ts
export default {
    async fetch(request: Request, env: Env): Promise<Response> {
        const url = new URL(request.url);
        const path = url.pathname;

        // Route matching
        if (path.startsWith("/v1/packages")) {
            return handlePackages(request, env);
        }
        if (path.startsWith("/v1/auth")) {
            return handleAuth(request, env);
        }
        if (path.startsWith("/v1/stats")) {
            return handleStats(request, env);
        }

        return new Response("Not Found", { status: 404 });
    }
};
```

**Key handler: Package download:**

```typescript
// src/versions.ts
async function handleDownload(request: Request, env: Env,
                               packageName: string, version: string): Promise<Response> {
    // 1. Look up version in D1
    const row = await env.DB.prepare(
        `SELECT v.*, p.name as pkg_name
         FROM versions v JOIN packages p ON v.package_id = p.id
         WHERE p.name = ? AND v.version = ? AND v.yanked = 0`
    ).bind(packageName, version).first();

    if (!row) {
        return new Response("Version not found", { status: 404 });
    }

    // 2. Get file from R2
    const key = `packages/${packageName}/${version}/${packageName}-${version}.kxpkg`;
    const obj = await env.BUCKET.get(key);
    if (!obj) {
        return new Response("Package file not found", { status: 404 });
    }

    // 3. Record download
    await env.DB.prepare(
        `INSERT INTO downloads (id, package_id, version_id, client_ip, user_agent)
         VALUES (lower(hex(randomblob(16))), ?, ?, ?, ?)`
    ).bind(row.package_id, row.id,
           request.headers.get("cf-connecting-ip"),
           request.headers.get("user-agent"))
      .run();

    // 4. Return file with proper headers
    return new Response(obj.body, {
        headers: {
            "Content-Type": "application/gzip",
            "Content-Disposition": `attachment; filename="${packageName}-${version}.kxpkg"`,
            "X-Checksum-Sha256": row.checksum,
        }
    });
}
```

**Key handler: Publish:**

```typescript
async function handlePublish(request: Request, env: Env,
                              packageName: string, version: string): Promise<Response> {
    // 1. Authenticate
    const user = await authenticate(request, env);
    if (!user) return new Response("Unauthorized", { status: 401 });

    // 2. Read body (the .kxpkg file)
    const body = await request.arrayBuffer();

    // 3. Compute checksum
    const checksum = await crypto.subtle.digest("SHA-256", body)
        .then(buf => Array.from(new Uint8Array(buf))
            .map(b => b.toString(16).padStart(2, '0')).join(''));

    // 4. Extract and parse .kxmanifest from the archive
    // (using a tar parsing library)
    const manifest = await extractManifest(body);

    // 5. Verify manifest matches URL
    if (manifest.name !== packageName || manifest.version_str !== version) {
        return new Response("Manifest mismatch", { status: 400 });
    }

    // 6. Verify signature
    const sigValid = await verifySignature(body, manifest.publisher_key);
    if (!sigValid) {
        return new Response("Invalid signature", { status: 403 });
    }

    // 7. Store in R2
    const key = `packages/${packageName}/${version}/${packageName}-${version}.kxpkg`;
    await env.BUCKET.put(key, body, {
        httpMetadata: { contentType: "application/gzip" }
    });

    // 8. Store metadata in D1
    await env.DB.batch([
        // Create package if not exists
        env.DB.prepare(
            `INSERT OR IGNORE INTO packages (id, name, description, license, repository, owner_id)
             VALUES (lower(hex(randomblob(16))), ?, ?, ?, ?, ?)`
        ).bind(packageName, manifest.description, manifest.license,
               manifest.repository, user.id),
        // Create version
        env.DB.prepare(
            `INSERT INTO versions (id, package_id, version, description, file_size,
                                    checksum, manifest, signing_key, publisher_id)
             VALUES (lower(hex(randomblob(16))),
                     (SELECT id FROM packages WHERE name = ?),
                     ?, ?, ?, ?, ?, ?, ?)`
        ).bind(packageName, version, manifest.description,
               body.byteLength, checksum, JSON.stringify(manifest),
               manifest.publisher_key, user.id),
    ]);

    return new Response(JSON.stringify({
        name: packageName,
        version: version,
        checksum: checksum,
    }), {
        status: 201,
        headers: { "Content-Type": "application/json" }
    });
}
```

### 5.6 Version Resolution Algorithm

When `kubex add kx-spatial@^0.3.0`:

```
1. Client sends: GET /v1/packages/kx-spatial/versions
2. Registry returns all versions for kx-spatial
3. Client applies semver range matching:
   - Filter versions satisfying ^0.3.0 (>=0.3.0, <0.4.0)
   - Select highest matching version
4. Client downloads that specific version
```

The resolution is done **client-side** (like npm/cargo), not server-side. This allows offline resolution once the version list is cached.

**Client-side semver matching (Kubexic):**

```csharp
var satisfies(version: string, requirement: string) -> bool {
    // Parse version into major.minor.patch
    var v = parse_semver(version);

    if (requirement == "*") return true;

    if (requirement.StartsWith("^")) {
        // Compatible with: >= requirement, < next major
        var req = parse_semver(requirement.Substring(1));
        return v.major == req.major &&
               (v.major > req.major ||
                (v.minor > req.minor ||
                 (v.minor == req.minor && v.patch >= req.patch)));
    }

    if (requirement.StartsWith("~")) {
        // Approximately: >= requirement, < next minor
        var req = parse_semver(requirement.Substring(1));
        return v.major == req.major && v.minor == req.minor && v.patch >= req.patch;
    }

    if (requirement.StartsWith(">=")) {
        return compare_semver(v, parse_semver(requirement.Substring(2))) >= 0;
    }

    if (requirement.StartsWith(">")) {
        return compare_semver(v, parse_semver(requirement.Substring(1))) > 0;
    }

    if (requirement.StartsWith("<=")) {
        return compare_semver(v, parse_semver(requirement.Substring(2))) <= 0;
    }

    if (requirement.StartsWith("<")) {
        return compare_semver(v, parse_semver(requirement.Substring(1))) < 0;
    }

    // Exact match
    return version == requirement;
}
```

### 5.7 Authentication Flow

```
┌─────────┐     POST /v1/auth/register     ┌──────────┐
│  User   │ ──────────────────────────────▶ │ Registry │
│  (CLI)  │ ◀──── { user_id, token } ────── │  Worker  │
└─────────┘                                 └──────────┘

┌─────────┐     POST /v1/auth/login        ┌──────────┐
│  User   │ ──────────────────────────────▶ │ Registry │
│  (CLI)  │ ◀──── { api_token } ────────── │  Worker  │
└─────────┘                                 └──────────┘

┌─────────┐     PUT /v1/packages/:name/:ver  ┌──────────┐
│  User   │ ──── Authorization: Bearer <token> ───────▶ │ Registry │
│  (CLI)  │ ◀──── 201 Created ────────────── │  Worker  │
└─────────┘                                   └──────────┘
```

Credentials stored locally in `~/.kubex/credentials.toml`:

```
[default]
token = "kx_abc123def456..."
username = "slyrebula"
registry = "https://registry.kubex.dev"
```

---

## 6. kubex Tool Implementation (in Kubexic)

### 6.1 Project Structure

The `kubex` tool itself is a Kubexic project:

```
tools/kubex/
  .kxconf                    # manifest for the kubex tool itself
  main.kx                    # CLI entry point, argument parsing

  // Core modules
  commands/
    init.kx                  # kubex init
    add.kx                   # kubex add / remove
    build.kx                 # kubex build / run
    publish.kx               # kubex publish
    install.kx               # kubex install
    search.kx                # kubex search
    tree.kx                  # kubex tree
    test_cmd.kx              # kubex test
    update.kx                # kubex update
    cache_cmd.kx             # kubex cache
    login.kx                 # kubex login / logout
    info.kx                  # kubex info

  // Infrastructure
  config/
    kxconf_parser.kx         # .kxconf parser
    kxconf_model.kx          # .kxconf data model
    lock_file.kx             # kubex.lock reader/writer

  registry/
    client.kx                # HTTP client for registry API
    auth.kx                  # Authentication token management
    semver.kx                # Semver parsing and matching
    resolve.kx               # Dependency resolution

  archive/
    package_build.kx         # Build .kxpkg from project
    package_extract.kx       # Extract .kxpkg
    checksum.kx              # SHA-256 checksums
    signature.kx             # Ed25519 signing/verification

  fs/
    project.kx               # Project root detection, path utilities
    cache_dir.kx             # Cache directory management
    source_collector.kx      # Collect .kx files from project

  // The kubex tool needs a minimal runtime (not the full ECS runtime)
  // It uses: filesystem, HTTP, process execution, crypto
```

### 6.2 .kxconf for kubex itself

```
[package]
name = "kubex"
version = "0.1.0"
description = "Kubexic package manager"
license = "MIT"
author = "slyrebula"

[target]
kind = "binary"
entry = "main.kx"
output = "kubex"

[build]
optimization = "release"

[native]
libs = ["m"]

[features]
default = []
```

### 6.3 System Functions Needed

The kubex tool needs these system functions that are NOT in the current Kubexic stdlib. These need to be added as `extern` declarations backed by C glue code:

#### File I/O

```csharp
// File system operations (all backed by libc)
extern int mkdir(const char* path, int mode);
extern int rmdir(const char* path);
extern int rename(const char* old_path, const char* new_path);
extern int remove(const char* path);
extern int chmod(const char* path, int mode);

// File read/write
extern void* fopen(const char* path, const char* mode);
extern int fclose(void* fp);
extern int fread(void* buf, int size, int count, void* fp);
extern int fwrite(const void* buf, int size, int count, void* fp);
extern int fseek(void* fp, long offset, int whence);
extern long ftell(void* fp);

// File existence / listing
extern int access(const char* path, int mode);  // F_OK = 0, R_OK = 4, W_OK = 2
extern void* opendir(const char* path);
extern void* readdir(void* dir);
extern int closedir(void* dir);

// Path operations (using std.path in Kubexic, or extern)
extern char* realpath(const char* path, char* resolved);
```

#### Process Execution

```csharp
// Run a shell command and capture output
extern int system(const char* cmd);

// Better: pipe-based process execution
extern int popen2(const char* cmd, int* stdin_fd, int* stdout_fd, int* stderr_fd);
extern int waitpid(int pid, int* status, int options);
```

#### HTTP Client (for registry)

```csharp
// HTTP operations using libcurl
extern void* curl_easy_init();
extern int curl_easy_setopt(void* curl, int option, const char* value);
extern int curl_easy_perform(void* curl);
extern void curl_easy_cleanup(void* curl);
extern int curl_easy_getinfo(void* curl, int info, void* result);

// Or: use a simple HTTP implementation in Kubexic itself
// (TCP sockets + HTTP protocol)
extern int socket(int domain, int type, int protocol);
extern int connect(int sockfd, const struct sockaddr* addr, int addrlen);
extern int send(int sockfd, const void* buf, int len, int flags);
extern int recv(int sockfd, void* buf, int len, int flags);
extern int close(int fd);
```

#### Cryptography (for checksums and signatures)

```csharp
// SHA-256 using OpenSSL
extern void* SHA256(const void* data, int len, unsigned char* out);

// Ed25519 using libsodium
extern int crypto_sign_ed25519(unsigned char* sig, unsigned long long* siglen,
                                const unsigned char* msg, int msglen,
                                const unsigned char* secret_key);
extern int crypto_sign_ed25519_open(unsigned char* msg, unsigned long long* mlen,
                                     const unsigned char* sig, int siglen,
                                     const unsigned char* public_key);
extern int crypto_sign_ed25519_keypair(unsigned char* pk, unsigned char* sk);
```

#### Environment Variables

```csharp
extern char* getenv(const char* name);
extern int setenv(const char* name, const char* value, int overwrite);
```

### 6.4 How kubex Calls the Compiler

Since kubex needs to invoke `kxc` as a subprocess, it uses the `system()` extern or `popen()`:

```csharp
// build.kx — how kubex invokes the compiler

fn compile_project(project_dir: string, opts: BuildOptions) -> Result<(), string> {
    var cmd = opts.kxc_path;  // path to kxc binary

    cmd += " build";
    cmd += " --target " + opts.target;

    // Add dependency information
    for (var dep in opts.resolved_deps) {
        cmd += " --dep " + dep.name + ":" + dep.version;
        cmd += " --link-dir " + dep.lib_path;
    }

    // Library mode
    if (opts.shared) {
        cmd += " --shared";
        cmd += " --soname " + opts.soname;
    }

    cmd += " " + project_dir;

    if (opts.output != "") {
        cmd += " " + opts.output;
    }

    var rc = system(cmd);
    if (rc != 0) {
        return Err("compilation failed (exit code " + rc + ")");
    }

    return Ok(());
}
```

### 6.5 C Glue Code

Since the kubex tool is written in Kubexic but needs system functions, we need a small C glue file:

```c
// tools/kubex/glue.c
// Provides C implementations for extern declarations in kubex

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>

// File operations
int kx_mkdir(const char* path, int mode) {
    return mkdir(path, mode);
}

int kx_remove(const char* path) {
    return remove(path);
}

int kx_rename(const char* old_path, const char* new_path) {
    return rename(old_path, new_path);
}

int kx_access(const char* path, int mode) {
    return access(path, mode);
}

char* kx_realpath(const char* path) {
    char* resolved = malloc(4096);
    if (realpath(path, resolved)) return resolved;
    free(resolved);
    return NULL;
}

// Process execution
int kx_system(const char* cmd) {
    return system(cmd);
}

// Environment
char* kx_getenv(const char* name) {
    return getenv(name);
}
```

### 6.6 Building the kubex Tool

The kubex tool is built using `kxc` itself (bootstrapping):

```bash
# Step 1: Build kubex using kxc
kxc build tools/kubex/ -o kubex

# Or with the full project:
kxc build tools/kubex/ \
  --deps-dir .kubex/cache/ \
  --link-dir tools/kubex/lib/ \
  -o build/kubex
```

### 6.7 Bootstrapping Strategy

The kubex tool cannot depend on itself for bootstrapping. The initial version is built with `kxc`:

1. `kxc build tools/kubex/ --output build/kubex` (uses `kxc` directly)
2. After kubex is built, subsequent versions of kubex can be built with `kubex build`

---

### 6.8 Testing Framework

#### Test Attribute Syntax

The `@test` attribute before a function marks it as a test:

```
@test
fn test_addition() {
    expect_eq(2 + 2, 4)
}
```

#### Test Discovery

`kubex test` finds all `@test` functions across the project. It scans every `.kx` source file and collects functions annotated with `@test`, building a test index before execution.

#### Assertion Library

Kubexic provides a built-in assertion library for tests:

- `expect_eq(a, b)` — assert two values are equal
- `expect_true(cond)` — assert a condition is true
- `expect_false(cond)` — assert a condition is false
- `expect_panics(expr)` — assert that an expression panics (tests error paths)

#### Test Runner

The test runner executes each test function individually and reports pass/fail results with the source file and line number for easy identification:

```
test test_addition ... ok
test test_division_by_zero ... FAILED (tests/math_test.kx:23)
test test_parse_valid ... ok

2 passed, 1 failed
```

#### `kubex test` Behavior

`kubex test` compiles all test functions, runs them, and reports results. It does not produce a binary output — tests are compiled and executed in one pass. Failed tests cause a non-zero exit code.

#### Library vs Binary Test Filtering

- `kubex test --lib` — runs only library tests (tests in library source files)
- `kubex test --bin` — runs only binary tests (tests in the binary entry point and its local sources)

---

### 6.9 Doc Comments

#### Item-Level Documentation

Use `///` for item-level documentation, placed before components, systems, functions, and other declarations:

```
/// A 3D position with x, y, z coordinates.
component Pos3 {
    x: float
    y: float
    z: float
}

/// Calculates the distance between two positions.
fn distance(a: Pos3, b: Pos3) -> float {
    // ...
}
```

#### Module/File-Level Documentation

Use `//!` for module or file-level documentation, placed at the top of a file:

```
//! kx-spatial provides spatial partitioning and
//! proximity queries for Kubexic ECS projects.
```

#### AST Storage

Doc comments are parsed and stored in the AST. The `Decl` struct gains a `docComment` field:

```
struct Decl {
    // ... existing fields ...
    var docComment = ""   // accumulated doc comment text
}
```

#### Documentation Generation

`kubex doc` generates HTML documentation from doc comments across the project. It produces an index page with links to each documented component, system, and function.

#### Tested Code Examples

Code examples in ` ```kx ` fenced blocks within doc comments are extracted and tested during `kubex test`. If an example fails to compile or produces incorrect results, the test fails:

```
/// Add two numbers.
///
/// ```
/// expect_eq(add(2, 3), 5)
/// ```
fn add(a: int, b: int) -> int {
    return a + b
}
```

---

### 6.10 Feature Flags in Code

#### Motivation

Kubexic needs a conditional compilation mechanism to allow features to be enabled or disabled at compile time. This is essential for optional functionality (rendering, audio, networking) and platform-specific code.

#### Proposed Syntax

A preprocessor-like directive set:

```
# if feature("rendering")
    // rendering-specific code
# else
    // fallback or stub
# end
```

The `# if`, `# else`, `# end` directives are processed before compilation. Only the active branch is compiled.

#### Feature Propagation

The kubex tool passes enabled features to the compiler. Features defined in `.kxconf` under `[features]` are propagated to `kxc` via command-line flags.

If package A enables feature X and depends on package B, package B can check for feature X using the same `# if feature("X")` syntax. The feature set flows down the dependency tree.

#### Additive-Only Constraint

Features must be additive: enabling a feature must never break existing code. A feature can only add functionality, never remove or change existing behavior. This ensures that enabling extra features in a dependency does not cause regressions.

---

### 6.11 Backward Compatibility

#### `kxc build` Unchanged

`kxc build` continues to work without `.kxconf`. The current standalone compiler behavior is fully preserved. Projects that do not use the package manager are not affected.

#### kubex Wraps kxc

`kubex` wraps `kxc` — kubex resolves dependencies, assembles include paths and link flags, then calls `kxc` with the right arguments. The compiler itself does not need to know about packages.

#### Migration Path

Existing projects can adopt kubex incrementally:

1. Run `kubex init` in an existing project to generate a `.kxconf` manifest
2. Add dependencies as needed with `kubex add`
3. Build with `kubex build` instead of `kxc build`

#### `kxc new` Projects

Existing projects created with `kxc new` can adopt kubex by adding a `.kxconf` file. No restructuring of source files is required.

---

### 6.12 How kubex Finds kxc

#### Search Order

kubex locates the `kxc` compiler using the following search order:

1. `KUBEXIC_KXC_PATH` environment variable (highest priority)
2. `./kxc` in the project root (for vendored or local builds)
3. `~/.local/bin/kxc` (standard user install location)
4. `kxc` on the system `PATH` (lowest priority)

#### Error Handling

If `kxc` is not found by any of these methods, kubex prints a clear error message with install instructions:

```
error: kxc compiler not found
  install: curl -sSL https://kubex.dev/install.sh | sh
  or set: KUBEXIC_KXC_PATH=/path/to/kxc
```

#### Configuration

The path to `kxc` can also be set in `.kxconf` under the `[build]` section:

```
[build]
kxc = "/path/to/kxc"
```

This takes precedence over all other search methods except the `KUBEXIC_KXC_PATH` environment variable.

---

### 6.13 Error Reporting

#### Colored Output

kubex uses colored terminal output for readability:

- **Red** for errors
- **Yellow** for warnings
- **Green** for success messages
- **Cyan** for informational messages

#### `.kxconf` Parse Errors

Parse errors include the file name, line, and column:

```
error: .kxconf:5:10: expected string after '='
```

#### Download Progress

Package downloads show progress with a spinner:

```
downloading kx-spatial v0.3.0...
downloading kx-math v0.2.0...
```

#### Verbose Mode

`kubex build --verbose` shows all commands being run, including the full `kxc` invocation:

```
[kubex] running: kxc build src/ --dep .kubex/cache/kx-spatial-0.3.0/ --output build/my-game
[kubex] exit code: 0
```

#### Completion Summary

On success, kubex prints a summary:

```
success: built my-game (release, 3 dependencies)
```

---

### 6.14 Cross-Compilation with Dependencies

#### Target-Compilation

Dependencies are compiled for the specified target, not the host platform. When building for `aarch64-linux-gnu`, all dependencies are cross-compiled for that target.

#### Source-Based Dependencies

Each dependency's `.kxpkg` contains source code, not pre-compiled artifacts. This ensures that cross-compilation works correctly — source is always available for the target compilation.

#### Cross-Compilation Command

```
kubex build --target aarch64-linux-gnu
```

This compiles the project and all dependencies for the `aarch64-linux-gnu` target.

#### Cross-Compiled Cache

Cross-compiled artifacts are cached separately from host-compiled artifacts:

```
~/.kubex/cache/<target>/<package>-<version>/
```

For example, `~/.kubex/cache/aarch64-linux-gnu/kx-spatial-0.3.0/` contains the cross-compiled version of `kx-spatial` for `aarch64-linux-gnu`.

---

### 6.15 Version Conflict Resolution

#### SemVer with Caret Ranges

Kubexic uses semantic versioning with caret ranges as the default. `^1.2.3` means `>=1.2.3, <2.0.0` — compatible within the same major version.

#### Major Version Conflicts

When two dependencies require incompatible major versions, kubex reports an error:

```
error: version conflict for `foo`
  package A requires foo@^1.0.0
  package B requires foo@^2.0.0
  (major version conflict — cannot satisfy both)
```

This is a hard error because major version bumps indicate breaking changes.

#### Compatible Version Selection

When two dependencies require compatible ranges, kubex picks the highest version that satisfies all constraints:

```
package A requires foo@^1.2.0
package B requires foo@^1.5.0
resolved: foo@1.8.0  (highest version satisfying both ^1.2.0 and ^1.5.0)
```

#### Lock File

The lock file records exact resolved versions for reproducibility. Once resolved, the same versions are used on every build.

#### Updating Dependencies

`kubex update` regenerates the lock file with the latest compatible versions, respecting the constraints in `.kxconf`:

```
kubex update           # update all dependencies
kubex update kx-spatial  # update a specific dependency
```

---

### 6.16 Package Limits

To prevent abuse and ensure predictable behavior, kubex enforces the following limits:

| Limit | Value |
|-------|-------|
| Max `.kxpkg` size | 50 MB |
| Max dependencies per package | 128 |
| Max dependency depth | 32 |
| Max package name length | 64 characters |
| Max version number | 9.999.999 |

These limits are checked during `kubex publish` (on the client and server side) and during `kubex add` / `kubex install`.

---

### 6.17 glue.c Specifics

The `glue.c` file in the kubex tool provides C implementations for system-level operations that are not available as built-in Kubexic primitives:

#### File I/O

- `fopen`, `fclose`, `fread`, `fwrite`, `fseek`, `ftell` — standard C file operations
- `mkdir`, `rename`, `remove` — filesystem manipulation

#### Process Execution

- `popen`, `pclose` — pipe-based process execution
- `system` — run shell commands

#### HTTP

- `libcurl` — `curl_easy_init`, `curl_easy_perform`, `curl_easy_setopt` for HTTP requests to the registry

#### Crypto

- `libsodium` — `crypto_sign_ed25519` for package signing, `crypto_hash_sha256` for checksums

#### Environment

- `getenv`, `setenv` — read and set environment variables (e.g., `KUBEXIC_KXC_PATH`)

#### Time

- `time`, `clock_gettime` — timestamps for build timing and cache invalidation

---

### 6.18 Samples to Packages

Several items currently in the `samples/` directory will be published as official packages on the registry:

| Sample | Package | Contents |
|--------|---------|----------|
| `kx-spatial` | Published package | Pos3, Spatial tag, `spatial.Overlap` / `spatial.Nearby` |
| `kx-math` | Published package | Math functions, vector types |
| `kx-test` | Published package | Test framework for Kubexic (`@test`, assertions, runner) |
| `kx-ecs-utils` | Published package | Common ECS patterns and helper functions |

The existing `samples/` directory is kept for examples and tutorials. It is not converted to packages — the published packages are separate, versioned artifacts with their own `.kxconf` manifests.

---

### 6.19 Build Optimization Flags

kubex supports three optimization levels that map to LLVM optimization flags in the compiler codegen:

| Flag | Level | Description |
|------|-------|-------------|
| `debug` | `-O0 -g` | Full debug info, no optimization. Fastest compile, easiest debugging. |
| `release` | `-O2` | Optimized code, no debug info. Best balance of speed and compile time. |
| `size` | `-Os` | Optimized for binary size. Ideal for embedded or constrained targets. |

#### Configuration

Set the optimization level in `.kxconf` under the `[build]` section:

```
[build]
optimization = "release"
```

#### CLI Override

Override the `.kxconf` setting from the command line:

```
kubex build --release    # force release optimization
kubex build --debug      # force debug (full debug info)
kubex build --size       # force size optimization
```

The CLI flag takes precedence over the `.kxconf` setting.

---

## 7. Implementation Phases

### Phase 1: Foundation (Local Packages Only)

**Goal:** `kubex` CLI works for local projects, no registry.

**Duration:** ~2-3 weeks

#### Step 1.1: Compiler — Namespace Resolution (C++)

See also: [6.11 Backward Compatibility](#611-backward-compatibility)

Files to modify:
- `src/lexer/lexer.cpp` — add `pub` keyword
- `src/ast/ast.h` — add `Decl::isPublic`, `Program::sourceRoot`
- `src/parser/parser.cpp` — parse `pub` prefix
- `src/sema/checker.h` / `src/sema/checker.cpp` — namespace-qualified maps, `using` resolution
- `tools/kxc/main.cpp` — compute namespace from file path, pass source root

Test plan:
- Add tests in `tests/sema_tests.cpp` for namespace resolution
- Verify existing samples still compile (backward compatibility)
- Test nested namespaces: `combat/Damage.kx` → `combat.Damage`
- Test `using` directives work correctly
- Test name conflicts across namespaces

#### Step 1.2: Compiler — Library Output (C++)

See also: [6.14 Cross-Compilation with Dependencies](#614-cross-compilation-with-dependencies), [6.19 Build Optimization Flags](#619-build-optimization-flags)

Files to modify:
- `src/codegen/codegen.h` / `src/codegen/codegen.cpp` — `emitSharedLibrary()`, `emitStaticLibrary()`
- `tools/kxc/main.cpp` — new CLI flags: `--shared`, `--static`, `--soname`, `--dep`, `--link-dir`
- `tools/kxc/CMakeLists.txt` — no changes needed

Test plan:
- Build a simple Kubexic function to a `.so`
- Load `.so` from another program and call the function
- Test visibility: `pub` vs non-pub in shared library output

#### Step 1.3: .kxconf Parser (Kubexic)

New files:
- `tools/kubex/config/kxconf_model.kx`
- `tools/kubex/config/kxconf_parser.kx`
- `tools/kubex/config/lock_file.kx`

Test plan:
- Write unit tests for the parser (parse `.kxconf` → data model)
- Test minimal manifest, full manifest, edge cases
- Test lock file read/write

#### Step 1.4: kubex CLI Scaffold (Kubexic)

See also: [6.12 How kubex Finds kxc](#612-how-kubex-finds-kxc), [6.13 Error Reporting](#613-error-reporting), [6.17 glue.c Specifics](#617-gluec-specifics)

New files:
- `tools/kubex/main.kx` — CLI argument parsing
- `tools/kubex/commands/init.kx`
- `tools/kubex/commands/build.kx`
- `tools/kubex/commands/run.kx`
- `tools/kubex/fs/project.kx` — project root detection
- `tools/kubex/fs/source_collector.kx` — collect .kx files
- `tools/kubex/glue.c` — C glue for system calls

Test plan:
- `kubex init test-project` creates a valid project
- `kubex build` compiles it via kxc
- `kubex run` builds and executes

#### Step 1.5: Local Dependency Support

New files:
- `tools/kubex/commands/add.kx` — add/remove from .kxconf
- `tools/kubex/commands/tree.kx` — display dependency tree
- `tools/kubex/fs/cache_dir.kx` — manage local cache (~/.kubex/cache/)
- `tools/kubex/archive/package_extract.kx` — extract .kxpkg to cache
- `tools/kubex/archive/checksum.kx` — SHA-256 checksums

Workflow:
```
kubex add ./path/to/local-package
  1. Read .kxconf from local-package
  2. Build .kxpkg from local-package
  3. Store in ~/.kubex/cache/<name>-<ver>/
  4. Add to .kxconf as file dependency
```

`.kxconf` gets a new section for local dependencies:

```
[local-dependencies]
kx-spatial = "../kx-spatial"
```

### Phase 2: Registry

**Goal:** Full registry with publish/download/search.

**Duration:** ~2-3 weeks

#### Step 2.1: Archive Build/Verify (Kubexic)

See also: [6.15 Version Conflict Resolution](#615-version-conflict-resolution), [6.16 Package Limits](#616-package-limits)

New files:
- `tools/kubex/archive/package_build.kx` — build .kxpkg from project
- `tools/kubex/archive/signature.kx` — Ed25519 sign/verify
- `tools/kubex/registry/semver.kx` — semver parsing/matching

Test plan:
- Build .kxpkg from a sample project
- Extract and verify checksums
- Test semver matching for all range operators

#### Step 2.2: Registry Client (Kubexic)

New files:
- `tools/kubex/registry/client.kx` — HTTP client for registry API
- `tools/kubex/registry/auth.kx` — token management
- `tools/kubex/registry/resolve.kx` — dependency resolution from registry

New extern declarations needed:
- HTTP operations (libcurl or raw TCP)

Test plan:
- Mock registry responses
- Test `kubex search` against live registry
- Test `kubex publish` against live registry

#### Step 2.3: Registry Server (Cloudflare Workers)

New files:
- `registry/wrangler.toml`
- `registry/src/index.ts`
- `registry/src/router.ts`
- `registry/src/auth.ts`
- `registry/src/packages.ts`
- `registry/src/versions.ts`
- `registry/src/search.ts`
- `registry/src/storage.ts`
- `registry/src/db.ts`
- `registry/src/semver.ts`
- `registry/src/crypto.ts`
- `registry/migrations/0001_initial.sql`

Infrastructure:
- Create Cloudflare account
- Create R2 bucket: `kubex-registry`
- Create D1 database: `kubex-registry-db`
- Deploy worker with `wrangler deploy`
- Set up custom domain: `registry.kubex.dev`

Test plan:
- Test all API endpoints
- Test publish/download workflow end-to-end
- Test search functionality
- Test authentication flows
- Load test with concurrent downloads

#### Step 2.4: Integration

Wire up:
- `kubex publish` → signs → uploads to registry
- `kubex add kx-spatial@^0.3.0` → resolves → downloads → extracts → adds to .kxconf
- `kubex install kx-cli-tool` → downloads binary → installs to ~/.kubex/bin/

### Phase 3: Full Ecosystem

**Goal:** Polish, documentation, community features.

**Duration:** ~3-4 weeks

#### Step 3.1: Advanced Features

See also: [6.8 Testing Framework](#68-testing-framework), [6.9 Doc Comments](#69-doc-comments), [6.10 Feature Flags in Code](#610-feature-flags-in-code)

- `kubex test` — test harness with `kx-test` library (see [6.8 Testing Framework](#68-testing-framework))
- `kubex doc` — documentation generation (see [6.9 Doc Comments](#69-doc-comments))
- `kubex fmt` — formatting (delegates to `kxc fmt`)
- `kubex check` — validation (delegates to `kxc check-dir`)
- `kubex update` — version bumping
- `kubex login` / `kubex logout` — browser-based auth

#### Step 3.2: Workspace Support

- `kubex init --workspace` — create workspace with multiple packages
- Root `.kxconf` with `[workspace]` section
- Build all workspace members: `kubex build --workspace`
- Share dependencies across workspace members

#### Step 3.3: Caching and Offline Support

- Full offline mode: `kubex build --offline`
- Cache invalidation policies
- Mirror support: `--registry https://my-mirror.example.com`
- Cache integrity checks

#### Step 3.4: CI/CD Integration

- `kubex ci` — build in CI environment
- GitHub Actions template
- GitLab CI template
- Reproducible builds with lock file

#### Step 3.5: Documentation and Community

See also: [6.18 Samples to Packages](#618-samples-to-packages)

- Write comprehensive docs for all commands
- Publish `kx-test` as a reference package
- Create tutorial: "Building Your First Kubexic Library"
- Publish `kx-spatial`, `kx-math`, `kx-ecs-utils` as official packages
- Create package template: `kubex init --template ecs-game`

#### Step 3.6: Security Hardening

- Package signing by default for all publishes
- Key rotation support
- Audit logging for registry operations
- Rate limiting on registry API
- Package vulnerability scanning (future)

---

## Appendix A: Data Flow Diagrams

### A.1 Publishing a Package

```
Developer                    kubex CLI                  Registry
   │                             │                          │
   │  kubex publish              │                          │
   │────────────────────────────▶│                          │
   │                             │                          │
   │                  1. Read .kxconf                        │
   │                  2. Collect source files                │
   │                  3. Build .kxpkg                        │
   │                  4. Compute checksums                   │
   │                  5. Sign with Ed25519                   │
   │                             │                          │
   │                             │  PUT /v1/packages/:name/:ver
   │                             │  Authorization: Bearer <token>
   │                             │  Body: .kxpkg file       │
   │                             │─────────────────────────▶│
   │                             │                          │
   │                             │     6. Authenticate       │
   │                             │     7. Verify signature   │
   │                             │     8. Store in R2        │
   │                             │     9. Store metadata in D1
   │                             │                          │
   │                             │  201 Created              │
   │                             │◀─────────────────────────│
   │                             │                          │
   │  Published!                 │                          │
   │◀────────────────────────────│                          │
```

### A.2 Installing a Package

```
Developer                    kubex CLI              Registry
   │                             │                       │
   │  kubex add kx-spatial@^0.3.0                       │
   │────────────────────────────▶│                       │
   │                             │                       │
   │              1. Parse version requirement            │
   │              2. GET /v1/packages/kx-spatial/versions │
   │                             │──────────────────────▶│
   │                             │  [0.1.0, 0.2.0, 0.3.2]│
   │                             │◀──────────────────────│
   │                             │                       │
   │              3. Filter by ^0.3.0 → [0.3.2]          │
   │              4. Select 0.3.2                         │
   │                             │                       │
   │              5. GET /v1/packages/kx-spatial/0.3.2/download
   │                             │──────────────────────▶│
   │                             │  .kxpkg file          │
   │                             │◀──────────────────────│
   │                             │                       │
   │              6. Verify checksum                      │
   │              7. Verify signature                     │
   │              8. Extract to ~/.kubex/cache/kx-spatial-0.3.2/
   │              9. Add to .kxconf                       │
   │              10. Update kubex.lock                   │
   │                             │                       │
   │  Added kx-spatial 0.3.2     │                       │
   │◀────────────────────────────│                       │
```

### A.3 Building with Dependencies

```
Developer          kubex CLI           kxc compiler        .kubex/cache/
   │                  │                    │                    │
   │  kubex build     │                    │                    │
   │─────────────────▶│                    │                    │
   │                  │                    │                    │
   │     1. Parse .kxconf                  │                    │
   │     2. Read kubex.lock                │                    │
   │     3. For each dep:                  │                    │
   │        if not cached:                 │                    │
   │          download from registry        │                    │
   │     4. Collect project .kx files       │                    │
   │                  │                    │                    │
   │     5. Invoke kxc build               │                    │
   │        --dep kx-spatial:0.3.2         │                    │
   │        --link-dir cache/kx-spatial-0.3.2/lib/             │
   │        --dep kx-math:0.2.1            │                    │
   │        --link-dir cache/kx-math-0.2.1/lib/                │
   │                  │───────────────────▶│                    │
   │                  │                    │                    │
   │                  │        6. Compile all .kx files          │
   │                  │           (project + dependency sources)  │
   │                  │                    │                    │
   │                  │        7. Link with:                    │
   │                  │           project.o                     │
   │                  │           + kx-spatial-0.3.2/lib/*.so  │
   │                  │           + kx-math-0.2.1/lib/*.so     │
   │                  │           + runtime.o                   │
   │                  │           -lpthread -lm                  │
   │                  │                    │                    │
   │                  │        8. Output binary                  │
   │                  │◀───────────────────│                    │
   │                  │                    │                    │
   │  built my-game   │                    │                    │
   │◀─────────────────│                    │                    │
```

---

## Appendix B: File Index

All new/modified files organized by component:

### Compiler Changes (C++)

| File | Action | Description |
|------|--------|-------------|
| `src/lexer/lexer.cpp` | Modify | Add `pub` keyword |
| `src/ast/ast.h` | Modify | Add `Decl::isPublic`, `Program::sourceRoot` |
| `src/parser/parser.cpp` | Modify | Parse `pub` prefix on declarations |
| `src/sema/checker.h` | Modify | Namespace-qualified maps, using resolution |
| `src/sema/checker.cpp` | Modify | Implement namespace resolution |
| `src/codegen/codegen.h` | Modify | Add `emitSharedLibrary()`, `emitStaticLibrary()` |
| `src/codegen/codegen.cpp` | Modify | Implement shared lib output, visibility, dep linking |
| `tools/kxc/main.cpp` | Modify | New CLI flags, namespace computation |

### kubex CLI (Kubexic)

| File | Action | Description |
|------|--------|-------------|
| `tools/kubex/.kxconf` | New | Project manifest |
| `tools/kubex/main.kx` | New | CLI entry point |
| `tools/kubex/glue.c` | New | C glue for system calls |
| `tools/kubex/config/kxconf_model.kx` | New | .kxconf data model |
| `tools/kubex/config/kxconf_parser.kx` | New | .kxconf parser |
| `tools/kubex/config/lock_file.kx` | New | Lock file reader/writer |
| `tools/kubex/commands/init.kx` | New | kubex init |
| `tools/kubex/commands/add.kx` | New | kubex add/remove |
| `tools/kubex/commands/build.kx` | New | kubex build/run |
| `tools/kubex/commands/publish.kx` | New | kubex publish |
| `tools/kubex/commands/install.kx` | New | kubex install |
| `tools/kubex/commands/search.kx` | New | kubex search |
| `tools/kubex/commands/tree.kx` | New | kubex tree |
| `tools/kubex/commands/test_cmd.kx` | New | kubex test |
| `tools/kubex/commands/update.kx` | New | kubex update |
| `tools/kubex/commands/cache_cmd.kx` | New | kubex cache |
| `tools/kubex/commands/login.kx` | New | kubex login/logout |
| `tools/kubex/commands/info.kx` | New | kubex info |
| `tools/kubex/registry/client.kx` | New | HTTP client for registry |
| `tools/kubex/registry/auth.kx` | New | Auth token management |
| `tools/kubex/registry/semver.kx` | New | Semver parsing/matching |
| `tools/kubex/registry/resolve.kx` | New | Dependency resolution |
| `tools/kubex/archive/package_build.kx` | New | Build .kxpkg |
| `tools/kubex/archive/package_extract.kx` | New | Extract .kxpkg |
| `tools/kubex/archive/checksum.kx` | New | SHA-256 checksums |
| `tools/kubex/archive/signature.kx` | New | Ed25519 signing |
| `tools/kubex/fs/project.kx` | New | Project root detection |
| `tools/kubex/fs/cache_dir.kx` | New | Cache directory management |
| `tools/kubex/fs/source_collector.kx` | New | Source file collection |

### Registry Server (TypeScript/Cloudflare)

| File | Action | Description |
|------|--------|-------------|
| `registry/wrangler.toml` | New | Cloudflare Worker config |
| `registry/src/index.ts` | New | Worker entry point |
| `registry/src/router.ts` | New | Request routing |
| `registry/src/auth.ts` | New | Authentication |
| `registry/src/packages.ts` | New | Package CRUD |
| `registry/src/versions.ts` | New | Version publish/download |
| `registry/src/search.ts` | New | Search implementation |
| `registry/src/storage.ts` | New | R2 operations |
| `registry/src/db.ts` | New | D1 operations |
| `registry/src/semver.ts` | New | Semver matching |
| `registry/src/crypto.ts` | New | Signature verification |
| `registry/src/types.ts` | New | TypeScript types |
| `registry/migrations/0001_initial.sql` | New | Database schema |
| `registry/test/worker.test.ts` | New | Tests |

---

## Appendix C: Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Kubexic compiler cannot self-host kubex | Blocks Phase 1.4 | Build kubex with `kxc` initially; bootstrap later |
| Cloudflare Workers have execution time limits | Registry upload/download | R2 handles large files; Worker just orchestrates |
| HTTP client in Kubexic is complex | Blocks Phase 2.2 | Use `system("curl ...")` as initial fallback |
| Crypto libraries (Ed25519) need native linking | Blocks Phase 2.1 | Use `libsodium` via `[Link("sodium")]` |
| Semver edge cases | Incorrect resolution | Comprehensive test suite for semver matching |
| Namespace conflicts in large projects | Confusion | Document naming conventions; consider package prefix |
| .kxconf format insufficient for complex projects | User frustration | Start simple; extend format iteratively |
| Registry abuse / spam | Poor UX | Rate limiting, email verification, optional moderation |

---

*End of PLAN_PACKAGE_MANAGER.md*
