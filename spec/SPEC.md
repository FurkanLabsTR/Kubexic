# Kubexic — Language Specification (Draft v0)

> **Status**: M0 — language design frozen for initial implementation. This document is the
> normative reference. Sections marked **[Future]** are approved for later milestones and must
> not constrain the core design.

---

## 1. Identity

Kubexic is a general-purpose, compiled programming language where **ECS is the language itself**,
not a library. C#-like syntax, LLVM backend, native executables.

- The programmer **never manages threads or memory**. The compiler and runtime own both.
- The world model is: **entities** composed of **components** (data), evolved by **systems**
  (logic), grouped by **tags** (visibility).
- Target uses: games, scientific simulations, data pipelines, batch jobs — any program shaped as
  "many things evolving over steps."

### 1.1 Toolchain

| Component | Choice |
|---|---|
| Implementation language | C++17+ |
| Compiler backend | LLVM 21 |
| Build system | CMake + Ninja |
| Compiler driver | `kxc` |
| Source extension | `.kx` |

### 1.2 Project layout

```
Kubexic/
  spec/SPEC.md          — this document
  src/                  — compiler sources (lexer, parser, ast, sema, mir, codegen)
  runtime/              — precompiled runtime library (scheduler, stores, boards, requests)
  tools/kxc/            — compiler driver CLI
  tests/                — unit + end-to-end golden tests
  samples/              — example .kx programs (incl. kx.spatial)
```

---

## 2. The Core Law

> **Self is live. Everything else is frozen.**

- The entity a system is currently processing: **read and written immediately**.
- Every other entity: a **frozen snapshot from last tick**, **read-only**.
- You can never write another entity directly. You **attach a component** to it. The component is
  the message.
- All structural changes — `attach`, `detach`, `spawn`, `despawn` — are **requests**, applied at
  tick commit in deterministic order.

### 2.1 Guarantees derived from the Core Law

| Guarantee | Mechanism |
|---|---|
| Zero data races | Live data is touched only by the owning box; everything else is frozen copies |
| Box-invariant semantics | Program behavior never depends on which box an entity lives in |
| Core-count invariance | Results are bitwise-identical for any `cores` value |
| Determinism | Frozen iteration is sorted by entity ID; systems run in a fixed order |
| No dangling references | Generational entity IDs; stale targets are safe no-ops |
| No float reassociation | Compiler never reassociates floating point unless `[FastMath]` is applied |

---

## 3. Program Structure

- One declaration per file. File name must equal the declaration name.
- The compiler compiles all `.kx` files under the project root (recursive).
- A folder acts as a namespace. `using Other.Namespace;` imports names so they can be used
  unqualified.
- Everything declared is visible project-wide in v0. No access modifiers.
- A program has exactly one `main` function.

Example:

```
game/
  Health.kx        component Health
  Damage.kx        component Damage
  DamageSystem.kx  system DamageSystem
  Arrow.kx         component Arrow
  ArrowSystem.kx   system ArrowSystem
  main.kx          int main()
```

---

## 4. Variables and Types — Var-Only

The user never writes a type name. The compiler infers concrete machine types from literals and
context.

### 4.1 Literals and inferred types

| You write | Compiler infers |
|---|---|
| `var x = 5` | `int` (i32) |
| `var x = 5L` | `long` (i64) |
| `var x = 1.5` | `double` (f64) — science-safe default |
| `var x = 1.5f` | `float` (f32) |
| `var x = true` | `bool` |
| `var x = "text"` | `string` |

Internal machine types exist for codegen but are not written by users: `int` (i32), `long` (i64),
`float` (f32), `double` (f64), `bool`, `string` (UTF-8, heap), `byte` (u8).

### 4.2 EntityId

Builtin handle type. Opaque 64-bit generational ID. `EntityId.None` is the null-ish sentinel.
EntityId values are used in `attach`/`detach`/`despawn` and as component field payloads. A stale ID
(target despawned) is a safe no-op for requests and never dereferences.

### 4.3 No null — option types

No null keyword. `T?` marks an optional value: `string?`, `int?`.

```csharp
string? name = std.readln();
if (name is string s) { std.println($"hello {s}"); }
var v = name.ValueOr("unknown");
```

### 4.4 Constants

`const` at namespace level. Values are inferred; must be compile-time constants.

```csharp
const MaxPlayers = 100;
const Gravity = 9.81;
```

**Mutable global state is forbidden** (determinism). All mutable state lives in entities.

### 4.5 Numeric semantics

