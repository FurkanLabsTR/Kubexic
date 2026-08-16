#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define KX_MAX_COMPONENTS 64
#define KX_MAX_FIELDS 16
#define KX_INIT_ENTITIES 256
#define KX_MAX_TAGS 64

typedef long long kx_entity;

static int g_compCount;
static int g_fieldCounts[KX_MAX_COMPONENTS];
static void** g_fields;
static void** g_frozenFields;

static long long* g_tagMasks;
static long long* g_compMasks;
static int* g_gens;
static int g_size;
static int g_cap;

static long long* g_frozenIds;
static long long* g_frozenTagMasks;
static long long* g_frozenCompMasks;
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

static int slotAlive(long long slot) {
  return slot >= 0 && slot < g_size && g_gens[slot] != 0;
}

static kx_entity slotEntity(long long slot) {
  return (slot << 16) | (g_gens[slot] & 0xFFFF);
}

static int entitySlot(kx_entity e) { return (int)(e >> 16); }

static int entityGen(kx_entity e) { return (int)(e & 0xFFFF); }

static int entityAlive(kx_entity e) {
  long long slot = entitySlot(e);
  return slotAlive(slot) && entityGen(e) == g_gens[slot];
}

static void growStore(void) {
  int newCap = g_cap * 2;
  g_tagMasks = (long long*)realloc(g_tagMasks, sizeof(long long) * newCap);
  g_compMasks = (long long*)realloc(g_compMasks, sizeof(long long) * newCap);
  g_gens = (int*)realloc(g_gens, sizeof(int) * newCap);
  for (int c = 0; c < g_compCount; c++) {
    for (int f = 0; f < g_fieldCounts[c]; f++) {
      g_fields[c * KX_MAX_FIELDS + f] = realloc(g_fields[c * KX_MAX_FIELDS + f], 8 * newCap);
      g_frozenFields[c * KX_MAX_FIELDS + f] =
          realloc(g_frozenFields[c * KX_MAX_FIELDS + f], 8 * newCap);
    }
  }
  g_frozenIds = (long long*)realloc(g_frozenIds, sizeof(long long) * newCap);
  g_frozenTagMasks = (long long*)realloc(g_frozenTagMasks, sizeof(long long) * newCap);
  g_frozenCompMasks = (long long*)realloc(g_frozenCompMasks, sizeof(long long) * newCap);
  g_cap = newCap;
}

