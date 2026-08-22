#define _GNU_SOURCE
#include <ctype.h>
#include <dirent.h>
#include <math.h>
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <execinfo.h>
#include <signal.h>
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

void kx_panic(const char* msg);
void kx_poll_stdin(void);
char* kx_dup(const char* s);

/* ---- collections (ownership trees: never shared, deep-copied) ---- */

#define KX_COLLECTION_LIST 1
#define KX_COLLECTION_MAP 2
#define KX_MAP_EMPTY ((long long)0xFFFFFFFFFFFFFFFF)
#define KX_KIND_I64 0
#define KX_KIND_F64 1
#define KX_KIND_STR 2
#define KX_KIND_COLL 3

typedef struct {
  int kind;
} kx_collection;

typedef struct {
  int kind;
  long long* data;
  long long size;
  long long cap;
  int elemKind;
} kx_vec;

typedef struct {
  int kind;
  long long* keys;
  long long* vals;
  long long size;
  long long cap;
  int keyKind;
  int valKind;
} kx_map;

static kx_vec* vecOf(long long h) { return h ? (kx_vec*)(uintptr_t)h : NULL; }

static kx_map* mapOf(long long h) { return h ? (kx_map*)(uintptr_t)h : NULL; }

long long kx_list_new(int elemKind) {
  kx_vec* v = (kx_vec*)calloc(1, sizeof(kx_vec));
  v->kind = KX_COLLECTION_LIST;
  v->cap = 8;
  v->data = (long long*)calloc(v->cap, 8);
  v->elemKind = elemKind;
  return (long long)(uintptr_t)v;
}

void kx_list_add(long long h, long long val) {
  kx_vec* v = vecOf(h);
  if (!v) return;
  if (v->size >= v->cap) {
    v->cap *= 2;
    v->data = (long long*)realloc(v->data, v->cap * 8);
  }
  if (v->elemKind == KX_KIND_STR) val = (long long)(uintptr_t)kx_dup((char*)(uintptr_t)val);
  v->data[v->size++] = val;
}

long long kx_list_get(long long h, long long i) {
  kx_vec* v = vecOf(h);
  if (!v || i < 0 || i >= v->size) {
    fprintf(stderr, "FATAL: List.Get index=%lld size=%d vec=%p elemKind=%d\n", i, v ? v->size : -1, (void*)v, v ? v->elemKind : -1);
    void* bt[20];
    int nframes = backtrace(bt, 20);
    char** symbols = backtrace_symbols(bt, nframes);
    for (int fi = 0; fi < nframes && fi < 15; fi++) fprintf(stderr, "  #%d %s\n", fi, symbols[fi]);
    free(symbols);
    kx_panic("List.Get: index out of range");
  }
  return v->data[i];
}

void kx_list_set(long long h, long long i, long long val) {
  kx_vec* v = vecOf(h);
  if (!v || i < 0 || i >= v->size) kx_panic("List.Set: index out of range");
  if (v->elemKind == KX_KIND_STR) {
    free((void*)(uintptr_t)v->data[i]);
    val = (long long)(uintptr_t)kx_dup((char*)(uintptr_t)val);
  }
  v->data[i] = val;
}

void kx_list_remove_at(long long h, long long i) {
  kx_vec* v = vecOf(h);
  if (!v) return;
  if (i < 0 || i >= v->size) kx_panic("List.RemoveAt: index out of range");
  for (long long j = i; j + 1 < v->size; j++) v->data[j] = v->data[j + 1];
  v->size--;
}

void kx_list_clear(long long h) {
  kx_vec* v = vecOf(h);
  if (!v) return;
  v->size = 0;
}

long long kx_list_size(long long h) {
  kx_vec* v = vecOf(h);
  return v ? v->size : 0;
}

int kx_list_contains(long long h, long long val) {
  kx_vec* v = vecOf(h);
  if (!v) return 0;
  for (long long i = 0; i < v->size; i++) {
    if (v->data[i] == val) return 1;
    /* Also check strings by content */
    if (v->elemKind == KX_KIND_STR) {
      const char* a = (const char*)(uintptr_t)v->data[i];
      const char* b = (const char*)(uintptr_t)val;
      if (a && b && strcmp(a, b) == 0) return 1;
    }
  }
  return 0;
}

long long kx_list_begin(long long h) {
  kx_vec* v = vecOf(h);
  return (v && v->size > 0) ? 0 : -1;
}

long long kx_list_next(long long h, long long i) {
  kx_vec* v = vecOf(h);
  if (!v || i < 0) return -1;
  return (i + 1 < v->size) ? i + 1 : -1;
}

static unsigned long long mix64(unsigned long long x) {
  x = (x ^ (x >> 30)) * 0xbf58476d1ce4e5b9ull;
  x = (x ^ (x >> 27)) * 0x94d049bb133111ebull;
  return x ^ (x >> 31);
}

static unsigned long long hashKey(const kx_map* m, long long k) {
  if (m->keyKind == KX_KIND_STR) {
    const unsigned char* s = (const unsigned char*)(uintptr_t)k;
    unsigned long long h = 1469598103934665603ull;
    if (s) {
      for (; *s; s++) {
        h ^= *s;
        h *= 1099511628211ull;
      }
    }
    return h;
  }
  return mix64((unsigned long long)k);
}

static int keyEq(const kx_map* m, long long a, long long b) {
  if (m->keyKind == KX_KIND_STR) {
    if (a == b) return 1;
    const char* x = (const char*)(uintptr_t)a;
    const char* y = (const char*)(uintptr_t)b;
    return x && y && strcmp(x, y) == 0;
  }
  return a == b;
}

static void mapGrow(kx_map* m) {
  long long newCap = m->cap ? m->cap * 2 : 8;
  long long* newKeys = (long long*)malloc(newCap * 8);
  long long* newVals = (long long*)calloc(newCap, 8);
  for (long long i = 0; i < newCap; i++) newKeys[i] = KX_MAP_EMPTY;
  for (long long i = 0; i < m->cap; i++) {
    if (m->keys[i] == KX_MAP_EMPTY) continue;
    long long j = hashKey(m, m->keys[i]) & (newCap - 1);
    while (newKeys[j] != KX_MAP_EMPTY) j = (j + 1) & (newCap - 1);
    newKeys[j] = m->keys[i];
    newVals[j] = m->vals[i];
  }
  free(m->keys);
  free(m->vals);
  m->keys = newKeys;
  m->vals = newVals;
  m->cap = newCap;
}

long long kx_map_new(int keyKind, int valKind) {
  kx_map* m = (kx_map*)calloc(1, sizeof(kx_map));
  m->kind = KX_COLLECTION_MAP;
  m->cap = 8;
  m->keys = (long long*)malloc(m->cap * 8);
  m->vals = (long long*)calloc(m->cap, 8);
  for (long long i = 0; i < m->cap; i++) m->keys[i] = KX_MAP_EMPTY;
  m->keyKind = keyKind;
  m->valKind = valKind;
  return (long long)(uintptr_t)m;
}

