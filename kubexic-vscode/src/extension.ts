import * as path from "path";
import * as vscode from "vscode";
import { execFile } from "child_process";
import { promisify } from "util";
import * as fs from "fs";
import * as os from "os";

const execFileAsync = promisify(execFile);

let diagnosticCollection: vscode.DiagnosticCollection;
let outputChannel: vscode.OutputChannel;

function findKxc(): string {
  const candidates = [
    "kxc",
    path.join(process.env.HOME || "", ".local/bin/kxc"),
    "/usr/local/bin/kxc",
    "/usr/bin/kxc",
  ];
  for (const c of candidates) {
    try { if (fs.existsSync(c)) return c; } catch {}
  }
  return "kxc";
}

export function activate(context: vscode.ExtensionContext) {
  outputChannel = vscode.window.createOutputChannel("Kubexic");
  diagnosticCollection = vscode.languages.createDiagnosticCollection("kubexic");
  context.subscriptions.push(diagnosticCollection);

  let checkTimer: ReturnType<typeof setTimeout> | null = null;

  // Diagnostics on change (debounced)
  context.subscriptions.push(
    vscode.workspace.onDidChangeTextDocument((e) => {
      if (e.document.languageId === "kubexic") {
        if (checkTimer) clearTimeout(checkTimer);
        checkTimer = setTimeout(() => checkProject(e.document), 800);
      }
    })
  );

  // Diagnostics on save
  context.subscriptions.push(
    vscode.workspace.onDidSaveTextDocument((doc) => {
      if (doc.languageId === "kubexic") checkProject(doc);
    })
  );

  // Diagnostics on open
  context.subscriptions.push(
    vscode.workspace.onDidOpenTextDocument((doc) => {
      if (doc.languageId === "kubexic") checkProject(doc);
    })
  );

  // Hover provider
  context.subscriptions.push(
    vscode.languages.registerHoverProvider("kubexic", {
      provideHover(document, position) {
        const word = getWordAt(document, position);
        if (!word) return null;
        return getHoverInfo(word, document);
      },
    })
  );

  // Definition provider
  context.subscriptions.push(
    vscode.languages.registerDefinitionProvider("kubexic", {
      provideDefinition(document, position) {
        const word = getWordAt(document, position);
        if (!word) return null;
        return getDefinition(word, document);
      },
    })
  );

  // Completion provider
  context.subscriptions.push(
    vscode.languages.registerCompletionItemProvider(
      "kubexic",
      {
        provideCompletionItems(document, position) {
          const line = document.lineAt(position).text;
          const wordBefore = line.substring(0, position.character);
          const match = wordBefore.match(/([a-zA-Z_][a-zA-Z0-9_.]*)$/);
          if (!match) return [];
          const parts = match[1].split(".");
          return getCompletions(parts, document);
        },
      },
      "."
    )
  );

  // Check command
  context.subscriptions.push(
    vscode.commands.registerCommand("kubexic.check", () => {
      const editor = vscode.window.activeTextEditor;
      if (editor) checkProject(editor.document);
    })
  );

  // Check initial files
  for (const doc of vscode.workspace.textDocuments) {
      if (doc.languageId === "kubexic") checkProject(doc);
  }
}

function getWordAt(document: vscode.TextDocument, position: vscode.Position): string | null {
  const line = document.lineAt(position).text;
  let start = position.character;
  let end = position.character;
  while (start > 0 && /[a-zA-Z0-9_.]/.test(line[start - 1])) start--;
  while (end < line.length && /[a-zA-Z0-9_.]/.test(line[end])) end++;
  if (start === end) return null;
  return line.substring(start, end);
}

