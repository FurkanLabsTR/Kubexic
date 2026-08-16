# Rebulacian Voxel MMO Engine — Comprehensive Technical Guide

## Overview

Rebulacian is a voxel-based MMO game engine written in Java, architected to support **thousands of concurrent players** (configurable up to **12,000**) in a shared block world. The engine achieves its massive scale through a combination of **spatial partitioning**, **parallel execution**, **sharded data structures**, **client-side prediction**, **LOD-based entity management**, **asynchronous I/O**, and **data-oriented design** at every layer.

---

## PART 1: PROJECT STRUCTURE MODULES

The project is organized into 6 Gradle submodules:

| Module | Purpose |
|---|---|
| `engine-server` | The voxel MMO server — handles simulation, networking, persistence, and world management |
| `engine-client` | The LWJGL/SDL-based client — handles rendering, input, prediction, and audio |
| `engine-common` | Shared code — protocol packets, coordinate utilities, entity snapshots, chunk codec |
| `engine-plugin-api` | Plugin development API — GameSystem, BoxView, WorldView, CommandBuffer |
| `Rebulacian-Plugin` | Example plugin — SkyWars-style last-man-standing game |
| `tools` | Load testing tool — simulates thousands of bot clients |

---

## PART 2: SERVER-SIDE ARCHITECTURE (engine-server)

### 2.1 Entry Point — `ServerMain.java`

The server entry point. It creates an `EngineKernel`, registers a JVM shutdown hook for graceful termination, and blocks the main thread with a `while(running)` sleep loop until the kernel stops.

**Scaling relevance**: The main thread is essentially idle — all work is offloaded to the kernel and worker thread pools.

---

### 2.2 The Heartbeat — `EngineKernel.java` (1105 lines)

The most important file in the entire engine. It manages the **60 TPS fixed-timestep game loop** and orchestrates all systems via phase-based execution.

#### Configurable Constants (set via system properties)

| Property Key | Default | Purpose |
|---|---|---|
| `rebulacian.server.maxPlayers` | **12,000** | Hard connection cap |
| `rebulacian.server.boxCount` | `max(4, CPU cores)` | Number of simulation boxes |
| `rebulacian.server.boxThreads` | `min(boxCount, cores)` | Box thread pool size |
| `rebulacian.server.chunkViewRadiusXZ` | 6 | Horizontal chunk view distance |
| `rebulacian.server.chunkViewRadiusY` | 1 | Vertical chunk view distance |
| `rebulacian.server.entityAoiRadiusBlocks` | 80 | Entity visibility radius |
| `rebulacian.server.entityAoiCellSizeBlocks` | 320 | AOI grid cell size |
| `rebulacian.server.entityAoiUpdateIntervalTicks` | 6 | AOI recompute frequency |
| `rebulacian.server.chunkGeneratorThreads` | `min(4, cores/2)` | Generator thread count |
| `rebulacian.server.maxLoadedChunks` | 0 (unlimited) | Memory limit for loaded chunks |
| `rebulacian.server.worldSeed` | `0x4ADE5A78423L` | World generation seed |
| `rebulacian.server.clientSideChunkGen` | `true` | Client generates chunks locally |
| `rebulacian.server.chunkStreamSendBudget` | 32 | Max chunk sends/tick/session |
| `rebulacian.server.chunkStreamInitialSendBudget` | 4 | Ramp-up starting budget |
| `rebulacian.server.chunkStreamRampTicksPerChunk` | 20 | Ramp rate (ticks/budget) |
| `rebulacian.server.chunkStreamGlobalSendBudget` | 32,768 | Total chunk send budget/tick |
| `rebulacian.server.chunkStreamGlobalRequestBudget` | 32,768 | Total chunk request budget/tick |
| `rebulacian.server.chunkUnloadIntervalTicks` | 300 (5s) | Chunk eviction scan interval |
| `rebulacian.server.chunkUnloadGraceTicks` | 1200 (20s) | Grace period before eviction |
| `rebulacian.server.maxClientViewLeashChunks` | 256 | Max client view offset from authority |
| `rebulacian.server.boxRebalanceIntervalTicks` | 30 (0.5s) | Load balance frequency |
| `rebulacian.server.boxRebalanceMaxMigrations` | 256 | Max entity migrations/tick |
| `rebulacian.server.boxRebalanceEntityImbalance` | 64 | Imbalance threshold to trigger migration |
| `rebulacian.server.networkInputBudget` | 8192 | Max input packets processed/tick |
| `rebulacian.server.networkSessionBudget` | 2048 | Max sessions processed/tick |
| `rebulacian.server.maxClientPacketsPerTick` | 256 | Rate limit per client |
| `rebulacian.server.maxAssetRequestsPerSecond` | 4096 | Asset request rate limit |
| `rebulacian.server.soBacklog` | 4096 | TCP listen backlog |
| `rebulacian.server.writeBufferLowWaterMark` | 4 MB | Netty write buffer low mark |
| `rebulacian.server.writeBufferHighWaterMark` | 8 MB | Netty write buffer high mark |
| `rebulacian.server.chunkStripes` | `max(32, CPU cores)` | Chunk index stripe count |
| `rebulacian.server.entityStoreInitialCapacity` | 4096 | EntityStore initial size |
| `rebulacian.server.persistenceWriteBatchSize` | 128 | Directory batch write size |
| `rebulacian.server.persistenceWriteBacklogHighWaterMark` | 4096 | High watermark for backpressure |

#### The Tick Loop

Uses a **fixed timestep** approach:
```
nextTickTime += TICK_DURATION_NANOS (16.67ms)
sleep if ahead of schedule
if more than 2 ticks behind: reset schedule (prevent spiral-of-death)
```

#### Tick Phases (executed in strict order)

1. **BEGIN** — Reset migration flags in all boxes, clean stale AOI state (periodic purge every 600 ticks)
2. **NETWORK_INPUT** — Drain all incoming packets from Netty's input queues:
   - Process CONNECT/DISCONNECT events
   - Handle CHelloPacket → `handleHello()` creates player entity
   - Handle CInputMovePacket → routes to appropriate SimulationBox
   - Handle CBlockActionPacket / CUiActionPacket / CAssetRequestPacket / CPlayerSkinPacket
   - Rate-limit enforcement per client
   - Rebuild session order list if dirty
