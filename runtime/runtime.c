#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

void kx_stop(void) {}

void kx_panic(const char* msg) {
  fprintf(stderr, "panic: %s\n", msg ? msg : "");
  exit(1);
}

long long kx_rng_seed(long long seed) { return seed; }

long long kx_rng_next(long long state) {
  state = state * 6364136223846793005LL + 1442695040888963407LL;
  return state;
}

long long kx_others_begin(void) { return -1; }

long long kx_others_next(long long handle) { (void)handle; return -1; }

long long kx_snap_read(long long handle, int field) {
  (void)handle;
  (void)field;
  return 0;
}

long long kx_spawn_stub(void) { return 0; }

void kx_attach_stub(long long target, long long component) {
  (void)target;
  (void)component;
}

void kx_detach_stub(long long target, long long component) {
  (void)target;
  (void)component;
}

void kx_despawn_stub(long long target) { (void)target; }