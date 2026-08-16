#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

mkdir -p build
if [ ! -x build/kxc ]; then
  echo "e2e: kxc not built; run ./build.sh first"
  exit 1
fi

./build/kxc build samples/hello build/e2e_hello
OUTPUT=$(timeout 10 ./build/e2e_hello)

EXPECTED="hello, kubexic
point: (3, 4)
dist: 25
sum 1..100 = 5050
while: 1
while: 3
logic ok
pi = 3.14159"

if [ "$OUTPUT" != "$EXPECTED" ]; then
  echo "e2e: FAIL"
  echo "--- expected ---"
  echo "$EXPECTED"
  echo "--- got ---"
  echo "$OUTPUT"
  exit 1
fi
echo "e2e: PASS (hello sample matches golden output)"
exit 0