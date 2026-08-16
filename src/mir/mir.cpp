#include "mir.h"

#include <algorithm>

namespace kx {

bool Mir::analyze(const Checker& checker) {
  systems_.clear();
  publishQueries_.clear();
  errors_.clear();

  for (const auto& [name, decl] : checker.systems()) {
    analyzeSystem(*decl, checker);
  }

  return errors_.empty();
}

void Mir::addComponent(const std::string& name, const Checker& c, SystemAnalysis& out) {
  if (!c.components().count(name)) return;
  if (std::find(out.matchComponents.begin(), out.matchComponents.end(), name) ==
      out.matchComponents.end()) {
    out.matchComponents.push_back(name);
  }
}

void Mir::addRead(const std::string& component, const std::string& tag, bool exact) {
  for (auto& s : systems_) {
    for (auto& r : s.reads) {
      if (r.component == component && r.tag == tag && r.exact == exact) return;
    }
  }
  systems_.back().reads.push_back(SystemAnalysis::Read{component, tag, exact});
  auto& tags = publishQueries_[component];
  if (std::find(tags.begin(), tags.end(), tag) == tags.end()) tags.push_back(tag);
}

void Mir::analyzeSystem(const Decl& d, const Checker& c) {
  SystemAnalysis out;
  out.name = d.name;
  for (const auto& w : d.withList) {
    if (std::find(out.matchComponents.begin(), out.matchComponents.end(), w) ==
        out.matchComponents.end()) {
      out.matchComponents.push_back(w);
    }
  }
  out.withoutComponents = d.withoutList;
  systems_.push_back(out);
  if (d.body) {
    for (const auto& s : d.body->body) walkStmt(*s, c, systems_.back());
  }
}

void Mir::walkStmt(const Stmt& s, const Checker& c, SystemAnalysis& out) {
  switch (s.kind) {
    case Stmt::Kind::Block:
      for (const auto& st : s.body) walkStmt(*st, c, out);
      break;
    case Stmt::Kind::VarDecl:
      if (s.initExpr) walkExpr(*s.initExpr, c, out);
      break;
    case Stmt::Kind::Expr:
      if (s.value) walkExpr(*s.value, c, out);
      break;
    case Stmt::Kind::If:
      if (s.cond) walkExpr(*s.cond, c, out);
      if (s.thenStmt) walkStmt(*s.thenStmt, c, out);
      if (s.elseStmt) walkStmt(*s.elseStmt, c, out);
      break;
    case Stmt::Kind::While:
      if (s.cond) walkExpr(*s.cond, c, out);
      if (s.bodyStmt) walkStmt(*s.bodyStmt, c, out);
      break;
    case Stmt::Kind::For:
      if (s.initStmt) walkStmt(*s.initStmt, c, out);
      if (s.initExpr) walkExpr(*s.initExpr, c, out);
      if (s.cond) walkExpr(*s.cond, c, out);
      if (s.inc) walkExpr(*s.inc, c, out);
      if (s.bodyStmt) walkStmt(*s.bodyStmt, c, out);
      break;
    case Stmt::Kind::Foreach:
      if (s.container) walkExpr(*s.container, c, out);
      if (s.bodyStmt) walkStmt(*s.bodyStmt, c, out);
      break;
    case Stmt::Kind::Return:
      if (s.value) walkExpr(*s.value, c, out);
      break;
    case Stmt::Kind::Break:
    case Stmt::Kind::Continue:
      break;
    case Stmt::Kind::Attach:
      if (s.target) walkExpr(*s.target, c, out);
      for (const auto& f : s.attachInit.fields) walkExpr(*f.second, c, out);
      break;
    case Stmt::Kind::Detach:
      if (s.target) walkExpr(*s.target, c, out);
      break;
    case Stmt::Kind::Despawn:
      if (s.target) walkExpr(*s.target, c, out);
      break;
  }
}

void Mir::walkExpr(const Expr& e, const Checker& c, SystemAnalysis& out) {
  switch (e.kind) {
    case Expr::Kind::Identifier:
      addComponent(e.str, c, out);
      break;
    case Expr::Kind::MemberAccess:
      if (e.lhs && e.lhs->kind == Expr::Kind::Identifier) {
        addComponent(e.lhs->str, c, out);
      } else if (e.lhs) {
        walkExpr(*e.lhs, c, out);
      }
      break;
    case Expr::Kind::Call: {
      const Expr* callee = e.lhs.get();
      bool isOthers = callee && callee->kind == Expr::Kind::Identifier &&
                      callee->str == "others";
      if (isOthers) {
        for (const auto& comp : e.typeArgs) {
          bool exact = false;
          std::string tag;
          for (const auto& arg : e.args) {
            if (arg.name == "tag") {
              if (arg.value && arg.value->kind == Expr::Kind::Unary &&
                  arg.value->unOp == UnaryOp::Exact && arg.value->lhs &&
                  arg.value->lhs->kind == Expr::Kind::Identifier) {
                exact = true;
                tag = arg.value->lhs->str;
              } else if (arg.value && arg.value->kind == Expr::Kind::Identifier) {
                tag = arg.value->str;
              }
            }
          }
          addRead(comp, tag, exact);
        }
      } else {
        if (callee) walkExpr(*callee, c, out);
        for (const auto& arg : e.args) walkExpr(*arg.value, c, out);
      }
      break;
    }
    case Expr::Kind::Binary:
      if (e.lhs) walkExpr(*e.lhs, c, out);
      if (e.rhs) walkExpr(*e.rhs, c, out);
      break;
    case Expr::Kind::Unary:
      if (e.lhs) walkExpr(*e.lhs, c, out);
      break;
    case Expr::Kind::Ternary:
      if (e.lhs) walkExpr(*e.lhs, c, out);
      if (e.mid) walkExpr(*e.mid, c, out);
      if (e.rhs) walkExpr(*e.rhs, c, out);
      break;
    case Expr::Kind::Assign:
      if (e.lhs) walkExpr(*e.lhs, c, out);
      if (e.rhs) walkExpr(*e.rhs, c, out);
      break;
    case Expr::Kind::Is:
      if (e.lhs) walkExpr(*e.lhs, c, out);
      break;
    case Expr::Kind::Interpolated:
      for (const auto& seg : e.interpExprs) walkExpr(*seg, c, out);
      break;
    case Expr::Kind::Spawn:
      for (const auto& ci : e.spawnInits) {
        for (const auto& f : ci.fields) walkExpr(*f.second, c, out);
      }
      break;
    case Expr::Kind::StructInit:
      for (const auto& f : e.structInit.fields) walkExpr(*f.second, c, out);
      break;
    case Expr::Kind::IntLit:
    case Expr::Kind::FloatLit:
    case Expr::Kind::StringLit:
    case Expr::Kind::BoolLit:
      break;
  }
}

void dumpMir(const Mir& mir, std::ostream& out) {
  for (const auto& s : mir.systems()) {
    out << "(system " << s.name;
    if (!s.matchComponents.empty()) {
      out << " match:";
      for (const auto& m : s.matchComponents) out << " " << m;
    }
    if (!s.withoutComponents.empty()) {
      out << " without:";
      for (const auto& m : s.withoutComponents) out << " " << m;
    }
    for (const auto& r : s.reads) {
      out << " read:" << r.component << "@" << (r.exact ? "exact " : "") << r.tag;
    }
    out << ")";
  }
  for (const auto& [comp, tags] : mir.publishQueries()) {
    out << "\n(publish " << comp << ":";
    for (const auto& t : tags) out << " " << t;
    out << ")";
  }
}

}  // namespace kx