async function checkProject(changedDocument: vscode.TextDocument) {
  const changedFile = changedDocument.uri.fsPath;
  const workspaceFolder = vscode.workspace.getWorkspaceFolder(vscode.Uri.file(changedFile));
  const root = workspaceFolder?.uri.fsPath || path.dirname(changedFile);
  const kxc = findKxc();
  const checkRoot = fs.mkdtempSync(path.join(os.tmpdir(), "kubexic-vscode-"));

  copyKxProject(root, checkRoot);
  const relativeChanged = path.relative(root, changedFile);
  const overlayFile = path.join(checkRoot, relativeChanged);
  fs.mkdirSync(path.dirname(overlayFile), { recursive: true });
  fs.writeFileSync(overlayFile, changedDocument.getText(), "utf-8");

  try {
    const result = await execFileAsync(kxc, ["check-dir", checkRoot], {
      cwd: checkRoot,
      timeout: 15000,
      encoding: "utf-8",
    }).catch((err) => ({ stdout: err.stdout || "", stderr: err.stderr || "" }));

    const output = `${result.stdout || ""}\n${result.stderr || ""}`;
    outputChannel.appendLine(`checked ${root} with ${kxc}`);
    outputChannel.appendLine(output.trim() || "check produced no output");

    diagnosticCollection.clear();

    if (output.includes("check: OK")) {
      return;
    }

    const diagnostics = parseErrors(output, checkRoot, root, changedFile, changedDocument.getText());
    for (const [file, diags] of diagnostics) {
      diagnosticCollection.set(vscode.Uri.file(file), diags);
    }
    outputChannel.appendLine(`published ${Array.from(diagnostics.values()).reduce((n, ds) => n + ds.length, 0)} diagnostic(s)`);
  } catch {
    outputChannel.appendLine(`failed to run ${kxc}`);
  } finally {
    fs.rmSync(checkRoot, { recursive: true, force: true });
  }
}

function copyKxProject(sourceRoot: string, targetRoot: string) {
  const copyDir = (sourceDir: string, targetDir: string) => {
    let entries: fs.Dirent[];
    try {
      entries = fs.readdirSync(sourceDir, { withFileTypes: true });
    } catch {
      return;
    }
    for (const entry of entries) {
      if (entry.name.startsWith(".") || entry.name === "node_modules") continue;
      const source = path.join(sourceDir, entry.name);
      const target = path.join(targetDir, entry.name);
      if (entry.isDirectory()) {
        fs.mkdirSync(target, { recursive: true });
        copyDir(source, target);
      } else if (entry.isFile() && entry.name.endsWith(".kx")) {
        fs.mkdirSync(path.dirname(target), { recursive: true });
        fs.copyFileSync(source, target);
      }
    }
  };

  copyDir(sourceRoot, targetRoot);
}

function parseErrors(
  output: string,
  checkRoot: string,
  originalRoot: string,
  changedFile: string,
  changedText: string,
): Map<string, vscode.Diagnostic[]> {
  const byFile = new Map<string, vscode.Diagnostic[]>();

  for (const line of output.split("\n")) {
    if (!line.trim()) continue;

    // Parser errors can include a path; semantic errors currently use line:col only.
    // The severity label is optional because kxc emits messages such as:
    //   2:5: unknown identifier 'name'
    //   main.kx:2:5: unknown identifier 'name'
    const fileMatch = line.match(/^(.+\.kx):(\d+):(\d+):\s*(?:(error|warning|note):\s*)?(.+)$/i);
    const localMatch = line.match(/^(\d+):(\d+):\s*(?:(error|warning|note):\s*)?(.+)$/i);

    if (fileMatch || localMatch) {
      const maybePath = fileMatch?.[1];
      const lineStr = fileMatch?.[2] ?? localMatch![1];
      const colStr = fileMatch?.[3] ?? localMatch![2];
      const severity = fileMatch?.[4] ?? localMatch?.[3] ?? "error";
      const message = fileMatch?.[5] ?? localMatch![4];

      let absPath: string;
      let realLine: number;
      let realCol: number;

      if (maybePath) {
        const checkedPath = path.isAbsolute(maybePath)
          ? maybePath
          : path.resolve(checkRoot, maybePath);
        const relativePath = path.relative(checkRoot, checkedPath);
        absPath = path.resolve(originalRoot, relativePath);
      } else {
        absPath = changedFile;
      }

      realLine = Math.max(0, parseInt(lineStr, 10) - 1);
      realCol = Math.max(0, parseInt(colStr, 10) - 1);

      if (!absPath) continue;

      const sev = severity.toLowerCase() === "warning"
        ? vscode.DiagnosticSeverity.Warning
        : vscode.DiagnosticSeverity.Error;

      // Extend range to cover the full problematic token
      let startCol = realCol;
      let endCol = realCol + 1;
      try {
        let fileText: string;
        if (absPath === changedFile) {
          fileText = changedText;
        } else {
          // Read from the temp overlay
          const overlayPath = path.join(checkRoot, path.relative(originalRoot, absPath));
          fileText = fs.readFileSync(overlayPath, "utf-8");
        }
        const lines = fileText.split("\n");
        const errorLine = lines[realLine] || "";
        // Walk backward to find start of token (including dotted names like std.func)
        startCol = realCol;
        while (startCol > 0 && /[a-zA-Z0-9_.]/.test(errorLine[startCol - 1])) startCol--;
        // Walk forward to find end of token
        endCol = realCol;
        while (endCol < errorLine.length && /[a-zA-Z0-9_.]/.test(errorLine[endCol])) endCol++;
        if (endCol === startCol) endCol = startCol + 1;
      } catch {}

      const diag = new vscode.Diagnostic(
        new vscode.Range(realLine, startCol, realLine, endCol),
        message,
        sev
      );
      diag.source = "kubexic";

      if (!byFile.has(absPath)) byFile.set(absPath, []);
      byFile.get(absPath)!.push(diag);
    }
  }

  return byFile;
}

