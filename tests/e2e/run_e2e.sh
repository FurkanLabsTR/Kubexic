#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

mkdir -p build
if [ ! -x build/kxc ]; then
  echo "e2e: kxc not built; run ./build.sh first"
  exit 1
fi

PASS=0

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
  echo "e2e hello: FAIL"
  echo "--- expected ---"; echo "$EXPECTED"
  echo "--- got ---"; echo "$OUTPUT"
  exit 1
fi
PASS=$((PASS + 1))
echo "e2e hello: PASS"

./build/kxc build samples/ecs build/e2e_ecs
OUTPUT=$(timeout 10 ./build/e2e_ecs)
EXPECTED="spawned: 1, 65537, 131073
tick 1: max counter seen = 1
tick 2: max counter seen = 2
tick 3: max counter seen = 3
tick 4: max counter seen = 4
tick 4: counter hit 5
tick 4: counter hit 5
tick 4: counter hit 5
tick 5: max counter seen = 5
tick 6: max counter seen = 6
world done"
if [ "$OUTPUT" != "$EXPECTED" ]; then
  echo "e2e ecs: FAIL"
  echo "--- expected ---"; echo "$EXPECTED"
  echo "--- got ---"; echo "$OUTPUT"
  exit 1
fi
PASS=$((PASS + 1))
echo "e2e ecs: PASS"

OUTPUT2=$(timeout 10 ./build/e2e_ecs)
if [ "$OUTPUT" != "$OUTPUT2" ]; then
  echo "e2e determinism: FAIL (two runs differ)"
  exit 1
fi
PASS=$((PASS + 1))
echo "e2e determinism: PASS"

echo "e2e: $PASS/3 checks passed"
exit 0