- Integer overflow: defined two's-complement wrap (identical on every machine).
- Division by zero: `panic`.
- Floating point: strict IEEE-754; no reassociation unless `[FastMath]`.

---

## 5. Functions

No `fn` keyword. Declarations start with `void` (no return) or `var` (inferred return type).
Parameters are untyped — **inferred generics**, monomorphized at compile time per call site.

```csharp
var Max(a, b) { if (a > b) { return a; } return b; }   // int, double, ... all work

void Log(msg) { std.println(msg); }

var Distance2(a, b) {   // two points as structs
    var dx = a.x - b.x; var dy = a.y - b.y; var dz = a.z - b.z;
    return dx * dx + dy * dy + dz * dz;
}
```

Rules:
- Return type inferred from `return` statements; `var` with no returns is an error.
- No overloading in v0. **[Future]: overloading.**
- Generic functions are monomorphized; all call sites are known at compile time (whole-project
  compilation).

---

## 6. Components — Pure Data

Components are value-ish data holders attached to entities. No logic inside components.

```csharp
// Health.kx
component Health {
    var hp = 100;
    var name = "unknown";
}

// Damage.kx — a message component
component Damage {
    var amount = 10;
    var sender = EntityId.None;
}
```

Rules:
- Fields always have a **default initializer**; the type is inferred from it. (SoA stores require
  a default value anyway.)
- Fields may hold heap data (`string`, `List<T>`, `Map<K,V>`, structs) — managed by ownership
  trees (§14).
- A component type is attached to an entity **at most once**. `attach` on an existing type is an
  **upsert**: it replaces the payload.
- There is no `event` keyword. Cleanup is the programmer's job: `detach(self, Damage)` consumes a
  message; leaving it attached re-runs dependent systems every tick (deliberate DoT/buff pattern).

---

## 7. Systems — Name and Body

A system is a name and a body. The body runs **once per matching entity, every tick**.

```csharp
// DamageSystem.kx
system DamageSystem {
    Health.hp -= Damage.amount;
    if (Health.hp <= 0) {
        attach(Damage.sender, new Healing { amount = 5 });
        despawn self;
    } else {
        detach(self, Damage);
    }
}
```

### 7.1 Match-set inference

The match set is **inferred from the components the body touches**:
- Body accesses `Damage.amount` and `Health.hp` → the system runs on entities that have **both**
  `Damage` and `Health`.
- Touched components are directly in scope: `Damage.amount`, `Health.hp` — no `Get<T>()`, no
  `e.` prefix, no `update()` wrapper.
- **An entity missing any required component is silently skipped. It is never an error.**

### 7.2 Explicit clauses

`with` / `without` refine or constrain the match set when inference cannot express intent:

```csharp
// marker component, never field-accessed:
system PoisonTick with (Health, Poisoned) { Health.hp -= 1; }

// exclusion filter:
system Regen without (Dead) { Health.hp += 2; }
```

Accessing a component not in the effective match set is a compile error.

### 7.3 Builtins inside a system body

| Builtin | Meaning |
|---|---|
| `self` | The current entity (`.Id` yields its EntityId) |
| `dt` | Tick delta time (seconds as double) |
| `tick` | Current tick number (u64) |

### 7.4 Execution order

- Systems run in **alphabetical order** of system name each tick (deterministic).
- `[Order(n)]` overrides: lower n runs first; ties broken alphabetically.
- Order only matters within a box for self-field visibility; cross-entity communication is
  inherently next-tick and therefore order-tolerant.

### 7.5 Attributes

C#-style brackets. v0 attributes: `[Order(n)]`, `[FastMath]`.

---

## 8. Control Flow, Operators, Comments

- Control flow: `if` / `else if` / `else`, `while`, `for`, `foreach`, `break`, `continue`,
  `return`.
- Operators: `+ - * / %`, `== != < > <= >=`, `&& || !`, `= += -= *= /= %=`, postfix `++` `--`, ternary `?:`.
- String interpolation: `$"text {expr}"`.
- Comments: `//` line, `/* */` block.

```csharp
for (var i = 0; i < 10; i++) { ... }
foreach (var e in items) { ... }
if (Health.hp > 50) { ... } else if (Health.hp > 0) { ... } else { ... }
```

---

## 9. Structs and Enums

```csharp
struct Vec3 {
    var x = 0.0;
    var y = 0.0;
    var z = 0.0;
}

enum Direction { North, East, South, West }
```

- Structs are plain data grouping; no inheritance.
- Enums are simple integer-backed named constants.

