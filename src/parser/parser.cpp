#include "parser.h"

#include "lexer.h"

#include <memory>

namespace kx {

namespace {

const char* binaryOpName(BinaryOp op) {
  switch (op) {
    case BinaryOp::Add: return "add";
    case BinaryOp::Sub: return "sub";
    case BinaryOp::Mul: return "mul";
    case BinaryOp::Div: return "div";
    case BinaryOp::Mod: return "mod";
    case BinaryOp::Eq: return "eq";
    case BinaryOp::Ne: return "ne";
    case BinaryOp::Lt: return "lt";
    case BinaryOp::Gt: return "gt";
    case BinaryOp::Le: return "le";
    case BinaryOp::Ge: return "ge";
    case BinaryOp::And: return "and";
    case BinaryOp::Or: return "or";
  }
  return "?";
}

const char* unaryOpName(UnaryOp op) {
  switch (op) {
    case UnaryOp::Not: return "not";
    case UnaryOp::Neg: return "neg";
    case UnaryOp::Exact: return "exact";
    case UnaryOp::PostInc: return "postinc";
    case UnaryOp::PostDec: return "postdec";
  }
  return "?";
}

const char* assignOpName(AssignOp op) {
  switch (op) {
    case AssignOp::Assign: return "assign";
    case AssignOp::Add: return "addassign";
    case AssignOp::Sub: return "subassign";
    case AssignOp::Mul: return "mulassign";
    case AssignOp::Div: return "divassign";
    case AssignOp::Mod: return "modassign";
  }
  return "?";
}

const char* declKindName(Decl::Kind k) {
  switch (k) {
    case Decl::Kind::Component: return "component";
    case Decl::Kind::System: return "system";
    case Decl::Kind::Tag: return "tag";
    case Decl::Kind::Struct: return "struct";
    case Decl::Kind::Enum: return "enum";
    case Decl::Kind::Const: return "const";
    case Decl::Kind::Function: return "function";
  }
  return "?";
}

const char* stmtKindName(Stmt::Kind k) {
  switch (k) {
    case Stmt::Kind::Switch: return "switch";
    case Stmt::Kind::Block: return "block";
    case Stmt::Kind::VarDecl: return "vardecl";
    case Stmt::Kind::Expr: return "expr";
    case Stmt::Kind::If: return "if";
    case Stmt::Kind::While: return "while";
    case Stmt::Kind::For: return "for";
    case Stmt::Kind::Foreach: return "foreach";
    case Stmt::Kind::Return: return "return";
    case Stmt::Kind::Break: return "break";
    case Stmt::Kind::Continue: return "continue";
    case Stmt::Kind::Attach: return "attach";
    case Stmt::Kind::Detach: return "detach";
    case Stmt::Kind::Despawn: return "despawn";
  }
  return "?";
}

const char* exprKindName(Expr::Kind k) {
  switch (k) {
    case Expr::Kind::IntLit: return "int";
    case Expr::Kind::FloatLit: return "float";
    case Expr::Kind::StringLit: return "string";
    case Expr::Kind::BoolLit: return "bool";
    case Expr::Kind::Identifier: return "identifier";
    case Expr::Kind::MemberAccess: return "member";
    case Expr::Kind::Call: return "call";
    case Expr::Kind::Binary: return "binary";
    case Expr::Kind::Unary: return "unary";
    case Expr::Kind::Ternary: return "ternary";
    case Expr::Kind::Assign: return "assign";
    case Expr::Kind::Is: return "is";
    case Expr::Kind::Interpolated: return "interpolated";
    case Expr::Kind::Spawn: return "spawn";
    case Expr::Kind::StructInit: return "structinit";
  }
  return "?";
}

void dumpExpr(const Expr& e, std::ostream& out) {
  out << "(" << exprKindName(e.kind);
  switch (e.kind) {
    case Expr::Kind::IntLit:
      out << " " << e.intValue;
      break;
    case Expr::Kind::FloatLit:
      out << " " << e.floatValue;
      break;
    case Expr::Kind::StringLit:
      out << " \"" << e.str << "\"";
      break;
    case Expr::Kind::BoolLit:
      out << (e.intValue ? " true" : " false");
      break;
    case Expr::Kind::Identifier:
      out << " " << e.str;
      break;
    case Expr::Kind::MemberAccess:
      out << " ";
      dumpExpr(*e.lhs, out);
      out << " " << e.member;
      break;
    case Expr::Kind::Call:
      out << " ";
      dumpExpr(*e.lhs, out);
      for (const auto& ta : e.typeArgs) out << " <" << ta << ">";
      for (const auto& a : e.args) {
        out << " ";
        if (!a.name.empty()) out << a.name << ":";
        dumpExpr(*a.value, out);
      }
      break;
    case Expr::Kind::Binary:
      out << " " << binaryOpName(e.binOp) << " ";
      dumpExpr(*e.lhs, out);
      out << " ";
      dumpExpr(*e.rhs, out);
      break;
    case Expr::Kind::Unary:
      out << " " << unaryOpName(e.unOp) << " ";
      dumpExpr(*e.lhs, out);
      break;
    case Expr::Kind::Ternary:
      out << " ";
      dumpExpr(*e.lhs, out);
      out << " ";
      dumpExpr(*e.mid, out);
      out << " ";
      dumpExpr(*e.rhs, out);
      break;
    case Expr::Kind::Assign:
      out << " " << assignOpName(e.asOp) << " ";
      dumpExpr(*e.lhs, out);
      out << " ";
      dumpExpr(*e.rhs, out);
      break;
    case Expr::Kind::Is:
      out << " ";
      dumpExpr(*e.lhs, out);
      out << " " << e.patternType;
      if (!e.patternVar.empty()) out << " " << e.patternVar;
      break;
    case Expr::Kind::Interpolated:
      for (size_t i = 0; i < e.interpText.size(); ++i) {
        out << " \"" << e.interpText[i] << "\"";
        if (i < e.interpExprs.size()) {
          out << " {";
          dumpExpr(*e.interpExprs[i], out);
          out << "}";
        }
      }
      break;
    case Expr::Kind::Spawn:
      for (const auto& ci : e.spawnInits) {
        out << " (" << ci.type;
        for (const auto& f : ci.fields) {
          out << " " << f.first << "=";
          dumpExpr(*f.second, out);
        }
        out << ")";
      }
      for (const auto& t : e.spawnTags) out << " tag:" << t;
      break;
    case Expr::Kind::StructInit:
      out << " (" << e.structInit.type;
      for (const auto& f : e.structInit.fields) {
        out << " " << f.first << "=";
        dumpExpr(*f.second, out);
      }
      out << ")";
      break;
  }
  out << ")";
}

void dumpStmt(const Stmt& s, std::ostream& out) {
  out << "(" << stmtKindName(s.kind);
  switch (s.kind) {
    case Stmt::Kind::Switch:
      out << " ";
      dumpExpr(*s.cond, out);
      for (const auto& c : s.switchCases) {
        out << " (";
        for (const auto& v : c.values) {
          out << " case ";
          dumpExpr(*v, out);
        }
        out << " ";
        dumpStmt(*c.body, out);
        out << ")";
      }
      break;
    case Stmt::Kind::Block:
      for (const auto& st : s.body) {
        out << " ";
        dumpStmt(*st, out);
      }
      break;
    case Stmt::Kind::VarDecl:
      out << " " << s.varName << " ";
      dumpExpr(*s.initExpr, out);
      break;
    case Stmt::Kind::Expr:
      out << " ";
      dumpExpr(*s.value, out);
      break;
    case Stmt::Kind::If:
      out << " ";
      dumpExpr(*s.cond, out);
      out << " ";
      dumpStmt(*s.thenStmt, out);
      if (s.elseStmt) {
        out << " ";
        dumpStmt(*s.elseStmt, out);
      }
      break;
    case Stmt::Kind::While:
      out << " ";
      dumpExpr(*s.cond, out);
      out << " ";
      dumpStmt(*s.bodyStmt, out);
      break;
    case Stmt::Kind::For:
      if (s.initStmt) {
        out << " ";
        dumpStmt(*s.initStmt, out);
      } else if (s.initExpr) {
        out << " ";
        dumpExpr(*s.initExpr, out);
      }
      if (s.cond) {
        out << " ";
        dumpExpr(*s.cond, out);
      }
      if (s.inc) {
        out << " ";
        dumpExpr(*s.inc, out);
      }
      out << " ";
      dumpStmt(*s.bodyStmt, out);
      break;
    case Stmt::Kind::Foreach:
      out << " " << s.varName << " ";
      dumpExpr(*s.container, out);
      out << " ";
      dumpStmt(*s.bodyStmt, out);
      break;
    case Stmt::Kind::Return:
      if (s.value) {
        out << " ";
        dumpExpr(*s.value, out);
      }
      break;
    case Stmt::Kind::Break:
    case Stmt::Kind::Continue:
      break;
    case Stmt::Kind::Attach:
      out << " ";
      dumpExpr(*s.target, out);
      out << " (" << s.attachInit.type;
      for (const auto& f : s.attachInit.fields) {
        out << " " << f.first << "=";
        dumpExpr(*f.second, out);
      }
      out << ")";
      break;
    case Stmt::Kind::Detach:
      out << " ";
      dumpExpr(*s.target, out);
      out << " " << s.detachType;
      break;
    case Stmt::Kind::Despawn:
      out << " ";
      dumpExpr(*s.target, out);
      break;
  }
  out << ")";
}

void dumpDecl(const Decl& d, std::ostream& out) {
  out << "(" << declKindName(d.kind) << " " << d.name;
  switch (d.kind) {
    case Decl::Kind::Component:
    case Decl::Kind::Struct:
      for (const auto& f : d.fields) {
        out << " (" << f.first << " ";
        dumpExpr(*f.second, out);
        out << ")";
      }
      break;
    case Decl::Kind::System:
      for (const auto& w : d.withList) out << " with:" << w;
      for (const auto& w : d.withoutList) out << " without:" << w;
      for (const auto& a : d.attributes) {
        out << " [" << a.name;
        for (const auto& arg : a.args) {
          out << " ";
          dumpExpr(*arg, out);
        }
        out << "]";
      }
      out << " ";
      dumpStmt(*d.body, out);
      break;
    case Decl::Kind::Tag:
      if (!d.parentTag.empty()) out << " : " << d.parentTag;
      break;
    case Decl::Kind::Enum:
      for (const auto& m : d.enumMembers) out << " " << m;
      break;
    case Decl::Kind::Const:
      out << " ";
      dumpExpr(*d.constValue, out);
      break;
    case Decl::Kind::Function:
      out << " " << d.retKind;
      for (const auto& p : d.params) out << " " << p;
      out << " ";
      dumpStmt(*d.body, out);
      break;
  }
  out << ")";
}

}  // namespace

ExprPtr Expr::makeInt(std::int64_t v, SourceLoc loc) {
  auto e = std::make_unique<Expr>();
  e->kind = Kind::IntLit;
  e->intValue = v;
  e->loc = loc;
  return e;
}

ExprPtr Expr::makeFloat(double v, bool isFloat, SourceLoc loc) {
  auto e = std::make_unique<Expr>();
  e->kind = Kind::FloatLit;
  e->floatValue = v;
  e->isFloat = isFloat;
  e->loc = loc;
  return e;
}

ExprPtr Expr::makeString(std::string s, SourceLoc loc) {
  auto e = std::make_unique<Expr>();
  e->kind = Kind::StringLit;
  e->str = std::move(s);
  e->loc = loc;
  return e;
}

ExprPtr Expr::makeBool(bool b, SourceLoc loc) {
  auto e = std::make_unique<Expr>();
  e->kind = Kind::BoolLit;
  e->intValue = b ? 1 : 0;
  e->loc = loc;
  return e;
}

ExprPtr Expr::makeIdentifier(std::string name, SourceLoc loc) {
  auto e = std::make_unique<Expr>();
  e->kind = Kind::Identifier;
  e->str = std::move(name);
  e->loc = loc;
  return e;
}

void dumpProgram(const Program& program, std::ostream& out) {
  out << "(program";
  if (!program.file.empty()) out << " file:" << program.file;
  if (!program.namespaceName.empty()) out << " ns:" << program.namespaceName;
  for (const auto& u : program.usings) out << " using:" << u;
  for (const auto& d : program.decls) {
    out << " ";
    dumpDecl(d, out);
  }
  out << ")";
}

Parser::Parser(std::vector<Token> tokens, std::string file)
    : tokens_(std::move(tokens)), file_(std::move(file)) {}

const Token& Parser::peek() const {
  static Token eof;
  if (cur_ >= tokens_.size()) return eof;
  return tokens_[cur_];
}

const Token& Parser::peekAt(size_t n) const {
  static Token eof;
  if (cur_ + n >= tokens_.size()) return eof;
  return tokens_[cur_ + n];
}

bool Parser::check(TokenKind k) const { return peek().kind == k; }
bool Parser::checkName() const { return isNameToken(peek()); }

bool Parser::isNameToken(const Token& t) const {
  if (t.text.empty()) return false;
  switch (t.kind) {
    case TokenKind::Eof:
    case TokenKind::IntLiteral:
    case TokenKind::FloatLiteral:
    case TokenKind::StringLiteral:
    case TokenKind::DollarString:
      return false;
    default:
      return true;
  }
}

const Token& Parser::advance() {
  const Token& t = peek();
  if (cur_ < tokens_.size()) cur_++;
  return t;
}

bool Parser::match(TokenKind k) {
  if (check(k)) {
    advance();
    return true;
  }
  return false;
}

bool Parser::expect(TokenKind k, const char* what) {
  if (check(k)) {
    advance();
    return true;
  }
  errorHere(std::string("expected ") + what);
  return false;
}

void Parser::errorHere(const std::string& msg) { errorAt(msg, peek().line, peek().col); }

void Parser::errorAt(const std::string& msg, int line, int col) {
  errors_.push_back(ParseError{file_ + ":" + std::to_string(line) + ":" + std::to_string(col) +
                                   ": " + msg,
                               line, col});
}

std::unique_ptr<Program> Parser::parse() {
  auto program = std::make_unique<Program>();
  program->file = file_;
  while (!check(TokenKind::Eof)) {
    if (check(TokenKind::KwUsing)) {
      advance();
      std::string ns;
      while (checkName()) {
        if (!ns.empty()) ns += ".";
        ns += advance().text;
        if (match(TokenKind::Dot)) continue;
        break;
      }
      expect(TokenKind::Semi, "';' after using directive");
      program->usings.push_back(ns);
      continue;
    }
    program->decls.push_back(parseTopLevel());
  }
  return program;
}

Decl Parser::parseTopLevel() {
  switch (peek().kind) {
    case TokenKind::KwComponent: return parseComponent();
    case TokenKind::KwSystem: return parseSystem();
    case TokenKind::KwTag: return parseTag();
    case TokenKind::KwStruct: return parseStruct();
    case TokenKind::KwEnum: return parseEnum();
    case TokenKind::KwConst: return parseConst();
    case TokenKind::KwVoid:
    case TokenKind::KwVar:
    case TokenKind::KwInt:
      return parseFunction();
    default:
      errorHere("expected a top-level declaration");
      advance();
      return Decl{};
  }
}

Decl Parser::parseComponent() {
  Decl d;
  d.kind = Decl::Kind::Component;
  const Token& start = advance();
  d.loc = SourceLoc{start.line, start.col};
  if (!expect(TokenKind::Identifier, "component name")) return d;
  d.name = tokens_[cur_ - 1].text;
  if (!expect(TokenKind::LBrace, "'{' after component name")) return d;
  while (!check(TokenKind::RBrace) && !check(TokenKind::Eof)) {
    if (!match(TokenKind::KwVar)) {
      errorHere("expected 'var' in component field");
      break;
    }
    if (!expect(TokenKind::Identifier, "field name")) break;
    std::string fname = tokens_[cur_ - 1].text;
    if (!expect(TokenKind::Assign, "'=' in field default")) break;
    d.fields.emplace_back(fname, parseExpression());
    expect(TokenKind::Semi, "';' after field");
  }
  expect(TokenKind::RBrace, "'}' to close component");
  return d;
}

Decl Parser::parseSystem() {
  Decl d;
  d.kind = Decl::Kind::System;
  const Token& start = advance();
  d.loc = SourceLoc{start.line, start.col};
  if (!expect(TokenKind::Identifier, "system name")) return d;
  d.name = tokens_[cur_ - 1].text;

  for (;;) {
    if (check(TokenKind::KwWith)) {
      advance();
      if (expect(TokenKind::LParen, "'(' after with")) {
        while (checkName() && !check(TokenKind::RParen)) {
          d.withList.push_back(advance().text);
          if (!match(TokenKind::Comma)) break;
        }
        expect(TokenKind::RParen, "')' after with list");
      }
      continue;
    }
    if (check(TokenKind::KwWithout)) {
      advance();
      if (expect(TokenKind::LParen, "'(' after without")) {
        while (checkName() && !check(TokenKind::RParen)) {
          d.withoutList.push_back(advance().text);
          if (!match(TokenKind::Comma)) break;
        }
        expect(TokenKind::RParen, "')' after without list");
      }
      continue;
    }
    break;
  }

  while (check(TokenKind::LBracket)) {
    advance();
    Attribute attr;
    if (checkName()) attr.name = advance().text;
    if (match(TokenKind::LParen)) {
      while (!check(TokenKind::RParen) && !check(TokenKind::Eof)) {
        attr.args.push_back(parseExpression());
        if (!match(TokenKind::Comma)) break;
      }
      expect(TokenKind::RParen, "')' after attribute args");
    }
    expect(TokenKind::RBracket, "']' to close attribute");
    d.attributes.push_back(std::move(attr));
  }

  d.body = parseBlock();
  return d;
}

Decl Parser::parseTag() {
  Decl d;
  d.kind = Decl::Kind::Tag;
  const Token& start = advance();
  d.loc = SourceLoc{start.line, start.col};
  if (!expect(TokenKind::Identifier, "tag name")) return d;
  d.name = tokens_[cur_ - 1].text;
  if (match(TokenKind::Colon)) {
    if (expect(TokenKind::Identifier, "parent tag name")) d.parentTag = tokens_[cur_ - 1].text;
  }
  expect(TokenKind::Semi, "';' after tag");
  return d;
}

Decl Parser::parseStruct() {
  Decl d;
  d.kind = Decl::Kind::Struct;
  const Token& start = advance();
  d.loc = SourceLoc{start.line, start.col};
  if (!expect(TokenKind::Identifier, "struct name")) return d;
  d.name = tokens_[cur_ - 1].text;
  if (!expect(TokenKind::LBrace, "'{' after struct name")) return d;
  while (!check(TokenKind::RBrace) && !check(TokenKind::Eof)) {
    if (!match(TokenKind::KwVar)) {
      errorHere("expected 'var' in struct field");
      break;
    }
    if (!expect(TokenKind::Identifier, "field name")) break;
    std::string fname = tokens_[cur_ - 1].text;
    if (!expect(TokenKind::Assign, "'=' in field default")) break;
    d.fields.emplace_back(fname, parseExpression());
    expect(TokenKind::Semi, "';' after field");
  }
  expect(TokenKind::RBrace, "'}' to close struct");
  return d;
}

Decl Parser::parseEnum() {
  Decl d;
  d.kind = Decl::Kind::Enum;
  const Token& start = advance();
  d.loc = SourceLoc{start.line, start.col};
  if (!expect(TokenKind::Identifier, "enum name")) return d;
  d.name = tokens_[cur_ - 1].text;
  if (!expect(TokenKind::LBrace, "'{' after enum name")) return d;
  while (checkName() && !check(TokenKind::RBrace)) {
    d.enumMembers.push_back(advance().text);
    if (!match(TokenKind::Comma)) break;
  }
  expect(TokenKind::RBrace, "'}' to close enum");
  return d;
}

Decl Parser::parseConst() {
  Decl d;
  d.kind = Decl::Kind::Const;
  const Token& start = advance();
  d.loc = SourceLoc{start.line, start.col};
  if (!expect(TokenKind::Identifier, "const name")) return d;
  d.name = tokens_[cur_ - 1].text;
  if (!expect(TokenKind::Assign, "'=' in const")) return d;
  d.constValue = parseExpression();
  expect(TokenKind::Semi, "';' after const");
  return d;
}

Decl Parser::parseFunction() {
  Decl d;
  d.kind = Decl::Kind::Function;
  const Token& start = advance();
  d.loc = SourceLoc{start.line, start.col};
  d.retKind = start.text;
  if (!expect(TokenKind::Identifier, "function name")) return d;
  d.name = tokens_[cur_ - 1].text;
  if (!expect(TokenKind::LParen, "'(' after function name")) return d;
  while (checkName() && !check(TokenKind::RParen)) {
    d.params.push_back(advance().text);
    if (!match(TokenKind::Comma)) break;
  }
  expect(TokenKind::RParen, "')' after parameters");
  d.body = parseBlock();
  return d;
}

StmtPtr Parser::parseBlock() {
  auto s = std::make_unique<Stmt>();
  s->kind = Stmt::Kind::Block;
  s->loc = SourceLoc{peek().line, peek().col};
  if (!expect(TokenKind::LBrace, "'{' to start block")) return s;
  while (!check(TokenKind::RBrace) && !check(TokenKind::Eof)) {
    s->body.push_back(parseStatement());
  }
  expect(TokenKind::RBrace, "'}' to close block");
  return s;
}

StmtPtr Parser::parseStatement() {
  switch (peek().kind) {
    case TokenKind::LBrace: return parseBlock();
    case TokenKind::KwVar: return parseVarDecl();
    case TokenKind::KwIf: return parseIf();
    case TokenKind::KwWhile: return parseWhile();
    case TokenKind::KwFor: return parseFor();
    case TokenKind::KwForeach: return parseForeach();
    case TokenKind::KwReturn: return parseReturn();
    case TokenKind::KwSwitch: return parseSwitch();
    case TokenKind::KwBreak: {
      auto s = std::make_unique<Stmt>();
      s->kind = Stmt::Kind::Break;
      s->loc = SourceLoc{peek().line, peek().col};
      advance();
      expect(TokenKind::Semi, "';' after break");
      return s;
    }
    case TokenKind::KwContinue: {
      auto s = std::make_unique<Stmt>();
      s->kind = Stmt::Kind::Continue;
      s->loc = SourceLoc{peek().line, peek().col};
      advance();
      expect(TokenKind::Semi, "';' after continue");
      return s;
    }
    case TokenKind::KwAttach: return parseAttach();
    case TokenKind::KwDetach: return parseDetach();
    case TokenKind::KwDespawn: return parseDespawn();
    default: {
      auto s = std::make_unique<Stmt>();
      s->kind = Stmt::Kind::Expr;
      s->loc = SourceLoc{peek().line, peek().col};
      s->value = parseExpression();
      expect(TokenKind::Semi, "';' after expression");
      return s;
    }
  }
}

StmtPtr Parser::parseVarDecl() {
  auto s = std::make_unique<Stmt>();
  s->kind = Stmt::Kind::VarDecl;
  s->loc = SourceLoc{peek().line, peek().col};
  advance();
  if (!expect(TokenKind::Identifier, "variable name")) return s;
  s->varName = tokens_[cur_ - 1].text;
  if (!expect(TokenKind::Assign, "'=' in variable declaration")) return s;
  s->initExpr = parseExpression();
  expect(TokenKind::Semi, "';' after variable declaration");
  return s;
}

StmtPtr Parser::parseIf() {
  auto s = std::make_unique<Stmt>();
  s->kind = Stmt::Kind::If;
  s->loc = SourceLoc{peek().line, peek().col};
  advance();
  if (expect(TokenKind::LParen, "'(' after if")) {
    s->cond = parseExpression();
    expect(TokenKind::RParen, "')' after if condition");
  }
  s->thenStmt = parseStatement();
  if (match(TokenKind::KwElse)) {
    if (check(TokenKind::KwIf)) {
      s->elseStmt = parseIf();
    } else {
      s->elseStmt = parseStatement();
    }
  }
  return s;
}

StmtPtr Parser::parseWhile() {
  auto s = std::make_unique<Stmt>();
  s->kind = Stmt::Kind::While;
  s->loc = SourceLoc{peek().line, peek().col};
  advance();
  if (expect(TokenKind::LParen, "'(' after while")) {
    s->cond = parseExpression();
    expect(TokenKind::RParen, "')' after while condition");
  }
  s->bodyStmt = parseStatement();
  return s;
}

StmtPtr Parser::parseFor() {
  auto s = std::make_unique<Stmt>();
  s->kind = Stmt::Kind::For;
  s->loc = SourceLoc{peek().line, peek().col};
  advance();
  if (!expect(TokenKind::LParen, "'(' after for")) return s;
  if (!check(TokenKind::Semi)) {
    if (check(TokenKind::KwVar)) {
      auto init = std::make_unique<Stmt>();
      init->kind = Stmt::Kind::VarDecl;
      advance();
      if (expect(TokenKind::Identifier, "loop variable name")) init->varName = tokens_[cur_ - 1].text;
      if (expect(TokenKind::Assign, "'=' in loop init")) init->initExpr = parseExpression();
      s->initStmt = std::move(init);
    } else {
      s->initExpr = parseExpression();
    }
  }
  expect(TokenKind::Semi, "';' after for init");
  if (!check(TokenKind::Semi)) s->cond = parseExpression();
  expect(TokenKind::Semi, "';' after for condition");
  if (!check(TokenKind::RParen)) s->inc = parseExpression();
  expect(TokenKind::RParen, "')' after for clauses");
  s->bodyStmt = parseStatement();
  return s;
}

StmtPtr Parser::parseForeach() {
  auto s = std::make_unique<Stmt>();
  s->kind = Stmt::Kind::Foreach;
  s->loc = SourceLoc{peek().line, peek().col};
  advance();
  if (expect(TokenKind::LParen, "'(' after foreach")) {
    if (match(TokenKind::KwVar)) {
      if (expect(TokenKind::Identifier, "loop variable name")) s->varName = tokens_[cur_ - 1].text;
    }
    if (!expect(TokenKind::KwIn, "'in' in foreach")) return s;
    s->container = parseExpression();
    expect(TokenKind::RParen, "')' after foreach container");
  }
  s->bodyStmt = parseStatement();
  return s;
}

StmtPtr Parser::parseReturn() {
  auto s = std::make_unique<Stmt>();
  s->kind = Stmt::Kind::Return;
  s->loc = SourceLoc{peek().line, peek().col};
  advance();
  if (!check(TokenKind::Semi)) s->value = parseExpression();
  expect(TokenKind::Semi, "';' after return");
  return s;
}

StmtPtr Parser::parseSwitch() {
  auto s = std::make_unique<Stmt>();
  s->kind = Stmt::Kind::Switch;
  s->loc = SourceLoc{peek().line, peek().col};
  advance();
  if (expect(TokenKind::LParen, "'(' after switch")) {
    s->cond = parseExpression();
    expect(TokenKind::RParen, "')' after switch condition");
  }
  if (!expect(TokenKind::LBrace, "'{' to start switch")) return s;
  bool sawDefault = false;
  while (!check(TokenKind::RBrace) && !check(TokenKind::Eof)) {
    Stmt::SwitchCase sc;
    if (check(TokenKind::KwCase)) {
      while (match(TokenKind::KwCase)) {
        sc.values.push_back(parseExpression());
        if (!match(TokenKind::Comma)) break;
      }
      if (!expect(TokenKind::Colon, "':' after case value")) return s;
    } else if (check(TokenKind::KwDefault)) {
      if (sawDefault) {
        errorHere("duplicate 'default' in switch");
        return s;
      }
      sawDefault = true;
      advance();
      if (!expect(TokenKind::Colon, "':' after default")) return s;
    } else {
      errorHere("expected 'case' or 'default' in switch");
      return s;
    }
    auto block = std::make_unique<Stmt>();
    block->kind = Stmt::Kind::Block;
    block->loc = SourceLoc{peek().line, peek().col};
    while (!check(TokenKind::KwCase) && !check(TokenKind::KwDefault) &&
           !check(TokenKind::RBrace) && !check(TokenKind::Eof)) {
      block->body.push_back(parseStatement());
    }
    sc.body = std::move(block);
    s->switchCases.push_back(std::move(sc));
  }
  expect(TokenKind::RBrace, "'}' to close switch");
  return s;
}

StmtPtr Parser::parseAttach() {
  auto s = std::make_unique<Stmt>();
  s->kind = Stmt::Kind::Attach;
  s->loc = SourceLoc{peek().line, peek().col};
  advance();
  if (!expect(TokenKind::LParen, "'(' after attach")) return s;
  s->target = parseExpression();
  if (!expect(TokenKind::Comma, "',' between target and component")) return s;
  match(TokenKind::KwNew);
  s->attachInit = parseComponentInit();
  expect(TokenKind::RParen, "')' after attach");
  expect(TokenKind::Semi, "';' after attach");
  return s;
}

StmtPtr Parser::parseDetach() {
  auto s = std::make_unique<Stmt>();
  s->kind = Stmt::Kind::Detach;
  s->loc = SourceLoc{peek().line, peek().col};
  advance();
  if (!expect(TokenKind::LParen, "'(' after detach")) return s;
  s->target = parseExpression();
  if (!expect(TokenKind::Comma, "',' between target and component type")) return s;
  if (expect(TokenKind::Identifier, "component type name")) s->detachType = tokens_[cur_ - 1].text;
  expect(TokenKind::RParen, "')' after detach");
  expect(TokenKind::Semi, "';' after detach");
  return s;
}

StmtPtr Parser::parseDespawn() {
  auto s = std::make_unique<Stmt>();
  s->kind = Stmt::Kind::Despawn;
  s->loc = SourceLoc{peek().line, peek().col};
  advance();
  s->target = parseExpression();
  expect(TokenKind::Semi, "';' after despawn");
  return s;
}

ExprPtr Parser::parseExpression() { return parseAssignment(); }

ExprPtr Parser::parseAssignment() {
  auto lhs = parseTernary();
  switch (peek().kind) {
    case TokenKind::Assign:
    case TokenKind::PlusEq:
    case TokenKind::MinusEq:
    case TokenKind::StarEq:
    case TokenKind::SlashEq:
    case TokenKind::PercentEq: {
      AssignOp op = AssignOp::Assign;
      switch (peek().kind) {
        case TokenKind::Assign: op = AssignOp::Assign; break;
        case TokenKind::PlusEq: op = AssignOp::Add; break;
        case TokenKind::MinusEq: op = AssignOp::Sub; break;
        case TokenKind::StarEq: op = AssignOp::Mul; break;
        case TokenKind::SlashEq: op = AssignOp::Div; break;
        case TokenKind::PercentEq: op = AssignOp::Mod; break;
        default: break;
      }
      auto e = std::make_unique<Expr>();
      e->kind = Expr::Kind::Assign;
      e->loc = SourceLoc{peek().line, peek().col};
      e->asOp = op;
      e->lhs = std::move(lhs);
      advance();
      e->rhs = parseAssignment();
      return e;
    }
    default:
      return lhs;
  }
}

ExprPtr Parser::parseTernary() {
  auto cond = parseLogicalOr();
  if (match(TokenKind::QMark)) {
    auto e = std::make_unique<Expr>();
    e->kind = Expr::Kind::Ternary;
    e->loc = SourceLoc{peek().line, peek().col};
    e->lhs = std::move(cond);
    e->mid = parseExpression();
    if (!expect(TokenKind::Colon, "':' in ternary")) return e;
    e->rhs = parseTernary();
    return e;
  }
  return cond;
}

ExprPtr Parser::parseLogicalOr() {
  auto lhs = parseLogicalAnd();
  while (match(TokenKind::PipePipe)) {
    auto e = std::make_unique<Expr>();
    e->kind = Expr::Kind::Binary;
    e->binOp = BinaryOp::Or;
    e->loc = SourceLoc{peek().line, peek().col};
    e->lhs = std::move(lhs);
    e->rhs = parseLogicalAnd();
    lhs = std::move(e);
  }
  return lhs;
}

ExprPtr Parser::parseLogicalAnd() {
  auto lhs = parseEquality();
  while (match(TokenKind::AmpAmp)) {
    auto e = std::make_unique<Expr>();
    e->kind = Expr::Kind::Binary;
    e->binOp = BinaryOp::And;
    e->loc = SourceLoc{peek().line, peek().col};
    e->lhs = std::move(lhs);
    e->rhs = parseEquality();
    lhs = std::move(e);
  }
  return lhs;
}

ExprPtr Parser::parseEquality() {
  auto lhs = parseRelational();
  for (;;) {
    BinaryOp op;
    if (match(TokenKind::EqEq)) op = BinaryOp::Eq;
    else if (match(TokenKind::BangEq)) op = BinaryOp::Ne;
    else break;
    auto e = std::make_unique<Expr>();
    e->kind = Expr::Kind::Binary;
    e->binOp = op;
    e->loc = SourceLoc{peek().line, peek().col};
    e->lhs = std::move(lhs);
    e->rhs = parseRelational();
    lhs = std::move(e);
  }
  return lhs;
}

ExprPtr Parser::parseRelational() {
  auto lhs = parseAdditive();
  for (;;) {
    BinaryOp op;
    if (match(TokenKind::Lt)) op = BinaryOp::Lt;
    else if (match(TokenKind::Gt)) op = BinaryOp::Gt;
    else if (match(TokenKind::LtEq)) op = BinaryOp::Le;
    else if (match(TokenKind::GtEq)) op = BinaryOp::Ge;
    else break;
    auto e = std::make_unique<Expr>();
    e->kind = Expr::Kind::Binary;
    e->binOp = op;
    e->loc = SourceLoc{peek().line, peek().col};
    e->lhs = std::move(lhs);
    e->rhs = parseAdditive();
    lhs = std::move(e);
  }
  return lhs;
}

ExprPtr Parser::parseAdditive() {
  auto lhs = parseMultiplicative();
  for (;;) {
    BinaryOp op;
    if (match(TokenKind::Plus)) op = BinaryOp::Add;
    else if (match(TokenKind::Minus)) op = BinaryOp::Sub;
    else break;
    auto e = std::make_unique<Expr>();
    e->kind = Expr::Kind::Binary;
    e->binOp = op;
    e->loc = SourceLoc{peek().line, peek().col};
    e->lhs = std::move(lhs);
    e->rhs = parseMultiplicative();
    lhs = std::move(e);
  }
  return lhs;
}

ExprPtr Parser::parseMultiplicative() {
  auto lhs = parseUnary();
  for (;;) {
    BinaryOp op;
    if (match(TokenKind::Star)) op = BinaryOp::Mul;
    else if (match(TokenKind::Slash)) op = BinaryOp::Div;
    else if (match(TokenKind::Percent)) op = BinaryOp::Mod;
    else break;
    auto e = std::make_unique<Expr>();
    e->kind = Expr::Kind::Binary;
    e->binOp = op;
    e->loc = SourceLoc{peek().line, peek().col};
    e->lhs = std::move(lhs);
    e->rhs = parseUnary();
    lhs = std::move(e);
  }
  return lhs;
}

ExprPtr Parser::parseUnary() {
  if (match(TokenKind::KwExact)) {
    auto e = std::make_unique<Expr>();
    e->kind = Expr::Kind::Unary;
    e->unOp = UnaryOp::Exact;
    e->loc = SourceLoc{peek().line, peek().col};
    e->lhs = parseUnary();
    return e;
  }
  if (match(TokenKind::Bang)) {
    auto e = std::make_unique<Expr>();
    e->kind = Expr::Kind::Unary;
    e->unOp = UnaryOp::Not;
    e->loc = SourceLoc{peek().line, peek().col};
    e->lhs = parseUnary();
    return e;
  }
  if (match(TokenKind::Minus)) {
    auto e = std::make_unique<Expr>();
    e->kind = Expr::Kind::Unary;
    e->unOp = UnaryOp::Neg;
    e->loc = SourceLoc{peek().line, peek().col};
    e->lhs = parseUnary();
    return e;
  }
  return parsePostfix();
}

ExprPtr Parser::parsePostfix() {
  auto e = parsePrimary();

  for (;;) {
    if (match(TokenKind::Dot)) {
      if (!checkName()) {
        errorHere("expected member name after '.'");
        return e;
      }
      auto m = std::make_unique<Expr>();
      m->kind = Expr::Kind::MemberAccess;
      m->loc = SourceLoc{peek().line, peek().col};
      m->lhs = std::move(e);
      m->member = advance().text;
      e = std::move(m);
      continue;
    }

    if (check(TokenKind::Lt)) {
      std::vector<std::string> typeArgs;
      size_t save = cur_;
      if (tryParseTypeArgs(typeArgs) && check(TokenKind::LParen)) {
        e = parseCall(std::move(e), std::move(typeArgs));
        continue;
      }
      cur_ = save;
      return e;
    }

    if (check(TokenKind::LParen)) {
      e = parseCall(std::move(e), {});
      continue;
    }

    if (match(TokenKind::KwIs)) {
      auto is = std::make_unique<Expr>();
      is->kind = Expr::Kind::Is;
      is->loc = SourceLoc{peek().line, peek().col};
      is->lhs = std::move(e);
      if (!checkName()) {
        errorHere("expected type name after 'is'");
        return is;
      }
      is->patternType = advance().text;
      if (check(TokenKind::Identifier)) is->patternVar = advance().text;
      e = std::move(is);
      continue;
    }

    if (match(TokenKind::PlusPlus) || match(TokenKind::MinusMinus)) {
      auto u = std::make_unique<Expr>();
      u->kind = Expr::Kind::Unary;
      u->unOp = tokens_[cur_ - 1].kind == TokenKind::PlusPlus ? UnaryOp::PostInc
                                                              : UnaryOp::PostDec;
      u->loc = SourceLoc{peek().line, peek().col};
      u->lhs = std::move(e);
      e = std::move(u);
      continue;
    }

    return e;
  }
}

ExprPtr Parser::parseCall(ExprPtr base, std::vector<std::string> typeArgs) {
  auto call = std::make_unique<Expr>();
  call->kind = Expr::Kind::Call;
  call->loc = SourceLoc{peek().line, peek().col};
  call->lhs = std::move(base);
  call->typeArgs = std::move(typeArgs);
  if (!expect(TokenKind::LParen, "'('")) return call;
  while (!check(TokenKind::RParen) && !check(TokenKind::Eof)) {
    CallArg arg;
    if (isNameToken(peek()) && peekAt(1).kind == TokenKind::Colon) {
      arg.name = advance().text;
      advance();
    }
    arg.value = parseExpression();
    call->args.push_back(std::move(arg));
    if (!match(TokenKind::Comma)) break;
  }
  expect(TokenKind::RParen, "')'");
  return call;
}

bool Parser::tryParseTypeArgs(std::vector<std::string>& out) {
  size_t save = cur_;
  if (!match(TokenKind::Lt)) return false;
  while (checkName() && !check(TokenKind::Gt)) {
    out.push_back(advance().text);
    if (!match(TokenKind::Comma)) break;
  }
  if (!match(TokenKind::Gt)) {
    cur_ = save;
    out.clear();
    return false;
  }
  return true;
}

ComponentInit Parser::parseComponentInit() {
  ComponentInit ci;
  if (!expect(TokenKind::Identifier, "component type name")) return ci;
  ci.type = tokens_[cur_ - 1].text;
  if (!expect(TokenKind::LBrace, "'{' after component type")) return ci;
  while (!check(TokenKind::RBrace) && !check(TokenKind::Eof)) {
    if (!checkName()) break;
    std::string fname = advance().text;
    if (!expect(TokenKind::Assign, "'=' in component initializer")) break;
    ci.fields.emplace_back(fname, parseExpression());
    if (!match(TokenKind::Comma)) break;
  }
  expect(TokenKind::RBrace, "'}' to close component initializer");
  return ci;
}

ExprPtr Parser::parsePrimary() {
  SourceLoc loc{peek().line, peek().col};
  switch (peek().kind) {
    case TokenKind::IntLiteral: {
      auto e = Expr::makeInt(peek().intValue, loc);
      advance();
      return e;
    }
    case TokenKind::FloatLiteral: {
      auto e = Expr::makeFloat(peek().floatValue, peek().isFloat, loc);
      advance();
      return e;
    }
    case TokenKind::StringLiteral: {
      auto e = Expr::makeString(peek().text, loc);
      advance();
      return e;
    }
    case TokenKind::DollarString: {
      Token t = peek();
      advance();
      return parseInterpolated(t);
    }
    case TokenKind::KwTrue:
      advance();
      return Expr::makeBool(true, loc);
    case TokenKind::KwFalse:
      advance();
      return Expr::makeBool(false, loc);
    case TokenKind::Identifier: {
      if (peekAt(1).kind == TokenKind::LBrace) {
        auto e = std::make_unique<Expr>();
        e->kind = Expr::Kind::StructInit;
        e->loc = SourceLoc{peek().line, peek().col};
        e->structInit = parseComponentInit();
        return e;
      }
      auto e = Expr::makeIdentifier(peek().text, loc);
      advance();
      return e;
    }
    case TokenKind::KwSelf: {
      auto e = Expr::makeIdentifier("self", loc);
      advance();
      return e;
    }
    case TokenKind::KwSpawn: {
      advance();
      auto e = std::make_unique<Expr>();
      e->kind = Expr::Kind::Spawn;
      e->loc = SourceLoc{peek().line, peek().col};
      if (!expect(TokenKind::LBrace, "'{' after spawn")) return e;
      while (!check(TokenKind::RBrace) && !check(TokenKind::Eof)) {
        if (check(TokenKind::KwTags)) {
          advance();
          if (expect(TokenKind::LBracket, "'[' after tags")) {
            while (checkName() && !check(TokenKind::RBracket)) {
              e->spawnTags.push_back(advance().text);
              if (!match(TokenKind::Comma)) break;
            }
            expect(TokenKind::RBracket, "']' to close tags");
          }
        } else {
          e->spawnInits.push_back(parseComponentInit());
        }
        if (!match(TokenKind::Comma)) break;
      }
      expect(TokenKind::RBrace, "'}' to close spawn");
      return e;
    }
    case TokenKind::LParen: {
      advance();
      auto inner = parseExpression();
      expect(TokenKind::RParen, "')' after expression");
      return inner;
    }
    default:
      errorHere("expected an expression");
      advance();
      return Expr::makeInt(0, loc);
  }
}

ExprPtr Parser::parseInterpolated(const Token& dollar) {
  auto e = std::make_unique<Expr>();
  e->kind = Expr::Kind::Interpolated;
  e->loc = SourceLoc{dollar.line, dollar.col};

  std::string literal;
  const std::string& content = dollar.text;
  size_t i = 0;
  while (i < content.size()) {
    char c = content[i];
    if (c == '{') {
      size_t depth = 1;
      size_t j = i + 1;
      std::string inner;
      while (j < content.size() && depth > 0) {
        char d = content[j];
        if (d == '{') depth++;
        else if (d == '}') depth--;
        if (depth > 0) inner += d;
        j++;
      }
      if (depth != 0) {
        errorAt("unterminated interpolation expression", dollar.line, dollar.col);
        break;
      }
      e->interpText.push_back(literal);
      literal.clear();
      Lexer sub(inner, file_);
      auto toks = sub.tokenize();
      if (!sub.ok()) {
        for (const auto& err : sub.errors()) errorAt(err.message, dollar.line, dollar.col);
        e->interpExprs.push_back(Expr::makeString("", SourceLoc{dollar.line, dollar.col}));
      } else {
        std::vector<Token> saved = std::move(tokens_);
        size_t savedCur = cur_;
        tokens_ = std::move(toks);
        cur_ = 0;
        e->interpExprs.push_back(parseExpression());
        tokens_ = std::move(saved);
        cur_ = savedCur;
      }
      i = j;
    } else {
      literal += c;
      i++;
    }
  }
  e->interpText.push_back(literal);
  return e;
}

std::unique_ptr<Program> parseSource(const std::string& source, const std::string& file,
                                     std::vector<ParseError>* errors) {
  Lexer lexer(source, file);
  auto toks = lexer.tokenize();
  if (!lexer.ok()) {
    if (errors) {
      for (const auto& e : lexer.errors()) {
        errors->push_back(ParseError{e.message, e.line, e.col});
      }
    }
    return nullptr;
  }
  Parser parser(std::move(toks), file);
  auto program = parser.parse();
  if (errors) *errors = parser.errors();
  return parser.ok() ? std::move(program) : nullptr;
}

}  // namespace kx