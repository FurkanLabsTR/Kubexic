# Kubexic Language Documentation

---

## 1. Introduction

### What is Kubexic?

Kubexic is a general-purpose, compiled programming language where **ECS (Entity Component System) is a first-class language feature**, not a library. It uses C-like syntax, compiles via LLVM to native executables, and targets games, scientific simulations, data pipelines, and any program shaped as "many things evolving over steps."

Source file extension: **`.kx`**
Compiler driver: **`kxc`**

### Core Philosophy

- The programmer **never manages threads or memory**. The compiler and runtime own both.
- The world model is: **entities** composed of **components** (data), evolved by **systems** (logic), grouped by **tags** (visibility).
- Mutable global state is **forbidden**. All mutable state lives in entities.
- Determinism is guaranteed: programs produce **bitwise-identical output** regardless of core count.

> **The Core Law**: Self is live. Everything else is frozen.
> -- SPEC Section 2

The entity a system is currently processing is read and written immediately. Every other entity is a frozen snapshot from last tick, read-only. Cross-entity communication is always mediated by component attachments, applied deterministically at tick commit.

### Toolchain

| Component | Choice |
|---|---|
| Implementation language | C++17+ |
| Compiler backend | LLVM 21 |
| Runtime | C (compiled from source) |
| Build system | build.sh (g++) |
| Compiler driver | `kxc` |
| Source extension | `.kx` |
| VS Code extension | `kubexic-vscode/` (syntax + native editor features) |

### Project Layout

```
Kubexic/
  spec/SPEC.md              -- language specification
  src/                      -- compiler sources (lexer, parser, ast, sema, mir, codegen)
  runtime/runtime.c         -- ECS runtime library (C, compiled from source)
  tools/kxc/                -- compiler driver CLI
  tests/                    -- unit + end-to-end golden tests
  samples/                  -- example .kx programs
  kubexic-vscode/           -- VS Code extension (syntax + native editor features)
  DOCUMENTATION.md          -- this file
```

---

## 2. Basic Syntax

### Variables

Type is always inferred. Never write type names for local variables.

```csharp
var x = 10;        // int (i32)
var y = 3.14;      // double (f64)
var flag = true;   // bool
var name = "kubexic"; // string
```

Literals infer types as follows (SPEC Section 4.1):

| Literal | Inferred Type |
|---|---|
| `5` | `int` (i32) |
| `5L` | `long` (i64) |
| `1.5` | `double` (f64) |
| `1.5f` | `float` (f32) |
| `true` | `bool` |
| `"text"` | `string` |

### Constants

Constants are compile-time values declared at namespace level. Mutable global state is forbidden.

```csharp
const MaxPlayers = 100;
const Gravity = 9.81;
```

SPEC Section 4.4: "Values are inferred; must be compile-time constants."

### Functions

No `fn` keyword. Return type is inferred from `return` statements. Parameters are untyped and work as inferred generics, monomorphized at compile time per call site.

```csharp
var add(a, b) -> a + b;            // expression body (implicit return)
var Sum(n) {
    var total = 0;
    for (var i = 1; i <= n; i++) {
        total += i;
    }
    return total;
}
```

SPEC Section 5: "Return type inferred from `return` statements; `var` with no returns is an error."

### Entry Point

Every program has exactly one `main` function. It returns `int` and serves as sequential bootstrap.

```csharp
int main() {
    std.println("Starting simulation...");
    spawn { Health { hp = 100 }, tags [Combatant] };
    run(60);
    return 0;
}
```

### Comments

```csharp
// line comment
/* block comment */
```

### String Interpolation

Use `$"text {expr}"` to embed expressions in strings.

```csharp
var name = "world";
std.println($"Hello {name}!");           // "Hello world!"
std.println($"2 + 2 = {2 + 2}");        // "2 + 2 = 4"
std.println($"tick {tick}: count={Counter.value}");
```

### Print

```csharp
std.print("no newline");
std.println("with newline");
```

In systems, output is buffered per box and flushed deterministically at commit. In `main`, it is immediate (SPEC Section 13.1).

---

## 3. Types

### Primitives