3. **ROUTING** — Organizer rebuilds entity-to-box and chunk-to-boxes routing tables by scanning every entity in every box
4. **BOX_SIMULATION** — Fire-and-forget: all SimulationBoxes simulate in parallel on `BoxExecutor` thread pool (phase C pipelining)
5. **COMMAND_COMMIT** — Apply plugin system outputs (entity moves, block changes, spawn/despawn, component changes)
6. **MIGRATION** — Execute entity migrations between boxes (load balancing rebalancer runs every 30 ticks)
7. **SNAPSHOT_FREEZE** — All boxes freeze their entity snapshots in parallel. AOI frame rebuilt (every 6 ticks). `SnapshotExecutor` launched for parallel network output generation
8. **BACKGROUND_HANDOFF** — Process loaded chunks from disk, queue chunk generation requests, apply generation results, evict inactive chunks, flush pending persistence writes

#### Phase C Pipeline Optimization

The box simulation for tick N runs on worker threads while the main thread simultaneously processes network input for tick N+1, effectively hiding simulation latency behind input processing.

#### The Hello Handshake (`handleHello`)

When a client connects:
1. Check if already connected → reject with "already-connected"
2. Check `MAX_PLAYERS` capacity → reject with "Server full" if exceeded
3. Select least-loaded `SimulationBox` via `organizer.getLeastLoadedBox()`
4. Generate unique entity ID from that box's `EntityIdGenerator`
5. Try to load saved player entity from Custom Binary Format (restores position/velocity/component mask)
6. If no saved data, spawn at default position (world 8, clearance=2, 8)
7. Register session in Organizer: `ChannelId → entityId`, `ChannelHandlerContext → entityId`
8. Send `SHelloPacket` confirming connection with assigned entity ID

#### Connection Lifecycle

On disconnect:
- Player entity saved to Custom Binary Format via PersistenceManager.savePlayerEntity()
- All subscriptions cleaned up
- Session removed from Organizer
- Entity removed from its SimulationBox's EntityStore
- Session order list marked dirty for rebuild

---

### 2.3 The Organizer — `Organizer.java` (603 lines)

The central coordination hub connecting boxes, entities, sessions, and chunks.

#### P9 Optimization: Striped Chunk Index

The chunk index is sharded into **N stripes** (`max(32, CPU cores)`) to eliminate ConcurrentHashMap contention under high loads. Each stripe has its own `ReentrantReadWriteLock`:
```
chunkStripes[N] = Array of HashMaps
stripeLocks[N] = Array of ReadWriteLocks
stripe(key) = Math.floorMod(key, N) // Hash-based stripe selection
```

#### Key Data Structures

| Structure | Type | Purpose |
|---|---|---|
| `boxes` | `HashMap<Integer, SimulationBox>` | All simulation boxes by ID |
| `entityToBox` | `ConcurrentHashMap<Long, Integer>` | Entity ID → Box ID routing |
| `chunkToBoxes` | `ConcurrentHashMap<Long, List<Integer>>` | Chunk key → Box IDs with entities in it |
| `channelToEntity` | `ConcurrentHashMap<ChannelId, Long>` | Channel ID → Entity ID |
| `channelContexts` | `ConcurrentHashMap<ChannelId, ChannelHandlerContext>` | Channel ID → Netty context |
| `sessionSubscriptions` | `ConcurrentHashMap<Long, Set<Long>>` | Entity ID → subscribed chunk keys |
| `chunkSubscriptionCounts` | `ConcurrentHashMap<Long, Integer>` | Chunk key → subscriber count |
| `playerAoiStates` | `ConcurrentHashMap<Long, long[]>` | Entity ID → currently visible entity IDs |
| `pendingGeneration` | `ConcurrentHashSet<Long>` | Chunks queued for generation |
| `pendingGenerationQueue` | `ConcurrentLinkedQueue<Long>` | FIFO generation queue |
| `migrationQueue` | `ArrayList<MigrationRequest>` | Entity migrations to execute |

#### Key Operations

- **registerSession / removeSession** — Maps ChannelId ↔ entityId, manages chunk subscriptions
- **subscribe / retainSubscriptions / isSubscribed** — Tracks which chunks each session has received (critical for delta updates — only send new chunks)
- **registerChunk / getChunk / removeChunk** — Stripe-aware chunk CRUD operations
- **requestChunk / drainPendingGeneration** — Chunk generation pipeline: request → queue → generate → register
- **updateRoutingTable** — Every ROUTING phase: scan all entities in all boxes, rebuild entity→box and chunk→boxes maps
- **getLeastLoadedBox** — Selects box with fewest entities (tie-breaker: fewest active chunks)
- **queueMigration / executeMigrations** — Move entities between boxes (atomic export from source, import to target, update routing)
- **rebalanceEntityLoad** — Every 30 ticks: find heaviest and lightest boxes, migrate entities until imbalance drops below threshold (64)

---

### 2.4 SimulationBox — `SimulationBox.java` (323 lines)

Each SimulationBox is an **independent game simulation domain** — a "shard" managing a subset of the world's entities.

#### Box Partitioning

Entities belong to boxes based on their chunk coordinates:
```java
int calculateBoxId(int cX, int cY, int cZ) {
    int regionX = Math.floorDiv(cX, 8); // Regions of 8x4x8 chunks (128x64x128 blocks)
    int regionY = Math.floorDiv(cY, 4);
    int regionZ = Math.floorDiv(cZ, 8);
    return hash(regionX, regionY, regionZ) % boxPartitionCount;
}
```

A 128×64×128 block region is deterministically assigned to exactly one box. When a player crosses a region boundary, a `MigrationFlag` is emitted and processed in the MIGRATION phase.

#### Box Contents

| Component | Type | Purpose |
|---|---|---|
| **EntityStore** | SoA primitive arrays | Entity data (positions, velocities, types) |
| **BulletinBoard** | Snapshot store | Frozen snapshots for network broadcast |
| **BoxCommandBuffer** | Command accumulator | Plugin system outputs for the tick |
| **inputQueue** | `ConcurrentLinkedQueue<EntityInput>` | Player movement inputs from network |
| **latestInputs** | `HashMap<Long, TrackedInput>` | Latest input per entity (with timeout) |
| **activeChunks** | `HashMap<Long, VoxelChunk>` | Cached chunk references |
| **liquidChunks** | `HashMap<Long, VoxelChunk>` | Chunks with liquid for liquid simulation |
| **components** | `Map<Class<?>, Map<Long, Object>>` | ECS component storage |
| **entityRegistry** | `Map<Integer, EntityTypeDefinition>` | Entity type definitions (width/height/depth) |
| **IdGenerator** | `EntityIdGenerator` | Unique entity IDs (serverId + boxId encoded) |

#### Simulation Tick (`simulate()`)

