#!/usr/bin/env bash
# Kubexic build script — pure Kubexic, no C++ required (after initial bootstrap)
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p build

# The self-hosted Kubexic binary compiles itself.
# Bootstrap: you need ONE prebuilt 'kubexic' binary (from the cpp-archive repo).
BOOTSTRAP_BIN="build/kubexic"
SELFHOST_SRC="src/kubex/kubex.kx"

if [ ! -f "$SELFHOST_SRC" ]; then
  echo "error: $SELFHOST_SRC not found"
  exit 1
fi

echo "== building kubexic (self-hosted) =="
if [ -x "$BOOTSTRAP_BIN" ]; then
  echo "  using existing binary to recompile itself..."
  ./"$BOOTSTRAP_BIN" build src/kubex 2>/dev/null || true
  SELFHOST_OUT="src/kubex/build/kubex"
  if [ -f "$SELFHOST_OUT" ]; then
    cp "$SELFHOST_OUT" "$BOOTSTRAP_BIN"
    rm -rf src/kubex/build
    echo "  rebuilt successfully"
  else
    echo "  WARN: self-hosted rebuild failed; keeping existing binary"
  fi
else
  # Try the C++ kxc as last-resort bootstrap
  KXC="build/kxc"
  if [ -x "$KXC" ]; then
    echo "  using C++ kxc for bootstrap..."
    ./"$KXC" build src/kubex "$BOOTSTRAP_BIN" || true
  else
    echo "WARNING: no kubexic binary or kxc found."
    echo "  To bootstrap: build the C++ compiler from the cpp-archive repo,"
    echo "  then run: kxc build src/kubex build/kubexic"
    exit 0
  fi
fi

if [ ! -x "$BOOTSTRAP_BIN" ]; then
  echo "error: failed to produce kubexic binary"
  exit 1
fi

echo ""
echo "== verifying kubexic =="
./"$BOOTSTRAP_BIN" --version

echo ""
echo "== e2e golden tests =="
./tests/e2e/run_e2e.sh