| Type | Description |
|---|---|
| `int` | 32-bit signed integer (i32) |
| `long` | 64-bit signed integer (i64) |
| `float` | 32-bit IEEE-754 float (f32) |
| `double` | 64-bit IEEE-754 float (f64) -- science-safe default |
| `byte` | 8-bit unsigned integer (u8) |
| `bool` | Boolean |
| `string` | UTF-8 string (heap-allocated, ownership-tracked) |

Users never write type names directly. These are internal machine types inferred from literals (SPEC Section 4.1).

### EntityId

Opaque 64-bit generational handle. `EntityId.None` is the null-ish sentinel. Used in `attach`/`detach`/`despawn` and as component field payloads. A stale ID (target despawned) is a safe no-op and never dereferences (SPEC Section 4.2).

```csharp
component Damage {
    var amount = 10;
    var sender = EntityId.None;
}
```

### Optional

No `null` keyword. `T?` marks an optional value (SPEC Section 4.3).

```csharp
string? name = std.readln();
if (name is string s) { std.println($"hello {s}"); }
var v = name.ValueOr("unknown");
```

### Result

`Result<T, E>` for expected failures. The caller must handle them.

```csharp
var r = LoadProfile("player");
if (r is Err(msg)) { panic($"load failed: {msg}"); }
if (r is Ok(val)) { /* use val */ }
```

SPEC Section 15: "No exceptions. No hidden control flow."

### User-Defined Types

**Structs** -- plain data grouping, no inheritance:

```csharp
struct Vec3 {
    var x = 0.0;
    var y = 0.0;
    var z = 0.0;
}
```

**Enums** -- simple integer-backed named constants:

```csharp
enum Direction { North, East, South, West }
```

SPEC Section 9: "Structs are plain data grouping; no inheritance. Enums are simple integer-backed named constants."

### Collections

```csharp
List<T>     // ordered list
Map<K, V>   // key-value map
```

See Section 9 for full details.

---

## 4. ECS Primitives

### Components -- Pure Data

Components are value-ish data holders attached to entities. No logic inside components. Fields always have a default initializer; the type is inferred from it.

```csharp
// Health.kx
component Health {
    var hp = 100;
    var name = "unknown";
}

// Damage.kx -- a message component
component Damage {
    var amount = 10;
    var sender = EntityId.None;
}
```

Rules (SPEC Section 6):
- A component type is attached to an entity **at most once**. `attach` on an existing type is an **upsert** (replaces the payload).
- Cleanup is the programmer's job: `detach(self, Damage)` consumes a message component; leaving it attached re-runs dependent systems every tick (deliberate DoT/buff pattern).
- Fields may hold heap data (`string`, `List<T>`, `Map<K,V>`, structs) managed by ownership trees.

### Systems -- Logic

A system is a name and a body. The body runs **once per matching entity, every tick**. Component fields are directly in scope: no `Get<T>()`, no `e.` prefix, no `update()` wrapper.

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

**Match-set inference** (SPEC Section 7.1): The match set is inferred from the components the body touches. If the body accesses `Damage.amount` and `Health.hp`, the system runs on entities that have **both** `Damage` and `Health`. An entity missing any required component is silently skipped -- never an error.

**Explicit `with`/`without` clauses** (SPEC Section 7.2):

```csharp
// Explicit component requirements:
system PoisonTick with (Health, Poisoned) { Health.hp -= 1; }

// Exclusion filter:
system Regen without (Dead) { Health.hp += 2; }
```

**Execution order** (SPEC Section 7.4): Systems run in alphabetical order by name each tick. `[Order(n)]` overrides: lower `n` runs first; ties broken alphabetically.

**Builtins inside a system body** (SPEC Section 7.3):

| Builtin | Meaning |
|---|---|
| `self` | The current entity (`.Id` yields its EntityId) |
| `dt` | Tick delta time (seconds as double) |
| `tick` | Current tick number (u64) |

### Tags -- Visibility Filters

Tags are the publication mechanism: an entity carrying a tag publishes its frozen state under that tag. Any system may query the frozen world by tag.

```csharp
tag Combatant;
tag Projectile;
tag Spatial;
```