Called by `BoxExecutor` across all boxes in parallel:
1. `processInputs()` — Poll input queue, update latest inputs, enforce sequence ordering (older sequences ignored)
2. `emitControlledMigrationFlags()` — Check if any player entity's region has changed; flag for migration if needed
3. Plugin systems run — Each registered `GameSystem` is executed in sequence:
   - `system.run(boxView, commandBuffer, deltaSeconds)`
   - Errors are caught and logged without crashing the box

#### Input Handling

Inputs tracked with `TrackedInput(packet, receivedTick)`. If no input received for 10 ticks (`INPUT_HOLD_TIMEOUT_TICKS`), `getPlayerInput()` returns null (player considered idle/moved boxes).

---

### 2.5 EntityStore — `EntityStore.java` (334 lines)

**Data-Oriented Design**: Uses Structure of Arrays (SoA) with primitive arrays for maximum cache locality and minimal garbage collection.

```
Initial capacity: 4096 (configurable), auto-doubles on overflow
```

Array layout:
| Array | Type |
|---|---|
| entityIds | `long[]` |
| entityTypeIds | `int[]` |
| lastProcessedSequence | `int[]` |
| chunkX, chunkY, chunkZ | `int[]` |
| localX, localY, localZ | `float[]` |
| velX, velY, velZ | `float[]` |
| flags | `int[]` |
| componentMask | `long[]` |

ID-to-index lookup: `ConcurrentHashMap<Long, Integer>` — allows lock-free parallel lookups.

#### Key Operations

- **addEntity** — Appends at `size` index, auto-doubles capacity if full
- **removeEntity** — Swap-remove: last element moved into removed slot (no fragmentation, O(1))
- **normalizePosition** — Wraps local coordinates through chunk boundaries (keeps local in [0,16))
- **importEntity / exportEntity** — Serialize/deserialize complete entity bundle (for migration)
- **createSnapshot** — Creates `EntitySnapshot` for a given index
- **writeToSnapshot** (P8 optimization): Writes directly into a pre-allocated snapshot slot — **zero allocation**

---

### 2.6 BulletinBoard — `BulletinBoard.java` (115 lines)

Stores **frozen** entity snapshots for a single SimulationBox. Repopulated every tick by `freezeSnapshots()`.

#### Dual Indexing

- **Chunk index**: `Map<Long, List<EntitySnapshot>>` — snapshots grouped by chunk key for neighbor queries
- **Entity index**: `Map<Long, EntitySnapshot>` — O(1) lookup by entity ID

#### Optimization

Tracks which chunk keys have active snapshots via `activeSnapshotKeys[]` array. `clearSnapshotLists()` only clears populated entries instead of iterating all map keys.

---

### 2.7 BoxCommandBuffer — `BoxCommandBuffer.java`

Accumulates commands from plugin systems during simulation. Committed after simulation in COMMAND_COMMIT phase.

#### Command Types

| Command | Purpose |
|---|---|
| **SpawnCommand** (typeId, position) | Create new entity in the least-loaded box |
| **DespawnCommand** (entityId) | Remove entity from its box |
| **MoveEntityCommand** (entityId, dx, dy, dz, velocity, flags) | Update entity position/velocity |
| **SetBlockCommand** (chunkX/Y/Z, localX/Y/Z, blockId) | Modify world block |
| **AttachComponentCommand** (entityId, class, component) | Add ECS component to entity |
| **RemoveComponentCommand** (entityId, class) | Remove ECS component from entity |
| **ShowUiCommand** (entityId, uiId) | Send UI layout to specific player |

---

### 2.8 CommandCommitter — `CommandCommitter.java` (121 lines)

**E.2 Optimization**: Parallelized commit — each box's command buffer is independent, so all commits execute concurrently on the box thread pool via a `Phaser`.

After commit, all changed chunk keys are returned to `EngineKernel` for broadcast to subscribed sessions.

---

### 2.9 BoxExecutor — `BoxExecutor.java` (82 lines)

Manages parallel execution of SimulationBoxes using a fixed thread pool. Provides two execution modes:
- `executeBoxes()` — Runs all boxes' `simulate()` in parallel, waits for all to complete
- `executeTasks()` — Runs arbitrary Runnable tasks in parallel (used for snapshot freezing, AOI collection, chunk broadcasting)

Uses `Phaser` for synchronization (main thread + N workers).

---

### 2.10 EntityIdGenerator — `EntityIdGenerator.java` (30 lines)

Generates globally unique entity IDs:
```java
return ((long)serverId << 48) | ((long)boxId << 32) | atomicCounter++;
```

Zero ID collisions between boxes without any cross-box coordination.

---

## PART 3: NETWORK LAYER

### 3.1 NetworkServer — `NetworkServer.java` (176 lines)

Built on **Netty** (NIO networking framework) with configurable boss (default 1) and worker (default = CPU cores) thread groups.

#### Netty Channel Pipeline

```
PacketEncoder → PacketDecoder → EventHandler → PacketHandler
```

1. **PacketEncoder** (`PacketEncoder.java`) — Serializes outgoing Packet objects to binary Netty ByteBufs using the binary protocol
2. **PacketDecoder** (`PacketDecoder.java`) — Deserializes incoming binary to typed Packet objects
3. **EventHandler** — Fires CONNECT/DISCONNECT events to event queue
4. **PacketHandler** — Routes packets to network queues

#### Input Processing Optimizations

- **Move packets** (`CInputMovePacket`): Go through `latestMovePackets` (ConcurrentHashMap) — only the most recent input per client is kept, preventing old inputs from accumulating
- **Non-move packets**: Go to `inputQueue` (ConcurrentLinkedQueue)
- **Backpressure**: If pending input packets exceed 200,000, the client is disconnected (DoS protection)
- **Channel writability**: WriteBufferWaterMark (4MB/8MB) provides flow control

#### E.4 Optimization: UDP Side-Channel

A UDP socket (port 25566) is prepared for position data to bypass TCP head-of-line blocking (not fully implemented).

---

### 3.2 Protocol Layer (engine-common)

#### Packet Type Enumeration

