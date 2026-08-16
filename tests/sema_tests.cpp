#include "checker.h"
#include "parser.h"
#include "test_framework.h"

#include <string>
#include <vector>

using namespace kx;
using namespace kxtest;

static std::vector<std::string> checkAll(std::vector<std::string> sources) {
  Checker c;
  for (auto& src : sources) {
    std::vector<ParseError> perr;
    auto prog = parseSource(src, "", &perr);
    if (!prog) {
      std::string msg = "PARSE:";
      for (const auto& e : perr) msg += " " + e.message;
      return {msg};
    }
    c.addProgram(std::move(prog));
  }
  c.check();
  return c.errors();
}

static bool ok(std::vector<std::string> sources) { return checkAll(std::move(sources)).empty(); }

KX_TEST(valid_minimal_program) {
  Expect::true_(ok({"int main() { return 0; }"}), "minimal program");
}

KX_TEST(valid_component_system_main) {
  std::vector<std::string> srcs = {
      "component Health { var hp = 100; }",
      "system DamageSystem { Health.hp -= 1; }",
      "int main() { spawn { Health { hp = 50 } }; return 0; }",
  };
  Expect::true_(ok(srcs), "component + system + main");
}

KX_TEST(missing_main) {
  Expect::false_(ok({"component A { var x = 1; }"}), "no main");
}

KX_TEST(duplicate_declaration) {
  std::vector<std::string> srcs = {
      "component A { var x = 1; }",
      "component A { var y = 2; }",
      "int main() { return 0; }",
  };
  Expect::false_(ok(srcs), "duplicate component");
}

KX_TEST(with_unknown_component) {
  std::vector<std::string> srcs = {
      "component Health { var hp = 1; }",
      "system S with (Health, Nope) { Health.hp = 0; }",
      "int main() { return 0; }",
  };
  Expect::false_(ok(srcs), "unknown component in with");
}

KX_TEST(unknown_tag_in_others) {
  std::vector<std::string> srcs = {
      "component Health { var hp = 1; }",
      "system S { foreach (var t in others<Health>(tag: Nope)) { } }",
      "int main() { return 0; }",
  };
  Expect::false_(ok(srcs), "unknown tag");
}

KX_TEST(others_requires_tag) {
  std::vector<std::string> srcs = {
      "component Health { var hp = 1; }",
      "tag T;",
      "system S { foreach (var t in others<Health>(tag: T)) { } }",
      "int main() { return 0; }",
  };
  Expect::true_(ok(srcs), "valid others");
  Expect::false_(ok({
      "component Health { var hp = 1; }",
      "tag T;",
      "system S { foreach (var t in others<Health>()) { } }",
      "int main() { return 0; }",
  }), "others without tag");
}

KX_TEST(component_field_access) {
  std::vector<std::string> srcs = {
      "component Health { var hp = 100; }",
      "system S { Health.missing = 1; }",
      "int main() { return 0; }",
  };
  Expect::false_(ok(srcs), "unknown component field");
}

KX_TEST(unknown_identifier_in_system) {
  std::vector<std::string> srcs = {
      "system S { Nope.x = 1; }",
      "int main() { return 0; }",
  };
  Expect::false_(ok(srcs), "unknown identifier");
}

KX_TEST(unknown_identifier_in_main) {
  Expect::false_(ok({"int main() { var x = missing_thing; return 0; }"}), "unknown identifier");
}

KX_TEST(attach_unknown_component) {
  std::vector<std::string> srcs = {
      "system S { attach(self, new Nope { x = 1 }); }",
      "int main() { return 0; }",
  };
  Expect::false_(ok(srcs), "unknown component in attach");
}

KX_TEST(attach_field_type_mismatch) {
  std::vector<std::string> srcs = {
      "component Damage { var amount = 10; }",
      "system S { attach(self, new Damage { amount = \"big\" }); }",
      "int main() { return 0; }",
  };
  Expect::false_(ok(srcs), "string to int field");
}

KX_TEST(spawn_unknown_tag) {
  Expect::false_(ok({"int main() { spawn { tags [Ghost] }; return 0; }"}), "unknown tag");
}

KX_TEST(assign_type_mismatch) {
  std::vector<std::string> srcs = {
      "component Health { var hp = 100; }",
      "system S { Health.hp = \"full\"; }",
      "int main() { return 0; }",
  };
  Expect::false_(ok(srcs), "string to int");
}

KX_TEST(const_folding) {
  Expect::true_(ok({"const A = 2 + 3 * 4;", "int main() { var x = A; return 0; }"}),
               "folded const");
  Expect::false_(ok({"const A = x;", "int main() { return 0; }"}), "non-const const");
}

KX_TEST(void_function_returns_value) {
  Expect::false_(ok({"void F() { return 5; }", "int main() { return 0; }"}), "void returns value");
}

KX_TEST(var_function_no_return) {
  Expect::false_(ok({"var F(a) { var b = 1; }", "int main() { return 0; }"}), "var no return");
}

KX_TEST(nonmain_int_function) {
  Expect::false_(ok({"int F() { return 1; }", "int main() { return 0; }"}), "non-main int");
}

KX_TEST(call_arg_count_mismatch) {
  Expect::false_(ok({"var F(a, b) { return a; }", "int main() { var x = F(1); return 0; }"}),
                 "wrong arg count");
}

