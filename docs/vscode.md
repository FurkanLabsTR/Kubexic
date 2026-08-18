---
title: VS Code Extension
---

# VS Code Extension

The `kubexic-vscode` directory ships a VS Code extension for editing `.kx` files. It provides syntax highlighting, compiler diagnostics, code completion, and navigation through VS Code's native extension APIs.

---

## 1. Features

### Syntax Highlighting

A TextMate grammar (`syntaxes/kubexic.tmLanguage.json`) provides syntax highlighting for all Kubexic language constructs: keywords, types, strings, comments, ECS primitives, operators, and literals.

### Diagnostics

The extension checks the complete project with `kxc check-dir` and reports errors inline in the editor. Unsaved edits are checked through a temporary project overlay, so typos appear without modifying files on disk. Diagnostics appear as red squiggles with hover messages.

### Code Completion

Typing triggers context-aware completions:

- **Keywords**: `component`, `system`, `tag`, `spawn`, `despawn`, `attach`, `detach`, `run`, and all other language keywords.
- **`std.*` functions**: `println`, `sqrt`, `sin`, `cos`, `rng`, and the full standard library.
- **`spatial.*` functions**: `Overlap`, `Nearby`.
- **Collection methods**: `Add`, `Get`, `Set`, `RemoveAt`, `Clear`, `Count` for `List<T>`; `Set`, `Get`, `Has`, `Remove`, `Clear`, `Count` for `Map<K,V>`.
- **Project symbols**: component, system, tag, struct, enum, function, and constant names are offered as completions.

### Hover

Hovering over a symbol shows its declaration:

- Keywords display as `keyword`.
- Component names show the full `component Name { ... }` declaration with fields.
- System names show `system Name`.
- Tag names show `tag Name`.

### Document Symbols

The outline view (Ctrl+Shift+O) lists all declarations in the current file: components, systems, tags, structs, enums, and constants.

### Go-to-Definition

Ctrl+click or F12 on a component, system, tag, struct, enum, or constant name jumps to its declaration anywhere in the workspace.

### Editor Features

- Bracket matching and auto-closing pairs for `()`, `{}`, `[]`, `""`, `''`.
- Code folding for blocks.
- Comment toggle with `//` for line comments.
- Indentation rules matching the language syntax.

---

## 2. Installation

### From Source

Clone the repository and build the extension:

```bash
cd kubexic-vscode
npm install
npm run compile
npx vsce package
```

This produces a `.vsix` file. Install it in VS Code:

1. Open VS Code.
2. Open the Command Palette (Ctrl+Shift+P).
3. Run **Extensions: Install from VSIX...**
4. Select the generated `.vsix` file.

### Prerequisites

- Node.js 18 or later.
- The `kxc` compiler must be installed and available on your PATH (or configured via the `kubexic.kxcPath` setting).

---

## 3. Configuration

The extension exposes two settings under the `kubexic` namespace:

| Setting | Type | Default | Description |
|---|---|---|---|
| `kubexic.kxcPath` | `string` | `"kxc"` | Path to the `kxc` compiler binary. Use an absolute path if `kxc` is not on your PATH. |
| `kubexic.checkOnSave` | `boolean` | `true` | Run project diagnostics when a `.kx` file is saved. |

To change these settings, open **Settings** (Ctrl+,) and search for "kubexic", or add them to your `settings.json`:

```json
{
  "kubexic.kxcPath": "/usr/local/bin/kxc",
  "kubexic.checkOnSave": true
}
```

The extension reads these settings when it checks the project.

---

## 4. Commands

The extension registers one command accessible through the Command Palette (Ctrl+Shift+P):

### Kubexic: Check Project for Errors

Runs `kxc check-dir` on the current project and reports diagnostics.

---

## 5. How It Works

The extension runs directly inside VS Code; it does not launch a separate language-server process.

It:

1. Watches `.kx` files in the workspace.
2. On edits, creates a temporary full-project overlay and runs `kxc check-dir` against it.
3. Provides completions, hover, and definitions by scanning project declarations.
4. Uses VS Code's native diagnostics, hover, definition, and completion providers.

The extension does not perform compilation or code generation -- all semantic analysis is delegated to the `kxc` compiler.
