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

GOLDEN=$(KUBEXIC_CORES=1 timeout 10 ./build/e2e_ecs)
EXPECTED="spawned 3 entities
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
if [ "$GOLDEN" != "$EXPECTED" ]; then
  echo "e2e ecs (1 box): FAIL"
  echo "--- expected ---"; echo "$EXPECTED"
  echo "--- got ---"; echo "$GOLDEN"
  exit 1
fi
PASS=$((PASS + 1))
echo "e2e ecs (1 box): PASS"

MULTI=$(KUBEXIC_CORES=8 timeout 10 ./build/e2e_ecs)
if [ "$MULTI" != "$GOLDEN" ]; then
  echo "e2e ecs (8 boxes): FAIL — differs from single-box run"
  echo "--- 1 box ---"; echo "$GOLDEN"
  echo "--- 8 boxes ---"; echo "$MULTI"
  exit 1
fi
PASS=$((PASS + 1))
echo "e2e core-count invariance (1 box == 8 boxes): PASS"

MULTI2=$(KUBEXIC_CORES=8 timeout 10 ./build/e2e_ecs)
if [ "$MULTI2" != "$MULTI" ]; then
  echo "e2e determinism: FAIL (8-box runs differ)"
  exit 1
fi
PASS=$((PASS + 1))
echo "e2e determinism (8 boxes, two runs): PASS"

./build/kxc build samples/rebalance build/e2e_rebalance

RB1=$(KUBEXIC_CORES=1 timeout 20 ./build/e2e_rebalance)
RB4=$(KUBEXIC_CORES=4 timeout 20 ./build/e2e_rebalance)
RBM=$(KUBEXIC_CORES=4 KUBEXIC_MIGRATE_ALL=1 timeout 20 ./build/e2e_rebalance)
if [ "$RB1" != "$RB4" ]; then
  echo "e2e rebalance: FAIL (1 box != 4 boxes)"
  exit 1
fi
if [ "$RBM" != "$RB4" ]; then
  echo "e2e rebalance: FAIL (forced migration changed results)"
  exit 1
fi
PASS=$((PASS + 1))
echo "e2e migration invariance (migrate-all == normal): PASS"

echo "e2e: $PASS/5 checks passed"
exit 0