void kx_map_set(long long h, long long key, long long val) {
  kx_map* m = mapOf(h);
  if (!m) return;
  if (m->keyKind == KX_KIND_STR) key = (long long)(uintptr_t)kx_dup((char*)(uintptr_t)key);
  if (m->valKind == KX_KIND_STR) val = (long long)(uintptr_t)kx_dup((char*)(uintptr_t)val);
  if ((m->size + 1) * 10 >= m->cap * 7) mapGrow(m);
  long long i = hashKey(m, key) & (m->cap - 1);
  while (m->keys[i] != KX_MAP_EMPTY && !keyEq(m, m->keys[i], key)) i = (i + 1) & (m->cap - 1);
  if (m->keys[i] == KX_MAP_EMPTY) {
    m->keys[i] = key;
    m->size++;
  } else {
    if (m->keyKind == KX_KIND_STR) free((void*)(uintptr_t)key);
    if (m->valKind == KX_KIND_STR) free((void*)(uintptr_t)m->vals[i]);
  }
  m->vals[i] = val;
}

long long kx_map_get(long long h, long long key) {
  kx_map* m = mapOf(h);
  if (!m) kx_panic("Map.Get: null map");
  long long i = hashKey(m, key) & (m->cap - 1);
  while (m->keys[i] != KX_MAP_EMPTY) {
    if (keyEq(m, m->keys[i], key)) return m->vals[i];
    i = (i + 1) & (m->cap - 1);
  }
  kx_panic("Map.Get: key not found");
  return 0;
}

int kx_map_has(long long h, long long key) {
  kx_map* m = mapOf(h);
  if (!m) return 0;
  long long i = hashKey(m, key) & (m->cap - 1);
  while (m->keys[i] != KX_MAP_EMPTY) {
    if (keyEq(m, m->keys[i], key)) return 1;
    i = (i + 1) & (m->cap - 1);
  }
  return 0;
}

void kx_map_remove(long long h, long long key) {
  kx_map* m = mapOf(h);
  if (!m) return;
  long long i = hashKey(m, key) & (m->cap - 1);
  while (m->keys[i] != KX_MAP_EMPTY) {
    if (keyEq(m, m->keys[i], key)) {
      m->keys[i] = KX_MAP_EMPTY;
      m->vals[i] = 0;
      m->size--;
      return;
    }
    i = (i + 1) & (m->cap - 1);
  }
}

void kx_map_clear(long long h) {
  kx_map* m = mapOf(h);
  if (!m) return;
  for (long long i = 0; i < m->cap; i++) m->keys[i] = KX_MAP_EMPTY;
  memset(m->vals, 0, m->cap * 8);
  m->size = 0;
}

long long kx_map_size(long long h) {
  kx_map* m = mapOf(h);
  return m ? m->size : 0;
}

static long long copyHandle(long long h, int kind);
static void freeHandle(long long h);

static long long copyHandle(long long h, int kind) {
  if (!h) return 0;
  (void)kind;
  kx_collection* c = (kx_collection*)(uintptr_t)h;
  if (c->kind == KX_COLLECTION_LIST) {
    kx_vec* v = (kx_vec*)h;
    long long nh = kx_list_new(v->elemKind);
    kx_vec* nv = vecOf(nh);
    while (nv->cap < v->size) {
      nv->cap *= 2;
      nv->data = (long long*)realloc(nv->data, nv->cap * 8);
    }
    for (long long i = 0; i < v->size; i++) {
      long long el = v->data[i];
      if (v->elemKind == KX_KIND_COLL) el = copyHandle(el, 3);
      else if (v->elemKind == KX_KIND_STR) el = (long long)(uintptr_t)kx_dup((char*)(uintptr_t)el);
      nv->data[i] = el;
    }
    nv->size = v->size;
    return nh;
  }
  if (c->kind == KX_COLLECTION_MAP) {
    kx_map* m = (kx_map*)h;
    long long nh = kx_map_new(m->keyKind, m->valKind);
    for (long long i = 0; i < m->cap; i++) {
      if (m->keys[i] == KX_MAP_EMPTY) continue;
      long long k = m->keyKind == KX_KIND_COLL ? copyHandle(m->keys[i], 3) : m->keys[i];
      long long vv = m->valKind == KX_KIND_COLL ? copyHandle(m->vals[i], 3) : m->vals[i];
      kx_map_set(nh, k, vv);
    }
    return nh;
  }
  return h;
}

static void freeHandle(long long h) {
  if (!h) return;
  kx_collection* c = (kx_collection*)(uintptr_t)h;
  if (c->kind == KX_COLLECTION_LIST) {
    kx_vec* v = (kx_vec*)h;
    for (long long i = 0; i < v->size; i++) {
      if (v->elemKind == KX_KIND_COLL) freeHandle(v->data[i]);
      else if (v->elemKind == KX_KIND_STR) free((void*)(uintptr_t)v->data[i]);
    }
    free(v->data);
    free(v);
  } else if (c->kind == KX_COLLECTION_MAP) {
    kx_map* m = (kx_map*)h;
    for (long long i = 0; i < m->cap; i++) {
      if (m->keys[i] == KX_MAP_EMPTY) continue;
      if (m->keyKind == KX_KIND_COLL) freeHandle(m->keys[i]);
      else if (m->keyKind == KX_KIND_STR) free((void*)(uintptr_t)m->keys[i]);
      if (m->valKind == KX_KIND_COLL) freeHandle(m->vals[i]);
      else if (m->valKind == KX_KIND_STR) free((void*)(uintptr_t)m->vals[i]);
    }
    free(m->keys);
    free(m->vals);
    free(m);
  }
}

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
  void** fzFields;

  int* freeSlots;
  int freeTop;
  int freeCap;
} kx_box;

static int g_compCount;
static int g_fieldCounts[KX_MAX_COMPONENTS];
static int g_fieldTypes[KX_MAX_COMPONENTS * KX_MAX_FIELDS];
static char** g_compNames;

void kx_set_comp_names(int count, char** names) {
  g_compNames = (char**)malloc(sizeof(char*) * count);
  for (int i = 0; i < count; i++) g_compNames[i] = names[i];
}
static int g_boxCount = 1;
static kx_box* g_boxes;

static long long* g_frozenIds;
static long long* g_frozenTagMasks;
static long long* g_frozenCompMasks;
static void** g_frozenFields;
static long long g_frozenSize;
static long long g_frozenCap = 0;

/* ---- tag index (per-bit inverted index over frozen view) ---- */

