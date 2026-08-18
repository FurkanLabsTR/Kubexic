---
title: Getting Started
---

This tutorial walks you through installing the Kubexic toolchain, creating your first project, and understanding how it works.

## 1. Installation

### Build the compiler

Clone the repository and run the build script:

```bash
git clone https://github.com/kubexic/kubexic.git
cd kubexic
./build.sh
```

Then symlink the compiler binary so it is available on your PATH:

```bash
mkdir -p ~/.local/bin
ln -s "$(pwd)/build/kxc" ~/.local/bin/kxc
```

### Install the VS Code extension

The `kubexic-vscode/` directory ships a VS Code extension with syntax highlighting, error diagnostics, and code completion for `.kx` files.

```bash
cd kubexic-vscode
npm install
npm run compile
npx vsce package
```

Install the generated `.vsix` file in VS Code via **Extensions > Install from VSIX**.

### Verify the installation

```bash
kxc
```

You should see the compiler help output listing available commands (`new`, `build`, `run`, `check`, etc.).

## 2. Your First Project

Scaffold a new project with one command:

```bash
kxc new mygame
```

This prints:

```
created project 'mygame'
  files: Counter.kx, CountSystem.kx, main.kx
  build: kxc build mygame
  run:   kxc run mygame
```

Look at what was created:

```bash
ls mygame/
```

```
Counter.kx  CountSystem.kx  main.kx
```

### Counter.kx

```csharp
component Counter {
    var value = 0;
}
```

A **component** holds data. `Counter` has one field, `value`, which starts at `0`.

### CountSystem.kx

```csharp
system CountSystem {
    Counter.value += 1;
    if (Counter.value == 3) {
        std.println($"tick {tick}: counter={Counter.value}");
    }
}
```

A **system** runs logic every tick on every entity that has the components it touches. `CountSystem` accesses `Counter.value`, so it runs on any entity with a `Counter` component. It increments the value by 1 each tick and prints when the counter hits 3.

### main.kx

```csharp
int main() {
    spawn { Counter { value = 0 } };
    run(max, ticks: 5);
    std.println("done");
    return 0;
}
```

The `main` function is the entry point. It spawns an entity with a `Counter` component, runs the tick loop for 5 ticks at maximum speed, then prints "done".

## 3. Build and Run

### Option A: Build then run manually

```bash
kxc build mygame
./a.out
```

### Option B: Build and run in one step

```bash
kxc run mygame
```

Both approaches produce the same output:

```
tick 2: counter=3
done
```

## 4. Understanding the Output

Here is what happened step by step:

1. `main` spawns a single entity with `Counter { value = 0 }`.
2. `run(max, ticks: 5)` starts the tick loop. The runtime runs all systems for 5 ticks.
3. Each tick, `CountSystem` runs on the entity and increments `Counter.value` by 1.
4. At tick 2 (zero-indexed), `Counter.value` reaches 3, so the system prints `tick 2: counter=3`.
5. After 5 ticks the loop ends. `main` resumes and prints `done`.

The counter keeps incrementing past 3 (it reaches 5 by the end), but only the tick where it hits 3 produces a print.

## 5. What Just Happened? (ECS Intro)

Kubexic uses an **Entity Component System** (ECS) architecture. Everything in a running program is built from three concepts:

### Components hold data

A component is a named bag of fields. It has no logic, only state.

```csharp
component Counter {
    var value = 0;
}
```

Components are attached to entities. An entity can have many different components, but at most one of each type.

### Systems run logic

A system is a named block of code that runs once per matching entity, every tick. The system's match set is inferred from which components the body accesses. If a system touches `Counter.value`, it runs on every entity that has a `Counter`.

```csharp
system CountSystem {
    Counter.value += 1;
}
```

No `Get<T>()`, no `entity.` prefix -- component fields are directly in scope.

### Entities are spawned with components

An entity is created by the `spawn` keyword with an initializer list of components:

```csharp
spawn { Counter { value = 0 } };
```

`spawn` returns an `EntityId` you can store and reference later.

### The tick loop runs systems on matching entities

`run(max, ticks: 5)` starts the tick loop. Each tick, every system runs on every entity that matches its requirements. Systems run in alphabetical order. The loop runs until the tick count is exhausted or `std.stop()` is called.

```
Tick 1:  Counter.value goes from 0 to 1
Tick 2:  Counter.value goes from 1 to 2
Tick 3:  Counter.value goes from 2 to 3  ->  prints "tick 2: counter=3"
Tick 4:  Counter.value goes from 3 to 4
Tick 5:  Counter.value goes from 4 to 5  ->  loop ends
```

## 6. Next Steps

- **[Language Basics](/basics/)** -- variables, functions, control flow, and types.
- **[ECS Guide](/ecs/)** -- components, systems, tags, spawning, and the frozen world model.
- **[Collections](/collections/)** -- `List<T>` and `Map<K, V>` inside components.
- **[CLI Reference](/cli/)** -- all `kxc` commands and options.
- **[VS Code](/vscode/)** -- editor setup, diagnostics, and code completion.
