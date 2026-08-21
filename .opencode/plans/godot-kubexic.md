# godot-kubexic: Godot Integration for Kubexic

> **Goal**: Use Godot as a library from Kubexic via libgodot (Godot 4.6+ PR #110863).
> Kubexic is the HOST — it creates and drives Godot instances, loads scenes, uses RPC,
> physics, rendering, audio, UI — the entire engine as a library.
> Full API coverage via auto-generation from extension_api.json + hand-written
> high-level Kubexic wrappers. Simple syntax. Complete documentation.
>
> **Location**: `/home/slyrebula/godot-kubexic/`

---

## Key Features (what the user wants)

1. **Scenes** — load `.tscn` files, instantiate, switch scenes from Kubexic
2. **RPC** — Godot's high-level multiplayer RPC system callable from Kubexic
3. **Run Godot from Kubexic** — `Godot.Init()` → `Godot.Iterate()` custom loop
4. **Full API coverage** — every class, method, property, signal, enum
5. **Simple syntax** — `Godot.LoadScene()`, `node.position = Vector2_new(x, y)`
6. **Complete docs** — getting started, API reference, guides, examples

---

## Architecture

```
Kubexic program (.kx)
  ├── api/Godot.kx          ← high-level Kubexic wrappers (hand-written)
  ├── components/*.kx       ← ECS bridge components
  ├── systems/*.kx          ← bridge systems
  ├── generated/*.kx        ← auto-generated extern declarations
  └── lib/*.c               ← C glue layer (bridges to libgodot.so)
       ↓
  libgodot.so               ← Godot 4.6+ built as shared library
```

**Key insight**: Kubexic is the HOST process. Godot runs inside it via `libgodot_create_godot_instance()`.
No godot-cpp dependency — the glue layer is pure C talking directly to the GDExtension C interface.

---

## libgodot C API (Godot 4.6+, PR #110863)

```c
// From core/extension/libgodot.h
GDExtensionObjectPtr libgodot_create_godot_instance(
    int p_argc, char *p_argv[],
    GDExtensionInitializationFunction p_init_func);
void libgodot_destroy_godot_instance(GDExtensionObjectPtr p_godot_instance);
```

GodotInstance object methods (accessed via GDExtension object_method_bind_call):
- `start()` — Main::setup2 + Main::start + MainLoop::initialize
- `iteration()` — DisplayServer::process_events + Main::iteration (one frame)
- `is_started()`
- `stop()` — MainLoop::finalize
- `pause()` / `resume()` / `focus_in()` / `focus_out()`

### GDExtension init callback (required)

```c
typedef GDExtensionBool (*GDExtensionInitializationFunction)(
    GDExtensionInterfaceGetProcAddress p_get_proc_address,
    GDExtensionClassLibraryPtr p_library,
    GDExtensionInitialization *r_initialization);
```

The glue layer's init callback:
1. Receives `p_get_proc_address` — the gateway to ALL Godot C functions
2. Sets `minimum_initialization_level = GDEXTENSION_INITIALIZATION_SCENE`
3. Registers initialize/deinitialize callbacks (used to resolve function pointers)
4. Returns 1 on success

---

## Package Structure

```
godot-kubexic/
├── .kxconf                    # Package manifest
├── README.md
├── LICENSE (MIT)
│
├── generator/                 # Code generator (Python 3)
│   ├── generate.py            # Main: reads extension_api.json → generates .kx + .c
│   ├── parser.py              # Parse extension_api.json
│   ├── type_mapper.py         # Godot type → Kubexic type mapping
│   └── run.sh                 # Convenience script
│
├── generated/                 # Auto-generated (checked in)
│   ├── godot_externs.kx       # extern declarations for all Godot methods
│   ├── godot_types.kx         # Vector2, Color, Transform structs
│   ├── godot_enums.kx         # All Godot enums
│   ├── godot_constants.kx     # All Godot constants
│   ├── godot_glue.h           # C header
│   └── godot_glue.c           # C bridge implementation
│
├── api/                       # Hand-written high-level wrappers
│   ├── Godot.kx               # Init, main loop, shutdown, scene management
│   ├── Node.kx                # Node operations
│   ├── Input.kx               # Input handling
│   ├── Signal.kx              # Signal → ECS bridge
│   ├── Resource.kx            # Resource loading
│   ├── Timer.kx               # Timer helpers
│   ├── Physics2D.kx           # 2D physics
│   ├── Physics3D.kx           # 3D physics
│   ├── UI.kx                  # UI helpers
│   ├── Audio.kx               # Audio helpers
│   └── Multiplayer.kx         # RPC bindings
│
├── components/                # ECS components
│   ├── GodotNode.kx           # Tracks a Godot node handle
│   ├── GodotBody2D.kx         # CharacterBody2D bridge
│   ├── GodotBody3D.kx         # CharacterBody3D bridge
│   ├── GodotSprite.kx         # Sprite bridge
│   ├── GodotTimer.kx          # Timer bridge
│   └── GodotSignal.kx         # Incoming signal payload
│
├── systems/                   # Bridge systems
│   ├── NodeSyncSystem.kx      # Syncs ECS position → Godot
│   └── SignalSystem.kx        # Processes Godot signals as ECS events
│
├── lib/                       # Native C glue (pure C, no godot-cpp)
│   ├── godot_glue.h           # Internal C header
│   ├── godot_glue_init.c      # libgodot initialization + dlopen
│   ├── godot_glue_variant.c   # GVar marshalling
│   ├── godot_glue_node.c      # Node operations
│   ├── godot_glue_signal.c    # Signal connect/emit
│   ├── godot_glue_resource.c  # Resource loading
│   ├── godot_glue_input.c     # Input polling
│   ├── godot_glue_rpc.c       # Multiplayer RPC bindings
│   ├── godot_handles.c        # Handle table (int64 ↔ GDExtensionObjectPtr)
│   └── godot_queue.c          # Command queue for thread safety
│
├── samples/                   # Example projects
│   ├── hello_godot/           # Minimal Godot integration
│   ├── platformer/            # Full platformer example
│   ├── rpc_demo/              # Multiplayer RPC example
│   └── ui_demo/               # UI integration example
│
└── CMakeLists.txt             # Build system
```

---

## C Glue Layer

### Initialization (dlopen-based)

```c
// lib/godot_glue_init.c
int gd_init(const char* executable_path, const char* project_path) {
    // 1. dlopen("libgodot.so", RTLD_NOW | RTLD_GLOBAL)
    // 2. dlsym("libgodot_create_godot_instance")
    // 3. dlsym("libgodot_destroy_godot_instance")
    // 4. Call create with our GDExtension init callback
    // 5. Init callback receives p_get_proc_address → resolve all function pointers
    // 6. Call GodotInstance.start() via object_method_bind_call
}
void gd_iterate(void);   // Calls GodotInstance.iteration() — one frame
void gd_shutdown(void);  // Calls stop() + destroy + dlclose
int  gd_is_initialized(void);
```

### Handle table (int64 ↔ Godot object)

```c
// lib/godot_handles.c
// Godot objects are tracked in a generational handle table.
// Kubexic never sees raw pointers.
// Handle encoding: (slot << 16) | generation

int64_t gd_handle_store(GDExtensionObjectPtr obj);
GDExtensionObjectPtr gd_handle_resolve(int64_t handle);
void gd_handle_free(int64_t handle);
// Generation counters detect stale handles (matches Kubexic EntityId semantics)
```

### GVar — flat C variant representation

```c
// 32-byte struct passable through Kubexic extern calls
typedef struct {
    int64_t  type;       // GVarType enum
    union {
        int64_t  i64;
        double   f64;
        struct { double x, y; }        v2;
        struct { double x, y, z; }     v3;
        struct { double x, y, z, w; }  v4;
        struct { double r, g, b, a; }  color;
        int64_t  obj;      // handle
        int64_t  pack[4];  // packed arrays, raw storage
    } data;
} GVar;
```

Marshalling functions:
```c
GVar   gvar_from_vector2(double x, double y);
GVar   gvar_from_vector3(double x, double y, double z);
GVar   gvar_from_color(double r, double g, double b, double a);
GVar   gvar_from_object(int64_t handle);
GVar   gvar_from_string(const char* str);
double gvar_to_float(GVar v);
int64_t gvar_to_int(GVar v);
```

### Node operations

```c
int64_t gd_node_create(const char* class_name);      // ClassDB.instantiate
void    gd_node_free(int64_t node);                  // node.free()
void    gd_node_add_child(int64_t parent, int64_t child, int auto_name);
void    gd_node_remove_child(int64_t parent, int64_t child);
int64_t gd_node_find(const char* path);              // scene tree lookup
char*   gd_node_get_path(int64_t node);
void    gd_node_set(int64_t node, const char* property, GVar value);
GVar    gd_node_get(int64_t node, const char* property);
GVar    gd_call(int64_t object, const char* method, int argc, GVar* argv);
```

### Signal bridge

```c
typedef void (*gd_signal_callback)(int64_t node, const char* signal,
                                    int argc, GVar* argv, void* user_data);
int  gd_signal_connect(int64_t node, const char* signal,
                        gd_signal_callback callback, void* user_data);
void gd_signal_disconnect(int64_t node, const char* signal,
                           gd_signal_callback callback, void* user_data);
void gd_signal_emit(int64_t node, const char* signal, int argc, GVar* argv);
```

### RPC bindings

```c
// MultiplayerAPI → SceneMultiplayer
void  gd_rpc_id(int64_t node, int64_t peer_id, const char* method, int argc, GVar* argv);
void  gd_rpc(int64_t node, const char* method, int argc, GVar* argv);
int   gd_get_unique_id(void);                        // multiplayer.get_unique_id()
int   gd_is_server(void);                            // multiplayer.is_server()
void  gd_set_multiplayer_peer(int64_t peer_handle);  // multiplayer.set_multiplayer_peer()
// RPC config on methods: rpc("any_peer"/"authority"), call_local, transfer_mode
```

### Thread safety: Command queue

```c
void gd_queue_command(gd_command_fn fn, void* arg);  // Enqueue from any thread
void gd_process_queue(void);                          // Execute on main thread
```

---

## Auto-Generated Bindings

### Acquiring extension_api.json

```bash
# Build Godot first, then dump the API
cd godot
scons platform=linux target=editor dev_build=yes
./bin/godot.linuxbsd.editor.dev.x86_64 --dump-extension-api --headless
# Produces extension_api.json + gdextension_interface.json
```

### Code generator (Python) reads extension_api.json (100k+ lines)

Outputs:
- `godot_externs.kx` — extern declarations for every Godot class method
- `godot_types.kx` — Vector2, Color, Transform structs
- `godot_enums.kx` — Every Godot enum
- `godot_constants.kx` — Every constant
- `godot_glue.c` — C functions that bridge extern calls to GDExtension

### Type mapping (complete)

| Godot | Kubexic (extern) | Kubexic (user) | Notes |
|-------|-----------------|----------------|-------|
| `bool` | `int` | `bool` | |
| `int` | `long` | `long` | |
| `float` | `double` | `double` | |
| `String` | `string` | `string` | C char* |
| `StringName` | `string` | `string` | C char* |
| `NodePath` | `string` | `string` | C char* |
| `Vector2/3/4` | `GVar` (4×long) | `Vector2/3/4` struct | |
| `Vector2i/3i/4i` | `GVar` | `VectorNi` struct | |
| `Color` | `GVar` | `Color` struct | |
| `Rect2/Rect2i` | `GVar` | struct | |
| `Transform2D/3D` | `GVar` | struct | |
| `Basis/Quaternion` | `GVar` | struct | |
| `AABB/Plane` | `GVar` | struct | |
| `Object` + subclasses | `long` (handle) | handle | generational handle table |
| `Resource` + subclasses | `long` (handle) | handle | |
| `Variant` | `GVar` | GVar | universal container |
| `Array` | `long` (handle) | handle | |
| `Dictionary` | `long` (handle) | handle | |
| `Packed*Array` | `long` (handle) | handle | |
| `Callable` | `long` (handle) | handle | |
| `Signal` | `long` (handle) | handle | |
| `enum X` | `long` | `enum X` | auto-generated |
| `RID` | `long` (handle) | handle | |

### Naming convention

```
extern long Godot_Node2D_set_position(long self, long position);
extern long Godot_Sprite2D_set_texture(long self, long texture);
extern long Godot_Timer_start(double time_sec);
extern long Godot_Node_rpc_id(long self, long peer_id, string method, int argc, long argv);
```

---

## High-Level Kubexic API

### Simple usage example

```csharp
// main.kx
int main() {
    Godot.Init(".", "res://project.godot");

    var node = Godot.CreateNode("Sprite2D");
    Godot.AddChild(Godot.CurrentScene(), node);

    spawn {
        GodotNode { handle = node },
        Position { x = 100, y = 200 },
        tags [Renderable]
    };

    run(60);
    Godot.Shutdown();
    return 0;
}
```

### System example

```csharp
system PlayerMoveSystem {
    var input = Godot.Input.GetAxis("move_left", "move_right");
    Player.speed = input * 100.0;
    Position.x += Player.speed * dt;

    var node = GodotNode.handle;
    Godot.Node.Set(node, "position",
        Vector2_new(Position.x, Position.y));
}
```

### RPC example

```csharp
system MultiplayerSyncSystem {
    // Server broadcasts position to all peers
    if (Godot.Multiplayer.IsServer()) {
        GodotNode.rpc(GodotNode.handle, "set_position",
            Position.x, Position.y);
    }
}
```

### Signal example

```csharp
system DamageOnCollision {
    if (GodotSignal.signal_name == "body_entered") {
        attach(self, new Damage { amount = 10 });
    }
}
```

---

## Build System

### Building Godot as libgodot.so

```bash
cd godot && git checkout 4.6-stable
scons platform=linux target=template_release library_type=shared use_llvm=yes
# Output: bin/libgodot.linux.template_release.x86_64.so

# Then dump the API for the code generator
scons platform=linux target=editor dev_build=yes
./bin/godot.linuxbsd.editor.dev.x86_64 --dump-extension-api --headless
```

### Building the glue layer

```bash
cd godot-kubexic
gcc -shared -fPIC -o libgodot_kubexic.so \
    lib/*.c generated/*.c -Ilib -Igenerated -ldl -lpthread
```

### User project integration

```ini
# .kxconf
[dependencies]
godot-kubexic = "^0.1.0"

[native]
libs = ["dl", "pthread", "godot_kubexic"]
link_dirs = ["/path/to/godot/bin", ".kubex/cache/godot-kubexic-0.1.0/lib"]
```

---

## Threading Model

```
Main Thread:                              ECS Worker Threads:
  ┌────────────────────────┐              ┌────────────────────┐
  │ gd_process_queue()     │              │ Box 0: systems     │
  │ gd_iterate()           │              │ Box 1: systems     │
  │ Godot runs physics +   │              │ Box 2: systems     │
  │   rendering + audio    │              │ ...                │
  │ signals → queue        │←────────────│ spawn/attach/detach│
  └────────────────────────┘              └────────────────────┘
```

- `gd_iterate()` MUST run on the main thread (Godot constraint)
- ECS systems run on worker threads (Kubexic runtime)
- `gd_queue_command()` marshals calls from workers → main thread
- `gd_process_queue()` executes queued commands before each Godot iteration
- Godot signals enqueue GodotSignal components → ECS processes next tick
- Integration point: `run(60)` calls `gd_process_queue()` + `gd_iterate()` each tick

---

## Memory Management

- **Handles, not pointers**: Kubexic only sees int64 handles with generation counters
- **Godot owns Nodes**: `gd_node_free()` calls `node.free()` which Godot schedules
- **Resources are ref-counted**: GDExtension handles ref/deref automatically
- **GVar is stack data**: passed by value through extern calls, no allocation
- **Strings**: C glue copies strings into Godot String; returned strings freed by caller
- **Stale handles are safe no-ops**: generation counter check, same as Kubexic EntityId

---

## Error Handling Strategy

- `gd_init()` returns error code: -1 = dlopen failed, -2 = missing entry points, -3 = create failed
- All node operations are safe no-ops on invalid handles
- `gd_call()` returns GVar with type NIL if method doesn't exist
- Kubexic wrappers panic with descriptive messages on fatal errors
- Verbose mode: `GODOT_KUBEXIC_DEBUG=1` enables stderr logging of all calls

---

## Known Risks & Constraints (from libgodot PR)

1. **Single instance only** — Godot's global singletons allow one instance per process
2. **Repeated lifecycle unsupported** — create → run → destroy works once; re-init unreliable
3. **Main thread requirement** — start/iteration/stop must be on the creating thread
4. **No static linking** — only `library_type=shared_library` works
5. **Platforms**: Linux, Windows, macOS supported (Android/iOS in development)
6. **No window embedding yet** — Godot controls its own window (embedding PR in progress)

---

## Testing Strategy

1. **Glue layer unit tests** (C): handle table, GVar marshalling, queue
2. **Kubexic integration tests**: `kubex test` with mock Godot responses
3. **Sample validation**: each sample builds and runs headless (`--headless`)
4. **Cross-platform CI**: Linux primary, Windows/macOS secondary
5. **E2E test**: spawn node, set property, verify get property returns same value

---

## Implementation Phases

### Phase 1: Core (2-3 weeks)
- Handle table + GVar + command queue (C)
- libgodot init/iterate/shutdown (C)
- Node operations (create, add_child, set/get properties)
- Code generator skeleton (parse extension_api.json, generate externs)
- High-level Godot.kx wrapper
- Scene loading + switching
- hello_godot sample (headless test)

### Phase 2: Full API (3-4 weeks)
- Auto-generate ALL class bindings (no omissions)
- Physics, rendering, audio wrappers
- Signal system → ECS bridge
- Node hierarchy helpers
- RPC bindings (SceneMultiplayer, MultiplayerAPI, rpc_id, peer management)
- platformer + rpc_demo samples

### Phase 3: Polish (2-3 weeks)
- Documentation site (getting started, API reference, guides)
- More samples (ui_demo)
- Performance optimization (batch command queue, handle cache)
- Error handling improvements
- Cross-platform build verification

---

## Documentation Plan

```
docs/
├── getting-started.md     # Build Godot, install package, hello world
├── api-reference.md       # Auto-generated from extension_api.json
├── guides/
│   ├── scenes.md          # Loading, switching, instantiating scenes
│   ├── rpc.md             # Multiplayer RPC from Kubexic
│   ├── physics.md         # Physics integration
│   ├── signals.md         # Signal → ECS bridging
│   ├── input.md           # Input handling
│   ├── ui.md              # UI integration
│   └── threading.md       # Thread model explanation
└── examples/
    ├── hello-godot.md
    ├── platformer.md
    └── rpc-demo.md
```

---

## File Count Estimate

| Area | Files | Lines (est) |
|------|-------|-------------|
| generator/ | 4 | ~800 Python |
| generated/ | 5 | ~50k auto-generated |
| api/ | 11 | ~1,500 .kx |
| components/ | 6 | ~300 .kx |
| systems/ | 2 | ~150 .kx |
| lib/ | 11 | ~2,500 C |
| samples/ | 12 | ~600 .kx |
| docs/ | 13 | ~2,000 md |
| **Total** | **~64** | **~58k** |
