#include "checker.h"
#include "mir.h"
#include "parser.h"
#include "test_framework.h"

#include <sstream>
#include <string>
#include <vector>

using namespace kx;
using namespace kxtest;

static Mir analyzeSources(std::vector<std::string> sources) {
  Checker c;
  for (auto& src : sources) {
    auto prog = parseSource(src, "", nullptr);
    c.addProgram(std::move(prog));
  }
  c.check();
  Mir mir;
  mir.analyze(c);
  return mir;
}

static const SystemAnalysis* findSystem(const Mir& mir, const std::string& name) {
  for (const auto& s : mir.systems()) {
    if (s.name == name) return &s;
  }
  return nullptr;
}

KX_TEST(inferred_match_set) {
  auto mir = analyzeSources({
      "component Health { var hp = 100; }",
      "component Damage { var amount = 10; }",
      "system DamageSystem { Health.hp -= Damage.amount; }",
      "int main() { return 0; }",
  });
  auto* s = findSystem(mir, "DamageSystem");
  Expect::true_(s != nullptr, "system found");
  Expect::eq(2, (long)s->matchComponents.size(), "two match components");
  Expect::strEq("Health", s->matchComponents[0], "first");
  Expect::strEq("Damage", s->matchComponents[1], "second");
}

KX_TEST(with_clause_adds_marker) {
  auto mir = analyzeSources({
      "component Health { var hp = 100; }",
      "component Poisoned { }",
      "system PoisonTick with (Health, Poisoned) { Health.hp -= 1; }",
      "int main() { return 0; }",
  });
  auto* s = findSystem(mir, "PoisonTick");
  Expect::eq(2, (long)s->matchComponents.size(), "Health + Poisoned");
  Expect::strEq("Health", s->matchComponents[0], "with-first?");
}

KX_TEST(without_clause) {
  auto mir = analyzeSources({
      "component Health { var hp = 100; }",
      "component Dead { }",
      "system Regen without (Dead) { Health.hp += 2; }",
      "int main() { return 0; }",
  });
  auto* s = findSystem(mir, "Regen");
  Expect::eq(1, (long)s->withoutComponents.size(), "one without");
  Expect::strEq("Dead", s->withoutComponents[0], "Dead excluded");
}

KX_TEST(others_read_and_publish) {
  auto mir = analyzeSources({
      "component Health { var hp = 100; }",
      "tag Combatant;",
      "tag Monster : Combatant;",
      "system S { foreach (var t in others<Health>(tag: Combatant)) { } }",
      "int main() { return 0; }",
  });
  auto* s = findSystem(mir, "S");
  Expect::eq(1, (long)s->reads.size(), "one read");
  Expect::strEq("Health", s->reads[0].component, "read component");
  Expect::strEq("Combatant", s->reads[0].tag, "read tag");
  Expect::false_(s->reads[0].exact, "not exact");
  auto it = mir.publishQueries().find("Health");
  Expect::true_(it != mir.publishQueries().end(), "Health published");
  Expect::eq(1, (long)it->second.size(), "one query tag");
  Expect::strEq("Combatant", it->second[0], "publish under Combatant");
}

KX_TEST(exact_tag_read) {
  auto mir = analyzeSources({
      "component Health { var hp = 100; }",
      "tag Monster;",
      "system S { foreach (var t in others<Health>(tag: exact Monster)) { } }",
      "int main() { return 0; }",
  });
  auto* s = findSystem(mir, "S");
  Expect::true_(s->reads[0].exact, "exact read");
}

KX_TEST(attach_init_references_self_component) {
  auto mir = analyzeSources({
      "component Arrow { var sender = EntityId.None; }",
      "component Damage { var amount = 10; var sender = EntityId.None; }",
      "tag P;",
      "system ArrowSystem { foreach (var hit in others<Arrow>(tag: P)) { "
      "attach(hit.Id, new Damage { sender = Arrow.sender }); despawn self; } }",
      "int main() { return 0; }",
  });
  auto* s = findSystem(mir, "ArrowSystem");
  bool hasArrow = false;
  for (const auto& m : s->matchComponents) {
    if (m == "Arrow") hasArrow = true;
  }
  Expect::true_(hasArrow, "Arrow in match set via attach init");
}

KX_TEST(no_pollution_from_snapshot_access) {
  auto mir = analyzeSources({
      "component Health { var hp = 100; }",
      "component Position { var x = 0.0; }",
      "tag T;",
      "system S { foreach (var t in others<Health>(tag: T)) { var x = t.Health.hp; } }",
      "int main() { return 0; }",
  });
  auto* s = findSystem(mir, "S");
  Expect::eq(0, (long)s->matchComponents.size(), "no self match requirements");
}

KX_TEST(spawn_and_attach_do_not_pollute) {
  auto mir = analyzeSources({
      "component Health { var hp = 100; }",
      "tag T;",
      "system S { spawn { Health { hp = 50 } }; }",
      "int main() { var w = spawn { Health { hp = 1 } }; return 0; }",
  });
  auto* s = findSystem(mir, "S");
  Expect::eq(0, (long)s->matchComponents.size(), "spawn does not require components on self");
}

KX_TEST(dedup_reads) {
  auto mir = analyzeSources({
      "component Health { var hp = 100; }",
      "tag T;",
      "system S { foreach (var a in others<Health>(tag: T)) { "
      "foreach (var b in others<Health>(tag: T)) { } } }",
      "int main() { return 0; }",
  });
  auto* s = findSystem(mir, "S");
  Expect::eq(1, (long)s->reads.size(), "deduplicated reads");
}

KX_TEST(dump_output) {
  auto mir = analyzeSources({
      "component Health { var hp = 100; }",
      "tag T;",
      "system S { Health.hp -= 1; foreach (var t in others<Health>(tag: T)) { } }",
      "int main() { return 0; }",
  });
  std::ostringstream os;
  dumpMir(mir, os);
  std::string expected =
      "(system S match: Health read:Health@T)\n(publish Health: T)";
  Expect::strEq(expected, os.str(), "dump matches");
}

int main() { return kxtest::runAll("mir"); }