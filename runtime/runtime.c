#define _GNU_SOURCE
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#define KX_MAX_COMPONENTS 64
#define KX_MAX_FIELDS 16
#define KX_MAX_BOXES 256
#define KX_INIT_ENTITIES 256
#define KX_MAX_TAGS 64
#define KX_BUF_CAP 4096

typedef long long kx_entity;

/* ---- request queue (deterministic cross-box mutation) ---- */

typedef enum {
  REQ_ENSURE,
  REQ_WRITE_I64,
  REQ_WRITE_F64,
  REQ_WRITE_STR,
  REQ_DETACH,
  REQ_DESPAWN,
} kx_req_kind;

typedef struct {
  int kind;
  int comp;
  int field;
  long long v;
} kx_req;

/* ---- per-box entity store ---- */

typedef struct {
  pthread_mutex_t allocLock;
  long long* tagMasks;
  long long* compMasks;
  int* gens;
  int size;
  int cap;

  kx_req** queues;
  int* qSize;
  int* qCap;

  long long* fIds;
  long long* fTags;
  long long* fComps;
  long long fSize;
  void** fFields;
} kx_box;

static int g_compCount;
static int g_fieldCounts[KX_MAX_COMPONENTS];
static int g_boxCount = 1;
static kx_box* g_boxes;

static long long* g_frozenIds;
static long long* g_frozenTagMasks;
static long long* g_frozenCompMasks;
static void** g_frozenFields;
static long long g_frozenSize;

static int g_sysCount;
static long long* g_sysMatch;
static long long* g_sysWithout;
static void (**g_sysBodies)(long long);

static int g_tps;
static long long g_maxTicks;
static long long g_tick;
static double g_dt;
static volatile int g_stop;

static long long g_spawnCounter;
static pthread_mutex_t g_spawnLock = PTHREAD_MUTEX_INITIALIZER;

static int entityBox(kx_entity e);
static int entitySlot(kx_entity e);
static int entityGen(kx_entity e);
static int slotAlive(kx_box* b, long long slot);

/* ---- migration location table (entity id -> current box + slot) ---- */

static void locInsert(kx_entity e, int box, long long slot);

static kx_entity* g_locKeys;
static int* g_locBoxes;
static long long* g_locSlots;
static int g_locCap;
static int g_locCount;

static void locGrow(void) {
  int newCap = g_locCap ? g_locCap * 2 : 64;
  kx_entity* oldKeys = g_locKeys;
  int* oldBoxes = g_locBoxes;
  long long* oldSlots = g_locSlots;
  int oldCap = g_locCap;
  g_locKeys = (kx_entity*)calloc(newCap, sizeof(kx_entity));
  g_locBoxes = (int*)calloc(newCap, sizeof(int));
  g_locSlots = (long long*)calloc(newCap, sizeof(long long));
  g_locCap = newCap;
  g_locCount = 0;
  for (int i = 0; i < oldCap; i++) {
    if (oldKeys[i] != 0) locInsert(oldKeys[i], oldBoxes[i], oldSlots[i]);
  }
  free(oldKeys);
  free(oldBoxes);
  free(oldSlots);
}

static void locInsert(kx_entity e, int box, long long slot) {
  if (g_locCount * 10 >= g_locCap * 7) locGrow();
  size_t i = (size_t)(e * 2654435761u) & (g_locCap - 1);
  while (g_locKeys[i] != 0 && g_locKeys[i] != e) i = (i + 1) & (g_locCap - 1);
  if (g_locKeys[i] == 0) {
    g_locKeys[i] = e;
    g_locCount++;
  }
  g_locBoxes[i] = box;
  g_locSlots[i] = slot;
}

/* Resolve an entity to (box, slot): origin first, then the migration table. */
static int resolve(kx_entity e, kx_box** box, long long* slot) {
  int ob = entityBox(e);
  if (ob < 0 || ob >= g_boxCount) return 0;
  kx_box* b = &g_boxes[ob];
  long long oslot = entitySlot(e);
  if (slotAlive(b, oslot) && entityGen(e) == b->gens[oslot]) {
    *box = b;
    *slot = oslot;
    return 1;
  }
  if (g_locCap) {
    size_t i = (size_t)(e * 2654435761u) & (g_locCap - 1);
    for (int probes = 0; probes < g_locCap; probes++) {
      kx_entity k = g_locKeys[i];
      if (k == 0) return 0;
      if (k == e) {
        *box = &g_boxes[g_locBoxes[i]];
        *slot = g_locSlots[i];
        return 1;
      }
      i = (i + 1) & (g_locCap - 1);
    }
  }
  return 0;
}

/* ---- output buffers (deterministic flush order) ---- */

