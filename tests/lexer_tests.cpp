#include "lexer.h"
#include "test_framework.h"

using namespace kx;
using namespace kxtest;

KX_TEST(component_declaration) {
  Lexer lx("component Health { var hp = 100; }");
  auto toks = lx.tokenize();
  Expect::eq(10, toks.size(), "token count");
  Expect::eq((long)TokenKind::KwComponent, (long)toks[0].kind, "kw component");
  Expect::eq((long)TokenKind::Identifier, (long)toks[1].kind, "identifier Health");
  Expect::strEq("Health", toks[1].text, "text Health");
  Expect::eq((long)TokenKind::LBrace, (long)toks[2].kind, "lbrace");
  Expect::eq((long)TokenKind::KwVar, (long)toks[3].kind, "kw var");
  Expect::eq((long)TokenKind::Identifier, (long)toks[4].kind, "identifier hp");
  Expect::eq((long)TokenKind::Assign, (long)toks[5].kind, "assign");
  Expect::eq((long)TokenKind::IntLiteral, (long)toks[6].kind, "int literal");
  Expect::eq(100, toks[6].intValue, "value 100");
  Expect::eq((long)TokenKind::Semi, (long)toks[7].kind, "semi");
  Expect::eq((long)TokenKind::RBrace, (long)toks[8].kind, "rbrace");
  Expect::eq((long)TokenKind::Eof, (long)toks[9].kind, "eof");
  Expect::true_(lx.ok(), "no errors");
}

KX_TEST(system_declaration_with_operators) {
  Lexer lx("system DamageSystem { Health.hp -= Damage.amount; if (Health.hp <= 0) { despawn self; } }");
  auto toks = lx.tokenize();
  Expect::true_(lx.ok(), "no errors");
  bool sawMinusEq = false, sawLtEq = false, sawKwDespawn = false, sawKwSelf = false;
  for (auto& t : toks) {
    if (t.kind == TokenKind::MinusEq) sawMinusEq = true;
    if (t.kind == TokenKind::LtEq) sawLtEq = true;
    if (t.kind == TokenKind::KwDespawn) sawKwDespawn = true;
    if (t.kind == TokenKind::KwSelf) sawKwSelf = true;
  }
  Expect::true_(sawMinusEq, "-=");
  Expect::true_(sawLtEq, "<=");
  Expect::true_(sawKwDespawn, "despawn");
  Expect::true_(sawKwSelf, "self");
}

KX_TEST(numeric_literals) {
  Lexer lx("5 5L 1.5 1.5f 0.5 1e5 2.5e-3");
  auto toks = lx.tokenize();
  Expect::eq(8, toks.size(), "count");
  Expect::eq((long)TokenKind::IntLiteral, (long)toks[0].kind, "5 int");
  Expect::eq(5, toks[0].intValue, "5");
  Expect::eq((long)TokenKind::IntLiteral, (long)toks[1].kind, "5L int (long suffix)");
  Expect::eq(5, toks[1].intValue, "5L");
  Expect::eq((long)TokenKind::FloatLiteral, (long)toks[2].kind, "1.5 float");
  Expect::close(1.5, toks[2].floatValue, "1.5");
  Expect::false_(toks[2].isFloat, "1.5 is double");
  Expect::eq((long)TokenKind::FloatLiteral, (long)toks[3].kind, "1.5f float");
  Expect::close(1.5, toks[3].floatValue, "1.5f");
  Expect::true_(toks[3].isFloat, "1.5f is float");
  Expect::eq((long)TokenKind::FloatLiteral, (long)toks[4].kind, "0.5");
  Expect::close(0.5, toks[4].floatValue, "0.5");
  Expect::eq((long)TokenKind::FloatLiteral, (long)toks[5].kind, "1e5");
  Expect::close(100000.0, toks[5].floatValue, "1e5");
  Expect::eq((long)TokenKind::FloatLiteral, (long)toks[6].kind, "2.5e-3");
  Expect::close(0.0025, toks[6].floatValue, "2.5e-3");
  Expect::eq((long)TokenKind::Eof, (long)toks[7].kind, "eof");
  Expect::true_(lx.ok(), "no errors");
}

