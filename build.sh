#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p build

# -g on the LLVM codegen TU is a memory hog (OOMs the machine).
# Core tests keep -g; the kxc compiler builds without it.
CORE_FLAGS=(-std=c++17 -Wall -Wextra -Wpedantic -g -Isrc -Isrc/lexer -Isrc/parser -Isrc/ast -Isrc/sema -Isrc/mir -Isrc/codegen -Itests)
KXC_FLAGS=(-std=c++17 -O0 -w -Isrc -Isrc/lexer -Isrc/parser -Isrc/ast -Isrc/sema -Isrc/mir -Isrc/codegen -Itests)
LLVM_FLAGS=$(llvm-config-21 --cxxflags)
LLVM_LIBS="$(llvm-config-21 --ldflags) -lLLVM-21"

echo "== building lexer tests =="
g++ "${CORE_FLAGS[@]}" src/lexer/lexer.cpp tests/lexer_tests.cpp -o build/lexer_tests
./build/lexer_tests

echo
echo "== building parser tests =="
g++ "${CORE_FLAGS[@]}" src/lexer/lexer.cpp src/parser/parser.cpp tests/parser_tests.cpp \
  -o build/parser_tests
./build/parser_tests

echo
echo "== building sema tests =="
g++ "${CORE_FLAGS[@]}" src/lexer/lexer.cpp src/parser/parser.cpp src/sema/types.cpp \
  src/sema/checker.cpp tests/sema_tests.cpp -o build/sema_tests
./build/sema_tests

echo
echo "== building mir tests =="
g++ "${CORE_FLAGS[@]}" src/lexer/lexer.cpp src/parser/parser.cpp src/sema/types.cpp \
  src/sema/checker.cpp src/mir/mir.cpp tests/mir_tests.cpp -o build/mir_tests
./build/mir_tests

echo
echo "== building kxc (LLVM, cached object) =="
KXC_CORE_OBJ=build/kxc_codegen.o
if [ ! -f build/kxc_lexer.o ] || [ ! -f build/kxc_codegen.o ] || \
   [ src/codegen/codegen.cpp -nt build/kxc_codegen.o ] || \
   [ src/lexer/lexer.cpp -nt build/kxc_lexer.o ] || \
   [ src/parser/parser.cpp -nt build/kxc_parser.o ] || \
   [ src/sema/types.cpp -nt build/kxc_types.o ] || \
   [ src/sema/checker.cpp -nt build/kxc_checker.o ] || \
   [ src/mir/mir.cpp -nt build/kxc_mir.o ]; then
  rm -f build/kxc_*.o
  for src in src/lexer/lexer.cpp src/parser/parser.cpp src/sema/types.cpp \
             src/sema/checker.cpp src/mir/mir.cpp src/codegen/codegen.cpp; do
    name=$(basename "$src" .cpp)
    g++ "${KXC_FLAGS[@]}" $LLVM_FLAGS \
      -DKX_RUNTIME_SOURCE="\"$(pwd)/runtime/runtime.c\"" -DKX_TRIPLE='"x86_64-pc-linux-gnu"' \
      -c "$src" -o "build/kxc_${name}.o"
  done
fi

g++ "${KXC_FLAGS[@]}" $LLVM_FLAGS \
  -DKX_RUNTIME_SOURCE="\"$(pwd)/runtime/runtime.c\"" -DKX_TRIPLE='"x86_64-pc-linux-gnu"' \
  tools/kxc/main.cpp build/kxc_lexer.o build/kxc_parser.o build/kxc_types.o \
  build/kxc_checker.o build/kxc_mir.o build/kxc_codegen.o $LLVM_LIBS \
  -o build/kxc

./build/kxc check-dir samples/arrow
./build/kxc mir samples/arrow
echo
echo "== e2e golden tests =="
./tests/e2e/run_e2e.sh