typedef struct {
  char data[KX_BUF_CAP];
  int len;
} kx_buffer;

static kx_buffer g_buffers[KX_MAX_BOXES + 1];

static _Thread_local int g_currentBuffer = -1;

static void bufAppend(int idx, const char* s) {
  if (idx < 0 || idx > KX_MAX_BOXES) return;
  kx_buffer* b = &g_buffers[idx];
  size_t n = strlen(s);
  if (b->len + (int)n >= KX_BUF_CAP) {
    fwrite(b->data, 1, b->len, stdout);
    b->len = 0;
  }
  memcpy(b->data + b->len, s, n);
  b->len += (int)n;
}

static void bufFlush(int idx) {
  if (idx < 0 || idx > KX_MAX_BOXES) return;
  if (g_buffers[idx].len > 0) {
    fwrite(g_buffers[idx].data, 1, g_buffers[idx].len, stdout);
    g_buffers[idx].len = 0;
  }
}

static int entityBox(kx_entity e) { return (int)(e >> 48); }

static int entitySlot(kx_entity e) { return (int)((e >> 16) & 0xFFFFFFFFLL); }

static int entityGen(kx_entity e) { return (int)(e & 0xFFFF); }

static int slotAlive(kx_box* b, long long slot) {
  return slot >= 0 && slot < b->size && b->gens[slot] != 0;
}

static kx_box* resolveBox(kx_entity e) {
  kx_box* b;
  long long s;
  return resolve(e, &b, &s) ? b : NULL;
}

static void growBox(kx_box* b) {
  int newCap = b->cap * 2;
  b->tagMasks = (long long*)realloc(b->tagMasks, sizeof(long long) * newCap);
  b->compMasks = (long long*)realloc(b->compMasks, sizeof(long long) * newCap);
  b->gens = (int*)realloc(b->gens, sizeof(int) * newCap);
  for (int c = 0; c < g_compCount; c++) {
    for (int f = 0; f < g_fieldCounts[c]; f++) {
      b->fFields[c * KX_MAX_FIELDS + f] =
          realloc(b->fFields[c * KX_MAX_FIELDS + f], 8 * newCap);
    }
  }
  b->fIds = (long long*)realloc(b->fIds, sizeof(long long) * newCap);
  b->fTags = (long long*)realloc(b->fTags, sizeof(long long) * newCap);
  b->fComps = (long long*)realloc(b->fComps, sizeof(long long) * newCap);
  b->cap = newCap;
}

static void createBoxes(int count) {
  if (count < 1) count = 1;
  if (count > KX_MAX_BOXES) count = KX_MAX_BOXES;
  if (g_boxes && g_boxCount == count) return;
  if (g_boxes) {
    for (int i = 0; i < g_boxCount; i++) {
      free(g_boxes[i].tagMasks);
      free(g_boxes[i].compMasks);
      free(g_boxes[i].gens);
      for (int c = 0; c < g_compCount; c++) {
        for (int f = 0; f < g_fieldCounts[c]; f++) free(g_boxes[i].fFields[c * KX_MAX_FIELDS + f]);
      }
      for (int s = 0; s < count; s++) {
        free(g_boxes[i].queues[s]);
        free(g_boxes[i].qSize);
      }
      free(g_boxes[i].queues);
      free(g_boxes[i].qSize);
      free(g_boxes[i].qCap);
      free(g_boxes[i].fIds);
      free(g_boxes[i].fTags);
      free(g_boxes[i].fComps);
      free(g_boxes[i].fFields);
      pthread_mutex_destroy(&g_boxes[i].allocLock);
    }
    free(g_boxes);
    g_boxes = NULL;
  }
  g_boxCount = count;
  g_boxes = (kx_box*)calloc(count, sizeof(kx_box));
  for (int i = 0; i < count; i++) {
    kx_box* b = &g_boxes[i];
    pthread_mutex_init(&b->allocLock, NULL);
    b->cap = KX_INIT_ENTITIES;
    b->tagMasks = (long long*)calloc(b->cap, sizeof(long long));
    b->compMasks = (long long*)calloc(b->cap, sizeof(long long));
    b->gens = (int*)calloc(b->cap, sizeof(int));
    b->fFields = (void**)calloc(g_compCount * KX_MAX_FIELDS, sizeof(void*));
    for (int c = 0; c < g_compCount; c++) {
      for (int f = 0; f < g_fieldCounts[c]; f++) {
        b->fFields[c * KX_MAX_FIELDS + f] = calloc(8, b->cap);
      }
    }
    b->fIds = (long long*)calloc(b->cap, sizeof(long long));
    b->fTags = (long long*)calloc(b->cap, sizeof(long long));
    b->fComps = (long long*)calloc(b->cap, sizeof(long long));
    b->queues = (kx_req**)calloc(count + 1, sizeof(kx_req*));
    b->qSize = (int*)calloc(count + 1, sizeof(int));
    b->qCap = (int*)calloc(count + 1, sizeof(int));
    for (int s = 0; s < count + 1; s++) {
      b->qCap[s] = 64;
      b->queues[s] = (kx_req*)malloc(sizeof(kx_req) * 64);
    }
  }
  g_frozenIds = (long long*)realloc(g_frozenIds, sizeof(long long) * g_boxCount * KX_INIT_ENTITIES);
  g_frozenTagMasks =
      (long long*)realloc(g_frozenTagMasks, sizeof(long long) * g_boxCount * KX_INIT_ENTITIES);
  g_frozenCompMasks =
      (long long*)realloc(g_frozenCompMasks, sizeof(long long) * g_boxCount * KX_INIT_ENTITIES);
}