| ID | Packet | Direction | Payload |
|---|---|---|---|
| 0 | C_HELLO | C→S | playerKey, clientVersion |
| 1 | S_HELLO | S→C | accepted, message, entityId |
| 10 | C_INPUT_MOVE | C→S | sequence, tick, moveBits, jump, sprint, yaw, pitch, viewChunkX/Y/Z |
| 11 | C_INPUT_LOOK | C→S | yaw, pitch |
| 12 | C_BLOCK_ACTION | C→S | sequence, place, blockId |
| 20 | S_PLAYER_STATE | S→C | sequence, entityId, chunkX/Y/Z, localX/Y/Z, velX/Y/Z, flags |
| 21 | S_ENTITY_DELTA | S→C | serverTick, visible snapshots[], removed IDs[] |
| 22 | S_CHUNK_FULL | S→C | chunkX/Y/Z, deflated block data, deflated light data |
| 23 | S_CHUNK_UNLOAD | S→C | chunk keys[] |
| 30 | S_LAYOUT | S→C | uiId, JSON template |
| 31 | C_UI_ACTION | C→S | uiId, actionId |
| 40 | S_ASSET_MANIFEST | S→C | protocolVersion, registryHash, block/item/entity definitions |
| 41 | C_ASSET_REQUEST | C→S | asset path |
| 42 | S_ASSET_DATA | S→C | asset path, raw bytes |
| 43 | C_PLAYER_SKIN | C→S | raw PNG bytes |
| 44 | S_SKIN_UPDATE | S→C | entityId, raw PNG bytes |

**Protocol version**: `ProtocolConstants.BINARY_PROTOCOL_VERSION = 6`

#### ChunkPayloadCodec

Blocks are encoded via run-length encoding (delta from air) and then deflated (zlib). This typically achieves 90%+ compression on world data.

---

## PART 4: AREA OF INTEREST (AOI) SYSTEM

### 4.1 EntityAoiFrame — `EntityAoiFrame.java` (101 lines)

A **linear spatial hash grid** rebuilt every `ENTITY_AOI_UPDATE_INTERVAL_TICKS` (default: 6 ticks, i.e., 10 times/second).

#### Construction

1. All entity snapshots across all boxes are collected in parallel (`parallelCollectSnapshots`)
2. Each snapshot is assigned a cell key: `aoiCellKey(aoiCell(worldX), aoiCell(worldY), aoiCell(worldZ))` where cell size = 320 blocks
3. Snapshots are **quicksorted** in-place by cell key (zero allocation)
4. A hash table (power-of-2 size, open addressing with linear probing) maps cell key → `[startIndex, endIndex)` range into the sorted snapshot array

#### Lookup

For a given cell key, returns the contiguous range of snapshots in that cell in O(1). Each snapshot only lives in one cell.

---

### 4.2 AoiScratchpad — `AoiScratchpad.java` (179 lines)

Thread-safe AOI computation with **LOD rings**:

```
Ring 1 (< 64 blocks²):  Always update (60 Hz)
Ring 2 (< 80 blocks²):  15 Hz update (every 4 ticks)
Ring 3 (< 160 blocks²): 5 Hz update (every 12 ticks)
Outside Ring 3:         Not sent at all
```

Each snapshot thread gets its own `AoiScratchpad` via `ThreadLocal`.

#### Computation Steps

1. **Collect candidates**: Scan 3×3×3 cell neighborhood around the player center (27 cells)
2. **LOD filtering**: Apply ring-based update frequency, stagger by entity ID modulo interval
3. **Budget capping**: Sort by priority (players first) then distance, cap at `ENTITY_AOI_SEND_BUDGET` (50)
4. **State tracking**: Maintain `playerAoiStates` — sorted array of currently visible entity IDs
5. **Removal detection**: Binary search previous state against new state to find entities that fell out of range/budget

The result is an `EntityAoiResult` containing:
- `visible`: List of EntitySnapshots to send
- `removed`: List of entity IDs that are no longer visible

---

## PART 5: CHUNK MANAGEMENT

### 5.1 VoxelChunk — `VoxelChunk.java` (238 lines)

Represents a 16×16×16 partition of the voxel world.

#### P4 Optimization: Read-Write Lock

`ReentrantReadWriteLock` allows multiple snapshot threads to read cached network payloads simultaneously without blocking each other. Only actual block/light mutations require exclusive write access.

#### Cached Network Payload (E.5 Optimization)

The chunk pre-computes and caches:
- `SChunkPayloadPacket` — The Java packet object (reused until mutation)
- `ByteBuf` — Pre-encoded Netty ByteBuf for zero-copy channel writes

`toNetworkPayloadPacket()` uses double-checked locking:
1. Read lock → check if cached and valid → return
2. Write lock → double-check → rebuild if needed

---

### 5.2 Chunk Streaming

Chunks are streamed to clients via a **priority-based budget system**:

1. **View rebuild**: When the player's view center changes, `ChunkStreamState.rebuildIfCenterChanged()` recomputes the visible chunk set
2. **Ramp-up**: New sessions get `CHUNK_STREAM_INITIAL_SEND_BUDGET` (4) chunks/tick, which increases by 1 every `CHUNK_STREAM_RAMP_TICKS_PER_CHUNK` (20 ticks) until reaching `CHUNK_STREAM_SEND_BUDGET` (32)
3. **Global budget**: `CHUNK_STREAM_GLOBAL_SEND_BUDGET` (32,768) across all sessions per tick
4. **Missing chunks**: If a chunk hasn't been generated yet, it's added to `pendingKeys` and requested; if max loaded chunks reached, backpressure is applied (pause for 10 ticks)
5. **Unloading**: `retainSubscriptions()` removes subscriptions for chunks no longer visible; `SChunkUnloadPacket` notifies the client

#### ChunkStreamState

Per-session state tracking:
- `visibleKeys` — Set of chunk keys in current view (rebased when center changes)
- `pendingKeys` — Deque of chunks to send (in priority order)
- `sendBudget()` — Computes current session budget based on ramp-up
- `backpressurePausedUntilTick` — Backoff timer when chunk generation can't keep up

---

### 5.3 Chunk Generation Pipeline

```
Client requests chunk → Organizer.requestChunk(key)
  → if not already loaded: add to pendingGeneration set + queue
  → EngineKernel.BACKGROUND_HANDOFF: drainPendingGeneration(limit)
  → if not already in flight:
    1. Try PersistenceManager.loadChunk() from Custom Binary Format
    2. WorldGenerator.queueGeneration() on generator thread pool
  → Generation result (blocks + light + pre-encoded payload):
    - Apply initial sunlight (sunlight from top down)
    - Register chunk in Organizer's striped index
    - Pre-cache network payload
    - Deliver to sessions via SnapshotExecutor
```

---

### 5.4 Chunk Eviction

