---
title: ECS Guide
---

# ECS Guide

ECS (Entity Component System) is not a library in Kubexic -- it **is** the language. Every program is a world of entities composed of components (data), evolved by systems (logic), and grouped by tags (visibility). This guide covers every ECS concept you need.

---

## 1. What is ECS?

The three pillars:

- **Entities** are opaque 64-bit generational IDs. They have no data and no logic. They are handles -- slot identifiers in the world.
- **Components** are plain data attached to entities. A `Health` component holds `hp`. A `Damage` component holds `amount`. Components never contain logic.
- **Systems** are named functions that run once per matching entity every tick. A `DamageSystem` reads `Health.hp` and `Damage.amount`, computes the result, and writes back to `Health.hp`.

A fourth concept, **tags**, controls visibility -- which entities can be seen by `others<>` queries.

Together: you attach components to entity IDs, systems iterate over entities that have the right components, and tags let systems see each other's frozen state.

---

## 2. Components

### Declaration

Components are declared with the `component` keyword. Every field has a default initializer -- the type is inferred from it.

```csharp
component Health {
    var hp = 100;
    var name = "unknown";
}

component Damage {
    var amount = 10;
    var sender = EntityId.None;
}

component Velocity {
    var dx = 0.0;
    var dy = 0.0;
    var dz = 0.0;
}
```

Fields can be `int`, `long`, `float`, `double`, `bool`, `string`, `EntityId`, `List<T>`, `Map<K,V>`, or structs. You never write type names -- the compiler infers from the default.

### One component type per entity

An entity can hold at most one instance of each component type. If you `attach` a component type that already exists on the entity, it **upserts** -- the old payload is replaced.

```csharp
// Entity has Health.hp = 100
attach(self, new Health { hp = 50 });
// Now Health.hp = 50 -- the old Health was replaced
```

### Message components

Components are also the event/message system. There is no separate `event` keyword. A component like `Damage` acts as a message: attach it to an entity, and any system whose match set includes `Damage` will process it next tick.

```csharp
// Attaching Damage to an entity makes it a target for DamageSystem
attach(target, new Damage { amount = 10, sender = self.Id });
```

Whether you detach the component after processing or leave it attached is a design choice. Detaching consumes the message. Leaving it attached re-runs dependent systems every tick -- useful for damage-over-time or persistent buffs.

---

## 3. Systems

### Declaration

Systems are declared with the `system` keyword. The body runs once per matching entity every tick.

```csharp
system DamageSystem {
    Health.hp -= Damage.amount;
    if (Health.hp <= 0) {
        despawn self;
    } else {
        detach(self, Damage);
    }
}
```

### Direct field access

Inside a system body, component fields are directly in scope. No `Get<T>()`, no `e.` prefix, no `update()` wrapper. Write `Health.hp`, not `entity.Health.hp`.

### Match-set inference

The compiler infers which entities a system matches from the components the body touches. If you read `Health.hp` and `Damage.amount`, the system runs on entities that have **both** `Health` and `Damage`.

An entity missing any required component is silently skipped. It is never an error.

```csharp
system PoisonTick with (Health, Poisoned) {
    Health.hp -= 1;
}
```

### Explicit with/without

When inference cannot express your intent, use `with` and `without`:

```csharp
// Must have Health and Poisoned
system PoisonTick with (Health, Poisoned) { Health.hp -= 1; }

// Must have Health, must NOT have Dead
system Regen without (Dead) { Health.hp += 2; }

// Combine both
system BuffSystem with (Health, Buff) without (Dead) { ... }
```

Accessing a component not in the effective match set is a compile error.

### Execution order

Systems run in **alphabetical order** by name each tick. `DamageSystem` runs before `HealingSystem`. Use `[Order(n)]` to override -- lower `n` runs first:

```csharp
[Order(10)]
system EarlySystem { ... }

[Order(1)]
system FirstSystem { ... }  // runs before EarlySystem
```

Ties are broken alphabetically.

---

## 4. Builtins

Every system body has three implicit variables:

| Builtin | Type | Meaning |
|---|---|---|
| `self` | entity handle | The current entity being processed. `self.Id` yields its `EntityId`. |
| `dt` | `double` | Delta time -- seconds elapsed since last tick. |
| `tick` | `long` | Current tick number (u64). |