/* ---- mutation queue (single writer per source: deterministic) ---- */

static void enqueue(kx_box* box, int source, kx_req r) {
  if (box->qSize[source] >= box->qCap[source]) {
    box->qCap[source] *= 2;
    box->queues[source] =
        (kx_req*)realloc(box->queues[source], sizeof(kx_req) * box->qCap[source]);
  }
  box->queues[source][box->qSize[source]++] = r;
}

static void applyRequest(kx_entity e, const kx_req* r) {
  kx_box* b;
  long long slot;
  if (!resolve(e, &b, &slot)) return;
  switch (r->kind) {
    case REQ_ENSURE:
      b->compMasks[slot] |= (1LL << r->comp);
      break;
    case REQ_WRITE_I64:
      ((long long*)b->fFields[r->comp * KX_MAX_FIELDS + r->field])[slot] = r->v;
      break;
    case REQ_WRITE_F64: {
      double d;
      memcpy(&d, &r->v, 8);
      ((double*)b->fFields[r->comp * KX_MAX_FIELDS + r->field])[slot] = d;
      break;
    }
    case REQ_WRITE_STR:
      ((char**)b->fFields[r->comp * KX_MAX_FIELDS + r->field])[slot] = (char*)r->v;
      break;
    case REQ_DETACH:
      b->compMasks[slot] &= ~(1LL << r->comp);
      break;
    case REQ_DESPAWN: {
      b->gens[slot] = (b->gens[slot] + 1) & 0xFFFF;
      if (b->gens[slot] == 0) b->gens[slot] = 1;
      b->tagMasks[slot] = 0;
      b->compMasks[slot] = 0;
      break;
    }
  }
}

static void commitBox(kx_box* b) {
  for (int src = 0; src <= g_boxCount; src++) {
    for (int i = 0; i < b->qSize[src]; i++) {
      applyRequest(b->queues[src][i].v, &b->queues[src][i]);
    }
    b->qSize[src] = 0;
  }
}

/* ---- public API ---- */

void kx_init(int compCount, const int* fieldCounts) {
  g_compCount = compCount < KX_MAX_COMPONENTS ? compCount : KX_MAX_COMPONENTS;
  for (int c = 0; c < g_compCount; c++) g_fieldCounts[c] = fieldCounts[c];
}

void kx_set_systems(int count, const void* table) {
  g_sysCount = count;
  g_sysMatch = (long long*)malloc(sizeof(long long) * count);
  g_sysWithout = (long long*)malloc(sizeof(long long) * count);
  g_sysBodies = (void (**)(long long))malloc(sizeof(void*) * count);
  const char* p = (const char*)table;
  for (int i = 0; i < count; i++) {
    long long match, without;
    void (*body)(long long);
    memcpy(&match, p, 8);
    memcpy(&without, p + 8, 8);
    memcpy(&body, p + 16, 8);
    g_sysMatch[i] = match;
    g_sysWithout[i] = without;
    g_sysBodies[i] = body;
    p += 24;
  }
}

static int defaultBoxCount(void) {
  const char* env = getenv("KUBEXIC_CORES");
  if (env) {
    double v = atof(env);
    if (v > 0) {
      int n = v < 1 ? (int)(v * sysconf(_SC_NPROCESSORS_ONLN)) : (int)v;
      return n < 1 ? 1 : (n > KX_MAX_BOXES ? KX_MAX_BOXES : n);
    }
  }
  int ncpu = (int)sysconf(_SC_NPROCESSORS_ONLN);
  return ncpu > 1 ? ncpu : 1;
}