---

## 10. Tags — Visibility

Tags are the **publication** mechanism: an entity carrying a tag publishes its frozen state under
that tag. Any system may query the frozen world by tag. Symmetric interaction is just both sides
carrying the same tag.

```csharp
tag Actor;
tag Combatant : Actor;      // Combatant is-a Actor
tag Monster   : Combatant;
tag Player    : Combatant;
```

- Tags are hierarchical. Matching by a tag includes its subtags by default.
- `tag: exact X` matches only entities carrying exactly `X` (not subtags).
- Compiled to **bitmasks**: a tag check is one AND instruction; hierarchy expansion is computed at
  compile time. An entity's tag mask is stored in the SoA store beside its component mask.
- **64 tags per program (v0).** Exceeding it is a compile error.
- **Zero-cost**: if no system queries by tag, no tag/board machinery is emitted at all.
- Untagged entities are invisible to tag queries and addressable only by their EntityId.

### 10.1 Reading the frozen world

```csharp
foreach (var t in others<Health>(tag: Combatant)) { ... }         // includes subtags
foreach (var t in others<Health>(tag: exact Monster)) { ... }     // exact only
```

`others<C>(tag: X)` returns frozen snapshots of entities carrying `X` (or subtags) with component
`C`. Iteration order is **sorted by entity ID** — deterministic on any machine/core count. Results
are read-only; writing is a compile error.

---

## 11. The Four Verbs — Only Mutations

| Statement | Effect |
|---|---|
| `attach(id, comp)` | Add or upsert a component on any entity; applied next tick |
| `detach(id, ComponentType)` | Remove a component; applied next tick |
| `spawn { ... }` | Create an entity; applied at commit; ID returned immediately |
| `despawn self` / `despawn id` | Remove an entity; applied next tick |

```csharp
var arrow = spawn { Pos3 { x = 1, y = 2, z = 3 }, Arrow { sender = self.Id }, tags [Projectile] };
attach(arrow, new Velocity { dx = 10, dy = 0, dz = 0 });
detach(self, Damage);
despawn self;
```

Rules:
- `attach` on a dead ID: safe no-op.
- `attach` on an existing component type: upsert (payload replaced).
- Commit order is deterministic: system order, then emission order within a system.
- `spawn` returns the entity's ID immediately (pre-committed); the entity materializes at commit.
- Structural changes **to self** are also requests (`despawn self`, `detach(self, X)`) — but
  **field writes to self are immediate**.

### 11.1 The reactive model

Attaching a component is how systems are invoked: the target entity becomes a match for every
system whose inferred match set includes that component, starting next tick. There is no separate
event system — the component appearing *is* the event.

---

## 12. The Tick and Threading

Per tick, the runtime executes, in order:

1. **Deliver** — apply requests from the previous commit to their targets' boxes.
2. **Simulate** — all boxes run their systems in parallel on the thread pool.
3. **Commit** — apply this tick's requests in deterministic order.
4. **Freeze** — publish each box's declared components to the global frozen view; entities
   awaiting despawn are removed.

### 12.1 Scheduling

- Default: **all CPU cores**. Boxes are partitioned, scheduled, and load-rebalanced automatically
  (entities migrate between boxes invisibly; semantics unaffected by the Core Law).
- Partitioning (v0): `box = hash(entityId) % boxCount`; boxCount = cores. Rebalancing via
  imbalance-threshold migration (engine-style).

### 12.2 run() modes

| Call | Meaning |
|---|---|
| `run(60)` | Realtime, 60 ticks/sec |
| `run(max, ticks: 1000000)` | Headless batch — run N ticks as fast as possible (science) |
| `run(60, cores: 0.5)` | Use 50% of cores |
| `run(60, cores: 4)` | Use exactly 4 cores |
| `run(60, cores: 1)` | Single-threaded debug mode (fully reproducible execution order) |

`run` returns when `std.stop()` is called or the run is exhausted; execution continues in `main`.

---

## 13. main() and the std Library

`main` is the sequential bootstrap: parse args, spawn the world, `run()`.

```csharp
// main.kx
int main() {
    std.println("Starting simulation...");
    string? name = std.readln();
    for (var i = 0; i < 100; i++) {
        spawn { Pos3 { x = i, y = 10, z = 0 }, Health { hp = 100 }, tags [Combatant] };
    }
    run(60);
    std.println("World ended.");
    return 0;
}
```

### 13.1 Console and process control