KX_TEST(break_outside_loop) {
  Expect::false_(ok({"int main() { break; return 0; }"}), "break outside loop");
}

KX_TEST(is_pattern_valid) {
  Expect::true_(ok({"int main() { var name = std.readln(); if (name is string s) { s = \"\"; } "
                    "return 0; }"}),
                "is string pattern");
  Expect::false_(ok({"int main() { var x = 1; if (x is Nope n) { } return 0; }"}),
                 "unknown is-type");
}

KX_TEST(unknown_std_function) {
  Expect::false_(ok({"int main() { std.doesNotExist(); return 0; }"}), "unknown std fn");
}

KX_TEST(enum_members) {
  Expect::true_(ok({"enum Direction { North, East }", "int main() { var d = Direction.North; "
                    "return 0; }"}),
                "enum member access");
  Expect::false_(ok({"enum Direction { North }", "int main() { var d = Direction.South; "
                    "return 0; }"}),
                 "unknown enum member");
}

KX_TEST(unknown_attribute) {
  Expect::false_(ok({"system S [Bogus] { }", "int main() { return 0; }"}), "unknown attribute");
}

KX_TEST(tag_extends_unknown) {
  Expect::false_(ok({"tag A : Missing;", "int main() { return 0; }"}), "tag parent unknown");
}

KX_TEST(arrow_sample_end_to_end) {
  std::vector<std::string> srcs = {
      "component Pos3 { var x = 0.0; var y = 0.0; var z = 0.0; }",
      "component Health { var hp = 100; }",
      "component Damage { var amount = 10; var sender = EntityId.None; }",
      "component Healing { var amount = 5; }",
      "component Arrow { var sender = EntityId.None; }",
      "tag Combatant;",
      "tag Projectile;",
      "system ArrowSystem { foreach (var hit in spatial.Overlap(Pos3, 0.5)) { "
      "attach(hit.Id, new Damage { amount = 10, sender = Arrow.sender }); despawn self; } }",
      "system DamageSystem { Health.hp -= Damage.amount; if (Health.hp <= 0) { "
      "attach(Damage.sender, new Healing { amount = 5 }); despawn self; } else { "
      "detach(self, Damage); } }",
      "int main() { var world = spawn { Pos3 { x = 0, y = 0, z = 0 }, Health { hp = 100 }, "
      "tags [Combatant] }; var arrow = spawn { Pos3 { x = 0, y = 0, z = 0 }, Arrow { "
      "sender = world }, tags [Projectile] }; run(60); return 0; }",
  };
  auto errs = checkAll(srcs);
  for (const auto& e : errs) {
    if (e.rfind("PARSE", 0) == 0) throw std::string("parse error: " + e);
  }
  Expect::true_(errs.empty(), "arrow sample typechecks");
}

KX_TEST(tick_and_dt_builtins) {
  Expect::true_(ok({"component P { var x = 0.0; }",
                    "system Move { P.x += dt * 1.0; var t = tick; }",
                    "int main() { return 0; }"}),
                "dt/tick builtins");
  Expect::false_(ok({"int main() { var x = dt; return 0; }"}), "dt outside system");
}

KX_TEST(collections_list_map) {
  Expect::true_(ok({
      "component Inv { var items = List<string>(); var stats = Map<string, long>(); }",
      "system S { Inv.items.Add(\"x\"); var n = Inv.items.Count; var s = Inv.items.Get(0); "
      "Inv.items.Set(0, \"y\"); Inv.items.RemoveAt(0); Inv.items.Clear(); "
      "Inv.stats.Set(\"hp\", 10); var v = Inv.stats.Get(\"hp\"); var h = Inv.stats.Has(\"hp\"); "
      "Inv.stats.Remove(\"hp\"); Inv.stats.Clear(); }",
      "int main() { var l = List<int>(); l.Add(1); var m = Map<string, int>(); "
      "m.Set(\"k\", 2); return 0; }",
  }), "valid collections usage");
}

KX_TEST(collections_type_mismatch) {
  Expect::false_(ok({
      "component Inv { var items = List<int>(); }",
      "system S { Inv.items.Add(\"not an int\"); }",
      "int main() { return 0; }",
  }), "string into List<int>");
  Expect::false_(ok({
      "int main() { var l = List<int>(); l.Add(\"x\"); return 0; }",
  }), "string into List<int> local");
}

KX_TEST(collections_foreach_unwrap) {
  Expect::true_(ok({
      "system S { var total = 0; foreach (var it in List<int>()) { total += it; } }",
      "int main() { return 0; }",
  }), "foreach over List<int> unwraps int");
}

KX_TEST(collections_frozen_mutation_rejected) {
  Expect::false_(ok({
      "component Inv { var items = List<int>(); }",
      "tag T;",
      "system S { foreach (var t in others<Inv>(tag: T)) { t.Inv.items.Add(1); } }",
      "int main() { return 0; }",
  }), "mutating another entity's list through a snapshot");
  Expect::true_(ok({
      "component Inv { var items = List<int>(); }",
      "tag T;",
      "system S { foreach (var t in others<Inv>(tag: T)) { var n = t.Inv.items.Count; } }",
      "int main() { return 0; }",
  }), "reading a snapshot's list is allowed");
}

KX_TEST(collections_nested_rejected) {
  Expect::false_(ok({
      "int main() { var l = List<List<int>>(); return 0; }",
  }), "nested generics not supported");
}

int main() { return kxtest::runAll("sema"); }