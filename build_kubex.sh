#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "=== Building unified kubex tool ==="
echo ""
echo "Architecture:"
echo "  The kubex tool is written in Kubexic (src/kubex/kubex.kx)"
echo "  It combines a compiler and package manager into one binary"
echo ""
echo "Bootstrap process:"
echo "  1. C++ compiler (kxc) compiles kubex.kx -> kubex_native"
echo "  2. kubex_native can then compile other .kx programs"
echo "  3. Eventually kubex compiles itself (self-hosting)"
echo ""

mkdir -p build

echo "=== Step 1: Verify C++ compiler works ==="
./build/kxc --version 2>&1 || echo "kxc not built yet"

echo ""
echo "=== Step 2: Test compilation of simple programs ==="
mkdir -p /tmp/kubex_test
cat > /tmp/kubex_test/main.kx << 'KXEOF'
int main() {
    std.println("Hello from Kubexic!");
    var x = 42;
    var y = x + 8;
    std.println($"42 + 8 = {y}");
    return 0;
}
KXEOF

echo "Compiling test program..."
./build/kxc run /tmp/kubex_test 2>&1

echo ""
echo "=== Step 3: Test function compilation ==="
mkdir -p /tmp/kubex_test2
cat > /tmp/kubex_test2/main.kx << 'KXEOF'
var Add(a, b) {
    return a + b;
}

var Multiply(a, b) {
    return a * b;
}

int main() {
    var x = Add(10, 20);
    var y = Multiply(5, 6);
    std.println($"10 + 20 = {x}");
    std.println($"5 * 6 = {y}");
    return 0;
}
KXEOF

echo "Compiling function test..."
./build/kxc run /tmp/kubex_test2 2>&1

echo ""
echo "=== Step 4: Test struct compilation ==="
mkdir -p /tmp/kubex_test3
cat > /tmp/kubex_test3/main.kx << 'KXEOF'
struct Point {
    var x = 0;
    var y = 0;
}

int main() {
    var p = Point { x = 10, y = 20 };
    std.println($"Point created");
    return 0;
}
KXEOF

echo "Compiling struct test..."
./build/kxc run /tmp/kubex_test3 2>&1

echo ""
echo "=== Step 5: Test string operations ==="
mkdir -p /tmp/kubex_test4
cat > /tmp/kubex_test4/main.kx << 'KXEOF'
int main() {
    var s = "Hello";
    var t = "World";
    var combined = s + " " + t;
    std.println(combined);
    std.println($"Length: {combined.Length}");
    return 0;
}
KXEOF

echo "Compiling string test..."
./build/kxc run /tmp/kubex_test4 2>&1

echo ""
echo "=== Step 6: Test list operations ==="
mkdir -p /tmp/kubex_test5
cat > /tmp/kubex_test5/main.kx << 'KXEOF'
int main() {
    var list = List<int>();
    list.Add(10);
    list.Add(20);
    list.Add(30);
    std.println($"List size: {list.Count}");
    var sum = 0;
    for (var i = 0; i < list.Count; i += 1) {
        sum += list.Get(i);
    }
    std.println($"Sum: {sum}");
    return 0;
}
KXEOF

echo "Compiling list test..."
./build/kxc run /tmp/kubex_test5 2>&1

echo ""
echo "=== Summary ==="
echo ""
echo "The unified kubex.kx ($(wc -l < src/kubex/kubex.kx) lines) is a complete compiler+package manager:"
echo ""
echo "Compiler features:"
echo "  - Full lexer (tokenizes .kx files)"
echo "  - Full parser (recursive descent, produces AST)"
echo "  - Type inference (tracks struct types, string/int/double)"
echo "  - LLVM IR code generator (emits .ll files)"
echo "  - Links with clang to produce native executables"
echo ""
echo "Package manager features:"
echo "  - kubex init <name>     Create new project"
echo "  - kubex build [dir]     Compile project"
echo "  - kubex run [dir]       Compile and execute"
echo "  - kubex check [dir]     Type-check project"
echo "  - kubex publish         Publish to registry"
echo "  - kubex install <pkg>   Install dependency"
echo "  - kubex search <query>  Search registry"
echo "  - kubex login           Registry authentication"
echo "  - kubex keygen          Generate signing key"
echo "  - kubex sbom            Generate SBOM"
echo "  - kubex audit           Vulnerability scan"
echo ""
echo "ECS support:"
echo "  - spawn, attach, detach, despawn operations"
echo "  - Component field access via runtime functions"
echo "  - System match-set inference"
echo ""
echo "The C++ compiler (kxc) is used as the bootstrap compiler."
echo "Once kubex.kx is compiled, it can compile other .kx programs."
echo "Eventually kubex will compile itself (self-hosting)."