**Tag hierarchy** (SPEC Section 10): Tags support single-parent inheritance.

```csharp
tag Actor;
tag Combatant : Actor;      // Combatant is-a Actor
tag Monster   : Combatant;
tag Player    : Combatant;
```

Matching by a tag includes its subtags by default. Compiled to bitmasks; a tag check is one AND instruction. Maximum 64 tags per program in v0.

**Zero-cost**: if no system queries by tag, no tag/board machinery is emitted at all. Untagged entities are invisible to tag queries and addressable only by their EntityId.

### The Four Verbs

Only mutations are possible through these four operations (SPEC Section 11):

| Statement | Effect |
|---|---|
| `attach(id, comp)` | Add or upsert a component on any entity; applied next tick |
| `detach(id, ComponentType)` | Remove a component; applied next tick |
| `spawn { ... }` | Create an entity; applied at commit; ID returned immediately |
| `despawn self` / `despawn id` | Remove an entity; applied next tick |

**The reactive model** (SPEC Section 11.1): Attaching a component is how systems are invoked. The target entity becomes a match for every system whose inferred match set includes that component, starting next tick. There is no separate event system -- the component appearing *is* the event.

### Match Sets

Systems automatically match entities by their component requirements. The match set is inferred from the components the body touches, combined with any explicit `with`/`without` clauses. Accessing a component not in the effective match set is a compile error.

### Without Lists

The `without` clause excludes entities with specified components from matching:

```csharp
system CountSystem without (Dead) {
    Counter.value += 1;
}
```

This system runs on entities that have `Counter` but **not** `Dead`.

---

## 5. Entity Operations

### Spawning Entities

```csharp
var arrow = spawn {
    Pos3 { x = 0, y = 0, z = 0 },
    Arrow { sender = target },
    tags [Projectile, Spatial]
};
```

`spawn` returns the entity's ID immediately (pre-committed). The entity materializes at commit. Structural changes from `spawn` are requests applied deterministically at commit (SPEC Section 11).

### Attaching Components

```csharp
attach(self, new Poison { damage = 5 });
attach(hit.Id, new Damage { amount = 10, sender = Arrow.sender });
```

`attach` on a dead ID is a safe no-op. `attach` on an existing component type is an upsert (payload replaced).

### Detaching Components

```csharp
detach(self, Damage);
detach(self, Poison);
```

Removing a component from an entity. Consumes the component -- the entity no longer matches systems requiring it.

### Despawning Entities

```csharp
despawn self;
despawn someEntityId;
```

Destroys the entity. `despawn self` is also a request applied at commit, but field writes to self are immediate.

### Getting Entity ID

```csharp
self.Id    // EntityId of the current entity within a system
```

---

## 6. Frozen World Model

### The Core Law

> Self is live. Everything else is frozen.
> -- SPEC Section 2

- The entity a system is currently processing: **read and written immediately**.
- Every other entity: a **frozen snapshot from last tick**, **read-only**.
- You can never write another entity directly. You attach a component to it. The component is the message.

### Reading Other Entities

Use `others<C>(tag: X)` to iterate frozen entities with component `C` under tag `X`. Iteration order is **sorted by entity ID** -- deterministic on any machine/core count. Results are read-only.

```csharp
// Read all entities with Counter component under the Counting tag:
foreach (var t in others<Counter>(tag: Counting)) {
    if (t.Counter.value > seen) {
        seen = t.Counter.value;
    }
}
```

SPEC Section 10.1: "`others<C>(tag: X)` returns frozen snapshots of entities carrying `X` (or subtags) with component `C`."

### Exact vs Inclusive Tag Matching

```csharp
// Inclusive: matches Creature and all subtags (Monster, Player, etc.)
foreach (var t in others<Counter>(tag: Creature)) { ... }

// Exact: matches only Monster, not subtags of Monster
foreach (var t in others<Counter>(tag: exact Monster)) { ... }
```

SPEC Section 10: "`tag: exact X` matches only entities carrying exactly `X` (not subtags)."

### Guarantees from the Frozen World

