#include "clone.h"

#include <utility>

namespace kx {

namespace {

ExprPtr cloneExpr(const Expr& e);
StmtPtr cloneStmt(const Stmt& s);

ComponentInit cloneComponentInit(const ComponentInit& ci) {
  ComponentInit out;
  out.type = ci.type;
  for (const auto& f : ci.fields) {
    out.fields.emplace_back(f.first, cloneExpr(*f.second));
  }
  return out;
}

ExprPtr cloneExpr(const Expr& e) {
  auto n = std::make_unique<Expr>();
  n->kind = e.kind;
  n->loc = e.loc;
  n->intValue = e.intValue;
  n->floatValue = e.floatValue;
  n->isFloat = e.isFloat;
  n->isLong = e.isLong;
  n->str = e.str;
  n->member = e.member;
  n->binOp = e.binOp;
  n->unOp = e.unOp;
  n->asOp = e.asOp;
  n->patternType = e.patternType;
  n->patternVar = e.patternVar;
  n->spawnTags = e.spawnTags;
  n->interpText = e.interpText;
  n->typeArgs = e.typeArgs;
  if (e.lhs) n->lhs = cloneExpr(*e.lhs);
  if (e.rhs) n->rhs = cloneExpr(*e.rhs);
  if (e.mid) n->mid = cloneExpr(*e.mid);
  for (const auto& a : e.args) {
    CallArg ca;
    ca.name = a.name;
    ca.value = cloneExpr(*a.value);
    n->args.push_back(std::move(ca));
  }
  for (const auto& s : e.interpExprs) n->interpExprs.push_back(cloneExpr(*s));
  for (const auto& ci : e.spawnInits) n->spawnInits.push_back(cloneComponentInit(ci));
  n->structInit = cloneComponentInit(e.structInit);
  return n;
}

StmtPtr cloneStmt(const Stmt& s) {
  auto n = std::make_unique<Stmt>();
  n->kind = s.kind;
  n->loc = s.loc;
  n->varName = s.varName;
  n->detachType = s.detachType;
  n->attachInit = cloneComponentInit(s.attachInit);
  for (const auto& st : s.body) n->body.push_back(cloneStmt(*st));
  for (const auto& sc : s.switchCases) {
    Stmt::SwitchCase nsc;
    for (const auto& v : sc.values) nsc.values.push_back(cloneExpr(*v));
    nsc.body = cloneStmt(*sc.body);
    n->switchCases.push_back(std::move(nsc));
  }
  if (s.thenStmt) n->thenStmt = cloneStmt(*s.thenStmt);
  if (s.elseStmt) n->elseStmt = cloneStmt(*s.elseStmt);
  if (s.bodyStmt) n->bodyStmt = cloneStmt(*s.bodyStmt);
  if (s.initStmt) n->initStmt = cloneStmt(*s.initStmt);
  if (s.cond) n->cond = cloneExpr(*s.cond);
  if (s.inc) n->inc = cloneExpr(*s.inc);
  if (s.initExpr) n->initExpr = cloneExpr(*s.initExpr);
  if (s.value) n->value = cloneExpr(*s.value);
  if (s.container) n->container = cloneExpr(*s.container);
  if (s.target) n->target = cloneExpr(*s.target);
  return n;
}

}  // namespace

std::vector<StmtPtr> cloneStmts(const std::vector<StmtPtr>& body) {
  std::vector<StmtPtr> out;
  for (const auto& s : body) out.push_back(cloneStmt(*s));
  return out;
}

}  // namespace kx