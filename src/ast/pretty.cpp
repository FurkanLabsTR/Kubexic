#include "pretty.h"

#include <cstdio>
#include <string>

namespace kx {

namespace {

std::string quote(const std::string& s) {
  std::string out = "\"";
  for (char c : s) {
    switch (c) {
      case '\n': out += "\\n"; break;
      case '\t': out += "\\t"; break;
      case '\r': out += "\\r"; break;
      case '\\': out += "\\\\"; break;
      case '"': out += "\\\""; break;
      default: out += c;
    }
  }
  out += "\"";
  return out;
}

void printExpr(const Expr& e, std::ostream& out);

const char* binOpSym(BinaryOp op) {
  switch (op) {
    case BinaryOp::Add: return " + ";
    case BinaryOp::Sub: return " - ";
    case BinaryOp::Mul: return " * ";
    case BinaryOp::Div: return " / ";
    case BinaryOp::Mod: return " % ";
    case BinaryOp::Eq: return " == ";
    case BinaryOp::Ne: return " != ";
    case BinaryOp::Lt: return " < ";
    case BinaryOp::Gt: return " > ";
    case BinaryOp::Le: return " <= ";
    case BinaryOp::Ge: return " >= ";
    case BinaryOp::And: return " && ";
    case BinaryOp::Or: return " || ";
  }
  return " ? ";
}

const char* assignOpSym(AssignOp op) {
  switch (op) {
    case AssignOp::Assign: return " = ";
    case AssignOp::Add: return " += ";
    case AssignOp::Sub: return " -= ";
    case AssignOp::Mul: return " *= ";
    case AssignOp::Div: return " /= ";
    case AssignOp::Mod: return " %= ";
  }
  return " = ";
}

void printComponentInit(const ComponentInit& ci, std::ostream& out) {
  out << ci.type << " { ";
  bool first = true;
  for (const auto& f : ci.fields) {
    if (!first) out << ", ";
    first = false;
    out << f.first << " = ";
    printExpr(*f.second, out);
  }
  out << " }";
}

void printExpr(const Expr& e, std::ostream& out) {
  switch (e.kind) {
    case Expr::Kind::IntLit:
      out << (e.isLong ? std::to_string(e.intValue) + "L" : std::to_string(e.intValue));
      break;
    case Expr::Kind::FloatLit:
      out << (e.isFloat ? std::to_string(e.floatValue) + "f" : std::to_string(e.floatValue));
      break;
    case Expr::Kind::StringLit:
      out << quote(e.str);
      break;
    case Expr::Kind::BoolLit:
      out << (e.intValue ? "true" : "false");
      break;
    case Expr::Kind::Identifier:
      out << e.str;
      break;
    case Expr::Kind::MemberAccess:
      printExpr(*e.lhs, out);
      out << "." << e.member;
      break;
    case Expr::Kind::Call:
      printExpr(*e.lhs, out);
      if (!e.typeArgs.empty()) {
        out << "<";
        for (size_t i = 0; i < e.typeArgs.size(); i++) {
          if (i) out << ", ";
          out << e.typeArgs[i];
        }
        out << ">";
      }
      out << "(";
      for (size_t i = 0; i < e.args.size(); i++) {
        if (i) out << ", ";
        if (!e.args[i].name.empty()) out << e.args[i].name << ": ";
        printExpr(*e.args[i].value, out);
      }
      out << ")";
      break;
    case Expr::Kind::Binary:
      out << "(";
      printExpr(*e.lhs, out);
      out << binOpSym(e.binOp);
      printExpr(*e.rhs, out);
      out << ")";
      break;
    case Expr::Kind::Unary: {
      switch (e.unOp) {
        case UnaryOp::Not: out << "!"; printExpr(*e.lhs, out); break;
        case UnaryOp::Neg: out << "-"; printExpr(*e.lhs, out); break;
        case UnaryOp::Exact: out << "exact "; printExpr(*e.lhs, out); break;
        case UnaryOp::PostInc: printExpr(*e.lhs, out); out << "++"; break;
        case UnaryOp::PostDec: printExpr(*e.lhs, out); out << "--"; break;
      }
      break;
    }
    case Expr::Kind::Ternary:
      out << "(";
      printExpr(*e.lhs, out);
      out << " ? ";
      printExpr(*e.mid, out);
      out << " : ";
      printExpr(*e.rhs, out);
      out << ")";
      break;
    case Expr::Kind::Assign:
      printExpr(*e.lhs, out);
      out << assignOpSym(e.asOp);
      printExpr(*e.rhs, out);
      break;
    case Expr::Kind::Is:
      printExpr(*e.lhs, out);
      out << " is " << e.patternType;
      if (!e.patternVar.empty()) out << " " << e.patternVar;
      break;
    case Expr::Kind::Interpolated: {
      out << "$\"";
      for (size_t i = 0; i < e.interpText.size(); i++) {
        out << e.interpText[i];
        if (i < e.interpExprs.size()) {
          out << "{";
          printExpr(*e.interpExprs[i], out);
          out << "}";
        }
      }
      out << "\"";
      break;
    }
    case Expr::Kind::Spawn: {
      out << "spawn { ";
      bool first = true;
      for (const auto& ci : e.spawnInits) {
        if (!first) out << ", ";
        first = false;
        printComponentInit(ci, out);
      }
      if (!e.spawnTags.empty()) {
        if (!first) out << ", ";
        out << "tags [";
        for (size_t i = 0; i < e.spawnTags.size(); i++) {
          if (i) out << ", ";
          out << e.spawnTags[i];
        }
        out << "]";
      }
      out << " }";
      break;
    }
    case Expr::Kind::StructInit:
      printComponentInit(e.structInit, out);
      break;
  }
}

void printStmt(const Stmt& s, std::ostream& out, int indent);

void indentOut(std::ostream& out, int n) {
  for (int i = 0; i < n; i++) out << "    ";
}

void printBlockBody(const std::vector<StmtPtr>& body, std::ostream& out, int indent) {
  for (const auto& st : body) {
    printStmt(*st, out, indent);
  }
}

void printStmt(const Stmt& s, std::ostream& out, int indent) {
  switch (s.kind) {
    case Stmt::Kind::Block:
      out << "{\n";
      printBlockBody(s.body, out, indent + 1);
      indentOut(out, indent);
      out << "}";
      break;
    case Stmt::Kind::VarDecl:
      indentOut(out, indent);
      out << "var " << s.varName << " = ";
      printExpr(*s.initExpr, out);
      out << ";\n";
      break;
    case Stmt::Kind::Expr:
      indentOut(out, indent);
      printExpr(*s.value, out);
      out << ";\n";
      break;
    case Stmt::Kind::If:
      indentOut(out, indent);
      out << "if (";
      printExpr(*s.cond, out);
      out << ") ";
      printStmt(*s.thenStmt, out, indent);
      if (s.elseStmt) {
        if (s.elseStmt->kind == Stmt::Kind::If) {
          out << " else ";
          printStmt(*s.elseStmt, out, indent);
        } else {
          out << " else ";
          printStmt(*s.elseStmt, out, indent);
        }
      }
      out << "\n";
      break;
    case Stmt::Kind::While:
      indentOut(out, indent);
      out << "while (";
      printExpr(*s.cond, out);
      out << ") ";
      printStmt(*s.bodyStmt, out, indent);
      out << "\n";
      break;
    case Stmt::Kind::For:
      indentOut(out, indent);
      out << "for (";
      if (s.initStmt) {
        out << "var " << s.initStmt->varName << " = ";
        printExpr(*s.initStmt->initExpr, out);
      } else if (s.initExpr) {
        printExpr(*s.initExpr, out);
      }
      out << "; ";
      if (s.cond) printExpr(*s.cond, out);
      out << "; ";
      if (s.inc) printExpr(*s.inc, out);
      out << ") ";
      printStmt(*s.bodyStmt, out, indent);
      out << "\n";
      break;
    case Stmt::Kind::Foreach:
      indentOut(out, indent);
      out << "foreach (var " << s.varName << " in ";
      printExpr(*s.container, out);
      out << ") ";
      printStmt(*s.bodyStmt, out, indent);
      out << "\n";
      break;
    case Stmt::Kind::Return:
      indentOut(out, indent);
      out << "return";
      if (s.value) {
        out << " ";
        printExpr(*s.value, out);
      }
      out << ";\n";
      break;
    case Stmt::Kind::Break:
      indentOut(out, indent);
      out << "break;\n";
      break;
    case Stmt::Kind::Continue:
      indentOut(out, indent);
      out << "continue;\n";
      break;
    case Stmt::Kind::Attach:
      indentOut(out, indent);
      out << "attach(";
      printExpr(*s.target, out);
      out << ", ";
      printComponentInit(s.attachInit, out);
      out << ");\n";
      break;
    case Stmt::Kind::Detach:
      indentOut(out, indent);
      out << "detach(";
      printExpr(*s.target, out);
      out << ", " << s.detachType << ");\n";
      break;
    case Stmt::Kind::Despawn:
      indentOut(out, indent);
      out << "despawn ";
      printExpr(*s.target, out);
      out << ";\n";
      break;
    case Stmt::Kind::Switch:
      indentOut(out, indent);
      out << "switch (";
      printExpr(*s.cond, out);
      out << ") {\n";
      for (const auto& c : s.switchCases) {
        for (const auto& v : c.values) {
          indentOut(out, indent + 1);
          out << "case ";
          printExpr(*v, out);
          out << ":\n";
        }
        if (c.values.empty()) {
          indentOut(out, indent + 1);
          out << "default:\n";
        }
        if (c.body) printBlockBody(c.body->body, out, indent + 2);
      }
      indentOut(out, indent);
      out << "}\n";
      break;
  }
}

void printDecl(const Decl& d, std::ostream& out) {
  switch (d.kind) {
    case Decl::Kind::Component: {
      out << "component " << d.name << " {\n";
      for (const auto& f : d.fields) {
        out << "    var " << f.first << " = ";
        printExpr(*f.second, out);
        out << ";\n";
      }
      out << "}\n\n";
      break;
    }
    case Decl::Kind::System: {
      out << "system " << d.name;
      if (!d.withList.empty()) {
        out << " with (";
        for (size_t i = 0; i < d.withList.size(); i++) {
          if (i) out << ", ";
          out << d.withList[i];
        }
        out << ")";
      }
      if (!d.withoutList.empty()) {
        out << " without (";
        for (size_t i = 0; i < d.withoutList.size(); i++) {
          if (i) out << ", ";
          out << d.withoutList[i];
        }
        out << ")";
      }
      for (const auto& a : d.attributes) {
        out << " [" << a.name;
        if (!a.args.empty()) {
          out << "(";
          for (size_t i = 0; i < a.args.size(); i++) {
            if (i) out << ", ";
            printExpr(*a.args[i], out);
          }
          out << ")";
        }
        out << "]";
      }
      out << " ";
      printStmt(*d.body, out, 0);
      out << "\n\n";
      break;
    }
    case Decl::Kind::Tag:
      out << "tag " << d.name;
      if (!d.parentTag.empty()) out << " : " << d.parentTag;
      out << ";\n\n";
      break;
    case Decl::Kind::Struct: {
      out << "struct " << d.name << " {\n";
      for (const auto& f : d.fields) {
        out << "    var " << f.first << " = ";
        printExpr(*f.second, out);
        out << ";\n";
      }
      out << "}\n\n";
      break;
    }
    case Decl::Kind::Enum: {
      out << "enum " << d.name << " { ";
      for (size_t i = 0; i < d.enumMembers.size(); i++) {
        if (i) out << ", ";
        out << d.enumMembers[i];
      }
      out << " }\n\n";
      break;
    }
    case Decl::Kind::Const:
      out << "const " << d.name << " = ";
      printExpr(*d.constValue, out);
      out << ";\n\n";
      break;
    case Decl::Kind::Function: {
      if (d.isExtern) {
        for (const auto& a : d.attributes) {
          out << "[" << a.name;
          if (!a.args.empty()) {
            out << "(";
            for (size_t i = 0; i < a.args.size(); i++) {
              if (i) out << ", ";
              printExpr(*a.args[i], out);
            }
            out << ")";
          }
          out << "] ";
        }
        out << "extern " << d.retKind << " " << d.name << "(";
        for (size_t i = 0; i < d.params.size(); i++) {
          if (i) out << ", ";
          out << (i < d.paramTypes.size() ? d.paramTypes[i] : "int") << " " << d.params[i];
        }
        out << ");\n\n";
        break;
      }
      out << d.retKind << " " << d.name << "(";
      for (size_t i = 0; i < d.params.size(); i++) {
        if (i) out << ", ";
        out << d.params[i];
      }
      out << ") ";
      printStmt(*d.body, out, 0);
      out << "\n\n";
      break;
    }
  }
}

}  // namespace

void printSource(const Program& program, std::ostream& out) {
  for (const auto& u : program.usings) out << "using " << u << ";\n";
  if (!program.usings.empty()) out << "\n";
  for (const auto& d : program.decls) printDecl(d, out);
}

}  // namespace kx