kx_entity kx_spawn(long long tagMask) {
  if (!g_boxes) createBoxes(defaultBoxCount());
  int target;
  pthread_mutex_lock(&g_spawnLock);
  target = (int)(g_spawnCounter++ % g_boxCount);
  pthread_mutex_unlock(&g_spawnLock);
  kx_box* b = &g_boxes[target];
  pthread_mutex_lock(&b->allocLock);
  long long slot = -1;
  for (int i = 0; i < b->size; i++) {
    if (!slotAlive(b, i)) { slot = i; break; }
  }
  if (slot < 0) {
    slot = b->size++;
    if (b->size > b->cap) growBox(b);
  }
  b->gens[slot] = (b->gens[slot] + 1) & 0xFFFF;
  if (b->gens[slot] == 0) b->gens[slot] = 1;
  b->tagMasks[slot] = tagMask;
  b->compMasks[slot] = 0;
  pthread_mutex_unlock(&b->allocLock);
  return ((kx_entity)target << 48) | (slot << 16) | b->gens[slot];
}

void kx_ensure_comp(kx_entity e, int comp) {
  kx_box* b = resolveBox(e);
  if (!b || comp < 0 || comp >= g_compCount) return;
  kx_req r = {REQ_ENSURE, comp, 0, e};
  enqueue(b, g_currentBuffer < 0 ? g_boxCount : g_currentBuffer, r);
}

void kx_detach_comp(kx_entity e, int comp) {
  kx_box* b = resolveBox(e);
  if (!b || comp < 0 || comp >= g_compCount) return;
  kx_req r = {REQ_DETACH, comp, 0, e};
  enqueue(b, g_currentBuffer < 0 ? g_boxCount : g_currentBuffer, r);
}

void kx_despawn(kx_entity e) {
  kx_box* b = resolveBox(e);
  if (!b) return;
  kx_req r = {REQ_DESPAWN, 0, 0, e};
  enqueue(b, g_currentBuffer < 0 ? g_boxCount : g_currentBuffer, r);
}

/* ---- live self-access (box-local, no locks) ---- */

long long kx_comp_read_i64(kx_entity e, int comp, int field) {
  kx_box* b;
  long long slot;
  if (!resolve(e, &b, &slot)) return 0;
  if (comp < 0 || comp >= g_compCount || field >= g_fieldCounts[comp]) return 0;
  return ((long long*)b->fFields[comp * KX_MAX_FIELDS + field])[slot];
}

void kx_comp_write_i64(kx_entity e, int comp, int field, long long v) {
  kx_box* b;
  long long slot;
  if (!resolve(e, &b, &slot)) return;
  if (comp < 0 || comp >= g_compCount || field >= g_fieldCounts[comp]) return;
  ((long long*)b->fFields[comp * KX_MAX_FIELDS + field])[slot] = v;
}

double kx_comp_read_f64(kx_entity e, int comp, int field) {
  kx_box* b;
  long long slot;
  if (!resolve(e, &b, &slot)) return 0.0;
  if (comp < 0 || comp >= g_compCount || field >= g_fieldCounts[comp]) return 0.0;
  return ((double*)b->fFields[comp * KX_MAX_FIELDS + field])[slot];
}

void kx_comp_write_f64(kx_entity e, int comp, int field, double v) {
  kx_box* b;
  long long slot;
  if (!resolve(e, &b, &slot)) return;
  if (comp < 0 || comp >= g_compCount || field >= g_fieldCounts[comp]) return;
  ((double*)b->fFields[comp * KX_MAX_FIELDS + field])[slot] = v;
}

char* kx_comp_read_str(kx_entity e, int comp, int field) {
  kx_box* b;
  long long slot;
  if (!resolve(e, &b, &slot)) return NULL;
  if (comp < 0 || comp >= g_compCount || field >= g_fieldCounts[comp]) return NULL;
  return ((char**)b->fFields[comp * KX_MAX_FIELDS + field])[slot];
}

void kx_comp_write_str(kx_entity e, int comp, int field, char* v) {
  kx_box* b;
  long long slot;
  if (!resolve(e, &b, &slot)) return;
  if (comp < 0 || comp >= g_compCount || field >= g_fieldCounts[comp]) return;
  ((char**)b->fFields[comp * KX_MAX_FIELDS + field])[slot] = v;
}

/* ---- freeze (per-box) + merge (sorted by entity id: deterministic
 * regardless of box placement or migration) ---- */