| Guarantee | Mechanism |
|---|---|
| Zero data races | Live data touched only by the owning box; everything else is frozen copies |
| Box-invariant semantics | Program behavior never depends on which box an entity lives in |
| Core-count invariance | Results are bitwise-identical for any `cores` value |
| Determinism | Frozen iteration is sorted by entity ID; systems run in a fixed order |
| No dangling references | Generational entity IDs; stale targets are safe no-ops |

---

## 7. Control Flow

### Conditionals

```csharp
if (Health.hp > 50) {
    // ...
} else if (Health.hp > 0) {
    // ...
} else {
    // ...
}
```

### While Loop

```csharp
var i = 0;
while (i < 3) {
    i += 1;
    if (i == 2) {
        continue;
    }
    std.println($"while: {i}");
}
```

### For Loop

```csharp
for (var i = 0; i < 10; i++) {
    // ...
}
```

### Foreach

```csharp
foreach (var item in list) {
    total += 1;
}

foreach (var e in others<Health>(tag: Combatant)) {
    // iterate frozen entities
}
```

### Switch

```csharp
switch (Counter.value) {
    case 1:
        std.println("one");
        break;
    case 2:
    case 3:
        std.println("two or three");
        break;
    default:
        std.println("other");
        break;
}
```

SPEC Section 13.1b: Shared labels (multiple `case` values), `break`/`return`/`continue` terminators required, string cases use content comparison.

### Return, Break, Continue

```csharp
return value;   // exit function
break;          // exit loop
continue;       // skip to next iteration
```

---

## 8. Operators

### Arithmetic

```
+   -   *   /   %
```

### Comparison

```
==   !=   <   >   <=   >=
```

### Logical

```
&&   ||   !
```

### Assignment

```
=   +=   -=   *=   /=   %=   ++   --
```

### Ternary

```csharp
var max = a > b ? a : b;
```

### Operator Overloading

Define on structs with convention functions (SPEC Section 13.1d):

```csharp
var (a: Vec3) + (b: Vec3) -> Vec3 {
    var result = Vec3 { };
    result.x = a.x + b.x;
    result.y = a.y + b.y;
    result.z = a.z + b.z;
    return result;
}
```

Convention functions: `op_add`, `op_sub`, `op_mul`, `op_div`, `op_mod`, `op_eq`, `op_ne`, `op_lt`, `op_le`, `op_gt`, `op_ge`. Triggered when either operand is a struct. Overloaded by arity (number of operands) -- `var F(a)` and `var F(a, b)` coexist (SPEC Section 13.1d).

### Numeric Semantics

- Integer overflow: defined two's-complement wrap (identical on every machine).
- Division by zero: `panic`.
- Floating point: strict IEEE-754; no reassociation unless `[FastMath]`.

---

## 9. Collections

### List\<T\>

```csharp
var items = List<string>();     // construct
items.Add("sword");             // append
items.Get(0);                   // read by index (panics if out of range)
items.Set(0, "shield");         // write by index
items.RemoveAt(0);              // remove by index
items.Clear();                  // remove all
var n = items.Count;            // property: number of elements
```

Iteration:

```csharp
foreach (var it in items) {
    total += 1;
}
```

### Map\<K, V\>

```csharp
var stats = Map<string, long>();    // construct
stats.Set("hits", 42);              // upsert
stats.Get("hits");                  // read (panics if missing)
stats.Has("hits");                  // check existence
stats.Remove("hits");               // remove
stats.Clear();                      // remove all
var n = stats.Count;                // property
```

### Element Types

Supported element types: `int`, `long`, `float`, `double`, `bool`, `string`, `EntityId`. Nested collections are not supported yet (SPEC Section 13.2).

### Ownership Semantics

Collections stored in component fields belong to that entity. They are deep-copied on store, deep-copied into the frozen view, and freed on despawn/detach/freeze-overwrite. Mutating a collection read through a frozen snapshot is a compile error; reads (`Count`, `Get`, `Has`) are allowed.

In `spawn` and `attach` initializers, a fresh `List()`/`Map()` constructor is taken by the entity (no copy) -- ownership transfers (SPEC Section 13.2).

### Example

From `samples/collections/`:

