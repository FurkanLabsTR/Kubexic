---
title: Kubexic Documentation
---

# Kubexic Documentation

Kubexic is a general-purpose, compiled programming language where ECS (Entity Component System) is a first-class language feature, not a library. It uses C-like syntax, compiles via LLVM to native executables, and targets games, scientific simulations, data pipelines, and any program shaped as "many things evolving over steps."

---

## Core Philosophy

- The programmer never manages threads or memory. The compiler and runtime own both.
- The world model is: entities composed of components (data), evolved by systems (logic), grouped by tags (visibility).
- Mutable global state is forbidden. All mutable state lives in entities.
- Determinism is guaranteed: programs produce bitwise-identical output regardless of core count.

---

## Quick Example

A simple ECS program that counts ticks:

```csharp
// Counter.kx
component Counter {
    var value = 0;
}

// CountSystem.kx
system CountSystem {
    Counter.value += 1;
    if (Counter.value == 3) {
        std.println($"tick {tick}: counter={Counter.value}");
    }
}

// main.kx
int main() {
    spawn { Counter { value = 0 } };
    run(max, ticks: 5);
    std.println("done");
    return 0;
}
```

Build and run:

```bash
kxc new mygame
kxc run mygame
```

Output:

```
tick 2: counter=3
done
```

---

## Documentation

- [Getting Started](getting-started.md) -- installation, first project, building and running.
- [Language Basics](basics.md) -- variables, functions, control flow, types, operators.
- [ECS Guide](ecs.md) -- components, systems, tags, spawning, the frozen world model.
- [Collections & Spatial](collections.md) -- `List<T>`, `Map<K,V>`, and spatial queries.
- [CLI Reference](cli.md) -- all `kxc` commands and options.
- [VS Code Extension](vscode.md) -- editor setup, diagnostics, and code completion.
- [Kubex Package Manager](kubex-tutorial.md) -- project management, dependencies, publishing, registry.

---

## Resources

- [GitHub Repository](https://github.com/kubexic/kubexic) -- source code, issues, and releases.
- [Language Specification](https://github.com/kubexic/kubexic/blob/main/spec/SPEC.md) -- the normative reference for the language.