static void freezeBox(kx_box* b) {
  long long fs = 0;
  for (int slot = 0; slot < b->size; slot++) {
    if (!slotAlive(b, slot)) continue;
    b->fIds[fs] = ((kx_entity)((b - g_boxes)) << 48) | (slot << 16) | b->gens[slot];
    b->fTags[fs] = b->tagMasks[slot];
    long long cm = b->compMasks[slot];
    b->fComps[fs] = cm;
    for (int c = 0; c < g_compCount; c++) {
      if (!(cm & (1LL << c))) continue;
      for (int f = 0; f < g_fieldCounts[c]; f++) {
        memcpy((char*)b->fFields[c * KX_MAX_FIELDS + f] + fs * 8,
               (char*)b->fFields[c * KX_MAX_FIELDS + f] + slot * 8, 8);
      }
    }
    fs++;
  }
  b->fSize = fs;
}

typedef struct {
  long long id;
  int box;
  long long idx;
} kx_fent;

static kx_fent* g_sortBuf;
static int g_sortCap;

static int cmpFent(const void* a, const void* b) {
  long long x = ((const kx_fent*)a)->id;
  long long y = ((const kx_fent*)b)->id;
  return x < y ? -1 : (x > y ? 1 : 0);
}

static void mergeFrozen(void) {
  long long total = 0;
  for (int i = 0; i < g_boxCount; i++) total += g_boxes[i].fSize;
  if (total > 0) {
    int cap = g_boxCount * KX_INIT_ENTITIES;
    while (cap < total) cap *= 2;
    g_frozenIds = (long long*)realloc(g_frozenIds, sizeof(long long) * cap);
    g_frozenTagMasks = (long long*)realloc(g_frozenTagMasks, sizeof(long long) * cap);
    g_frozenCompMasks = (long long*)realloc(g_frozenCompMasks, sizeof(long long) * cap);
  }
  if (total > g_sortCap) {
    g_sortCap = total > 0 ? total : 1;
    g_sortBuf = (kx_fent*)realloc(g_sortBuf, sizeof(kx_fent) * g_sortCap);
  }
  long long n = 0;
  for (int i = 0; i < g_boxCount; i++) {
    kx_box* b = &g_boxes[i];
    for (long long j = 0; j < b->fSize; j++) {
      g_sortBuf[n].id = b->fIds[j];
      g_sortBuf[n].box = i;
      g_sortBuf[n].idx = j;
      n++;
    }
  }
  qsort(g_sortBuf, n, sizeof(kx_fent), cmpFent);
  long long fs = 0;
  for (long long k = 0; k < n; k++) {
    kx_box* b = &g_boxes[g_sortBuf[k].box];
    long long j = g_sortBuf[k].idx;
    g_frozenIds[fs] = b->fIds[j];
    g_frozenTagMasks[fs] = b->fTags[j];
    long long cm = b->fComps[j];
    g_frozenCompMasks[fs] = cm;
    for (int c = 0; c < g_compCount; c++) {
      if (!(cm & (1LL << c))) continue;
      for (int f = 0; f < g_fieldCounts[c]; f++) {
        memcpy((char*)g_frozenFields[c * KX_MAX_FIELDS + f] + fs * 8,
               (char*)b->fFields[c * KX_MAX_FIELDS + f] + j * 8, 8);
      }
    }
    fs++;
  }
  g_frozenSize = fs;
}

static void growGlobalFrozen(void) {
  if (!g_frozenFields) {
    g_frozenFields = (void**)calloc(g_compCount * KX_MAX_FIELDS, sizeof(void*));
  }
  int cap = g_boxCount * KX_INIT_ENTITIES;
  for (int c = 0; c < g_compCount; c++) {
    for (int f = 0; f < g_fieldCounts[c]; f++) {
      g_frozenFields[c * KX_MAX_FIELDS + f] =
          realloc(g_frozenFields[c * KX_MAX_FIELDS + f], 8 * cap);
    }
  }
}

/* ---- frozen view (global, read-only during simulate) ---- */

static int frozenMatch(long long fs, long long subtreeMask, int exact) {
  if (subtreeMask == 0) return 0;
  if (exact) {
    long long m = g_frozenTagMasks[fs] & subtreeMask;
    long long bit = subtreeMask & -subtreeMask;
    return m == bit;
  }
  return (g_frozenTagMasks[fs] & subtreeMask) != 0;
}

long long kx_others_begin(long long subtreeMask, int exact) {
  for (long long i = 0; i < g_frozenSize; i++) {
    if (frozenMatch(i, subtreeMask, exact)) return i;
  }
  return -1;
}

long long kx_others_next(long long h, long long subtreeMask, int exact) {
  if (h < 0) return -1;
  for (long long i = h + 1; i < g_frozenSize; i++) {
    if (frozenMatch(i, subtreeMask, exact)) return i;
  }
  return -1;
}

long long kx_snap_id(long long h) {
  if (h < 0 || h >= g_frozenSize) return 0;
  return g_frozenIds[h];
}

