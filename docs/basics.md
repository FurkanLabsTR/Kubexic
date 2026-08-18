---
title: Language Basics
---

# Language Basics

This is a concise reference for Kubexic's core syntax. Kubexic uses C#-style syntax with full type inference -- you never write type annotations on local variables, parameters, or return types.

---

## 1. Variables

Variables are declared with `var`. The type is always inferred from the assigned literal or expression. No type annotations are needed.

```kx
var x = 10;          // int (i32)
var y = 3.14;        // double (f64)
var flag = true;     // bool
var name = "kubexic"; // string
```

### Literals

| Literal | Inferred Type | Description |
|---------|---------------|-------------|
| `5` | `int` (i32) | 32-bit signed integer |
| `5L` | `long` (i64) | 64-bit signed integer |
| `1.5` | `double` (f64) | 64-bit float (science-safe default) |
| `1.5f` | `float` (f32) | 32-bit float |
| `true` | `bool` | Boolean |
| `"text"` | `string` | UTF-8 string |

The `L` suffix on integers and `f` suffix on floats are the only places where you hint a type. Everything else is pure inference.

---

## 2. Constants

Constants are declared with `const` at namespace level. They must be compile-time values. Mutable global state is forbidden in Kubexic.

```kx
const MaxPlayers = 100;
const Gravity = 9.81;
const AppName = "Kubexic";
```

Constants behave like literals -- the compiler inlines their value wherever they are used.

---

## 3. Functions

Functions are declared with `var` (has return value) or `void` (no return value). There is no `fn` keyword. Parameters are untyped -- they act as inferred generics, monomorphized per call site at compile time.

### Expression Body

A single expression serves as the return value. No `return` keyword needed.

```kx
var add(a, b) -> a + b;
var square(n) -> n * n;
var isPositive(n) -> n > 0;
```

### Block Body

Use braces when the function needs multiple statements. Explicit `return` required.

```kx
var Sum(n) {
    var total = 0;
    for (var i = 1; i <= n; i++) {
        total += i;
    }
    return total;
}

var Max(a, b) {
    if (a > b) { return a; }
    return b;
}
```

### Void Functions

Functions with no return value use `void`.

```kx
void Log(msg) {
    std.println(msg);
}

void Greet(name) {
    std.println($"Hello, {name}!");
}
```

### Generic Parameters

Because parameters are untyped, a single function works with any compatible type:

```kx
var add(a, b) -> a + b;   // works with int, long, float, double...

var Distance2(a, b) {
    var dx = a.x - b.x;
    var dy = a.y - b.y;
    var dz = a.z - b.z;
    return dx * dx + dy * dy + dz * dz;
}
```

The compiler monomorphizes the function for each concrete type used at call sites.

---

## 4. Entry Point

Every Kubexic program has exactly one `main` function. It returns `int` and serves as sequential bootstrap before the tick loop starts.

```kx
int main() {
    std.println("Starting...");
    spawn { Health { hp = 100 }, tags [Combatant] };
    run(60);
    std.println("Done.");
    return 0;
}
```

`main` is where you parse arguments, spawn initial entities, and call `run()` to start the simulation.

---

## 5. Comments

```kx
// line comment

/* block comment
   spans multiple lines */
```

Block comments can span multiple lines but do not nest.

---

## 6. String Interpolation

Prefix a string with `$` and embed expressions inside `{}`:

```kx
var name = "world";
std.println($"Hello {name}!");              // "Hello world!"
std.println($"2 + 2 = {2 + 2}");           // "2 + 2 = 4"
std.println($"tick {tick}: count={Counter.value}");
```

Any valid expression can go inside the braces -- function calls, arithmetic, field access, and ternaries all work.

---

## 7. Control Flow

### if / else if / else

```kx
if (Health.hp > 50) {
    std.println("healthy");
} else if (Health.hp > 0) {
    std.println("wounded");
} else {
    std.println("dead");
}
```

### while

```kx
var i = 0;
while (i < 10) {
    i += 1;
}
```

### for

Standard C-style `for` loop with init, condition, and increment:

```kx
for (var i = 0; i < 10; i++) {
    std.println($"i = {i}");
}
```

### foreach

Iterate over a list:

```kx
var items = List<string>();
items.Add("sword");
items.Add("shield");

foreach (var item in items) {
    std.println(item);
}
```

Iterate over frozen entities with `others<>`:

```kx
foreach (var e in others<Health>(tag: Combatant)) {
    // e.Health.hp is available here (read-only)
}
```

Iterate over spatial results:

```kx
foreach (var hit in spatial.Overlap(Pos3, 1.0)) {
    // hit is a frozen snapshot
}
```

### switch / case / default

```kx
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

Multiple case values can share a label. A terminator (`break`, `return`, or `continue`) is required at the end of each case block. String cases use content comparison.

### break, continue, return

```kx
break;          // exit the enclosing loop
continue;       // skip to next iteration
return value;   // exit the enclosing function
```

---

## 8. Operators

### Arithmetic

| Operator | Description |
|----------|-------------|
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |
| `%` | Modulo |

Integer overflow is defined two's-complement wrap (identical on every machine). Division by zero panics.

### Comparison

| Operator | Description |
|----------|-------------|
| `==` | Equal |
| `!=` | Not equal |
| `<` | Less than |
| `>` | Greater than |
| `<=` | Less or equal |
| `>=` | Greater or equal |

### Logical

| Operator | Description |
|----------|-------------|
| `&&` | Logical AND |
| `||` | Logical OR |
| `!`  | Logical NOT |

### Assignment

| Operator | Description |
|----------|-------------|
| `=` | Assign |
| `+=` | Add and assign |
| `-=` | Subtract and assign |
| `*=` | Multiply and assign |
| `/=` | Divide and assign |
| `%=` | Modulo and assign |
| `++` | Increment (postfix) |
| `--` | Decrement (postfix) |

### Ternary

```kx
var max = a > b ? a : b;
```

---

## 9. Type Inference Rules

Kubexic is a var-only language. Users never write type names for local variables, function parameters, or return types. The compiler infers concrete machine types from literals and context.

| You write | Compiler infers |
|-----------|-----------------|
| `var x = 5` | `int` (i32) |
| `var x = 5L` | `long` (i64) |
| `var x = 1.5` | `double` (f64) |
| `var x = 1.5f` | `float` (f32) |
| `var x = true` | `bool` |
| `var x = "text"` | `string` |

Additional inference rules:

- **Component fields** infer types from their default initializer.
- **Function return types** are inferred from `return` statements. A `var` function with no `return` statements is a compile error.
- **Function parameters** are untyped and monomorphized per call site (inferred generics).
- **Constants** infer their type from the literal value.

The only place type names appear in user code is `extern` declarations (C interop), which require explicit parameter types.