Every `CHUNK_UNLOAD_INTERVAL_TICKS` (300 = 5s):
1. Snapshot all chunk keys from the striped index
2. For each candidate:
   - Skip if has subscribers, entities, pending changes, or in-flight generation
   - Skip if within `CHUNK_UNLOAD_GRACE_TICKS` (1200 = 20s) grace period
   - Save to Custom Binary Format, remove from index, clear interest tracking
3. Budget: `CHUNK_EVICTION_SCAN_BUDGET` (512) scanned, `CHUNK_EVICTION_REMOVE_BUDGET` (64) removed per tick

---

## PART 6: SNAPSHOT & NETWORK OUTPUT

### 6.1 SnapshotExecutor — `SnapshotExecutor.java` (281 lines)

**P0 optimization**: Multi-threaded snapshot processing. Auto-scales: `max(2, min(cores/4, 8))` threads.

For Ryzen 9950X (64 threads) = 8 snapshot threads.

#### Execution Flow

1. Sessions are partitioned into N batches (N = min(threads, sessions/batchSize))
2. Each partition processes its sessions in parallel:
   - **AOI Delta**: Compute entity visibility changes using AoiScratchpad + LOD rings
   - **Player State**: Send `SPlayerStatePacket` with authoritative position
   - **Chunk Streaming**: Send pending chunks based on session's ChunkStreamState + global budgets
   - **P1 optimization**: Batch flush per channel rather than per-packet
3. After all partitions complete: `broadcastChangedChunks()` sends dirty chunk updates to all subscribed sessions

#### E.1 Optimization: Thread-Local Packet Pools

Eliminates 720K packet allocations/second by pooling reusable packet objects per thread.

---

## PART 7: PERSISTENCE LAYER

### 7.1 PersistenceManager — `PersistenceManager.java`

Manages custom directory-based binary persistence for world data using **async I/O** with its own thread pool.

#### Storage Directory Structure

The base database path acts as a parent directory containing three subdirectories:
- `chunks/` containing `.rebchunk` files for voxel chunks (magic: `REBC`, version 1, tick, coords, blocks, light).
- `players/` containing `.rebplayer` files for player entities (magic: `REBP`, version 1, player key, fields, component mask).
- `profiles/` containing `.rebprofile` files for player profiles (magic: `REBF`, version 1, identity ID, nickname, kills, round ID).

#### Write Pipeline

1. `saveChunk()` → Clone block/light data, push to `pendingChunkSaves` queue, clear dirty flag.
2. `flushPendingWrites()` → Single-flight CAS, submit batch write to IO pool.
3. Batch writes serialize each element to a `.tmp` file and rename it atomically to the final filename.
4. High watermark (4096 pending): chunks stop being saved until backlog clears (backpressure).

#### Read Pipeline

1. `loadChunk()` submits read task to IO pool.
2. File is read and deserialized into `VoxelChunk` and placed in `loadedChunks` queue.
3. `processLoadedChunks()` drains queue in BACKGROUND_HANDOFF phase.

---

## PART 8: WORLD SYSTEMS

### 8.1 WorldGenerator — `WorldGenerator.java` (58 lines)

Orchestrates background chunk generation using a registered `ChunkGenerator` (from a plugin). Falls back to flat world generation if no plugin generator is registered.

Dedicated thread pool with `CHUNK_GENERATOR_THREADS` (default: `min(4, cores/2)`).

Generated chunk data flows: WorldGenerator → `generationResults` queue → EngineKernel processes → Organizer registers chunk.

### 8.2 LightingEngine — `LightingEngine.java`

Computes initial sunlight for new/generated chunks. Light values are nibble-packed: high nibble = sky light, low nibble = block light.

### 8.3 LiquidEngine — `LiquidEngine.java` (66 lines)

Cellular automata-based liquid simulation:
- Downward flow first (simple gravity)
- Lateral spread if blocked below
- Operates on chunks identified as containing liquid

### 8.4 VoxelPhysics — `VoxelPhysics.java`

Axis-aligned bounding box collision detection against world blocks. Used by plugin systems via `BoxView.isBlockColliding()`.

---

## PART 9: GLOBAL WORLD VIEW

### 9.1 GlobalWorldView — `GlobalWorldView.java` (85 lines)

`WorldView` implementation that aggregates snapshots from all Box BulletinBoards.

`forEachEntityInRange()`:
1. Clamps radius to 10 blocks (per design constraint)
2. Checks the center chunk and all 26 neighbors
3. Queries only boxes that have entities in each chunk (via routing table)
4. Filters by distance and forwards to callback

### 9.2 BoxEcsView — `BoxEcsView.java` (130 lines)

Box-local plugin view preserving SimulationBox ownership boundaries. Adapter implementing `BoxView` interface:
- Delegates entity queries to local box's EntityStore and BulletinBoard
- Delegates collision detection to box's physics engine
- Delegates range queries to GlobalWorldView
- Provides `forEachEntityWith()` for component iteration
- Provides `forEachOwnedEntity()` for entity iteration

---

## PART 10: PLUGIN API (engine-plugin-api)

### 10.1 GameSystem — `GameSystem.java` (61 lines)

Abstract base class for all plugin systems. Two modes:
- **Box-level**: `onUpdate(boxView, cmd, dt)` — runs once per box per tick
- **Entity-level**: `onUpdateEntity(entityId, component, boxView, cmd, dt)` — runs per entity that has the specified component

The engine automatically calls `run()` which invokes both box and entity-level logic.

### 10.2 BoxView — `BoxView.java`

Read-only view into a SimulationBox for plugin systems:

| Method | Purpose |
|---|---|
| `boxId()` | Current box ID |
| `currentTick()` | Engine tick number |
| `isDaylight()` | Day/night cycle check |
| `getCollisionEntity(entityId, filterType)` | AABB collision check |
| `getComponent(entityId, class)` | Read ECS component |
| `forEachEntityWith(class, callback)` | Iterate entities with component |
| `getEntitySnapshot(entityId)` | Current entity snapshot |
| `getPlayerInput(playerId)` | Latest player input |
| `getRecipes()` | Crafting recipes |
| `isBlockColliding(...)` | Block collision query |
| `forEachOwnedEntity(callback)` | Iterate all entities in this box |

### 10.3 WorldView — `WorldView.java`

Global world view interface:
- `forEachEntityInRange()` — Query entities in radius
- `currentTick()` — Engine tick
- `isDaylight()` — Global day/night

### 10.4 CommandBuffer — `CommandBuffer.java`