```csharp
system MovementSystem {
    Pos3.x += Velocity.dx * dt;
    Pos3.y += Velocity.dy * dt;
    Pos3.z += Velocity.dz * dt;
}

system LogSystem {
    if (tick % 60 == 0) {
        std.println($"tick {tick}: hp={Health.hp}");
    }
}
```

---

## 5. Tags

Tags are the visibility mechanism. An entity carrying a tag publishes its frozen state under that tag. Any system may query the frozen world by tag using `others<>`.

### Declaration

```csharp
tag Combatant;
tag Projectile;
tag Spatial;
```

### Hierarchy

Tags support single-parent inheritance:

```csharp
tag Actor;
tag Combatant : Actor;      // Combatant is-a Actor
tag Monster   : Combatant;
tag Player    : Combatant;
```

Matching by a tag includes its subtags by default. Querying `tag: Combatant` returns entities tagged `Combatant`, `Monster`, and `Player`.

### Bitmask-based, zero-cost

Tags compile to bitmasks. A tag check is one AND instruction. Hierarchy expansion is computed at compile time. An entity's tag mask is stored beside its component mask in the SoA store.

**64 tags per program** in v0. If no system queries by tag, no tag machinery is emitted at all -- zero cost.

### Untagged entities

Untagged entities are invisible to tag queries. They are addressable only by their `EntityId`. If you never use `others<>`, you never need tags.

---

## 6. The Four Verbs

All mutations in Kubexic go through exactly four operations. Every one is a **request** -- applied at tick commit, not immediately.

| Verb | Effect |
|---|---|
| `spawn { ... }` | Create an entity with the given components and tags. Returns the entity's ID immediately. The entity materializes at commit. |
| `attach(id, comp)` | Add or upsert a component on any entity. Applied next tick. |
| `detach(id, ComponentType)` | Remove a component from an entity. Applied next tick. |
| `despawn self` / `despawn id` | Remove an entity. Applied next tick. |

### spawn

```csharp
var player = spawn {
    Health { hp = 100, name = "hero" },
    Pos3 { x = 0, y = 0, z = 0 },
    tags [Combatant, Spatial]
};
```

`spawn` returns the entity's ID immediately. The entity does not exist in the world until commit, but the ID is valid for use in `attach`/`detach`/`despawn` calls (they become no-ops if the target hasn't materialized yet).

### attach

```csharp
// Send a damage message to another entity
attach(target, new Damage { amount = 10, sender = self.Id });

// Attach a component to self (upsert)
attach(self, new Poison { damage = 5 });
```

`attach` on a dead ID is a safe no-op. `attach` on an existing component type replaces the payload (upsert).

### detach

```csharp
// Consume a message component
detach(self, Damage);

// Remove a buff
detach(self, Poisoned);
```

Detaching a component removes it from the entity. The entity no longer matches systems requiring that component.

### despawn

```csharp
despawn self;
despawn someEntityId;
```

Removes the entity from the world. `despawn self` is also a request applied at commit, but field writes to self remain immediate within the current tick.

### The reactive model

Attaching a component **is** the event. There is no separate event system. When you attach `Damage` to an entity, that entity becomes a match for `DamageSystem` starting next tick. The component appearing *is* the signal.

---

## 7. The Frozen World Model

### The Core Law

> **Self is live. Everything else is frozen.**

- The entity a system is currently processing: **read and written immediately**.
- Every other entity: a **frozen snapshot from last tick**, **read-only**.
- You can never write another entity directly. You attach a component to it. The component is the message.

### Reading other entities

Use `others<C>(tag: X)` to iterate frozen entities with component `C` under tag `X`:

```csharp
system FindTarget {
    var closest = 0.0;
    var targetId = EntityId.None;
    foreach (var t in others<Health>(tag: Combatant)) {
        var dx = t.Pos3.x - Pos3.x;
        var dy = t.Pos3.y - Pos3.y;
        var dist = std.sqrt(dx * dx + dy * dy);
        if (dist < closest || targetId == EntityId.None) {
            closest = dist;
            targetId = t.Id;
        }
    }
}
```

Iteration order is **sorted by entity ID** -- deterministic on any machine, any core count. Results are read-only; writing is a compile error.

