# Kubexic Project — Working Preferences

## Build & Test
- Rebuild C++: `cd build && cmake --build . -j$(nproc)`
- Rebuild selfhost: `./build/tools/kxc/kxc build src/kubex/kubex.kx -o /tmp/kubex_full`
- Run tests: `./build/tests/{lexer,parser,sema,mir,codegen}_tests` — 89 total
- Filter noise: `grep -v warning | grep -v "runtime.c:" | grep -v fread`

## Architecture
- First-gen: kxc (C++) → `src/kubex/kubex.kx` → `kubexic` binary
- Second-gen: kubexic → own source → broken (LexAll control flow bug in nested while+continue)
- Runtime: `runtime/runtime.c` linked into every program
- Tokens: string-encoded `kind|text|line|col`

## Codegen Bugs Fixed This Session
- String comparisons: `i1`→`i32` + ICmpNE conversion
- Logic AND/OR phi type coercion before CreateCondBr and phi
- Ternary phi type coercion between branches
- ICmp integer width matching and pointer/int coercion
- SigSetParam: allow any type change from i64
- structinit return type: "struct:TypeName" not "i64"
- GenFunc: store semantic types in g.lt not IR types
- List<string>.Get(): listElem tracking + inttoptr cast
- Missing extern declarations for runtime functions

## Remaining Bootstrap Bug
- Second-gen LexAll: char-by-char tokens instead of identifiers
- Root cause: nested while+if+continue control flow codegen bug