```csharp
// Inventory.kx
component Inventory {
    var items = List<string>();
    var stats = Map<string, long>();
}

// InventorySystem.kx
system InventorySystem {
    Inventory.items.Add($"item-{tick}");
    if (tick < 5) {
        Inventory.stats.Set("hits", tick);
    }
    if (tick == 5) {
        var total = 0;
        foreach (var it in Inventory.items) {
            total += 1;
        }
        var first = Inventory.items.Get(0);
        std.println($"tick {tick}: count={Inventory.items.Count} iterated={total} first={first} hits={Inventory.stats.Get("hits")}");
        Inventory.items.Clear();
        Inventory.stats.Remove("hits");
    }
    if (tick == 7) {
        var hasHits = Inventory.stats.Has("hits");
        std.println($"tick {tick}: items={Inventory.items.Count} hasHits={hasHits}");
    }
}

// main.kx
int main() {
    spawn {
        Inventory { items = List<string>(), stats = Map<string, long>() },
        tags [Tracked]
    };
    run(max, ticks: 8);
    std.println("collections demo done");
    return 0;
}
```

---

## 10. Spatial Queries

Spatial interaction is built into the runtime as C functions, exposed through compiler intrinsics. The `Spatial` tag and position components are user-defined; the grid and query functions are runtime-provided.

### Requirements

- Entities must carry the `Spatial` tag to be spatially visible.
- Position component must have `x`, `y` (and optionally `z`) fields.

### API

```csharp
spatial.Overlap(Pos3, radius)    // find entities within radius of current entity's position
spatial.Nearby(Pos3, radius)     // alias for Overlap
```

Both return frozen snapshots. Iteration order is sorted by entity ID. Results are ~1 extra tick stale vs. native AOI (SPEC Section 16.2).

### Example

From `samples/arrow/ArrowSystem.kx`:

```csharp
system ArrowSystem {
    Pos3.z += 1.0;
    foreach (var hit in spatial.Overlap(Pos3, 0.5)) {
        attach(hit.Id, new Damage { amount = 10, sender = Arrow.sender });
        std.println($"tick {tick}: arrow hit");
        despawn self;
    }
}
```

---

## 11. Generics

Generics are monomorphized at compile time per call site. All call sites are known via whole-project compilation (SPEC Section 5).

### Generic Functions

Parameters are untyped -- inferred from usage:

```csharp
var max(a, b) -> a > b ? a : b;   // works with int, double, string, etc.

var Distance2(a, b) {
    var dx = a.x - b.x;
    var dy = a.y - b.y;
    var dz = a.z - b.z;
    return dx * dx + dy * dy + dz * dz;
}
```

### Generic Components

```csharp
component Wrapper<T> {
    var value: T;
}
```

### Operator Overloading (Polymorphic)

```csharp
var (a: Vec3) + (b: Vec3) -> Vec3 { ... }
```

Any struct can define operators; the compiler monomorphizes the operator function per type (SPEC Section 13.1d).

---

## 12. Error Handling

### Result\<T, E\>

For expected failures. The caller must handle them explicitly.

```csharp
var r = LoadProfile("player");
if (r is Err(msg)) {
    panic($"load failed: {msg}");
}
if (r is Ok(val)) {
    // use val
}
```

### panic

Halts the program with a message. Used for fatal bugs.

```csharp
panic("unexpected state");
```

SPEC Section 15: "No exceptions. No hidden control flow."

---

## 13. Extern (C Interop)

Call C functions directly with typed parameters (the one place type names appear in user code) (SPEC Section 13.1e).

```csharp
extern double sqrt(double x);
extern fun printf(fmt: string, ...);
```

Link libraries with the `[Link]` attribute:

```csharp
[Link("m")] extern double sqrt(double x);
```

---

## 14. The Tick Loop (Runtime Architecture)

Per tick, the runtime executes four phases in order (SPEC Section 12):

### Phase 1: Deliver

Apply requests from the previous commit to their targets' boxes.

### Phase 2: Simulate

All boxes run their systems in parallel on the thread pool.

### Phase 3: Commit

Apply this tick's requests in deterministic order (system order, then emission order within a system).