static long long** g_tagIdx;
static long long*  g_tagIdxSize;
static long long*  g_tagIdxCap;
static int g_tagIdxBuilt = 0;

/* ---- spatial hash grid ---- */

typedef struct {
  long long* entries;
  long long size;
  long long cap;
} kx_cell;

static kx_cell* g_spatialGrid = NULL;
static long long g_gridCells = 0;
static int g_gridMask = 0;
static double g_spatialCellSize = 1.0;
static int g_spatialComp = -1;
static int g_spatialFieldX = 0;
static int g_spatialFieldY = 1;
static int g_spatialFieldZ = 2;
static int g_spatialDims = 3;
static int g_spatialBuilt = 0;
static long long g_spatialSubtreeMask = 0;

static int g_sysCount;
static long long* g_sysMatch;
static long long* g_sysWithout;
static void (**g_sysBodies)(long long);

static int g_tps;
static long long g_maxTicks;
static long long g_tick;
static double g_dt;
static volatile int g_stop;
static volatile int g_inRun;
static int g_traceEnabled = 0;

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
  if (n >= KX_BUF_CAP) {
    if (b->len > 0) {
      fwrite(b->data, 1, b->len, stdout);
      b->len = 0;
    }
    fwrite(s, 1, n, stdout);
    return;
  }
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

static void growArr(void** arr, size_t elemSize, int oldCap, int newCap) {
  void* fresh = realloc(*arr, elemSize * newCap);
  if (!fresh) kx_panic("out of memory");
  memset((char*)fresh + elemSize * oldCap, 0, elemSize * (newCap - oldCap));
  *arr = fresh;
}