function scanProject(root: string): Map<string, { kind: string; name: string; file: string; line: number; fields?: string[]; params?: string[]; members?: string[]; parent?: string }> {
  const symbols = new Map<string, { kind: string; name: string; file: string; line: number; fields?: string[]; params?: string[]; members?: string[]; parent?: string }>();

  const scan = (dir: string) => {
    let entries: fs.Dirent[];
    try { entries = fs.readdirSync(dir, { withFileTypes: true }); } catch { return; }
    for (const e of entries) {
      const full = path.join(dir, e.name);
      if (e.isDirectory() && !e.name.startsWith(".") && e.name !== "node_modules") scan(full);
      else if (e.isFile() && e.name.endsWith(".kx")) scanFile(full);
    }
  };

  const scanFile = (file: string) => {
    let content: string;
    try { content = fs.readFileSync(file, "utf-8"); } catch { return; }
    const lines = content.split("\n");
    for (let i = 0; i < lines.length; i++) {
      let m: RegExpExecArray | null;
      if ((m = /\bcomponent\s+([A-Z][a-zA-Z0-9_]*)/.exec(lines[i]))) {
        symbols.set(m[1], { kind: "component", name: m[1], file, line: i, fields: extractFields(content, m.index) });
      }
      if ((m = /\bsystem\s+([A-Z][a-zA-Z0-9_]*)/.exec(lines[i]))) {
        symbols.set(m[1], { kind: "system", name: m[1], file, line: i });
      }
      if ((m = /\btag\s+([A-Z][a-zA-Z0-9_]*)\s*(?::\s*([A-Z][a-zA-Z0-9_]*))?/.exec(lines[i]))) {
        symbols.set(m[1], { kind: "tag", name: m[1], file, line: i, parent: m[2] });
      }
      if ((m = /\bstruct\s+([A-Z][a-zA-Z0-9_]*)/.exec(lines[i]))) {
        symbols.set(m[1], { kind: "struct", name: m[1], file, line: i, fields: extractFields(content, m.index) });
      }
      if ((m = /\benum\s+([A-Z][a-zA-Z0-9_]*)/.exec(lines[i]))) {
        const bs = content.indexOf("{", m.index); const be = bs >= 0 ? content.indexOf("}", bs) : -1;
        symbols.set(m[1], { kind: "enum", name: m[1], file, line: i, members: be >= 0 ? content.substring(bs + 1, be).split(",").map(s => s.trim()).filter(Boolean) : [] });
      }
      if ((m = /\b(var|void|int|long|float|double|bool|byte|string)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(/.exec(lines[i]))) {
        if (m[2] !== "main") {
          const ps = content.indexOf("(", m.index); const pe = ps >= 0 ? content.indexOf(")", ps) : -1;
          symbols.set(m[2], { kind: "function", name: m[2], file, line: i, params: pe >= 0 ? content.substring(ps + 1, pe).split(",").map(s => s.trim()).filter(Boolean) : [] });
        }
      }
      if ((m = /\bconst\s+([A-Z][a-zA-Z0-9_]*)\s*=/.exec(lines[i]))) {
        symbols.set(m[1], { kind: "constant", name: m[1], file, line: i });
      }
    }
  };

  const extractFields = (c: string, si: number): string[] => {
    const fields: string[] = [];
    const bs = c.indexOf("{", si); if (bs < 0) return fields;
    let d = 1, i = bs + 1, cl = "";
    while (i < c.length && d > 0) {
      if (c[i] === "{") d++; else if (c[i] === "}") d--;
      else if (c[i] === "\n") { const fm = cl.match(/^\s*var\s+([a-zA-Z_][a-zA-Z0-9_]*)/); if (fm) fields.push(fm[1]); cl = ""; }
      else cl += c[i]; i++;
    }
    const fm = cl.match(/^\s*var\s+([a-zA-Z_][a-zA-Z0-9_]*)/);
    if (fm) fields.push(fm[1]);
    return fields;
  };

  scan(root);
  return symbols;
}

function getHoverInfo(word: string, document: vscode.TextDocument): vscode.Hover | null {
  const root = vscode.workspace.getWorkspaceFolder(document.uri)?.uri.fsPath || path.dirname(document.uri.fsPath);
  const symbols = scanProject(root);
  const parts = word.split(".");

  if (parts.length === 2) {
    const [objName, fieldName] = parts;
    const sym = symbols.get(objName);
    if (sym && sym.fields?.includes(fieldName)) {
      const code = sym.kind === "component"
        ? `component ${objName} {\n${sym.fields.map(f => `    var ${f} = ...;`).join("\n")}\n}`
        : `struct ${objName} {\n${sym.fields.map(f => `    var ${f} = ...;`).join("\n")}\n}`;
      const rel = path.relative(root, sym.file);
      return new vscode.Hover([
        new vscode.MarkdownString(`\`\`\`kubexic\n${code}\n\`\`\``),
        new vscode.MarkdownString(`**${sym.kind}** field \`${fieldName}\`\n\n*${rel}:${sym.line + 1}*`),
      ]);
    }
    return null;
  }

  const sym = symbols.get(parts[0]);
  if (!sym) {
    const KEYWORDS = ["component","system","tag","struct","enum","const","extern","var","void","int","long","float","double","bool","byte","string","if","else","while","for","foreach","in","break","continue","return","spawn","despawn","attach","detach","self","new","with","without","tags","is","exact","using","true","false","panic","run","switch","case","default"];
    if (KEYWORDS.includes(parts[0])) {
      return new vscode.Hover(new vscode.MarkdownString(`\`\`\`kubexic\n${parts[0]}\n\`\`\`\n**keyword**`));
    }
    return null;
  }

  let code = "";
  if (sym.kind === "component") code = `component ${sym.name} {\n${(sym.fields||[]).map(f => `    var ${f} = ...;`).join("\n")}\n}`;
  else if (sym.kind === "system") code = `system ${sym.name}`;
  else if (sym.kind === "tag") code = `tag ${sym.name}${sym.parent ? " : " + sym.parent : ""}`;
  else if (sym.kind === "struct") code = `struct ${sym.name} {\n${(sym.fields||[]).map(f => `    var ${f} = ...;`).join("\n")}\n}`;
  else if (sym.kind === "enum") code = `enum ${sym.name} { ${(sym.members||[]).join(", ")} }`;
  else if (sym.kind === "function") code = `var ${sym.name}(${(sym.params||[]).join(", ")}) { ... }`;
  else if (sym.kind === "constant") code = `const ${sym.name} = ...`;

  const rel = path.relative(root, sym.file);
  return new vscode.Hover([
    new vscode.MarkdownString(`\`\`\`kubexic\n${code}\n\`\`\``),
    new vscode.MarkdownString(`**${sym.kind}**\n\n*${rel}:${sym.line + 1}*`),
  ]);
}

function getDefinition(word: string, document: vscode.TextDocument): vscode.Location | null {
  const root = vscode.workspace.getWorkspaceFolder(document.uri)?.uri.fsPath || path.dirname(document.uri.fsPath);
  const symbols = scanProject(root);
  const parts = word.split(".");

  let targetSym;
  if (parts.length === 2) {
    targetSym = symbols.get(parts[0]);
  } else {
    targetSym = symbols.get(parts[0]);
  }

  if (targetSym) {
    return new vscode.Location(
      vscode.Uri.file(targetSym.file),
      new vscode.Position(targetSym.line, 0)
    );
  }

  // Fallback: search current file
  const text = document.getText();
  const pats = [
    new RegExp(`\\bcomponent\\s+${parts[0]}\\b`),
    new RegExp(`\\bsystem\\s+${parts[0]}\\b`),
    new RegExp(`\\btag\\s+${parts[0]}\\b`),
    new RegExp(`\\bstruct\\s+${parts[0]}\\b`),
    new RegExp(`\\benum\\s+${parts[0]}\\b`),
    new RegExp(`\\b(const|var)\\s+${parts[0]}\\s*=`),
  ];
  for (const p of pats) {
    const m = p.exec(text);
    if (m) {
      const line = text.substring(0, m.index).split("\n").length - 1;
      return new vscode.Location(document.uri, new vscode.Position(line, 0));
    }
  }
  return null;
}

const STD_FUNCTIONS = ["println","print","readln","stop","exit","log","pollLine","rng","sqrt","sin","cos","tan","asin","acos","atan","atan2","pow","exp","log2","log10","floor","ceil","round","min","max","abs","clamp","lerp"];
const SPATIAL_FUNCTIONS = ["Overlap","Nearby"];
const KEYWORDS = ["component","system","tag","struct","enum","const","extern","var","void","int","long","float","double","bool","byte","string","if","else","while","for","foreach","in","break","continue","return","spawn","despawn","attach","detach","self","new","with","without","tags","is","exact","using","true","false","panic","run","switch","case","default"];

function getCompletions(parts: string[], document: vscode.TextDocument): vscode.CompletionItem[] {
  const root = vscode.workspace.getWorkspaceFolder(document.uri)?.uri.fsPath || path.dirname(document.uri.fsPath);
  const symbols = scanProject(root);
  const items: vscode.CompletionItem[] = [];

  if (parts.length >= 2) {
    const obj = parts[0];
    if (obj === "std") return STD_FUNCTIONS.map(f => new vscode.CompletionItem(f, vscode.CompletionItemKind.Function));
    if (obj === "spatial") return SPATIAL_FUNCTIONS.map(f => new vscode.CompletionItem(f, vscode.CompletionItemKind.Function));
    const sym = symbols.get(obj);
    if (sym?.fields) return sym.fields.map(f => new vscode.CompletionItem(f, vscode.CompletionItemKind.Field));
    return items;
  }

  for (const kw of KEYWORDS) items.push(new vscode.CompletionItem(kw, vscode.CompletionItemKind.Keyword));
  for (const [, sym] of symbols) {
    const kind = sym.kind === "component" ? vscode.CompletionItemKind.Class
      : sym.kind === "system" ? vscode.CompletionItemKind.Function
      : sym.kind === "tag" ? vscode.CompletionItemKind.Enum
      : sym.kind === "struct" ? vscode.CompletionItemKind.Struct
      : sym.kind === "enum" ? vscode.CompletionItemKind.Enum
      : sym.kind === "function" ? vscode.CompletionItemKind.Function
      : vscode.CompletionItemKind.Constant;
    items.push(new vscode.CompletionItem(sym.name, kind));
  }
  return items;
}

export function deactivate() {}
