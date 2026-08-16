#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p build
FLAGS=(-std=c++17 -Wall -Wextra -Wpedantic -g -Isrc -Isrc/lexer -Isrc/parser -Isrc/ast -Isrc/sema -Isrc/mir -Itests)

echo "== building lexer tests =="
g++ "${FLAGS[@]}" \
  src/lexer/lexer.cpp tests/lexer_tests.cpp \
  -o build/lexer_tests
./build/lexer_tests

echo
echo "== building parser tests =="
g++ "${FLAGS[@]}" \
  src/lexer/lexer.cpp src/parser/parser.cpp tests/parser_tests.cpp \
  -o build/parser_tests
./build/parser_tests

echo
echo "== building sema tests =="
g++ "${FLAGS[@]}" \
  src/lexer/lexer.cpp src/parser/parser.cpp src/sema/types.cpp src/sema/checker.cpp \
  tests/sema_tests.cpp \
  -o build/sema_tests
./build/sema_tests

echo
echo "== building mir tests =="
g++ "${FLAGS[@]}" \
  src/lexer/lexer.cpp src/parser/parser.cpp src/sema/types.cpp src/sema/checker.cpp \
  src/mir/mir.cpp tests/mir_tests.cpp \
  -o build/mir_tests
./build/mir_tests

echo
echo "== building kxc =="
g++ "${FLAGS[@]}" \
  src/lexer/lexer.cpp src/parser/parser.cpp src/sema/types.cpp src/sema/checker.cpp \
  src/mir/mir.cpp \
  tools/kxc/main.cpp \
  -o build/kxc
./build/kxc check-dir samples/arrow
./build/kxc mir samples/arrow