#include "parser.h"
#include "test_framework.h"

#include <sstream>

using namespace kx;
using namespace kxtest;

static std::string dumpSrc(const std::string& src) {
  std::vector<ParseError> errors;
  auto program = parseSource(src, "", &errors);
  std::ostringstream os;
  if (!program) {
    os << "PARSE_ERROR";
    for (const auto& e : errors) os << " " << e.message;
    return os.str();
  }
  dumpProgram(*program, os);
  return os.str();
}

static void expectDump(const std::string& src, const std::string& expected) {
  std::string actual = dumpSrc(src);
  Expect::strEq(actual, expected, "dump mismatch");
}

static void expectError(const std::string& src) {
  std::vector<ParseError> errors;
  auto program = parseSource(src, "<test>", &errors);
  Expect::false_(program != nullptr, "expected parse failure");
}

KX_TEST(component_declaration) {
  expectDump("component Health { var hp = 100; var name = \"unknown\"; }",
             "(program (component Health (hp (int 100)) (name (string \"unknown\"))))");
}

KX_TEST(system_with_logic) {
  std::string src = R"(
system DamageSystem {
    Health.hp -= Damage.amount;
    if (Health.hp <= 0) {
        attach(Damage.sender, new Healing { amount = 5 });
        despawn self;
    } else {
        detach(self, Damage);
    }
}
)";
  std::string expected =
      "(program (system DamageSystem (block "
      "(expr (assign subassign (member (identifier Health) hp) (member (identifier Damage) amount))) "
      "(if (binary le (member (identifier Health) hp) (int 0)) "
      "(block (attach (member (identifier Damage) sender) (Healing amount=(int 5))) (despawn (identifier self))) "
      "(block (detach (identifier self) Damage))))))";
  expectDump(src, expected);
}

KX_TEST(system_with_without_and_attributes) {
  expectDump("system PoisonTick with (Health, Poisoned) [Order(2)] { Health.hp -= 1; }",
             "(program (system PoisonTick with:Health with:Poisoned [Order (int 2)] "
             "(block (expr (assign subassign (member (identifier Health) hp) (int 1))))))");
  expectDump("system Regen without (Dead) { Health.hp += 2; }",
             "(program (system Regen without:Dead "
             "(block (expr (assign addassign (member (identifier Health) hp) (int 2))))))");
  expectDump("system Fast with (A) [FastMath] { A.x += 1; }",
             "(program (system Fast with:A [FastMath] "
             "(block (expr (assign addassign (member (identifier A) x) (int 1))))))");
}

KX_TEST(tag_hierarchy) {
  expectDump("tag Actor;", "(program (tag Actor))");
  expectDump("tag Combatant : Actor;", "(program (tag Combatant : Actor))");
}

KX_TEST(struct_enum_const) {
  expectDump("struct Vec3 { var x = 0.0; var y = 0.0; var z = 0.0; }",
             "(program (struct Vec3 (x (float 0)) (y (float 0)) (z (float 0))))");
  expectDump("enum Direction { North, East, South, West }",
             "(program (enum Direction North East South West))");
  expectDump("const MaxPlayers = 100;", "(program (const MaxPlayers (int 100)))");
}

KX_TEST(function_declarations) {
  expectDump("var Max(a, b) { return a; }",
             "(program (function Max var a b (block (return (identifier a)))))");
  expectDump("void Log(msg) { std.println(msg); }",
             "(program (function Log void msg (block (expr (call (member (identifier std) println) (identifier msg))))))");
  expectDump("int main() { return 0; }",
             "(program (function main int (block (return (int 0)))))");
}

KX_TEST(control_flow) {
  std::string src = R"(
int main() {
    for (var i = 0; i < 10; i += 1) { if (i > 5) { break; } }
    while (true) { continue; }
    foreach (var e in items) { Health.hp += 1; }
    return 0;
}
)";
  std::string expected =
      "(program (function main int (block "
      "(for (vardecl i (int 0)) (binary lt (identifier i) (int 10)) (assign addassign (identifier i) (int 1)) "
      "(block (if (binary gt (identifier i) (int 5)) (block (break))))) "
      "(while (bool true) (block (continue))) "
      "(foreach e (identifier items) (block (expr (assign addassign (member (identifier Health) hp) (int 1))))) "
      "(return (int 0)))))";
  expectDump(src, expected);
}

KX_TEST(else_if_chain) {
  expectDump("int main() { if (a > 1) { } else if (a > 0) { } else { } return 0; }",
             "(program (function main int (block (if (binary gt (identifier a) (int 1)) (block) "
             "(if (binary gt (identifier a) (int 0)) (block) (block))) (return (int 0)))))");
}