| Call | Where | Effect |
|---|---|---|
| `std.print(x)` / `std.println(x)` | anywhere | In systems: buffered per box, flushed in deterministic order at commit. In main: immediate |
| `std.readln()` | main only | Reads a line from stdin; returns `string?` |
| `std.stop()` | anywhere | Graceful: finishes current tick, `run()` returns, main continues |
| `std.exit(code)` | anywhere | Terminates the process immediately with exit code |
| `std.log(level, msg)` | anywhere | Deterministic, ordered logging |

### 13.1b Control flow (extended)

- `switch (expr) { case v1: ... case v2, v3: ... default: ... }` — shared
  labels, `break`/`return`/`continue` terminators required, string cases use
  content comparison.

### 13.1c Strings

- `Length` (property), `Substring(start, len)`, `Contains(s)`,
  `StartsWith(s)`, `EndsWith(s)`, `Upper()`, `Lower()`.
- `==`/`!=` compare content (not pointers).

### 13.1d Functions and operators

- Overloading by arity: `var F(a)` and `var F(a, b)` coexist; calls resolve
  by argument count.
- Operator overloading via convention functions: `op_add`, `op_sub`,
  `op_mul`, `op_div`, `op_mod`, `op_eq`, `op_ne`, `op_lt`, `op_le`, `op_gt`,
  `op_ge` (two parameters, declared like any function). Triggered when either
  operand is a struct; the return type is inferred from the operator body.
  Enables `Vec3`-style value types.

### 13.1e Extern (C interop)

- `extern double sqrt(double x);` — typed parameters (the one place type
  names appear), calls coerce arguments, symbols linked by name.
- `[Link("m")] extern ...` — adds `-lm` (or any library) to the link command.

### 13.2 Collections, math, rng

- `List<T>` — `Add(x)`, `Get(i)`, `Set(i, x)`, `RemoveAt(i)`, `Clear()`, `Count`
  (property), `foreach` iterates elements.
- `Map<K, V>` — `Set(k, v)` (upsert), `Get(k)`, `Has(k)`, `Remove(k)`, `Clear()`,
  `Count` (property).
- Element types: `int`, `long`, `float`, `double`, `bool`, `string`, `EntityId`.
  Nested collections are not supported yet.
- Constructed with `List<int>()`, `Map<string, int>()`. In `spawn` and
  `attach` initializers, a fresh `List()/Map()` constructor is **taken** by
  the entity (no copy) — ownership transfers.
