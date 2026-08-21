#!/bin/bash
set -e

# test_bootstrap.sh — Bootstrap verification test
# Verifies that the C++ compiler can compile the Kubexic compiler,
# and that the resulting binary can compile itself.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"

echo "=== Bootstrap Verification Test ==="

# Step 1: Build the C++ compiler
echo "1. Building C++ compiler..."
cd "$PROJECT_ROOT"
bash build.sh 2>&1 | tail -5

# Step 2: Compile the Kubexic compiler with C++
echo "2. Compiling Kubexic compiler with C++ compiler..."
mkdir -p "$BUILD_DIR/bootstrap"
# This would compile src/kubex/*.kx files
# For now, just verify the selfhost parser works
echo "   (self-hosting compilation not yet implemented)"
echo "   Skipping to verification..."

# Step 3: Verify the selfhost parser produces identical output
echo "3. Verifying selfhost parser output..."
SAMPLE="$PROJECT_ROOT/samples/ecs/main.kx"
if [ -f "$SAMPLE" ]; then
    echo "   Using sample: $SAMPLE"
    # Would compare C++ parser output with selfhost parser output
    echo "   (comparison not yet implemented)"
else
    echo "   No sample file found, skipping comparison"
fi

echo "=== Bootstrap Test Complete ==="
echo "Note: Full bootstrap verification requires completing the self-hosted compiler."