long long kx_snap_read_i64(long long h, int comp, int field) {
  if (h < 0 || h >= g_frozenSize || comp < 0 || comp >= g_compCount ||
      field >= g_fieldCounts[comp])
    return 0;
  return ((long long*)g_frozenFields[comp * KX_MAX_FIELDS + field])[h];
}

double kx_snap_read_f64(long long h, int comp, int field) {
  if (h < 0 || h >= g_frozenSize || comp < 0 || comp >= g_compCount ||
      field >= g_fieldCounts[comp])
    return 0.0;
  return ((double*)g_frozenFields[comp * KX_MAX_FIELDS + field])[h];
}

char* kx_snap_read_str(long long h, int comp, int field) {
  if (h < 0 || h >= g_frozenSize || comp < 0 || comp >= g_compCount ||
      field >= g_fieldCounts[comp])
    return NULL;
  return ((char**)g_frozenFields[comp * KX_MAX_FIELDS + field])[h];
}

/* ---- migration + load rebalancing (coordinator phase, deterministic) ---- */

static void migrateEntity(kx_box* from, long long slot, kx_box* to) {
  long long nslot = -1;
  for (int i = 0; i < to->size; i++) {
    if (!slotAlive(to, i)) { nslot = i; break; }
  }
  if (nslot < 0) {
    nslot = to->size++;
    if (to->size > to->cap) growBox(to);
  }
  to->gens[nslot] = (to->gens[nslot] + 1) & 0xFFFF;
  if (to->gens[nslot] == 0) to->gens[nslot] = 1;
  to->tagMasks[nslot] = from->tagMasks[slot];
  long long cm = from->compMasks[slot];
  to->compMasks[nslot] = cm;
  for (int c = 0; c < g_compCount; c++) {
    if (!(cm & (1LL << c))) continue;
    for (int f = 0; f < g_fieldCounts[c]; f++) {
      memcpy((char*)to->fFields[c * KX_MAX_FIELDS + f] + nslot * 8,
             (char*)from->fFields[c * KX_MAX_FIELDS + f] + slot * 8, 8);
    }
  }
  kx_entity id = ((kx_entity)(from - g_boxes) << 48) | (slot << 16) | from->gens[slot];
  locInsert(id, (int)(to - g_boxes), nslot);
  from->gens[slot] = (from->gens[slot] + 1) & 0xFFFF;
  if (from->gens[slot] == 0) from->gens[slot] = 1;
  from->tagMasks[slot] = 0;
  from->compMasks[slot] = 0;
}

static long long aliveCount(const kx_box* b) {
  long long n = 0;
  for (int i = 0; i < b->size; i++) {
    if (b->gens[i] != 0) n++;
  }
  return n;
}

static void rebalance(void) {
  if (g_boxCount < 2) return;
  if (getenv("KUBEXIC_MIGRATE_ALL")) {
    for (int i = 1; i < g_boxCount; i++) {
      kx_box* b = &g_boxes[i];
      for (long long slot = 0; slot < b->size; slot++) {
        if (slotAlive(b, slot)) migrateEntity(b, slot, &g_boxes[0]);
      }
    }
    return;
  }
  if (g_tick == 0 || g_tick % 30 != 0) return;
  int heavy = 0;
  int light = 0;
  for (int i = 1; i < g_boxCount; i++) {
    if (aliveCount(&g_boxes[i]) > aliveCount(&g_boxes[heavy])) heavy = i;
    if (aliveCount(&g_boxes[i]) < aliveCount(&g_boxes[light])) light = i;
  }
  long long diff = aliveCount(&g_boxes[heavy]) - aliveCount(&g_boxes[light]);
  if (diff <= 32) return;
  long long n = diff / 2;
  kx_box* h = &g_boxes[heavy];
  kx_box* l = &g_boxes[light];
  for (long long slot = 0; slot < h->size && n > 0; slot++) {
    if (slotAlive(h, slot)) {
      migrateEntity(h, slot, l);
      n--;
    }
  }
}

void kx_stop(void) { g_stop = 1; }

double kx_get_dt(void) { return g_dt; }

long long kx_get_tick(void) { return g_tick; }

/* ---- parallel tick loop ---- */

typedef struct {
  int boxIndex;
  pthread_barrier_t* startBarrier;
  pthread_barrier_t* simBarrier;
  pthread_barrier_t* commitBarrier;
  pthread_barrier_t* freezeBarrier;
} kx_worker_arg;