KX_TEST(expression_precedence) {
  expectDump("int main() { var v = 1 + 2 * 3; return 0; }",
             "(program (function main int (block (vardecl v (binary add (int 1) (binary mul (int 2) (int 3)))) (return (int 0)))))");
  expectDump("int main() { var v = (1 + 2) * 3; return 0; }",
             "(program (function main int (block (vardecl v (binary mul (binary add (int 1) (int 2)) (int 3))) (return (int 0)))))");
  expectDump("int main() { var v = a && b || !c; return 0; }",
             "(program (function main int (block (vardecl v (binary or (binary and (identifier a) (identifier b)) (unary not (identifier c)))) (return (int 0)))))");
}

KX_TEST(ternary) {
  expectDump("int main() { var v = a > b ? a : b; return 0; }",
             "(program (function main int (block (vardecl v (ternary (binary gt (identifier a) (identifier b)) (identifier a) (identifier b))) (return (int 0)))))");
}

KX_TEST(is_pattern) {
  expectDump("int main() { if (name is string s) { s = \"\"; } return 0; }",
             "(program (function main int (block (if (is (identifier name) string s) (block (expr (assign assign (identifier s) (string \"\"))))) (return (int 0)))))");
}

KX_TEST(spawn_expression) {
  expectDump(
      "int main() { var arrow = spawn { Pos3 { x = 1 }, Health { hp = 100 }, tags [Combatant, Monster] }; return 0; }",
      "(program (function main int (block (vardecl arrow "
      "(spawn (Pos3 x=(int 1)) (Health hp=(int 100)) tag:Combatant tag:Monster)) (return (int 0)))))");
}

KX_TEST(others_generic_call) {
  expectDump(
      "int main() { foreach (var t in others<Health>(tag: exact Combatant)) { t.Hp = 0; } return 0; }",
      "(program (function main int (block (foreach t "
      "(call (identifier others) <Health> tag:(unary exact (identifier Combatant))) "
      "(block (expr (assign assign (member (identifier t) Hp) (int 0))))) (return (int 0)))))");
  expectDump(
      "int main() { foreach (var t in others<Health>(tag: Combatant)) { } return 0; }",
      "(program (function main int (block (foreach t "
      "(call (identifier others) <Health> tag:(identifier Combatant)) (block)) (return (int 0)))))");
}

KX_TEST(interpolation) {
  expectDump("int main() { std.println($\"hp: {Health.hp}!\"); return 0; }",
             "(program (function main int (block (expr "
             "(call (member (identifier std) println) (interpolated \"hp: \" {(member (identifier Health) hp)} \"!\"))) "
             "(return (int 0)))))");
}

KX_TEST(member_chain_and_calls) {
  expectDump("int main() { spatial.Overlap(Pos3, 0.5); return 0; }",
             "(program (function main int (block (expr "
             "(call (member (identifier spatial) Overlap) (identifier Pos3) (float 0.5))) (return (int 0)))))");
  expectDump("int main() { std.readln(); return 0; }",
             "(program (function main int (block (expr (call (member (identifier std) readln))) (return (int 0)))))");
}

KX_TEST(using_directive) {
  expectDump("using Foo.Bar; component A { var x = 1; }",
             "(program using:Foo.Bar (component A (x (int 1))))");
}

KX_TEST(run_with_named_args) {
  expectDump("int main() { run(60, cores: 0.5, ticks: 100); return 0; }",
             "(program (function main int (block (expr "
             "(call (identifier run) (int 60) cores:(float 0.5) ticks:(int 100))) (return (int 0)))))");
}

KX_TEST(postfix_increment) {
  expectDump("int main() { var i = 0; i++; i--; return 0; }",
             "(program (function main int (block (vardecl i (int 0)) (expr (unary postinc (identifier i))) (expr (unary postdec (identifier i))) (return (int 0)))))");
}

KX_TEST(parse_error_missing_semicolon) {
  expectError("component A { var x = 1 }");
}

KX_TEST(parse_error_unterminated_brace) {
  expectError("component A { var x = 1; ");
}

KX_TEST(parse_error_bad_expression) {
  expectError("int main() { var x = ; return 0; }");
}

KX_TEST(parse_error_garbage) {
  expectError("???");
}

KX_TEST(parse_error_missing_component_name) {
  expectError("component { var x = 1; }");
}

int main() { return kxtest::runAll("parser"); }