- `std.sqrt`, `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `atan2`, `pow`,
  `exp`, `log`, `log2`, `log10`, `floor`, `ceil`, `round` (double),
  `min`, `max`, `abs`, `clamp(x,lo,hi)`, `lerp(a,b,t)`.
- `std.rng(seed)` → `Rng`; `r.Next()` (long), `r.NextInt(n)` (0..n-1),
  `r.NextDouble()` (0..1). Deterministic LCG: same seed → same sequence on
  any core count.
- `std.log(level, msg)` — stderr.
- `std.pollLine()` → `Option<string>` — non-blocking stdin; the coordinator
  polls once per tick, lines queue deterministically (works in systems).
- `opt.ValueOr(default)` on any `T?` value.
- Ownership semantics (ownership trees): a collection stored in a component
  field belongs to that entity — deep-copied when written to a field or frozen
  into the bulletin board, and freed when the entity despawns or the component
  is detached. Mutating a collection read through a **frozen snapshot** is a
  compile error; reads (`Count`, `Get`, `Has`) are allowed.
- Out-of-range `Get`/`Set`/`RemoveAt` and missing `Map.Get` keys `panic`.
- `Vec2`/`Vec3`/`Vec4` structs; math functions (`sqrt`, `sin`, `cos`, `pow`, `min`, `max`,
  `clamp`, `lerp`).
- `std.rng(seed)` — deterministic seeded RNG; same sequence on every machine. Seeds per entity
  for reproducible per-agent randomness.

### 13.3 Terminal interaction while the world runs

stdin while ticking is delivered via the IO-as-entities pattern: spawn a `TerminalInput` request
entity; each typed line arrives as an attached component next tick; the program `detach`s it after
reading. Consistent with §11 (messages are components; cleanup is the programmer's job).

---

## 14. Memory — Ownership Trees

- Component data lives in cache-friendly **SoA stores** owned per box.
- Heap data (`string`, `List<T>`, `Map<K,V>`) follows **ownership trees**:
  - Every heap value has exactly one owner (an entity, a component field, a local).
  - Freed automatically when its owner dies.
  - Transfers deep-copy (never shared).
  - No cycles are possible by construction (no shared references).
- **No GC, no malloc/free visible to the user, ever.**
- Entity references are generational IDs — stale IDs are detected, never dangling.

### 14.1 Implications

- Two entities cannot share a heap object. If sharing is desired, store the other entity's ID and
  read through the frozen view (the ECS-idiomatic answer).
- The manager-entity pattern (exemplified by kx.spatial, §16) is the recommended way to provide
  shared structures.

---

## 15. Errors

```csharp
var r = LoadProfile("slyrebula");
if (r is Err(msg)) { panic($"load failed: {msg}"); }
```

- `Result<T, E>` for expected failures — the caller must handle them (`is Ok(val)` / `is Err(e)`).
- `panic(msg)` for fatal bugs — stops the program with a message.
- No exceptions. No hidden control flow.

---

## 16. IO-as-Entities and the Spatial Library

### 16.1 IO-as-entities

No blocking calls inside systems. The outside world is modeled as entities:

- Spawn an IO request entity (e.g. `FileRead { path = "data.txt" }`, tagged appropriately).
- A runtime service box performs the IO off the tick path.
- The result **arrives as an attached component** next tick.
- The program `detach`es the result after consuming it.

Console output is the exception (buffered, deterministic flush at commit). Sockets, timers, HTTP,
file IO: all use the request pattern.

### 16.2 kx.spatial (library, written in Kubexic)

Spatial interaction is a **library**, not a language feature:

- `Pos2` / `Pos3` components.
- `Spatial` tag — entities carrying it are spatially visible.
- A singleton index entity with a hash-grid component; a system rebuilds the grid each tick from
  frozen `Pos3` of all `Spatial` entities.
- Helpers: `spatial.Nearby(pos, radius)`, `spatial.Overlap(pos, radius)` — query the frozen grid.
- Accepted trade-off: spatial results are ~1 extra tick stale vs. native AOI; the index strategy
  is swappable.

---

## 17. Future Chapters [Future — approved, not constraining v0]

All core-compatible features, to be implemented in later milestones:

- `switch`/`match` expressions
- Function overloading
- Operator overloading
- Properties (component field sugar)
- Delegates/lambdas (with live-reference capture restrictions)
- Interfaces (as generic constraints; no inheritance)
- Multiple worlds per process
- C interop (`extern`)
- JSON serialization
- Batch spawn API (bulk entity creation for science)
- Formatter + LSP
- Compile-time metadata/codegen hooks (the reflection replacement)

### 17.1 Permanently excluded

These conflict with the language's core invariants and will not be added:

| C# feature | Why excluded | Kubexic answer |
|---|---|---|
| Exceptions | Hidden control flow across ticks breaks determinism and the request model | `Result<T,E>` + `panic` |
| async/await | Reintroduces thread management the language removes | The tick model *is* the async model; IO-entities |
| Runtime reflection | Breaks whole-program analysis (auto-publish, zero-cost channels) | Compile-time metadata/codegen |
| Inheritance | Polymorphic components break SoA layout and box-invariance | Components + generics; interfaces as constraints only |

---

## 18. Compiler and Runtime Architecture (Informative)

### 18.1 Pipeline

```
.kx sources
  → lexer            tokens
  → parser           AST
  → sema             name resolution, type inference, constants
  → mir              match-set inference, tag/interaction analysis, auto-publish sets
  → codegen          LLVM IR (single module, whole-program)
  → object           linked with runtime → native executable