Provides plugin systems with commands to modify world state:
- `spawnEntity(typeId, chunkX, Y, Z, lX, lY, lZ, data)`
- `despawnEntity(entityId)`
- `moveEntity(entityId, dx, dy, dz, velX, velY, velZ, flags)`
- `setBlock(chunkX, chunkY, chunkZ, lX, lY, lZ, blockId)`
- `attachComponent(entityId, class, component)`
- `removeComponent(entityId, class)`
- `showUi(entityId, uiId)`

### 10.5 PluginManifest / Plugin / PluginRegistry

- `Plugin.java` — Plugin entry point interface
- `PluginManifest.java` — Plugin metadata and content registration
- `Registry.java` / `PluginRegistry.java` — Block, item, recipe, entity registration
- `SkinHandler.java` — Handles player skin uploads and broadcasts
- `ChunkGenerator.java` — Plugin-provided terrain generation

---

## PART 11: CLIENT-SIDE ARCHITECTURE (engine-client)

### 11.1 ClientApp — `ClientApp.java` (492 lines)

The main client coordinator. Two states: `LAUNCHER` (server selection) and `INGAME`.

#### Launcher State

- Renders server list using `UiManager` with SDL event handling
- Supports adding servers via text input with persistent buffered text
- Uses SDL_StartTextInput/SDL_StopTextInput for keyboard input
- Click detection on UI elements triggers actions: `start_add_server`, `save_server`, `cancel_add_server`, `connect:host:port`

#### Ingame State (per frame)

1. Drain network queues: hello responses, asset manifests + data, chunks, chunk unloads, UI layouts, entity deltas, skin updates
2. Read input → generate `InputCommand` → predict locally → send to server
3. Reconcile with latest authoritative `SPlayerStatePacket` (server reconciliation)
4. Process chunk updates: received chunks → cache → build meshes → upload to GPU
5. Evict chunks beyond `CHUNK_UNLOAD_DISTANCE` (8) from player
6. Rebuild chunk meshes (up to 2 per frame) for dirty chunks
7. Client-side prediction with interpolation (−1 tick) for smooth rendering
8. Render frame with interpolated camera position

#### Asset Syncing

1. Server sends `SAssetManifestPacket` on connect (registry hash, block definitions, item definitions, entity type definitions)
2. Client validates protocol version and registry hash
3. `AssetDownloader` reconciles local cache with server manifest — requests missing assets
4. On receiving asset data, rebuilds block texture atlas and marks all chunks dirty for mesh rebuild

#### Player Skins

- Client reads `assets/skin.png` and sends raw PNG data via `CPlayerSkinPacket`
- Server's `SkinHandler` receives and broadcasts to other players via `SSkinUpdatePacket`
- Client stores received skins by entity ID and applies them to entity models

### 11.2 PredictionBuffer — `PredictionBuffer.java` (236 lines)

Client-side prediction with server reconciliation.

#### Data Structures

- `commandHistory[BUFFER_SIZE=1024]` — Ring buffer of sent InputCommands
- `stateHistory[BUFFER_SIZE]` — Corresponding predicted states
- `currentState` — Latest predicted position
- `lastConfirmedSequence` — Last acknowledged server sequence

#### Prediction Loop

1. `predict(command)`: Apply input to current state using MovementConstants (speed, gravity, jump velocity)
2. `reconcile(serverState)`: Replace state with server's authoritative position, then replay all unacknowledged inputs from seq+1 to latest

#### Movement Physics

- Horizontal: Forward/strafe based on yaw, using `MovementConstants.horizontalSpeed()` (sprint: 5.612, walk: 4.317)
- Vertical: Jump velocity (0.42) + gravity (−0.08 per tick)
- Step-up: If moving into a wall, try stepping up by `PLAYER_STEP_HEIGHT` (0.5 blocks)
- Collision: Axis-aligned bounding box check against block data from `BlockCollisionView`

### 11.3 ClientNetwork — `ClientNetwork.java`

Manages the TCP connection to the server:
- Send hello packet
- Send input movements (packed as CInputMovePacket with sequence, move bits, yaw/pitch, view chunk)
- Receive and queue: chunks, state updates, entity deltas, layouts, asset manifests, asset data, skin updates
- Queue draining by ClientApp

### 11.4 Render Loop — `RenderLoop.java`

LWJGL/OpenGL renderer with:
- Chunk mesh rendering (opaque and transparent passes)
- Entity model rendering (GLTF/OBJ models with animation)
- UI overlay rendering
- Camera management (interpolated player position)
- Shader management

### 11.5 ChunkRenderer / ChunkCache / ChunkMesh

- **ChunkCache**: Stores received block/light data, provides neighbor blocks for mesh building
- **ChunkRenderer**: Generates GPU meshes from block data (greedy meshing?), handles opaque vs transparent faces
- **ChunkMesh**: Uploads vertex data to OpenGL VAO/VBO/EBO

---

## PART 12: EXAMPLE PLUGIN — REBULACIAN-PLUGIN

### 12.1 LastStandingSystem — `LastStandingSystem.java` (52 lines)

Implements a "last man standing" game mode:
- Counts entities with `PlayerComponent` where `alive = true`
- When count ≤ 1, declares the winner and ends the game

### 12.2 IslandBuilder / IslandConfig / ArenaBlocks

Generates the game arena:
- `IslandConfig.java` — Configuration (player count, island layout, arena size)
- `IslandBuilder.java` — Programmatically builds the island terrain using SetBlockCommands
- `ArenaBlocks.java` — Block type definitions for the arena

### 12.3 Game Systems

- **ShovelDigSystem** — Handles block digging with a shovel tool
- **IslandShrinkSystem** — Periodically shrinks the playable area (shrinking border)
- **LavaDeathSystem** — Kills players that fall into lava
- **LastStandingSystem** — Win condition tracking

### 12.4 PluginImporter — `PluginImporter.java`

Handles plugin bootstrapping: reading plugin manifest, registering blocks/items/recipes with the engine's PluginRegistry.

---

## PART 13: LOAD TESTING

### 13.1 LoadTestClient — `LoadTestClient.java` (288 lines)

Simulates thousands of bot clients connecting to the server for performance testing.

#### Configurable Parameters (CLI args)

| Arg | Default | Purpose |
|---|---|---|
| host | 127.0.0.1 | Server address |
| port | 25565 | Server port |
| clients | 10000 | Number of bots |
| duration | 120s | Test duration |
| inputsPerSecond | 20 | Input frequency per bot |
| spreadChunks | 64 | Spawn spread |
| connectRatePerSecond | 25 | Connection rate |
| movementMode | "walk" | Movement pattern (walk/idle) |

#### Bot Behavior

