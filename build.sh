#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p build
FLAGS=(-std=c++17 -Wall -Wextra -Wpedantic -g -Isrc -Isrc/lexer -Isrc/parser -Isrc/ast -Itests)

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
echo "== building kxc =="
g++ "${FLAGS[@]}" \
  src/lexer/lexer.cpp src/parser/parser.cpp tools/kxc/main.cpp \
  -o build/kxc
./build/kxc dump samples/arrow/main.kx