### Phase 4: Freeze

Publish each box's declared components to the global frozen view. Entities awaiting despawn are removed.

### Multi-Box Parallelism

- Default: **all CPU cores**. Boxes are partitioned, scheduled, and load-rebalanced automatically.
- Partitioning: `box = hash(entityId) % boxCount`; boxCount = cores.
- **Core-count invariance**: results are bitwise-identical for any `cores` value.
- **Migration invariance**: entities migrate between boxes every 30 ticks; semantics unaffected by the Core Law because frozen iteration is sorted by entity ID.

### Performance Optimizations

The runtime includes several optimizations for large entity counts:

- **Tag Index**: Per-tag sorted arrays built after each freeze. `others<>` queries use indexed lookup (O(log N + M)) instead of linear scan (O(N)).
- **Spatial Hash Grid**: 3D hash grid for `spatial.Overlap`/`spatial.Nearby`. Only queries nearby cells instead of scanning all entities. Configurable cell size via `kx_spatial_set_cell_size()`.
- **K-way Merge**: Frozen view merge uses min-heap k-way merge (O(N·log(boxCount))) instead of qsort (O(N·log(N))).
- **Free-list Spawn**: Entity allocation uses a free-slot stack (O(1)) instead of linear scan (O(size)).

### run() Modes

```csharp
run(60);                         // Realtime, 60 ticks/sec
run(max, ticks: 1000000);       // Headless batch -- run N ticks as fast as possible
run(60, cores: 0.5);            // Use 50% of cores
run(60, cores: 4);              // Use exactly 4 cores
run(60, cores: 1);              // Single-threaded debug mode
```

`run` returns when `std.stop()` is called or the run is exhausted; execution continues in `main` (SPEC Section 12.2).

### Environment Variables

- `KUBEXIC_CORES` -- controls box count (default: all cores).
- `KX_TRACE=1` -- traces every attach/detach/despawn request with component names.

---

## 15. Type Inference Rules

Kubexic uses **var-only** declarations. Users never write type names for local variables, function parameters, or return types. The compiler infers concrete machine types from literals and context (SPEC Section 4).

| You write | Compiler infers |
|---|---|
| `var x = 5` | `int` (i32) |
| `var x = 5L` | `long` (i64) |
| `var x = 1.5` | `double` (f64) |
| `var x = 1.5f` | `float` (f32) |
| `var x = true` | `bool` |
| `var x = "text"` | `string` |

Component fields infer types from default initializers. Function return types are inferred from `return` statements. The one exception is `extern` declarations, which require explicit type annotations on parameters.

---

## 16. Operator Overloading

Operators are overloaded by defining convention functions on structs. The compiler recognizes these by name and arity.

### Convention Functions

| Operator | Function Name |
|---|---|
| `+` | `op_add` |
| `-` | `op_sub` |
| `*` | `op_mul` |
| `/` | `op_div` |
| `%` | `op_mod` |
| `==` | `op_eq` |
| `!=` | `op_ne` |
| `<` | `op_lt` |
| `<=` | `op_le` |
| `>` | `op_gt` |
| `>=` | `op_ge` |

### Example

```csharp
var (a: Vec3) + (b: Vec3) -> Vec3 {
    var result = Vec3 { };
    result.x = a.x + b.x;
    result.y = a.y + b.y;
    result.z = a.z + b.z;
    return result;
}
```

Overloaded by arity: `var F(a)` and `var F(a, b)` are distinct functions. Triggered when either operand is a struct (SPEC Section 13.1d).

---

## 17. Exact vs Inclusive Tag Matching

### Inclusive (default)

```csharp
foreach (var t in others<Counter>(tag: Combatant)) { ... }
```

Matches entities tagged with `Combatant` **and** all subtags (`Monster`, `Player`, etc.). This is the default behavior.

### Exact

```csharp
foreach (var t in others<Counter>(tag: exact Monster)) { ... }
// or equivalently:
foreach (var t in others<Counter>(tag: ~Monster)) { ... }
```

Matches **only** entities tagged exactly with `Monster`, excluding subtags. Useful when you need to distinguish between tag hierarchy levels.

