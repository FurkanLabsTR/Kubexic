---
title: Collections & Spatial Queries
---

# Collections & Spatial Queries

This reference covers Kubexic's built-in collection types and the spatial query system.

---

## Collections

Kubexic provides two generic collection types: `List<T>` and `Map<K,V>`. They can be stored as component fields and participate in the ECS ownership model.

### List\<T\>

An ordered, dynamic array.

| Method | Description |
|--------|-------------|
| `List<T>()` | Construct an empty list |
| `.Add(value)` | Append an element |
| `.Get(index)` | Read by index (panics if out of range) |
| `.Set(index, value)` | Write by index |
| `.RemoveAt(index)` | Remove element at index |
| `.Clear()` | Remove all elements |
| `.Count` | Property: number of elements |

Iteration:

```kx
var items = List<string>();
items.Add("sword");
items.Add("shield");

foreach (var it in items) {
    std.println(it);
}
```

### Map\<K, V\>

An unordered key-value map.

| Method | Description |
|--------|-------------|
| `Map<K,V>()` | Construct an empty map |
| `.Set(key, value)` | Insert or update (upsert) |
| `.Get(key)` | Read value by key (panics if missing) |
| `.Has(key)` | Check if key exists |
| `.Remove(key)` | Remove a key-value pair |
| `.Clear()` | Remove all entries |
| `.Count` | Property: number of entries |

```kx
var stats = Map<string, long>();
stats.Set("hits", 42);
stats.Get("hits");        // 42
stats.Has("hits");        // true
stats.Remove("hits");
```

### Supported Element Types

Collections may hold: `int`, `long`, `float`, `double`, `bool`, `string`, `EntityId`. Nested collections (`List<List<int>>`) are not yet supported.

### Ownership Semantics

Collections stored in component fields belong to that entity:

- **Deep copy on store**: assigning a collection to a component field copies it.
- **Frozen view**: when the ECS publishes a frozen snapshot, collection data is deep-copied into it. Reads (`Count`, `Get`, `Has`) are allowed; mutations are a compile error.
- **Freed on despawn/detach**: collections are deallocated when the owning entity is despawned or the component is detached.
- **Move on spawn/attach**: a fresh `List()`/`Map()` constructor passed in a `spawn` or `attach` initializer transfers ownership (no copy).

---

## Full Example: `samples/collections/`

### Tags.kx

```kx
tag Tracked;
```

### Inventory.kx

```kx
component Inventory {
    var items = List<string>();
    var stats = Map<string, long>();
}
```

### InventorySystem.kx

```kx
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
```

### main.kx

```kx
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

## Spatial Queries

The `kx.spatial` module provides spatial queries backed by a runtime hash grid. Entities must opt in with the `Spatial` tag and carry a position component with `x`/`y`/`z` fields.

### Requirements

1. The entity must carry the **`Spatial` tag** (or a subtag of it).
2. The position component must have fields named **`x`**, **`y`**, and optionally **`z`**.

```kx
tag Spatial;

component Pos3 {
    var x = 0.0;
    var y = 0.0;
    var z = 0.0;
}
```

### API

| Function | Description |
|----------|-------------|
| `spatial.Overlap(Pos3, radius)` | Find entities within `radius` of current entity's position |
| `spatial.Nearby(Pos3, radius)` | Alias for `Overlap` |

Both functions:

- Return **frozen snapshots** (read-only, ~1 extra tick stale).
- Iterate in **sorted entity ID order** (deterministic).
- Use the runtime's spatial hash grid for performance (only queries nearby cells, not all entities).

### Full Example: `samples/arrow/`

A projectile flies toward a target and deals damage on collision.

#### Tags.kx

```kx
tag Combatant;
tag Projectile;
tag Spatial;
```

#### Pos3.kx

```kx
component Pos3 {
    var x = 0.0;
    var y = 0.0;
    var z = 0.0;
}
```

#### Health.kx

```kx
component Health {
    var hp = 100;
    var name = "unknown";
}
```

#### Damage.kx

```kx
component Damage {
    var amount = 10;
    var sender = EntityId.None;
}
```

#### Healing.kx

```kx
component Healing {
    var amount = 5;
}
```

#### Arrow.kx

```kx
component Arrow {
    var sender = EntityId.None;
}
```

#### ArrowSystem.kx

```kx
system ArrowSystem {
    Pos3.z += 1.0;
    foreach (var hit in spatial.Overlap(Pos3, 0.5)) {
        attach(hit.Id, new Damage { amount = 10, sender = Arrow.sender });
        std.println($"tick {tick}: arrow hit");
        despawn self;
    }
}
```

#### DamageSystem.kx

```kx
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

#### HealingSystem.kx

```kx
system HealingSystem {
    Health.hp += Healing.amount;
    detach(self, Healing);
}
```

#### main.kx

```kx
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

**What happens**: the arrow moves +1.0 on `z` each tick. When it reaches `z=30` (within 0.5 radius), `spatial.Overlap` finds the target, attaches `Damage`, and despawns the arrow. `DamageSystem` reduces HP; on kill it sends `Healing` back to the arrow's sender.