- Connects with unique player key: `"load-N"`
- Sends periodic move inputs with random yaw variations
- **Soft tether**: Bots gently turned back when wandering beyond a 20×20 area around spawn
- Reader thread drains server packets (drains without parsing for throughput measurement)
- Reports: connected count, failed count, frames read, MB read

---

## PART 14: HOW THE ENGINE HOSTS THOUSANDS OF PLAYERS

### 14.1 Summary of All Scaling Techniques

| Technique | Where | Impact |
|---|---|---|
| **Spatial Partitioning** (SimulationBoxes) | Server | Entities in different world regions simulate on different threads |
| **Parallel Box Execution** (BoxExecutor) | EngineKernel | All boxes simulate simultaneously on thread pool |
| **Pipelining** (Phase C) | EngineKernel | Network input processed while boxes simulate |
| **Striped Chunk Index** (P9) | Organizer | Eliminates ConcurrentHashMap contention under high load |
| **Data-Oriented EntityStore** (SoA) | EntityStore | Cache-friendly entity data, minimal GC pressure |
| **AOI System** (Spatial Hash Grid) | AoiFrame + AoiScratchpad | Only relevant entities sent to each player |
| **LOD Rings** (P5) | AoiScratchpad | Distant entities updated less frequently (5-15 Hz vs 60 Hz) |
| **Budget System** | ChunkStream + NetOutput | Predictable network utilization per tick |
| **Chunk Ramp-Up** | ChunkStreamState | New players don't flood the network |
| **Parallel Snapshotting** (P0) | SnapshotExecutor | Network output generation parallelized across 8 threads |
| **Read-Write Lock on Chunks** (P4) | VoxelChunk | Multiple snapshot threads can read payloads simultaneously |
| **Cached Network Payloads** (E.5) | VoxelChunk | Pre-encoded ByteBuf for zero-copy Netty writes |
| **Zero-Alloc Snapshots** (P8) | EntityStore | Eliminates per-tick snapshot object allocation |
| **Thread-Local Packet Pools** (E.1) | SnapshotExecutor | Eliminates 720K packet allocations/second |
| **Async Persistence** | PersistenceManager | Disk I/O never blocks the game loop |
| **Rate Limiting** | EngineKernel | Per-client packet/s asset request limits |
| **Write Watermarks** | NetworkServer | Flow control via Netty's writability detection |
| **Soft Player Cap** (12,000) | EngineKernel | Hard limit prevents resource exhaustion |
| **Client-Side Chunk Gen** | Protocol | Phase D: Clients generate chunks locally, eliminating chunk network traffic entirely |
| **Backpressure** | ChunkStream+Persist | When loaded chunks or write backlog exceed limits |
| **Entity Migration** | Organizer | Automatic load balancing between boxes |
| **Connection Ramping** | LoadTestClient | Gradual connection rate (25/s) prevents thundering herd |
| **Directory Batch Writes** | PersistenceManager | Batch writes rather than per-chunk writes |

### 14.2 Theoretical Capacity Analysis

With default settings on a Ryzen 9950X (64 threads):

| Resource | Capacity per Tick | Notes |
|---|---|---|
| **Players** | 12,000 (hard cap) | Limited by session count, not CPU |
| **Chunks streamed** | 32,768 (global send budget) | ~2.7 chunks/second per player at 12K players |
| **Entity AOI updates** | 50 entities/tick per player | With 10 Hz AOI, 500 unique entities visible/player |
| **Simulation** | ~2,000-3,000 entities/box | With 8 boxes, ~16-24K entities simulatable |
| **Memory** | ~10KB/chunk | 16×16×16 shorts + byte light + overhead |
| **Network (ingress)** | 8,192 move packets/tick | At 60 TPS = 491K moves/second, ~41 moves/player at 12K |

### 14.3 Key Architectural Decisions

1. **Why not a single world server?** The SimulationBox partitioning allows the engine to scale horizontally across CPU cores. Each box is a fully independent simulation domain that can run on its own thread.

2. **Why not ECS library (Artemis, etc.)?** Custom SoA implementation gives direct control over memory layout, cache behavior, and allocation patterns. The array-based storage is trivially parallelizable.

3. **Why TCP not UDP?** TCP's built-in ordering and reliability simplify game logic. The UDP side-channel was planned but not implemented because TCP throughput proved sufficient with proper flow control.

4. **Why custom binary files instead of databases?** Zero-configuration operation, highly optimized for voxel data, and zero external database dependencies. Atomic writes avoid database overhead.

5. **Why client-side chunk generation?** Phase D eliminates the single largest source of network traffic. The server only sends the world seed, and both sides generate identical terrain deterministically. This reduces bandwidth by ~90%.

---

## PART 15: METRICS & MONITORING

### 15.1 MetricsHttpServer — `MetricsHttpServer.java`

Exposes an HTTP endpoint on port 25566 with a `MetricsSnapshot` containing:

| Metric | Purpose |
|---|---|
| TPS | Actual ticks per second (target 60) |
| AvgTickMs | Average tick duration |
| AvgBoxMs | Average box simulation time |
| SessionCount | Currently connected players |
| EntityCount | Total entities across all boxes |
| ChunkCount | Currently loaded chunks |
| GenFlight | Chunks being generated |
| PendingChunkSaves | Chunk write backlog |
| PendingPlayerSaves | Player save backlog |

### 15.2 EngineKernel Metrics

Logged every second:
```
[Metrics] TPS: 60 | Avg Tick: 8.234 ms | Avg Box: 3.456 ms | GC: 12 ms | Alloc: 45.21 MB/s | 
Sessions: 2000 | Entities: 2050 | Chunks: 8456 | GenFlight: 12 | InputQ: 0 | PendingSaves: 0/128
```

Phase-level metrics (when enabled):
```
[Phases] Begin: 0.001 ms | In: 0.234 ms | Route: 0.567 ms | Box: 3.456 ms | 
Commit: 0.234 ms | Move: 0.123 ms | Snap: 2.345 ms | Net: 0.001 ms | Bg: 1.234 ms
```

---

## FILE REFERENCE INDEX