```

### 18.2 Invisible machinery (mapped to the Rebulacian engine)

| Kubexic runtime | Engine equivalent |
|---|---|
| Box partitioning + live rebalancing | `calculateBoxId`, `Organizer` migrations |
| Box → thread scheduling | `BoxExecutor` |
| Per-box SoA entity stores | `EntityStore` |
| Global frozen view (per-tick) | `BulletinBoard` + `GlobalWorldView` |
| Request queues + commit phase | `BoxCommandBuffer` + `CommandCommitter` |
| Generational entity IDs | `EntityIdGenerator` |

### 18.3 Interaction analysis (MIR)

The compiler scans every system body and derives:

1. **Match set** — components touched → the entity requirements (plus explicit `with`/`without`).
2. **Publish set** — components read via `others<C>(tag: X)` → must be frozen-published under tag
   `X`.
3. **Request sites** — `attach`/`detach`/`spawn`/`despawn` targets → commit queue layout.

No tag query in the program → no tag machinery emitted (§10 zero-cost).

---

## 19. Milestones

| Phase | Deliverable |
|---|---|
| **M0** | This specification |
| **M1** | Lexer + Parser + AST (CMake/Ninja, unit tests) |
| **M2** | Type checker: inference, `T?`, Result, constants |
| **M3** | MIR: match-set inference, interaction analysis, auto-publish |
| **M4** | LLVM codegen, single-box programs |
| **M5** | Runtime v1: scheduler, SoA stores, ownership heap, frozen view |
| **M6** | Multi-box: request commit pipeline, `others<>` boards, threading |
| **M7** | Migration + load rebalancing |
| **M8** | stdlib: collections, math, `std.rng`, `TerminalInput`; kx.spatial; samples |

### 19.1 Testing strategy

- Unit tests per compiler phase (GoogleTest).
- End-to-end golden tests: compile `.kx` → run → compare stdout (python3 harness).
- Determinism tests: run identical programs under different `cores` values, assert byte-identical
  output.

---

## 21. Implementation Status

| Phase | Status | Notes |
|---|---|---|
| M0 spec | done | this document |
| M1 lexer/parser | done | 38 tests |
| M2 type checker | done | 27 tests |
| M3 interaction analysis | done | 10 tests |
| M4 LLVM codegen | done | native executables, monomorphized generics |
| M5 runtime v1 | done | SoA stores, tick loop, frozen view |
| M6 multi-box | done | parallel boxes (pthreads), deterministic routing, core-count invariance proven (1 box == 8 boxes, byte-identical) |
| M7 migration | done | deterministic rebalancing; migration is semantically invisible (frozen iteration sorted by entity ID) |
| M8 stdlib v1 | done | kx.spatial (Pos3, Spatial tag, `spatial.Overlap/Nearby` with inline distance filter), arrow demo |
| collections | done | `List<T>` / `Map<K,V>` with ownership-tree semantics (deep copy, free on despawn), foreach over lists, frozen-snapshot mutation rejected at compile time |
| kx.spatial grid index | planned | replace O(N) distance scan with a hash grid (needs nothing new — collections now exist) |

Core guarantees verified end-to-end:
- **Zero data races** — live data only touched by the owning box; others always read the frozen view
- **Core-count invariance** — identical output for any `cores` value
- **Migration invariance** — forced migration produces byte-identical results
- **Determinism** — repeated runs identical

Run with `kxc build <dir> <out>`; `kxc run <dir>`; `kxc fmt <file>`;
`kxc fmt-dir <dir>`; `KUBEXIC_CORES` env var controls box count (default:
all cores); `KX_TRACE=1` traces every attach/detach/despawn request with
component names.

### 21.1 Memory-safety status

Ownership trees are fully enforced for stored data: collections and strings
in fields/collections are dup'd on store, deep-copied into the frozen view,
and freed on despawn/detach/freeze-overwrite. Verified with AddressSanitizer
on a despawn-heavy 2000-entity stress sample (1 and 8 boxes): zero memory
errors, zero collection leaks. Known caveat: string temporaries built at
runtime (interpolation results, `readln`, `Upper()` etc.) that are never
stored leak until process exit — bounded and benign.

---

## 22. Example: Complete Program (Reference)

```
samples/arrow/
  Pos3.kx, Health.kx, Damage.kx, Healing.kx, Arrow.kx, main.kx
```

```csharp
// Pos3.kx
component Pos3 { var x = 0.0; var y = 0.0; var z = 0.0; }

// Health.kx
component Health { var hp = 100; }

// Damage.kx
component Damage { var amount = 10; var sender = EntityId.None; }

// Healing.kx
component Healing { var amount = 5; }

// Arrow.kx
component Arrow { var sender = EntityId.None; }

// ArrowSystem.kx
system ArrowSystem {
    foreach (var hit in spatial.Overlap(Pos3, 0.5)) {
        attach(hit.Id, new Damage { amount = 10, sender = Arrow.sender });
        despawn self;
    }
}

// DamageSystem.kx
system DamageSystem {
    Health.hp -= Damage.amount;
    if (Health.hp <= 0) {
        attach(Damage.sender, new Healing { amount = 5 });
        despawn self;
    } else {
        detach(self, Damage);
    }
}

// main.kx
int main() {
    var world = spawn { Pos3 { x = 0, y = 0, z = 0 }, Health { hp = 100 }, tags [Combatant] };
    var arrow = spawn { Pos3 { x = 0, y = 0, z = 0 }, Arrow { sender = world }, tags [Projectile] };
    run(60);
    return 0;
}
```