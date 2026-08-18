---
title: CLI Reference
---

# CLI Reference

The `kxc` compiler driver handles project creation, compilation, formatting, checking, and debugging.

```
usage: kxc <command> [options] <file-or-dir> [output]
```

---

## Commands

| Command | Usage | Description |
|---------|-------|-------------|
| `new` | `kxc new <name>` | Scaffold a new project with `Counter.kx`, `CountSystem.kx`, and `main.kx` |
| `build` | `kxc build <dir>` | Compile all `.kx` files in `dir` to a native executable (`a.out`) |
| `build` | `kxc build <dir> <output>` | Compile with a custom output name |
| `run` | `kxc run <dir>` | Compile and execute immediately |
| `check` | `kxc check <file>` | Semantic-check a single `.kx` file |
| `check-dir` | `kxc check-dir <dir>` | Semantic-check all `.kx` files in a directory |
| `mir` | `kxc mir <dir>` | Run interaction (MIR) analysis on a directory |
| `fmt` | `kxc fmt <file>` | Format a single file in place |
| `fmt-dir` | `kxc fmt-dir <dir>` | Format all `.kx` files in a directory |
| `dump` | `kxc dump <file>` | Lex, parse, and print the AST |

### Examples

```bash
# Create a new project
kxc new my-game

# Build it
kxc build my-game

# Build with a custom output name
kxc build my-game my-game-bin

# Run directly
kxc run my-game

# Check for semantic errors
kxc check-dir my-game

# Format all files
kxc fmt-dir my-game

# Inspect the AST
kxc dump my-game/main.kx
```

---

## Cross-Compilation

Use `--target <triple>` with `build` or `run` to cross-compile:

```bash
kxc build --target aarch64-linux-gnu my-game
```

The `--target` flag must appear **before** the directory argument.

### Supported Targets

| Target Triple | Platform |
|---------------|----------|
| `x86_64-linux-gnu` | Linux x86-64 (default) |
| `aarch64-linux-gnu` | Linux ARM64 |
| `arm-linux-gnueabihf` | Linux ARM 32-bit |
| `x86_64-apple-darwin` | macOS Intel |
| `aarch64-apple-darwin` | macOS Apple Silicon |
| `x86_64-pc-windows-msvc` | Windows x86-64 |

### Cross-Compiler Installation

The matching cross-compiler must be installed on your system:

```bash
# Ubuntu/Debian — Linux ARM64
sudo apt install gcc-aarch64-linux-gnu

# Ubuntu/Debian — Linux ARM 32-bit
sudo apt install gcc-arm-linux-gnueabihf

# Ubuntu/Debian — Windows x86-64 (MinGW)
sudo apt install gcc-mingw-w64-x86-64
```

macOS-to-macOS and macOS-to-Linux cross-compilation uses the system `cc` (Xcode Command Line Tools).

---

## Environment Variables

| Variable | Effect | Default |
|----------|--------|---------|
| `KUBEXIC_CORES=<n>` | Override the number of ECS boxes (parallelism units). `0` = use all cores. | All available cores |
| `KX_TRACE=1` | Trace every `attach`, `detach`, and `despawn` request with component names to stderr. | Off |
| `KX_KEEP_TMP` | Retain temporary build files in `/tmp/kxbuild.*` instead of cleaning them up. Useful for debugging the LLVM IR and object files. | Off (temp dir deleted) |

### Examples

```bash
# Run single-threaded for debugging
KUBEXIC_CORES=1 kxc run my-game

# Trace all mutations
KX_TRACE=1 kxc run my-game

# Inspect intermediate build artifacts
KX_KEEP_TMP=1 kxc build my-game
```