KX_TEST(strings_and_escapes) {
  Lexer lx("\"hello\\n\\t\\\"world\\\"\"");
  auto toks = lx.tokenize();
  Expect::true_(lx.ok(), "no errors");
  Expect::eq((long)TokenKind::StringLiteral, (long)toks[0].kind, "string");
  Expect::strEq("hello\n\t\"world\"", toks[0].text, "decoded content");
}

KX_TEST(dollar_string) {
  Lexer lx("$\"hp: {Health.hp}\"");
  auto toks = lx.tokenize();
  Expect::true_(lx.ok(), "no errors");
  Expect::eq((long)TokenKind::DollarString, (long)toks[0].kind, "dollar string");
  Expect::strEq("hp: {Health.hp}", toks[0].text, "raw content kept");
}

KX_TEST(comments_ignored) {
  Lexer lx("component A { // line comment\n var x = 1; /* block\n comment */ var y = 2; }");
  auto toks = lx.tokenize();
  Expect::true_(lx.ok(), "no errors");
  Expect::eq((long)TokenKind::KwComponent, (long)toks[0].kind, "component");
  Expect::eq((long)TokenKind::Identifier, (long)toks[1].kind, "A");
  Expect::eq((long)TokenKind::LBrace, (long)toks[2].kind, "lbrace");
  Expect::eq((long)TokenKind::KwVar, (long)toks[3].kind, "var x");
  Expect::eq((long)TokenKind::Identifier, (long)toks[4].kind, "x");
  Expect::eq((long)TokenKind::Assign, (long)toks[5].kind, "=");
  Expect::eq((long)TokenKind::IntLiteral, (long)toks[6].kind, "1");
  Expect::eq((long)TokenKind::Semi, (long)toks[7].kind, ";");
  Expect::eq((long)TokenKind::KwVar, (long)toks[8].kind, "var y");
  Expect::eq((long)TokenKind::Identifier, (long)toks[9].kind, "y");
  Expect::eq((long)TokenKind::Assign, (long)toks[10].kind, "=");
  Expect::eq((long)TokenKind::IntLiteral, (long)toks[11].kind, "2");
  Expect::eq((long)TokenKind::Semi, (long)toks[12].kind, ";");
  Expect::eq((long)TokenKind::RBrace, (long)toks[13].kind, "rbrace");
}

KX_TEST(tag_keywords_and_context) {
  Lexer lx("tag Combatant : Actor; system S with (A, B) without (C)");
  auto toks = lx.tokenize();
  Expect::true_(lx.ok(), "no errors");
  Expect::eq((long)TokenKind::KwTag, (long)toks[0].kind, "tag");
  Expect::eq((long)TokenKind::Identifier, (long)toks[1].kind, "Combatant");
  Expect::eq((long)TokenKind::Colon, (long)toks[2].kind, "colon");
  Expect::eq((long)TokenKind::Identifier, (long)toks[3].kind, "Actor");
  Expect::eq((long)TokenKind::Semi, (long)toks[4].kind, "semi");
  Expect::eq((long)TokenKind::KwSystem, (long)toks[5].kind, "system");
  Expect::eq((long)TokenKind::Identifier, (long)toks[6].kind, "S");
  Expect::eq((long)TokenKind::KwWith, (long)toks[7].kind, "with");
  Expect::eq((long)TokenKind::LParen, (long)toks[8].kind, "lparen");
  Expect::eq((long)TokenKind::Identifier, (long)toks[9].kind, "A");
  Expect::eq((long)TokenKind::Comma, (long)toks[10].kind, "comma");
  Expect::eq((long)TokenKind::Identifier, (long)toks[11].kind, "B");
  Expect::eq((long)TokenKind::RParen, (long)toks[12].kind, "rparen");
  Expect::eq((long)TokenKind::KwWithout, (long)toks[13].kind, "without");
  Expect::eq((long)TokenKind::LParen, (long)toks[14].kind, "lparen");
  Expect::eq((long)TokenKind::Identifier, (long)toks[15].kind, "C");
  Expect::eq((long)TokenKind::RParen, (long)toks[16].kind, "rparen");
}