static void growBox(kx_box* b) {
  int oldCap = b->cap;
  int newCap = b->cap * 2;
  growArr((void**)&b->tagMasks, sizeof(long long), oldCap, newCap);
  growArr((void**)&b->compMasks, sizeof(long long), oldCap, newCap);
  growArr((void**)&b->gens, sizeof(int), oldCap, newCap);
  for (int c = 0; c < g_compCount; c++) {
    for (int f = 0; f < g_fieldCounts[c]; f++) {
      growArr(&b->fFields[c * KX_MAX_FIELDS + f], 8, oldCap, newCap);
      growArr(&b->fzFields[c * KX_MAX_FIELDS + f], 8, oldCap, newCap);
    }
  }
  growArr((void**)&b->fIds, sizeof(long long), oldCap, newCap);
  growArr((void**)&b->fTags, sizeof(long long), oldCap, newCap);
  growArr((void**)&b->fComps, sizeof(long long), oldCap, newCap);
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
        for (int f = 0; f < g_fieldCounts[c]; f++) {
          free(g_boxes[i].fFields[c * KX_MAX_FIELDS + f]);
          free(g_boxes[i].fzFields[c * KX_MAX_FIELDS + f]);
        }
      }
      for (int s = 0; s < g_boxCount; s++) {
        free(g_boxes[i].queues[s]);
      }
      free(g_boxes[i].queues);
      free(g_boxes[i].qSize);
      free(g_boxes[i].qCap);
      free(g_boxes[i].fIds);
      free(g_boxes[i].fTags);
      free(g_boxes[i].fComps);
      free(g_boxes[i].fFields);
      free(g_boxes[i].fzFields);
      free(g_boxes[i].freeSlots);
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
    b->fzFields = (void**)calloc(g_compCount * KX_MAX_FIELDS, sizeof(void*));
    for (int c = 0; c < g_compCount; c++) {
      for (int f = 0; f < g_fieldCounts[c]; f++) {
        b->fFields[c * KX_MAX_FIELDS + f] = calloc(8, b->cap);
        b->fzFields[c * KX_MAX_FIELDS + f] = calloc(8, b->cap);
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
    b->freeSlots = NULL;
    b->freeTop = -1;
    b->freeCap = 0;
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
  if (g_traceEnabled && (r->kind == REQ_ENSURE || r->kind == REQ_DETACH ||
                             r->kind == REQ_DESPAWN)) {
    char line[256];
    const char* kind = r->kind == REQ_ENSURE ? "attach" :
                       r->kind == REQ_DETACH ? "detach" : "despawn";
    if (r->kind == REQ_DESPAWN) {
      snprintf(line, sizeof(line), "[trace tick %lld] %s entity=%lld\n",
               (long long)g_tick, kind, (long long)e);
    } else {
      const char* cn = g_compNames && r->comp < g_compCount ? g_compNames[r->comp] : "?";
      snprintf(line, sizeof(line), "[trace tick %lld] %s entity=%lld comp=%s\n",
               (long long)g_tick, kind, (long long)e, cn ? cn : "?");
    }
    ssize_t wr = write(2, line, strlen(line));
    (void)wr;
  }
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
      for (int f = 0; f < g_fieldCounts[r->comp]; f++) {
        int kind = g_fieldTypes[r->comp * KX_MAX_FIELDS + f];
        if (kind == KX_KIND_COLL) {
          long long h = ((long long*)b->fFields[r->comp * KX_MAX_FIELDS + f])[slot];
          freeHandle(h);
          ((long long*)b->fFields[r->comp * KX_MAX_FIELDS + f])[slot] = 0;
        } else if (kind == KX_KIND_STR) {
          free((void*)(uintptr_t)((long long*)b->fFields[r->comp * KX_MAX_FIELDS + f])[slot]);
          ((long long*)b->fFields[r->comp * KX_MAX_FIELDS + f])[slot] = 0;
        }
      }
      b->compMasks[slot] &= ~(1LL << r->comp);
      break;
    case REQ_DESPAWN: {
      for (int c = 0; c < g_compCount; c++) {
        if (!(b->compMasks[slot] & (1LL << c))) continue;
        for (int f = 0; f < g_fieldCounts[c]; f++) {
          int kind = g_fieldTypes[c * KX_MAX_FIELDS + f];
          long long* arr = (long long*)b->fFields[c * KX_MAX_FIELDS + f];
          if (kind == KX_KIND_COLL) {
            freeHandle(arr[slot]);
            arr[slot] = 0;
          } else if (kind == KX_KIND_STR) {
            free((void*)(uintptr_t)arr[slot]);
            arr[slot] = 0;
          }
        }
      }
      b->gens[slot] = (b->gens[slot] + 1) & 0xFFFF;
      if (b->gens[slot] == 0) b->gens[slot] = 1;
      b->tagMasks[slot] = 0;
      b->compMasks[slot] = 0;
      if (b->freeTop + 1 >= b->freeCap) {
        b->freeCap = b->freeCap ? b->freeCap * 2 : 64;
        b->freeSlots = (int*)realloc(b->freeSlots, sizeof(int) * b->freeCap);
      }
      b->freeSlots[++b->freeTop] = (int)slot;
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

void kx_init(int compCount, const int* fieldCounts, const int* fieldTypes) {
  g_compCount = compCount < KX_MAX_COMPONENTS ? compCount : KX_MAX_COMPONENTS;
  for (int c = 0; c < g_compCount; c++) {
    g_fieldCounts[c] = fieldCounts[c];
    for (int f = 0; f < g_fieldCounts[c] && f < KX_MAX_FIELDS; f++) {
      g_fieldTypes[c * KX_MAX_FIELDS + f] = fieldTypes[c * KX_MAX_FIELDS + f];
    }
  }
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
  if (b->freeTop >= 0) {
    slot = b->freeSlots[b->freeTop--];
  } else {
    for (int i = 0; i < b->size; i++) {
      if (!slotAlive(b, i)) { slot = i; break; }
    }
    if (slot < 0) {
      slot = b->size++;
      if (b->size > b->cap) growBox(b);
    }
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
  long long* dst = (long long*)b->fFields[comp * KX_MAX_FIELDS + field];
  if (g_fieldTypes[comp * KX_MAX_FIELDS + field] == KX_KIND_COLL) {
    freeHandle(dst[slot]);
    dst[slot] = copyHandle(v, 3);
    return;
  }
  dst[slot] = v;
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

void kx_comp_take_i64(kx_entity e, int comp, int field, long long v) {
  kx_box* b;
  long long slot;
  if (!resolve(e, &b, &slot)) return;
  if (comp < 0 || comp >= g_compCount || field >= g_fieldCounts[comp]) return;
  long long* dst = (long long*)b->fFields[comp * KX_MAX_FIELDS + field];
  if (g_fieldTypes[comp * KX_MAX_FIELDS + field] == KX_KIND_COLL) {
    freeHandle(dst[slot]);
  }
  dst[slot] = v;
}

void kx_comp_write_str(kx_entity e, int comp, int field, char* v) {
  kx_box* b;
  long long slot;
  if (!resolve(e, &b, &slot)) return;
  if (comp < 0 || comp >= g_compCount || field >= g_fieldCounts[comp]) return;
  char** dst = (char**)b->fFields[comp * KX_MAX_FIELDS + field];
  free(dst[slot]);
  dst[slot] = kx_dup(v ? v : "");
}

/* ---- freeze (per-box) + merge (sorted by entity id: deterministic
 * regardless of box placement or migration) ---- */

static void freeFrozenSlot(kx_box* b, long long idx) {
  for (int c = 0; c < g_compCount; c++) {
    for (int f = 0; f < g_fieldCounts[c]; f++) {
      int kind = g_fieldTypes[c * KX_MAX_FIELDS + f];
      if (kind != KX_KIND_COLL && kind != KX_KIND_STR) continue;
      long long* dst = (long long*)b->fzFields[c * KX_MAX_FIELDS + f];
      if (kind == KX_KIND_COLL) {
        freeHandle(dst[idx]);
      } else {
        free((void*)(uintptr_t)dst[idx]);
      }
    }
  }
}

static void freezeBox(kx_box* b) {
  long long prev = b->fSize;
  long long fs = 0;
  for (int slot = 0; slot < b->size; slot++) {
    long long cm = slotAlive(b, slot) ? b->compMasks[slot] : 0;
    if (cm == 0) continue;
    if (fs < prev) freeFrozenSlot(b, fs);
    b->fIds[fs] = ((kx_entity)((b - g_boxes)) << 48) | (slot << 16) | b->gens[slot];
    b->fTags[fs] = b->tagMasks[slot];
    b->fComps[fs] = cm;
    for (int c = 0; c < g_compCount; c++) {
      if (!(cm & (1LL << c))) continue;
      for (int f = 0; f < g_fieldCounts[c]; f++) {
        long long* srcArr = (long long*)b->fFields[c * KX_MAX_FIELDS + f];
        long long* dstArr = (long long*)b->fzFields[c * KX_MAX_FIELDS + f];
        int kind = g_fieldTypes[c * KX_MAX_FIELDS + f];
        if (kind == KX_KIND_COLL) {
          dstArr[fs] = copyHandle(srcArr[slot], 3);
        } else if (kind == KX_KIND_STR) {
          dstArr[fs] = (long long)(uintptr_t)kx_dup((char*)(uintptr_t)srcArr[slot]);
        } else {
          dstArr[fs] = srcArr[slot];
        }
      }
    }
    fs++;
  }
  for (long long i = fs; i < prev; i++) freeFrozenSlot(b, i);
  b->fSize = fs;
}

typedef struct {
  long long id;
  int box;
  long long idx;
} kx_fent;

static kx_fent* g_sortBuf;
static int g_sortCap;

static void freeTagIdx(void);
static void buildTagIdx(void);

static void growGlobalFrozen(long long minSlots);

static void mergeFrozen(void) {
  long long total = 0;
  for (int i = 0; i < g_boxCount; i++) total += g_boxes[i].fSize;
  if (total > 0) {
    long long cap = g_boxCount * KX_INIT_ENTITIES;
    while (cap < total) cap *= 2;
    g_frozenIds = (long long*)realloc(g_frozenIds, sizeof(long long) * cap);
    g_frozenTagMasks = (long long*)realloc(g_frozenTagMasks, sizeof(long long) * cap);
    g_frozenCompMasks = (long long*)realloc(g_frozenCompMasks, sizeof(long long) * cap);
    growGlobalFrozen(total);
  }
  if (total == 0) {
    g_frozenSize = 0;
    buildTagIdx();
    return;
  }
  if (total > g_sortCap) {
    g_sortCap = total > 0 ? total : 1;
    g_sortBuf = (kx_fent*)realloc(g_sortBuf, sizeof(kx_fent) * g_sortCap);
  }
  int heapSize = 0;
  int heapBoxes[KX_MAX_BOXES];
  long long heapIdx[KX_MAX_BOXES];
  for (int i = 0; i < g_boxCount; i++) {
    kx_box* b = &g_boxes[i];
    if (b->fSize == 0) continue;
    int pos = heapSize++;
    heapBoxes[pos] = i;
    heapIdx[pos] = 0;
    while (pos > 0) {
      int parent = (pos - 1) / 2;
      long long pv = g_boxes[heapBoxes[parent]].fIds[heapIdx[parent]];
      long long cv = g_boxes[i].fIds[heapIdx[pos]];
      if (cv < pv) {
        int tb = heapBoxes[parent]; long long ti = heapIdx[parent];
        heapBoxes[parent] = heapBoxes[pos]; heapIdx[parent] = heapIdx[pos];
        heapBoxes[pos] = tb; heapIdx[pos] = ti;
        pos = parent;
      } else break;
    }
  }
  long long fs = 0;
  while (heapSize > 0) {
    int bi = heapBoxes[0];
    long long sj = heapIdx[0];
    kx_box* b = &g_boxes[bi];
    g_frozenIds[fs] = b->fIds[sj];
    g_frozenTagMasks[fs] = b->fTags[sj];
    long long cm = b->fComps[sj];
    g_frozenCompMasks[fs] = cm;
    for (int c = 0; c < g_compCount; c++) {
      if (!(cm & (1LL << c))) continue;
      for (int f = 0; f < g_fieldCounts[c]; f++) {
        memcpy((char*)g_frozenFields[c * KX_MAX_FIELDS + f] + fs * 8,
               (char*)b->fzFields[c * KX_MAX_FIELDS + f] + sj * 8, 8);
      }
    }
    fs++;
    long long nextIdx = sj + 1;
    if (nextIdx < b->fSize) {
      heapIdx[0] = nextIdx;
    } else {
      heapBoxes[0] = heapBoxes[--heapSize];
      heapIdx[0] = heapIdx[heapSize];
    }
    int pos = 0;
    for (;;) {
      int left = pos * 2 + 1;
      int right = left + 1;
      int smallest = pos;
      if (left < heapSize) {
        long long lv = g_boxes[heapBoxes[left]].fIds[heapIdx[left]];
        long long sv = g_boxes[heapBoxes[pos]].fIds[heapIdx[pos]];
        if (lv < sv) smallest = left;
      }
      if (right < heapSize) {
        long long rv = g_boxes[heapBoxes[right]].fIds[heapIdx[right]];
        long long sv = g_boxes[heapBoxes[smallest]].fIds[heapIdx[smallest]];
        if (rv < sv) smallest = right;
      }
      if (smallest == pos) break;
      int tb = heapBoxes[pos]; long long ti = heapIdx[pos];
      heapBoxes[pos] = heapBoxes[smallest]; heapIdx[pos] = heapIdx[smallest];
      heapBoxes[smallest] = tb; heapIdx[smallest] = ti;
      pos = smallest;
    }
  }
  g_frozenSize = fs;
  buildTagIdx();
}

static void buildTagIdx(void) {
  freeTagIdx();
  g_tagIdx = (long long**)calloc(KX_MAX_TAGS, sizeof(long long*));
  g_tagIdxSize = (long long*)calloc(KX_MAX_TAGS, sizeof(long long));
  g_tagIdxCap = (long long*)calloc(KX_MAX_TAGS, sizeof(long long));
  for (int bit = 0; bit < KX_MAX_TAGS; bit++) {
    g_tagIdxCap[bit] = 64;
    g_tagIdx[bit] = (long long*)malloc(sizeof(long long) * 64);
  }
  for (long long i = 0; i < g_frozenSize; i++) {
    long long tm = g_frozenTagMasks[i];
    while (tm) {
      int bit = __builtin_ctzll(tm);
      long long mask = tm & -tm;
      if (g_tagIdxSize[bit] >= g_tagIdxCap[bit]) {
        g_tagIdxCap[bit] *= 2;
        g_tagIdx[bit] = (long long*)realloc(g_tagIdx[bit], sizeof(long long) * g_tagIdxCap[bit]);
      }
      g_tagIdx[bit][g_tagIdxSize[bit]++] = i;
      tm &= ~mask;
    }
  }
  g_tagIdxBuilt = 1;
}

static void freeTagIdx(void) {
  if (g_tagIdx) {
    for (int bit = 0; bit < KX_MAX_TAGS; bit++) free(g_tagIdx[bit]);
    free(g_tagIdx);
  }
  free(g_tagIdxSize);
  free(g_tagIdxCap);
  g_tagIdx = NULL;
  g_tagIdxSize = NULL;
  g_tagIdxCap = NULL;
  g_tagIdxBuilt = 0;
}

/* ---- spatial hash grid ---- */

void kx_spatial_set_cell_size(double size) { g_spatialCellSize = size > 0.0 ? size : 1.0; }

void kx_spatial_set_comp(int comp, int fx, int fy, int fz, int dims) {
  g_spatialComp = comp;
  g_spatialFieldX = fx;
  g_spatialFieldY = fy;
  g_spatialFieldZ = fz;
  g_spatialDims = dims > 0 ? (dims < 3 ? dims : 3) : 3;
}

void kx_spatial_set_tag_mask(long long mask) { g_spatialSubtreeMask = mask; }

static long long spatialHash(int cx, int cy, int cz) {
  unsigned long long h = (unsigned long long)cx * 73856093u ^
                         (unsigned long long)cy * 19349663u ^
                         (unsigned long long)cz * 83492791u;
  return (long long)(h & (unsigned long long)g_gridMask);
}

static void spatialFreeGrid(void) {
  if (g_spatialGrid) {
    for (long long i = 0; i < g_gridCells; i++) free(g_spatialGrid[i].entries);
    free(g_spatialGrid);
  }
  g_spatialGrid = NULL;
  g_gridCells = 0;
  g_spatialBuilt = 0;
}

static void cellAdd(kx_cell* cell, long long idx) {
  if (cell->size >= cell->cap) {
    cell->cap = cell->cap ? cell->cap * 2 : 8;
    cell->entries = (long long*)realloc(cell->entries, sizeof(long long) * cell->cap);
  }
  cell->entries[cell->size++] = idx;
}

void kx_spatial_build(void) {
  spatialFreeGrid();
  g_gridCells = 1024;
  g_gridMask = g_gridCells - 1;
  g_spatialGrid = (kx_cell*)calloc(g_gridCells, sizeof(kx_cell));
  if (g_spatialComp < 0 || !g_tagIdxBuilt) return;
  for (long long i = 0; i < g_frozenSize; i++) {
    if (g_spatialSubtreeMask && !(g_frozenTagMasks[i] & g_spatialSubtreeMask)) continue;
    if (!(g_frozenCompMasks[i] & (1LL << g_spatialComp))) continue;
    double x = 0, y = 0, z = 0;
    double* px = (double*)g_frozenFields[g_spatialComp * KX_MAX_FIELDS + g_spatialFieldX];
    double* py = (double*)g_frozenFields[g_spatialComp * KX_MAX_FIELDS + g_spatialFieldY];
    double* pz = (double*)g_frozenFields[g_spatialComp * KX_MAX_FIELDS + g_spatialFieldZ];
    x = px[i]; y = py[i];
    if (g_spatialDims >= 3) z = pz[i];
    int cx = (int)floor(x / g_spatialCellSize);
    int cy = (int)floor(y / g_spatialCellSize);
    int cz = (int)floor(z / g_spatialCellSize);
    long long idx = spatialHash(cx, cy, cz);
    cellAdd(&g_spatialGrid[idx], i);
  }
  g_spatialBuilt = 1;
}

long long kx_spatial_query_begin(double cx, double cy, double cz, double radius) {
  if (!g_spatialBuilt || g_spatialComp < 0) {
    for (long long i = 0; i < g_frozenSize; i++) {
      if (g_spatialSubtreeMask && !(g_frozenTagMasks[i] & g_spatialSubtreeMask)) continue;
      if (!(g_frozenCompMasks[i] & (1LL << g_spatialComp))) continue;
      double* px = (double*)g_frozenFields[g_spatialComp * KX_MAX_FIELDS + g_spatialFieldX];
      double* py = (double*)g_frozenFields[g_spatialComp * KX_MAX_FIELDS + g_spatialFieldY];
      double* pz = (double*)g_frozenFields[g_spatialComp * KX_MAX_FIELDS + g_spatialFieldZ];
      double dx = px[i] - cx, dy = py[i] - cy, dz = (g_spatialDims >= 3 ? pz[i] : 0) - cz;
      if (dx*dx + dy*dy + dz*dz <= radius*radius) return i;
    }
    return -1;
  }
  int cellRadius = (int)ceil(radius / g_spatialCellSize);
  int minCx = (int)floor((cx - radius) / g_spatialCellSize);
  int maxCx = (int)floor((cx + radius) / g_spatialCellSize);
  int minCy = (int)floor((cy - radius) / g_spatialCellSize);
  int maxCy = (int)floor((cy + radius) / g_spatialCellSize);
  int minCz = (int)floor((cz - radius) / g_spatialCellSize);
  int maxCz = (int)floor((cz + radius) / g_spatialCellSize);
  double r2 = radius * radius;
  for (int ciX = minCx; ciX <= maxCx; ciX++) {
    for (int ciY = minCy; ciY <= maxCy; ciY++) {
      for (int ciZ = minCz; ciZ <= maxCz; ciZ++) {
        long long cellIdx = spatialHash(ciX, ciY, ciZ);
        kx_cell* cell = &g_spatialGrid[cellIdx];
        for (long long e = 0; e < cell->size; e++) {
          long long i = cell->entries[e];
          if (g_spatialSubtreeMask && !(g_frozenTagMasks[i] & g_spatialSubtreeMask)) continue;
          if (!(g_frozenCompMasks[i] & (1LL << g_spatialComp))) continue;
          double* px = (double*)g_frozenFields[g_spatialComp * KX_MAX_FIELDS + g_spatialFieldX];
          double* py = (double*)g_frozenFields[g_spatialComp * KX_MAX_FIELDS + g_spatialFieldY];
          double* pz = (double*)g_frozenFields[g_spatialComp * KX_MAX_FIELDS + g_spatialFieldZ];
          double dx = px[i] - cx, dy = py[i] - cy, dz = (g_spatialDims >= 3 ? pz[i] : 0) - cz;
          if (dx*dx + dy*dy + dz*dz <= r2) {
            long long packed = (cellIdx << 32) | (long long)e;
            return packed;
          }
        }
      }
    }
  }
  return -1;
}

long long kx_spatial_query_next(long long h, double cx, double cy, double cz, double radius) {
  if (h < 0) return -1;
  if (!g_spatialBuilt || g_spatialComp < 0) {
    for (long long i = h + 1; i < g_frozenSize; i++) {
      if (g_spatialSubtreeMask && !(g_frozenTagMasks[i] & g_spatialSubtreeMask)) continue;
      if (!(g_frozenCompMasks[i] & (1LL << g_spatialComp))) continue;
      double* px = (double*)g_frozenFields[g_spatialComp * KX_MAX_FIELDS + g_spatialFieldX];
      double* py = (double*)g_frozenFields[g_spatialComp * KX_MAX_FIELDS + g_spatialFieldY];
      double* pz = (double*)g_frozenFields[g_spatialComp * KX_MAX_FIELDS + g_spatialFieldZ];
      double dx = px[i] - cx, dy = py[i] - cy, dz = (g_spatialDims >= 3 ? pz[i] : 0) - cz;
      if (dx*dx + dy*dy + dz*dz <= radius*radius) return i;
    }
    return -1;
  }
  int minCx = (int)floor((cx - radius) / g_spatialCellSize);
  int maxCx = (int)floor((cx + radius) / g_spatialCellSize);
  int minCy = (int)floor((cy - radius) / g_spatialCellSize);
  int maxCy = (int)floor((cy + radius) / g_spatialCellSize);
  int minCz = (int)floor((cz - radius) / g_spatialCellSize);
  int maxCz = (int)floor((cz + radius) / g_spatialCellSize);
  double r2 = radius * radius;
  long long startCell = h >> 32;
  long long startEntry = (long long)(h & 0xFFFFFFFF);
  for (int ciX = minCx; ciX <= maxCx; ciX++) {
    for (int ciY = minCy; ciY <= maxCy; ciY++) {
      for (int ciZ = minCz; ciZ <= maxCz; ciZ++) {
        long long cellIdx = spatialHash(ciX, ciY, ciZ);
        kx_cell* cell = &g_spatialGrid[cellIdx];
        long long eStart = 0;
        if (cellIdx == startCell) {
          eStart = startEntry + 1;
        }
        for (long long e = eStart; e < cell->size; e++) {
          long long i = cell->entries[e];
          if (g_spatialSubtreeMask && !(g_frozenTagMasks[i] & g_spatialSubtreeMask)) continue;
          if (!(g_frozenCompMasks[i] & (1LL << g_spatialComp))) continue;
          double* px = (double*)g_frozenFields[g_spatialComp * KX_MAX_FIELDS + g_spatialFieldX];
          double* py = (double*)g_frozenFields[g_spatialComp * KX_MAX_FIELDS + g_spatialFieldY];
          double* pz = (double*)g_frozenFields[g_spatialComp * KX_MAX_FIELDS + g_spatialFieldZ];
          double dx = px[i] - cx, dy = py[i] - cy, dz = (g_spatialDims >= 3 ? pz[i] : 0) - cz;
          if (dx*dx + dy*dy + dz*dz <= r2) {
            long long packed = (cellIdx << 32) | (long long)e;
            return packed;
          }
        }
      }
    }
  }
  return -1;
}

long long kx_spatial_query_count(double cx, double cy, double cz, double radius) {
  long long count = 0;
  long long h = kx_spatial_query_begin(cx, cy, cz, radius);
  while (h >= 0) {
    count++;
    h = kx_spatial_query_next(h, cx, cy, cz, radius);
  }
  return count;
}

static void growGlobalFrozen(long long minSlots) {
  if (!g_frozenFields) {
    g_frozenFields = (void**)calloc(g_compCount * KX_MAX_FIELDS, sizeof(void*));
  }
  long long cap = g_boxCount * KX_INIT_ENTITIES;
  while (cap < minSlots) cap *= 2;
  if (cap <= g_frozenCap) return;
  g_frozenCap = cap;
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
  if (subtreeMask == 0 || !g_tagIdxBuilt) {
    for (long long i = 0; i < g_frozenSize; i++) {
      if (frozenMatch(i, subtreeMask, exact)) return i;
    }
    return -1;
  }
  if (exact) {
    long long bit = subtreeMask & -subtreeMask;
    int bitIdx = __builtin_ctzll(bit);
    for (long long k = 0; k < g_tagIdxSize[bitIdx]; k++) {
      long long i = g_tagIdx[bitIdx][k];
      if ((g_frozenTagMasks[i] & subtreeMask) == bit) return i;
    }
    return -1;
  }
  for (int bit = 0; bit < KX_MAX_TAGS; bit++) {
    if (!(subtreeMask & (1LL << bit))) continue;
    for (long long k = 0; k < g_tagIdxSize[bit]; k++) {
      long long i = g_tagIdx[bit][k];
      if ((g_frozenTagMasks[i] & subtreeMask) != 0) return i;
    }
  }
  return -1;
}

long long kx_others_next(long long h, long long subtreeMask, int exact) {
  if (h < 0) return -1;
  if (subtreeMask == 0 || !g_tagIdxBuilt) {
    for (long long i = h + 1; i < g_frozenSize; i++) {
      if (frozenMatch(i, subtreeMask, exact)) return i;
    }
    return -1;
  }
  if (exact) {
    long long bit = subtreeMask & -subtreeMask;
    int bitIdx = __builtin_ctzll(bit);
    for (long long k = 0; k < g_tagIdxSize[bitIdx]; k++) {
      long long i = g_tagIdx[bitIdx][k];
      if (i <= h) continue;
      if ((g_frozenTagMasks[i] & subtreeMask) == bit) return i;
    }
    return -1;
  }
  for (int bit = 0; bit < KX_MAX_TAGS; bit++) {
    if (!(subtreeMask & (1LL << bit))) continue;
    for (long long k = 0; k < g_tagIdxSize[bit]; k++) {
      long long i = g_tagIdx[bit][k];
      if (i <= h) continue;
      if ((g_frozenTagMasks[i] & subtreeMask) != 0) return i;
    }
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
      long long* fs = (long long*)from->fFields[c * KX_MAX_FIELDS + f];
      long long* ts = (long long*)to->fFields[c * KX_MAX_FIELDS + f];
      if (g_fieldTypes[c * KX_MAX_FIELDS + f] == KX_KIND_COLL) {
        ts[nslot] = copyHandle(fs[slot], 3);
      } else {
        ts[nslot] = fs[slot];
      }
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

void kx_stop(void) {
  g_stop = 1;
  freeTagIdx();
  spatialFreeGrid();
}

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
  g_inRun = 1;
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
  growGlobalFrozen(0);

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
      g_traceEnabled = getenv("KX_TRACE") != NULL;
      kx_poll_stdin();
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
      g_traceEnabled = getenv("KX_TRACE") != NULL;
      kx_poll_stdin();
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
  g_inRun = 0;
}

/* ---- console, string helpers, process control ---- */

char* kx_dup(const char* s) {
  size_t n = strlen(s);
  char* p = (char*)malloc(n + 1);
  if (!p) kx_panic("out of memory");
  memcpy(p, s, n + 1);
  return p;
}

char* kx_dup_n(const char* s, int len) {
  if (!s || len <= 0) { char* p = (char*)malloc(1); p[0] = '\0'; return p; }
  char* p = (char*)malloc((size_t)len + 1);
  if (!p) kx_panic("out of memory");
  memcpy(p, s, (size_t)len);
  p[len] = '\0';
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

int kx_str_eq(const char* a, const char* b) {
  if (a == b) return 1;
  if (!a || !b) return 0;
  return strcmp(a, b) == 0;
}

long long kx_str_len(const char* s) { return s ? (long long)strlen(s) : 0; }

char* kx_str_substr(const char* s, long long start, long long len) {
  if (!s || start < 0 || len < 0) return kx_dup("");
  long long n = (long long)strlen(s);
  if (start > n) return kx_dup("");
  if (len > n - start) len = n - start;
  char* p = (char*)malloc((size_t)len + 1);
  if (p) {
    memcpy(p, s + start, (size_t)len);
    p[len] = '\0';
  }
  return p;
}

char* kx_str_trim(const char* s) {
  if (!s) return kx_dup("");
  const char* start = s;
  while (*start == ' ' || *start == '\t' || *start == '\n' || *start == '\r') start++;
  const char* end = s + strlen(s);
  while (end > start && (*(end-1) == ' ' || *(end-1) == '\t' || *(end-1) == '\n' || *(end-1) == '\r')) end--;
  return kx_dup_n(start, (int)(end - start));
}

int kx_str_contains(const char* a, const char* b) {
  if (!a || !b) return 0;
  return strstr(a, b) != NULL;
}

long long kx_str_index_of(const char* s, const char* sub) {
  if (!s || !sub) return -1;
  const char* p = strstr(s, sub);
  return p ? (long long)(p - s) : -1;
}

int kx_str_starts_with(const char* a, const char* b) {
  if (!a || !b) return 0;
  size_t nb = strlen(b);
  return strncmp(a, b, nb) == 0;
}

int kx_str_ends_with(const char* a, const char* b) {
  if (!a || !b) return 0;
  size_t na = strlen(a), nb = strlen(b);
  if (nb > na) return 0;
  return memcmp(a + na - nb, b, nb) == 0;
}

char* kx_str_upper(const char* s) {
  if (!s) return kx_dup("");
  size_t n = strlen(s);
  char* p = (char*)malloc(n + 1);
  if (p) {
    for (size_t i = 0; i < n; i++) p[i] = (char)toupper((unsigned char)s[i]);
    p[n] = '\0';
  }
  return p;
}

char* kx_str_lower(const char* s) {
  if (!s) return kx_dup("");
  size_t n = strlen(s);
  char* p = (char*)malloc(n + 1);
  if (p) {
    for (size_t i = 0; i < n; i++) p[i] = (char)tolower((unsigned char)s[i]);
    p[n] = '\0';
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

int kx_system(const char* cmd) {
  if (!cmd) return -1;
  return system(cmd);
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

double kx_rng_next_double(long long state) {
  unsigned long long u = (unsigned long long)state >> 11;
  return (double)u / 9007199254740992.0;
}

void kx_log(long long level, const char* msg) {
  (void)level;
  if (msg) fprintf(stderr, "[log] %s\n", msg);
}

double kx_clamp(double x, double lo, double hi) {
  if (x < lo) return lo;
  if (x > hi) return hi;
  return x;
}

double kx_lerp(double a, double b, double t) { return a + (b - a) * t; }

/* ---- stdin line queue (polled between ticks, deterministic order) ---- */

#define KX_STDIN_Q 64

static char* g_stdinQueue[KX_STDIN_Q];
static int g_stdinHead;
static int g_stdinTail;
static int g_stdinCount;

void kx_poll_stdin(void) {
  if (g_stdinCount >= KX_STDIN_Q) return;
  struct timeval tv = {0, 0};
  fd_set set;
  FD_ZERO(&set);
  FD_SET(0, &set);
  if (select(1, &set, NULL, NULL, &tv) <= 0) return;
  if (!FD_ISSET(0, &set)) return;
  char* line = NULL;
  size_t cap = 0;
  ssize_t n = getline(&line, &cap, stdin);
  if (n < 0) {
    free(line);
    return;
  }
  while (n > 0 && (line[n - 1] == '\n' || line[n - 1] == '\r')) {
    line[n - 1] = '\0';
    n--;
  }
  g_stdinQueue[g_stdinTail] = line;
  g_stdinTail = (g_stdinTail + 1) % KX_STDIN_Q;
  g_stdinCount++;
}

char* kx_poll_line(void) {
  if (g_stdinCount == 0 && !g_inRun) kx_poll_stdin();
  if (g_stdinCount == 0) return NULL;
  char* line = g_stdinQueue[g_stdinHead];
  g_stdinHead = (g_stdinHead + 1) % KX_STDIN_Q;
  g_stdinCount--;
  return line;
}
char* kx_int_str(long long v) {
  char buf[32];
  int neg = 0;
  unsigned long long uv;
  if (v < 0) { neg = 1; uv = (unsigned long long)(-v); }
  else { uv = (unsigned long long)v; }
  if (uv == 0) { buf[0] = '0'; buf[1] = '\0'; }
  else {
    int i = 0;
    while (uv > 0) { buf[i++] = '0' + (int)(uv % 10); uv /= 10; }
    if (neg) buf[i++] = '-';
    buf[i] = '\0';
    for (int j = 0; j < i / 2; j++) { char t = buf[j]; buf[j] = buf[i-1-j]; buf[i-1-j] = t; }
  }
  return kx_dup(buf);
}

long long kx_struct_new(int fieldCount) {
  long long h = (long long)(uintptr_t)malloc((size_t)fieldCount * sizeof(long long));
  if (!h) kx_panic("out of memory");
  memset((void*)h, 0, (size_t)fieldCount * sizeof(long long));
  return h;
}

long long kx_struct_get(long long h, int field) {
  long long* p = (long long*)h;
  return p[field];
}

void kx_struct_set(long long h, int field, long long val) {
  long long* p = (long long*)h;
  p[field] = val;
}

void kx_struct_free(long long h, int fieldCount) {
  if (!h) return;
  long long* p = (long long*)h;
  for (int i = 0; i < fieldCount; i++) {
    if (p[i]) {
      kx_collection* c = (kx_collection*)(uintptr_t)p[i];
      if (c && (c->kind == KX_COLLECTION_LIST || c->kind == KX_COLLECTION_MAP)) {
        freeHandle(p[i]);
      }
    }
  }
  free((void*)h);
}

long long kx_box_struct(long long val, long long size) {
  void* p = malloc((size_t)size);
  if (!p) kx_panic("out of memory");
  memset(p, 0, (size_t)size);
  memcpy(p, &val, sizeof(long long) < (size_t)size ? sizeof(long long) : (size_t)size);
  return (long long)(uintptr_t)p;
}

long long kx_box_struct_full(long long h0, long long h1, long long h2, long long h3, long long size) {
  void* p = malloc((size_t)size);
  if (!p) kx_panic("out of memory");
  long long* buf = (long long*)p;
  buf[0] = h0;
  buf[1] = h1;
  buf[2] = h2;
  buf[3] = h3;
  return (long long)(uintptr_t)p;
}

int kx_str_le(const char* a, const char* b) {
  if (!a) a = "";
  if (!b) b = "";
  return strcmp(a, b) <= 0;
}

int kx_str_ge(const char* a, const char* b) {
  if (!a) a = "";
  if (!b) b = "";
  return strcmp(a, b) >= 0;
}

int kx_str_lt(const char* a, const char* b) {
  if (!a) a = "";
  if (!b) b = "";
  return strcmp(a, b) < 0;
}

int kx_str_gt(const char* a, const char* b) {
  if (!a) a = "";
  if (!b) b = "";
  return strcmp(a, b) > 0;
}

/* ---- std functions for self-hosting ---- */

static int g_argc = 0;
static char** g_argv = NULL;

void kx_save_args(int argc, char** argv) {
  g_argc = argc;
  g_argv = argv;
}

int kx_argc(void) {
  return g_argc;
}

char* kx_argv(int i) {
  if (i < 0 || i >= g_argc) return "";
  return g_argv[i];
}

long long kx_args(long long existing_list) {
  long long list = existing_list ? existing_list : kx_list_new(1);
  for (int i = 1; i < g_argc; i++) { /* skip argv[0] (program name) */
    kx_list_add(list, (long long)(uintptr_t)g_argv[i]);
  }
  return list;
}

char* kx_read_file(const char* path) {
  FILE* f = fopen(path, "rb");
  if (!f) return "";
  fseek(f, 0, SEEK_END);
  long len = ftell(f);
  fseek(f, 0, SEEK_SET);
  char* buf = (char*)malloc(len + 1);
  if (!buf) { fclose(f); return ""; }
  fread(buf, 1, len, f);
  buf[len] = '\0';
  fclose(f);
  return buf;
}

int kx_write_file(const char* path, const char* data) {
  FILE* f = fopen(path, "wb");
  if (!f) return 0;
  fwrite(data, 1, strlen(data), f);
  fclose(f);
  return 1;
}

long long kx_list_dir(const char* path) {
  DIR* dir = opendir(path ? path : ".");
  if (!dir) return kx_list_new(2); // KX_KIND_STR = 2
  long long list = kx_list_new(2);
  struct dirent* entry;
  while ((entry = readdir(dir)) != NULL) {
    if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) continue;
    kx_list_add(list, (long long)kx_dup(entry->d_name));
  }
  closedir(dir);
  return list;
}

int kx_parse_int(const char* s) {
  if (!s || !*s) return 0;
  return (int)strtol(s, NULL, 10);
}

double kx_parse_double(const char* s) {
  if (!s || !*s) return 0.0;
  return strtod(s, NULL);
}

int kx_system_cmd(const char* cmd) {
  if (!cmd || !*cmd) return -1;
  return system(cmd);
}

int kx_print_bytes(const char* s) {
  const unsigned char* p = (const unsigned char*)(s ? s : "");
  fprintf(stderr, "bytes:");
  for (int i = 0; i < 4 && p[i]; i++) fprintf(stderr, " %02x", p[i]);
  fprintf(stderr, "\n");
  return 0;
}