void kx_init(int compCount, const int* fieldCounts) {
  g_compCount = compCount < KX_MAX_COMPONENTS ? compCount : KX_MAX_COMPONENTS;
  g_cap = KX_INIT_ENTITIES;
  for (int c = 0; c < g_compCount; c++) g_fieldCounts[c] = fieldCounts[c];
  g_fields = (void**)calloc(g_compCount * KX_MAX_FIELDS, sizeof(void*));
  g_frozenFields = (void**)calloc(g_compCount * KX_MAX_FIELDS, sizeof(void*));
  for (int c = 0; c < g_compCount; c++) {
    for (int f = 0; f < g_fieldCounts[c]; f++) {
      g_fields[c * KX_MAX_FIELDS + f] = calloc(8, g_cap);
      g_frozenFields[c * KX_MAX_FIELDS + f] = calloc(8, g_cap);
    }
  }
  g_tagMasks = (long long*)calloc(g_cap, sizeof(long long));
  g_compMasks = (long long*)calloc(g_cap, sizeof(long long));
  g_gens = (int*)calloc(g_cap, sizeof(int));
  g_frozenIds = (long long*)calloc(g_cap, sizeof(long long));
  g_frozenTagMasks = (long long*)calloc(g_cap, sizeof(long long));
  g_frozenCompMasks = (long long*)calloc(g_cap, sizeof(long long));
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

kx_entity kx_spawn(long long tagMask) {
  long long slot = -1;
  for (int i = 0; i < g_size; i++) {
    if (!slotAlive(i)) { slot = i; break; }
  }
  if (slot < 0) {
    slot = g_size++;
    if (g_size > g_cap) growStore();
  }
  g_gens[slot] = (g_gens[slot] + 1) & 0xFFFF;
  if (g_gens[slot] == 0) g_gens[slot] = 1;
  g_tagMasks[slot] = tagMask;
  g_compMasks[slot] = 0;
  return slotEntity(slot);
}

void kx_despawn(kx_entity e) {
  long long slot = entitySlot(e);
  if (!entityAlive(e)) return;
  g_gens[slot] = (g_gens[slot] + 1) & 0xFFFF;
  if (g_gens[slot] == 0) g_gens[slot] = 1;
  g_tagMasks[slot] = 0;
  g_compMasks[slot] = 0;
}

void kx_ensure_comp(kx_entity e, int comp) {
  if (!entityAlive(e) || comp < 0 || comp >= g_compCount) return;
  g_compMasks[entitySlot(e)] |= (1LL << comp);
}

void kx_detach_comp(kx_entity e, int comp) {
  if (!entityAlive(e) || comp < 0 || comp >= g_compCount) return;
  g_compMasks[entitySlot(e)] &= ~(1LL << comp);
}

long long kx_comp_read_i64(kx_entity e, int comp, int field) {
  if (!entityAlive(e) || comp < 0 || comp >= g_compCount || field >= g_fieldCounts[comp])
    return 0;
  return ((long long*)g_fields[comp * KX_MAX_FIELDS + field])[entitySlot(e)];
}

void kx_comp_write_i64(kx_entity e, int comp, int field, long long v) {
  if (!entityAlive(e) || comp < 0 || comp >= g_compCount || field >= g_fieldCounts[comp])
    return;
  ((long long*)g_fields[comp * KX_MAX_FIELDS + field])[entitySlot(e)] = v;
}

double kx_comp_read_f64(kx_entity e, int comp, int field) {
  if (!entityAlive(e) || comp < 0 || comp >= g_compCount || field >= g_fieldCounts[comp])
    return 0.0;
  return ((double*)g_fields[comp * KX_MAX_FIELDS + field])[entitySlot(e)];
}

void kx_comp_write_f64(kx_entity e, int comp, int field, double v) {
  if (!entityAlive(e) || comp < 0 || comp >= g_compCount || field >= g_fieldCounts[comp])
    return;
  ((double*)g_fields[comp * KX_MAX_FIELDS + field])[entitySlot(e)] = v;
}

char* kx_comp_read_str(kx_entity e, int comp, int field) {
  if (!entityAlive(e) || comp < 0 || comp >= g_compCount || field >= g_fieldCounts[comp])
    return NULL;
  return ((char**)g_fields[comp * KX_MAX_FIELDS + field])[entitySlot(e)];
}

void kx_comp_write_str(kx_entity e, int comp, int field, char* v) {
  if (!entityAlive(e) || comp < 0 || comp >= g_compCount || field >= g_fieldCounts[comp])
    return;
  ((char**)g_fields[comp * KX_MAX_FIELDS + field])[entitySlot(e)] = v;
}

void kx_freeze(void) {
  long long fs = 0;
  for (int slot = 0; slot < g_size; slot++) {
    if (!slotAlive(slot)) continue;
    g_frozenIds[fs] = slotEntity(slot);
    g_frozenTagMasks[fs] = g_tagMasks[slot];
    long long cm = g_compMasks[slot];
    g_frozenCompMasks[fs] = cm;
    for (int c = 0; c < g_compCount; c++) {
      if (!(cm & (1LL << c))) continue;
      for (int f = 0; f < g_fieldCounts[c]; f++) {
        memcpy((char*)g_frozenFields[c * KX_MAX_FIELDS + f] + fs * 8,
               (char*)g_fields[c * KX_MAX_FIELDS + f] + slot * 8, 8);
      }
    }
    fs++;
  }
  g_frozenSize = fs;
}

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

void kx_stop(void) { g_stop = 1; }

double kx_get_dt(void) { return g_dt; }

long long kx_get_tick(void) { return g_tick; }

void kx_run(int tps, long long maxTicks) {
  g_tps = tps > 0 ? tps : 0;
  g_maxTicks = maxTicks;
  g_stop = 0;
  g_tick = 0;
  g_dt = g_tps > 0 ? 1.0 / (double)g_tps : 1.0 / 60.0;

  kx_freeze();

  struct timespec next;
  clock_gettime(CLOCK_MONOTONIC, &next);

  for (;;) {
    if (g_stop) break;
    if (g_maxTicks >= 0 && g_tick >= g_maxTicks) break;

    for (int s = 0; s < g_sysCount; s++) {
      if (g_sysMatch[s] == 0 && g_sysWithout[s] == 0) {
        g_sysBodies[s](0);
      }
    }

    for (long long fs = 0; fs < g_frozenSize; fs++) {
      long long cm = g_frozenCompMasks[fs];
      kx_entity e = g_frozenIds[fs];
      for (int s = 0; s < g_sysCount; s++) {
        if (g_sysMatch[s] == 0 && g_sysWithout[s] == 0) continue;
        if ((cm & g_sysMatch[s]) == g_sysMatch[s] && (cm & g_sysWithout[s]) == 0) {
          g_sysBodies[s](e);
        }
      }
    }

    kx_freeze();
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

/* ---- console, string helpers, process control (unchanged) ---- */

static char* kx_dup(const char* s) {
  size_t n = strlen(s);
  char* p = (char*)malloc(n + 1);
  if (p) memcpy(p, s, n + 1);
  return p;
}

void kx_print(const char* s) { if (s) fputs(s, stdout); }

void kx_println(const char* s) { if (s) puts(s); }

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

void kx_exit(int code) { exit(code); }

void kx_panic(const char* msg) {
  fprintf(stderr, "panic: %s\n", msg ? msg : "");
  exit(1);
}

long long kx_rng_seed(long long seed) { return seed; }

long long kx_rng_next(long long state) {
  state = state * 6364136223846793005LL + 1442695040888963407LL;
  return state;
}