### Exact vs inclusive tag matching

```csharp
// Inclusive: matches Creature and all subtags (Monster, Player, etc.)
foreach (var t in others<Counter>(tag: Creature)) { ... }

// Exact: matches only Monster, not subtags of Monster
foreach (var t in others<Counter>(tag: exact Monster)) { ... }
```

### Zero data races

The frozen world model guarantees zero data races by construction:

- Live data is touched only by the owning box.
- Everything else is frozen copies.
- Cross-entity communication is always via component attachments (requests), applied at commit.
- Results are bitwise-identical regardless of core count.

You never manage threads. The runtime owns scheduling. Your code is always safe.

---

## 8. Complete Example

A simple combat system: a warrior attacks a goblin. The goblin takes damage, dies, and the warrior heals.

### Tags.kx

```csharp
tag Combatant;
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

### Warrior.kx

```csharp
component Warrior {
    var attack = 10;
}
```

### Goblin.kx

```csharp
component Goblin {
    var loot = "gold";
}
```

### AttackSystem.kx

The warrior attacks every entity with `Goblin` and `Health`. It sends a `Damage` message.

```csharp
system AttackSystem {
    foreach (var t in others<Health>(tag: Combatant)) {
        if (t.Health.name == "goblin" && t.Health.hp > 0) {
            attach(t.Id, new Damage { amount = Warrior.attack, sender = self.Id });
            std.println($"tick {tick}: {Health.name} attacks for {Warrior.attack} damage");
        }
    }
}
```

### DamageSystem.kx

Processes damage on any entity with `Health` and `Damage`.

```csharp
system DamageSystem {
    Health.hp -= Damage.amount;
    if (Health.hp <= 0) {
        std.println($"tick {tick}: {Health.name} has been slain!");
        attach(Damage.sender, new Healing { amount = 5 });
        despawn self;
    } else {
        std.println($"tick {tick}: {Health.name} has {Health.hp} hp remaining");
        detach(self, Damage);
    }
}
```

### HealingSystem.kx

Processes healing on any entity with `Health` and `Healing`.

```csharp
system HealingSystem {
    Health.hp += Healing.amount;
    std.println($"tick {tick}: {Health.name} heals for {Healing.amount} (now {Health.hp} hp)");
    detach(self, Healing);
}
```

### main.kx

```csharp
int main() {
    var warrior = spawn {
        Health { hp = 100, name = "warrior" },
        Warrior { attack = 10 },
        tags [Combatant]
    };
    var goblin = spawn {
        Health { hp = 20, name = "goblin" },
        Goblin { loot = "gold" },
        tags [Combatant]
    };
    std.println("combat started");
    run(max, ticks: 5);
    std.println("combat ended");
    return 0;
}
```

### What happens

1. `main` spawns a warrior (hp=100, attack=10) and a goblin (hp=20) as combatants.
2. `run(max, ticks: 5)` starts the tick loop at max speed.
3. **Tick 1**: `AttackSystem` runs. The warrior sees the goblin via `others<Health>(tag: Combatant)`, attaches `Damage { amount=10 }` to the goblin.
4. **Tick 1**: `DamageSystem` runs on the goblin. `Health.hp` drops from 20 to 10. `Damage` is detached.
5. **Tick 2**: `AttackSystem` attaches another `Damage` to the goblin.
6. **Tick 2**: `DamageSystem` runs. `Health.hp` drops from 10 to 0. The goblin is despawned. A `Healing` message is sent to the warrior.
7. **Tick 3**: `HealingSystem` runs on the warrior. `Health.hp` increases from 100 to 105. `Healing` is detached.
8. After 5 ticks, `run` returns and `main` prints "combat ended".

---

## Summary

| Concept | Keyword | Purpose |
|---|---|---|
| Entity | `spawn` | Opaque ID, slot in the world |
| Component | `component` | Pure data attached to entities |
| System | `system` | Logic that runs per matching entity per tick |
| Tag | `tag` | Visibility filter for `others<>` queries |
| Message | component + `attach` | Cross-entity communication (the event system) |

The mental model: define components as data, wire them together with systems, use tags to control who sees whom, and let the runtime handle threading, memory, and determinism. You never touch a mutex, never malloc, never schedule a thread.