| File | Lines | Purpose |
|---|---|---|
| `engine-server/boot/ServerMain.java` | 37 | Server entry point |
| `engine-server/kernel/EngineKernel.java` | 1105 | Core game loop, tick phases, connection handling |
| `engine-server/organizer/Organizer.java` | 603 | Central coordinator, striped chunk index, routing, migration |
| `engine-server/box/SimulationBox.java` | 323 | Per-shard simulation domain |
| `engine-server/box/BoxExecutor.java` | 82 | Parallel box execution on thread pool |
| `engine-server/ecs/EntityStore.java` | 334 | Data-oriented entity storage (SoA) |
| `engine-server/ecs/EntityIdGenerator.java` | 30 | Globally unique entity IDs |
| `engine-server/bulletin/BulletinBoard.java` | 115 | Frozen entity snapshot store |
| `engine-server/command/BoxCommandBuffer.java` | - | Plugin command accumulator |
| `engine-server/command/CommandCommitter.java` | 121 | Parallel command commit phase |
| `engine-server/chunk/VoxelChunk.java` | 238 | 16×16×16 chunk with read-write lock |
| `engine-server/chunk/ChunkSerializer.java` | - | Chunk serialization |
| `engine-server/snapshot/SnapshotExecutor.java` | 281 | Multi-threaded network output |
| `engine-server/snapshot/SnapshotContext.java` | 61 | Immutable snapshot partition context |
| `engine-server/snapshot/ChunkStreamState.java` | - | Per-session chunk streaming state |
| `engine-server/aoi/EntityAoiFrame.java` | 101 | Linear spatial hash grid |
| `engine-server/aoi/EntityAoiResult.java` | 13 | AOI delta result |
| `engine-server/aoi/AoiDeltaEvent.java` | - | AOI change event |
| `engine-server/aoi/AoiScratchpad.java` | 179 | Thread-safe LOD ring AOI computation |
| `engine-server/net/NetworkServer.java` | 176 | Netty TCP server |
| `engine-server/net/PacketEncoder.java` | - | Packet serialization |
| `engine-server/net/PacketDecoder.java` | - | Packet deserialization |
| `engine-server/tick/TickContext.java` | 24 | Immutable tick data |
| `engine-server/tick/TickPhase.java` | 16 | Tick phase enumeration (9 phases) |
| `engine-server/persistence/PersistenceManager.java` | 320 | Async custom binary persistence |
| `engine-server/world/WorldGenerator.java` | 58 | Background chunk generation |
| `engine-server/world/LightingEngine.java` | - | Sunlight computation |
| `engine-server/world/LiquidEngine.java` | 66 | Liquid flow simulation |
| `engine-server/world/GeneratedChunk.java` | - | Generation result container |
| `engine-server/worldview/GlobalWorldView.java` | 85 | Cross-box entity range queries |
| `engine-server/worldview/BoxEcsView.java` | 130 | Box-local plugin view adapter |
| `engine-server/registry/BlockRegistry.java` | - | Block type definitions |
| `engine-server/asset/AssetManager.java` | - | Server-side asset serving |
| `engine-server/plugin/PluginLoader.java` | - | Plugin discovery and loading |
| `engine-server/plugin/InternalPluginRegistry.java` | - | Plugin registration |
| `engine-server/physics/VoxelPhysics.java` | - | Block collision detection |
| `engine-server/metrics/MetricsHttpServer.java` | - | HTTP metrics endpoint |
| `engine-server/metrics/MetricsSnapshot.java` | - | Metrics data snapshot |
| `engine-client/ClientApp.java` | 492 | Main client coordinator |
| `engine-client/boot/ClientMain.java` | - | Client entry point |
| `engine-client/net/ClientNetwork.java` | - | Client TCP connection |
| `engine-client/net/ServerManager.java` | - | Server list management |
| `engine-client/prediction/PredictionBuffer.java` | 236 | Client-side prediction with reconciliation |
| `engine-client/prediction/PredictionState.java` | - | Predicted position state |
| `engine-client/prediction/InputCommand.java` | - | Client input command |
| `engine-client/render/RenderLoop.java` | - | OpenGL rendering loop |
| `engine-client/render/chunk/ChunkCache.java` | - | Client-side chunk data cache |
| `engine-client/render/chunk/ChunkRenderer.java` | - | GPU mesh generation |
| `engine-client/render/chunk/ChunkMesh.java` | - | OpenGL mesh storage |
| `engine-client/render/WorldRenderState.java` | - | Client world state |
| `engine-client/render/ShaderProgram.java` | - | GLSL shader management |
| `engine-client/render/Texture.java` | - | OpenGL texture management |
| `engine-client/render/EntityModel.java` | - | Entity model rendering |
| `engine-client/render/GltfModel.java` | - | GLTF model loader |
| `engine-client/render/ObjModel.java` | - | OBJ model loader |
| `engine-client/render/SdlWindow.java` | - | SDL window management |
| `engine-client/input/InputCollector.java` | - | SDL input handling |
| `engine-client/audio/AudioSystem.java` | - | Audio playback |
| `engine-client/ui/UiManager.java` | - | UI overlay system |
| `engine-client/asset/AssetCache.java` | - | Client-side asset cache |
| `engine-client/asset/AssetDownloader.java` | - | Asset downloader |
| `engine-common/coord/ChunkKey.java` | - | Chunk key packing/unpacking |
| `engine-common/protocol/PacketType.java` | 47 | Packet type enumeration (18 types) |
| `engine-common/protocol/ProtocolConstants.java` | 8 | Protocol version (6) |
| `engine-common/protocol/ChunkPayloadCodec.java` | - | Chunk data compression |
| `engine-common/protocol/packet/*.java` | - | Packet record definitions |
| `engine-common/bulletin/EntitySnapshot.java` | - | Immutable entity state snapshot |
| `engine-common/registry/BlockDefinition.java` | - | Block type definition |
| `engine-common/registry/ItemDefinition.java` | - | Item type definition |
| `engine-common/registry/EntityTypeDefinition.java` | - | Entity type with bounding box |
| `engine-common/registry/Recipe.java` | - | Crafting recipe |
| `engine-common/asset/AssetManifest.java` | - | Server asset manifest |
| `engine-common/simulation/MovementConstants.java` | - | Movement physics constants |
| `engine-plugin-api/Plugin.java` | - | Plugin entry point |
| `engine-plugin-api/system/GameSystem.java` | 61 | Abstract plugin system |
| `engine-plugin-api/world/BoxView.java` | 85 | Box-local view interface |
| `engine-plugin-api/world/WorldView.java` | - | Global world view interface |
| `engine-plugin-api/world/ChunkGenerator.java` | - | Terrain generation interface |
| `engine-plugin-api/world/PlayerInput.java` | - | Player input interface |
| `engine-plugin-api/command/CommandBuffer.java` | - | World modification commands |
| `engine-plugin-api/registry/PluginRegistry.java` | - | Plugin registration API |
| `tools/LoadTestClient.java` | 288 | Multi-bot load testing tool |