static void* kx_worker(void* argp) {
  kx_worker_arg* a = (kx_worker_arg*)argp;
  int bi = a->boxIndex;
  g_currentBuffer = bi;
  kx_box* b = &g_boxes[bi];
  for (;;) {
    pthread_barrier_wait(a->startBarrier);
    if (g_stop) break;

    if (bi == 0) {
      for (int s = 0; s < g_sysCount; s++) {
        if (g_sysMatch[s] == 0 && g_sysWithout[s] == 0) g_sysBodies[s](0);
      }
    }

    for (long long fs = 0; fs < b->fSize; fs++) {
      long long cm = b->fComps[fs];
      kx_entity e = b->fIds[fs];
      for (int s = 0; s < g_sysCount; s++) {
        if (g_sysMatch[s] == 0 && g_sysWithout[s] == 0) continue;
        if ((cm & g_sysMatch[s]) == g_sysMatch[s] && (cm & g_sysWithout[s]) == 0) {
          g_sysBodies[s](e);
        }
      }
    }

    pthread_barrier_wait(a->simBarrier);
    commitBox(b);
    pthread_barrier_wait(a->commitBarrier);
    freezeBox(b);
    pthread_barrier_wait(a->freezeBarrier);
  }
  return NULL;
}

void kx_run(int tps, long long maxTicks, double cores) {
  g_tps = tps > 0 ? tps : 0;
  g_maxTicks = maxTicks;
  g_stop = 0;
  g_tick = 0;
  g_dt = g_tps > 0 ? 1.0 / (double)g_tps : 1.0 / 60.0;

  int boxCount;
  if (g_boxes) {
    boxCount = g_boxCount;
  } else if (cores < 0) {
    boxCount = defaultBoxCount();
  } else if (cores == 0) {
    boxCount = 1;
  } else if (cores < 1) {
    int n = (int)(cores * sysconf(_SC_NPROCESSORS_ONLN));
    boxCount = n < 1 ? 1 : n;
  } else {
    boxCount = (int)cores;
  }
  if (boxCount < 1) boxCount = 1;
  if (boxCount > KX_MAX_BOXES) boxCount = KX_MAX_BOXES;

  createBoxes(boxCount);
  growGlobalFrozen();

  bufFlush(g_boxCount);
  for (int i = 0; i < g_boxCount; i++) commitBox(&g_boxes[i]);
  for (int i = 0; i < g_boxCount; i++) freezeBox(&g_boxes[i]);
  mergeFrozen();

  if (g_boxCount > 1) {
    pthread_barrier_t startBarrier, simBarrier, commitBarrier, freezeBarrier;
    int participants = g_boxCount + 1;
    pthread_barrier_init(&startBarrier, NULL, participants);
    pthread_barrier_init(&simBarrier, NULL, participants);
    pthread_barrier_init(&commitBarrier, NULL, participants);
    pthread_barrier_init(&freezeBarrier, NULL, participants);
    pthread_t threads[KX_MAX_BOXES];
    kx_worker_arg args[KX_MAX_BOXES];
    for (int i = 0; i < g_boxCount; i++) {
      args[i] = (kx_worker_arg){i, &startBarrier, &simBarrier, &commitBarrier, &freezeBarrier};
      pthread_create(&threads[i], NULL, kx_worker, &args[i]);
    }

    struct timespec next;
    clock_gettime(CLOCK_MONOTONIC, &next);

    for (;;) {
      if (g_stop) break;
      if (g_maxTicks >= 0 && g_tick >= g_maxTicks) break;
      pthread_barrier_wait(&startBarrier);
      pthread_barrier_wait(&simBarrier);
      pthread_barrier_wait(&commitBarrier);
      pthread_barrier_wait(&freezeBarrier);
      mergeFrozen();
      rebalance();
      for (int i = 0; i < g_boxCount; i++) bufFlush(i);
      g_tick++;
      if (g_tps > 0) {
        next.tv_nsec += 1000000000L / g_tps;
        if (next.tv_nsec >= 1000000000L) {
          next.tv_sec += next.tv_nsec / 1000000000L;
          next.tv_nsec %= 1000000000L;
        }
        struct timespec now;
        clock_gettime(CLOCK_MONOTONIC, &now);
        if (now.tv_sec < next.tv_sec ||
            (now.tv_sec == next.tv_sec && now.tv_nsec < next.tv_nsec)) {
          struct timespec sleep = {next.tv_sec - now.tv_sec, next.tv_nsec - now.tv_nsec};
          if (sleep.tv_nsec < 0) {
            sleep.tv_sec -= 1;
            sleep.tv_nsec += 1000000000L;
          }
          nanosleep(&sleep, NULL);
        }
      }
    }

    g_stop = 1;
    pthread_barrier_wait(&startBarrier);
    for (int i = 0; i < g_boxCount; i++) pthread_join(threads[i], NULL);
    pthread_barrier_destroy(&startBarrier);
    pthread_barrier_destroy(&simBarrier);
    pthread_barrier_destroy(&commitBarrier);
    pthread_barrier_destroy(&freezeBarrier);
  } else {
    g_currentBuffer = 0;
    kx_box* b = &g_boxes[0];
    struct timespec next;
    clock_gettime(CLOCK_MONOTONIC, &next);
    for (;;) {
      if (g_stop) break;
      if (g_maxTicks >= 0 && g_tick >= g_maxTicks) break;
      for (int s = 0; s < g_sysCount; s++) {
        if (g_sysMatch[s] == 0 && g_sysWithout[s] == 0) g_sysBodies[s](0);
      }
      for (long long fs = 0; fs < b->fSize; fs++) {
        long long cm = b->fComps[fs];
        kx_entity e = b->fIds[fs];
        for (int s = 0; s < g_sysCount; s++) {
          if (g_sysMatch[s] == 0 && g_sysWithout[s] == 0) continue;
          if ((cm & g_sysMatch[s]) == g_sysMatch[s] && (cm & g_sysWithout[s]) == 0) {
            g_sysBodies[s](e);
          }
        }
      }
      commitBox(b);
      freezeBox(b);
      mergeFrozen();
      rebalance();
      bufFlush(0);
      g_tick++;
      if (g_tps > 0) {
        next.tv_nsec += 1000000000L / g_tps;
        if (next.tv_nsec >= 1000000000L) {
          next.tv_sec += next.tv_nsec / 1000000000L;
          next.tv_nsec %= 1000000000L;
        }
        struct timespec now;
        clock_gettime(CLOCK_MONOTONIC, &now);
        if (now.tv_sec < next.tv_sec ||
            (now.tv_sec == next.tv_sec && now.tv_nsec < next.tv_nsec)) {
          struct timespec sleep = {next.tv_sec - now.tv_sec, next.tv_nsec - now.tv_nsec};
          if (sleep.tv_nsec < 0) {
            sleep.tv_sec -= 1;
            sleep.tv_nsec += 1000000000L;
          }
          nanosleep(&sleep, NULL);
        }
      }
    }
  }
  g_currentBuffer = g_boxCount;
  for (int i = 0; i < g_boxCount; i++) commitBox(&g_boxes[i]);
  bufFlush(g_boxCount);
}