### Example from samples/features/

```csharp
// Tags.kx
tag Creature;
tag Player : Creature;
tag Monster : Creature;

// WatchSystem.kx
system WatchSystem {
    var count = 0;
    foreach (var t in others<Counter>(tag: Creature)) {
        count += 1;                          // includes Players and Monsters
    }
    var exactCount = 0;
    foreach (var t in others<Counter>(tag: exact Monster)) {
        exactCount += 1;                     // only Monsters, not Players
    }
    if (count > 0) {
        std.println($"tick {tick}: creatures={count} exactMonsters={exactCount}");
    }
}
```

---

## 18. Complete Example

A full working program demonstrating ECS, systems, tags, spatial queries, and collections. Adapted from the `samples/arrow/` directory.

### Tags.kx

```csharp
tag Combatant;
tag Projectile;
tag Spatial;
```

### Pos3.kx

```csharp
component Pos3 {
    var x = 0.0;
    var y = 0.0;
    var z = 0.0;
}
```

### Health.kx

```csharp
component Health {
    var hp = 100;
    var name = "unknown";
}
```

### Damage.kx

```csharp
component Damage {
    var amount = 10;
    var sender = EntityId.None;
}
```

### Healing.kx

```csharp
component Healing {
    var amount = 5;
}
```

### Arrow.kx

```csharp
component Arrow {
    var sender = EntityId.None;
}
```

### ArrowSystem.kx

```csharp
system ArrowSystem {
    Pos3.z += 1.0;
    foreach (var hit in spatial.Overlap(Pos3, 0.5)) {
        attach(hit.Id, new Damage { amount = 10, sender = Arrow.sender });
        std.println($"tick {tick}: arrow hit");
        despawn self;
    }
}
```

### DamageSystem.kx

```csharp
system DamageSystem {
    Health.hp -= Damage.amount;
    if (Health.hp <= 0) {
        attach(Damage.sender, new Healing { amount = 5 });
        std.println($"tick {tick}: target destroyed");
        despawn self;
    } else {
        detach(self, Damage);
    }
}
```

### HealingSystem.kx

```csharp
system HealingSystem {
    Health.hp += Healing.amount;
    detach(self, Healing);
}
```

### main.kx

```csharp
int main() {
    var target = spawn {
        Pos3 { x = 0, y = 0, z = 30 },
        Health { hp = 10 },
        tags [Combatant, Spatial]
    };
    spawn {
        Pos3 { x = 0, y = 0, z = 0 },
        Arrow { sender = target },
        tags [Projectile, Spatial]
    };
    run(max, ticks: 35);
    std.println("arrow demo done");
    return 0;
}
```

### What Happens

1. `main` spawns a target entity at z=30 with `Health` and `Combatant`+`Spatial` tags, and an arrow entity at z=0 with `Arrow` and `Projectile`+`Spatial` tags.
2. `run(max, ticks: 35)` starts the tick loop at max speed.
3. Each tick, `ArrowSystem` moves the arrow forward by incrementing `Pos3.z` by 1.0, then checks for nearby entities using `spatial.Overlap`.
4. When the arrow reaches z=30 (within 0.5 radius of the target), it attaches a `Damage` component to the target and despawns itself.
5. `DamageSystem` processes the damage, reducing `Health.hp`. Since hp drops to 0, it despawns the target and sends a `Healing` message to the arrow's sender.
6. After 35 ticks, `run` returns and `main` prints the completion message.

---

## 19. std Library Reference

### Console and Process Control

| Call | Where | Effect |
|---|---|---|
| `std.print(x)` / `std.println(x)` | anywhere | Buffered in systems, immediate in main |
| `std.readln()` | main only | Reads a line from stdin; returns `string?` |
| `std.stop()` | anywhere | Graceful: finishes current tick, `run()` returns |
| `std.exit(code)` | anywhere | Terminates immediately with exit code |
| `std.log(level, msg)` | anywhere | Deterministic, ordered logging |

### Math Functions

