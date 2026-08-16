#pragma once

#include "token.h"

#include <cstdint>
#include <memory>
#include <ostream>
#include <string>
#include <utility>
#include <vector>

namespace kx {

struct SourceLoc {
  int line = 0;
  int col = 0;
};

struct Expr;
struct Stmt;

using ExprPtr = std::unique_ptr<Expr>;
using StmtPtr = std::unique_ptr<Stmt>;

enum class BinaryOp { Add, Sub, Mul, Div, Mod, Eq, Ne, Lt, Gt, Le, Ge, And, Or };
enum class UnaryOp { Not, Neg, Exact, PostInc, PostDec };
enum class AssignOp { Assign, Add, Sub, Mul, Div, Mod };

struct CallArg {
  std::string name;
  ExprPtr value;
};

struct ComponentInit {
  std::string type;
  std::vector<std::pair<std::string, ExprPtr>> fields;
};

struct Attribute {
  std::string name;
  std::vector<ExprPtr> args;
};

struct Expr {
  enum class Kind {
    IntLit,
    FloatLit,
    StringLit,
    BoolLit,
    Identifier,
    MemberAccess,
    Call,
    Binary,
    Unary,
    Ternary,
    Assign,
    Is,
    Interpolated,
    Spawn,
  };

  Kind kind;
  SourceLoc loc;

  std::int64_t intValue = 0;
  double floatValue = 0.0;
  bool isFloat = false;
  std::string str;
  std::string member;

  ExprPtr lhs;
  ExprPtr rhs;
  ExprPtr mid;

  BinaryOp binOp = BinaryOp::Add;
  UnaryOp unOp = UnaryOp::Not;
  AssignOp asOp = AssignOp::Assign;

  std::vector<CallArg> args;
  std::vector<std::string> typeArgs;

  std::string patternType;
  std::string patternVar;

  std::vector<std::string> interpText;
  std::vector<ExprPtr> interpExprs;

  std::vector<ComponentInit> spawnInits;
  std::vector<std::string> spawnTags;

  static ExprPtr makeInt(std::int64_t v, SourceLoc loc);
  static ExprPtr makeFloat(double v, bool isFloat, SourceLoc loc);
  static ExprPtr makeString(std::string s, SourceLoc loc);
  static ExprPtr makeBool(bool b, SourceLoc loc);
  static ExprPtr makeIdentifier(std::string name, SourceLoc loc);
};

struct Stmt {
  enum class Kind {
    Block,
    VarDecl,
    Expr,
    If,
    While,
    For,
    Foreach,
    Return,
    Break,
    Continue,
    Attach,
    Detach,
    Despawn,
  };

  Kind kind;
  SourceLoc loc;

  std::vector<StmtPtr> body;
  StmtPtr thenStmt;
  StmtPtr elseStmt;
  StmtPtr bodyStmt;
  StmtPtr initStmt;

  ExprPtr cond;
  ExprPtr inc;
  ExprPtr initExpr;
  ExprPtr value;
  ExprPtr container;

  std::string varName;
  std::string detachType;
  ExprPtr target;

  ComponentInit attachInit;
};

struct Decl {
  enum class Kind {
    Component,
    System,
    Tag,
    Struct,
    Enum,
    Const,
    Function,
  };

  Kind kind;
  SourceLoc loc;
  std::string name;

  std::vector<std::pair<std::string, ExprPtr>> fields;
  std::vector<std::string> withList;
  std::vector<std::string> withoutList;
  std::vector<Attribute> attributes;
  StmtPtr body;
  std::vector<std::string> params;
  std::string retKind;
  std::string parentTag;
  std::vector<std::string> enumMembers;
  ExprPtr constValue;
};

struct Program {
  std::string file;
  std::string namespaceName;
  std::vector<std::string> usings;
  std::vector<Decl> decls;
};

void dumpProgram(const Program& program, std::ostream& out);

}  // namespace kx