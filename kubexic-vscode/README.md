# Kubexic VS Code Extension

Language support for the [Kubexic](https://github.com/kubexic/kubexic) programming language.

## Features

- **Syntax highlighting** for `.kx` files
- **Error diagnostics** from the `kxc` compiler, including unsaved edits
- **Code completion** for keywords, `std.*`, `spatial.*`, components, systems, and tags
- **Hover info** showing component fields, system names, and tag declarations
- **Document symbols** for outline view (components, systems, tags, structs, enums)
- **Go-to-definition** for declarations across the project
- **Bracket matching**, auto-closing pairs, and code folding

## Requirements

- [Kubexic compiler](https://github.com/kubexic/kubexic) (`kxc`) must be installed and available on your PATH
- VS Code 1.85 or newer

## Configuration

| Setting | Default | Description |
|---|---|---|
| `kubexic.kxcPath` | `"kxc"` | Path to the `kxc` compiler binary |
| `kubexic.checkOnSave` | `true` | Run diagnostics on file save |

## Installation

### From VSIX

```bash
cd kubexic-vscode
npm install
npm run compile
npm run package
# Install the generated .vsix in VS Code
```

### From Source

1. Clone this repository
2. Run `npm install`
3. Run `npm run compile`
4. Open in VS Code and press F5 to launch the Extension Development Host

## Commands

- **Kubexic: Check Project for Errors** — manually trigger diagnostics

## Known Issues

- Diagnostics run against the complete project. The compiler currently reports some semantic errors without a file path; those are attached to the file being edited.