`std.sqrt`, `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `atan2`, `pow`, `exp`, `log`, `log2`, `log10`, `floor`, `ceil`, `round`, `min`, `max`, `abs`, `clamp(x, lo, hi)`, `lerp(a, b, t)`.

### RNG

```csharp
var r = std.rng(seed);       // deterministic seeded RNG
r.Next();                     // long
r.NextInt(n);                 // 0..n-1
r.NextDouble();               // 0..1
```

Same seed produces the same sequence on any machine, any core count.

### String Methods

`Length` (property), `Substring(start, len)`, `Contains(s)`, `StartsWith(s)`, `EndsWith(s)`, `Upper()`, `Lower()`. `==`/`!=` compare content (not pointers) (SPEC Section 13.1c).

---

## 20. Building and Running

### Project Scaffolding

```bash
kxc new <project-name>                # create a new project with component, system, and main
```

This creates a minimal ECS project:
- `Counter.kx` — a component
- `CountSystem.kx` — a system that uses it
- `main.kx` — spawns an entity and runs the tick loop

### Building

```bash
kxc build <dir>                       # compile to native executable (default: a.out)
kxc build <dir> <output>              # compile with custom output name
kxc run <dir>                         # compile and run immediately
```

### Cross-Compilation

```bash
kxc build --target <triple> <dir>     # cross-compile for a different platform
```

Supported targets:

| Target triple | Platform |
|---|---|
| `x86_64-linux-gnu` | Linux x86-64 (default) |
| `aarch64-linux-gnu` | Linux ARM64 |
| `arm-linux-gnueabihf` | Linux ARM 32-bit |
| `x86_64-apple-darwin` | macOS Intel |
| `aarch64-apple-darwin` | macOS Apple Silicon |
| `x86_64-pc-windows-msvc` | Windows x86-64 |

Cross-compilation requires the matching cross-compiler to be installed:
```bash
# Ubuntu/Debian ARM64:
sudo apt install gcc-aarch64-linux-gnu

# Ubuntu/Debian ARM 32-bit:
sudo apt install gcc-arm-linux-gnueabihf

# Ubuntu/Debian Windows:
sudo apt install gcc-mingw-w64-x86-64
```

### Formatting

```bash
kxc fmt <file>                        # format a single file
kxc fmt-dir <dir>                     # format all files in a directory
```

### Checking

```bash
kxc check <file>                      # semantic-check a single file
kxc check-dir <dir>                   # semantic-check all files in a directory
```

### Environment Variables

- `KUBEXIC_CORES=<n>` — override core count (default: all cores)
- `KX_TRACE=1` — trace every attach/detach/despawn request with component names

---

## 21. VS Code Extension

The `kubexic-vscode/` directory contains a full VS Code extension with:

### Features

- **Syntax highlighting** for `.kx` files (TextMate grammar covering all keywords, types, strings, comments, ECS primitives)
- **Error diagnostics** — runs `kxc check` on save, shows errors inline
- **Code completion** — keywords, `std.*` functions, `spatial.*` functions, component/system/tag names
- **Hover info** — shows component fields, system/tag declarations
- **Document symbols** — outline view for components, systems, tags, structs, enums
- **Go-to-definition** — jump to declarations across the workspace
- **Editor features** — bracket matching, auto-closing pairs, code folding, comment toggle

### Installation

```bash
cd kubexic-vscode
npm install
npm run compile
npx vsce package
# Install the generated .vsix in VS Code via Extensions > Install from VSIX
```

### Configuration

| Setting | Default | Description |
|---|---|---|
| `kubexic.kxcPath` | `"kxc"` | Path to the `kxc` compiler binary |
| `kubexic.checkOnSave` | `true` | Run diagnostics on file save |

---

## 22. Permanently Excluded Features

These conflict with the language's core invariants and will never be added (SPEC Section 17.1):

| Feature | Why excluded | Kubexic answer |
|---|---|---|
| Exceptions | Hidden control flow across ticks breaks determinism | `Result<T,E>` + `panic` |
| async/await | Reintroduces thread management the language removes | The tick model *is* the async model; IO-entities |
| Runtime reflection | Breaks whole-program analysis | Compile-time metadata/codegen |
| Inheritance | Polymorphic components break SoA layout | Components + generics; interfaces as constraints only |