KX_TEST(other_language_tokens) {
  Lexer lx("others<Health>(tag: exact Combatant) foreach (var e in items)");
  auto toks = lx.tokenize();
  Expect::true_(lx.ok(), "no errors");
  Expect::eq((long)TokenKind::Identifier, (long)toks[0].kind, "others identifier");
  Expect::eq((long)TokenKind::Lt, (long)toks[1].kind, "<");
  Expect::eq((long)TokenKind::Identifier, (long)toks[2].kind, "Health");
  Expect::eq((long)TokenKind::Gt, (long)toks[3].kind, ">");
  Expect::eq((long)TokenKind::LParen, (long)toks[4].kind, "(");
  Expect::eq((long)TokenKind::KwTag, (long)toks[5].kind, "tag");
  Expect::eq((long)TokenKind::Colon, (long)toks[6].kind, ":");
  Expect::eq((long)TokenKind::KwExact, (long)toks[7].kind, "exact");
  Expect::eq((long)TokenKind::Identifier, (long)toks[8].kind, "Combatant");
  Expect::eq((long)TokenKind::RParen, (long)toks[9].kind, ")");
  Expect::eq((long)TokenKind::KwForeach, (long)toks[10].kind, "foreach");
  Expect::eq((long)TokenKind::LParen, (long)toks[11].kind, "(");
  Expect::eq((long)TokenKind::KwVar, (long)toks[12].kind, "var");
  Expect::eq((long)TokenKind::Identifier, (long)toks[13].kind, "e");
  Expect::eq((long)TokenKind::KwIn, (long)toks[14].kind, "in");
  Expect::eq((long)TokenKind::Identifier, (long)toks[15].kind, "items");
  Expect::eq((long)TokenKind::RParen, (long)toks[16].kind, ")");
}

KX_TEST(attach_detach_spawn_tokens) {
  Lexer lx("attach(hit.Id, new Damage { amount = 10 }); detach(self, Damage); despawn self; spawn { tags [Combatant] }");
  auto toks = lx.tokenize();
  Expect::true_(lx.ok(), "no errors");
  Expect::eq((long)TokenKind::KwAttach, (long)toks[0].kind, "attach");
  Expect::eq((long)TokenKind::KwNew, (long)toks[6].kind, "new");
  Expect::eq((long)TokenKind::KwDetach, (long)toks[15].kind, "detach");
  Expect::eq((long)TokenKind::KwDespawn, (long)toks[22].kind, "despawn");
  Expect::eq((long)TokenKind::KwSelf, (long)toks[23].kind, "self");
  Expect::eq((long)TokenKind::KwSpawn, (long)toks[25].kind, "spawn");
  Expect::eq((long)TokenKind::KwTags, (long)toks[27].kind, "tags");
}

KX_TEST(ternary_and_nullable) {
  Lexer lx("var v = a ? b : c; string? name = std.readln();");
  auto toks = lx.tokenize();
  Expect::true_(lx.ok(), "no errors");
  Expect::eq((long)TokenKind::QMark, (long)toks[4].kind, "? ternary");
  Expect::eq((long)TokenKind::Colon, (long)toks[6].kind, ": ternary");
  Expect::eq((long)TokenKind::KwString, (long)toks[9].kind, "string type");
  Expect::eq((long)TokenKind::QMark, (long)toks[10].kind, "? nullable");
}

KX_TEST(unterminated_string_error) {
  Lexer lx("\"oops");
  auto toks = lx.tokenize();
  Expect::false_(lx.ok(), "has error");
  Expect::eq(1, (long)lx.errors().size(), "one error");
}

KX_TEST(unknown_escape_error) {
  Lexer lx("\"bad\\q\"");
  auto toks = lx.tokenize();
  Expect::false_(lx.ok(), "has error");
}

KX_TEST(unterminated_block_comment_error) {
  Lexer lx("/* never closed");
  auto toks = lx.tokenize();
  Expect::false_(lx.ok(), "has error");
}

KX_TEST(unexpected_character_error) {
  Lexer lx("var x = @;");
  auto toks = lx.tokenize();
  Expect::false_(lx.ok(), "has error");
}

KX_TEST(line_column_tracking) {
  Lexer lx("component A {\n  var x = 1;\n}");
  auto toks = lx.tokenize();
  Expect::true_(lx.ok(), "no errors");
  Expect::eq(1, toks[0].line, "component line");
  Expect::eq(11, toks[1].col, "A col");
  Expect::eq(2, toks[3].line, "var line");
  Expect::eq(11, toks[6].col, "int literal col");
  Expect::eq(3, toks[8].line, "rbrace line");
}

int main() { return kxtest::runAll("lexer"); }