/* ---- console, string helpers, process control ---- */

static char* kx_dup(const char* s) {
  size_t n = strlen(s);
  char* p = (char*)malloc(n + 1);
  if (p) memcpy(p, s, n + 1);
  return p;
}

void kx_print(const char* s) {
  if (!s) return;
  int idx = g_currentBuffer >= 0 ? g_currentBuffer : g_boxCount;
  bufAppend(idx, s);
  if (idx == g_boxCount) bufFlush(idx);
}

void kx_println(const char* s) {
  if (!s) return;
  int idx = g_currentBuffer >= 0 ? g_currentBuffer : g_boxCount;
  bufAppend(idx, s);
  bufAppend(idx, "\n");
  if (idx == g_boxCount) bufFlush(idx);
}

char* kx_str_cat(const char* a, const char* b) {
  if (!a) a = "";
  if (!b) b = "";
  size_t na = strlen(a), nb = strlen(b);
  char* p = (char*)malloc(na + nb + 1);
  if (p) {
    memcpy(p, a, na);
    memcpy(p + na, b, nb + 1);
  }
  return p;
}

char* kx_str_from_i64(long long v) {
  char buf[32];
  snprintf(buf, sizeof(buf), "%lld", v);
  return kx_dup(buf);
}

char* kx_str_from_double(double v) {
  char buf[64];
  snprintf(buf, sizeof(buf), "%g", v);
  return kx_dup(buf);
}

char* kx_str_from_entity(long long id) {
  char buf[32];
  snprintf(buf, sizeof(buf), "%lld", id);
  return kx_dup(buf);
}

char* kx_readln(void) {
  char* line = NULL;
  size_t cap = 0;
  ssize_t n = getline(&line, &cap, stdin);
  if (n < 0) {
    free(line);
    return NULL;
  }
  while (n > 0 && (line[n - 1] == '\n' || line[n - 1] == '\r')) {
    line[n - 1] = '\0';
    n--;
  }
  return line;
}

void kx_exit(int code) {
  bufFlush(g_currentBuffer >= 0 ? g_currentBuffer : g_boxCount);
  fflush(stdout);
  exit(code);
}

void kx_panic(const char* msg) {
  fflush(stdout);
  fprintf(stderr, "panic: %s\n", msg ? msg : "");
  exit(1);
}

long long kx_rng_seed(long long seed) { return seed; }

long long kx_rng_next(long long state) {
  state = state * 6364136223846793005LL + 1442695040888963407LL;
  return state;
}