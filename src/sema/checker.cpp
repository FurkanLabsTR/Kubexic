#include "checker.h"

#include <algorithm>
#include <string>
#include <utility>
#include <vector>

namespace kx {

namespace {

bool isBoolish(const std::shared_ptr<Type>& t) {
  return t->isUnknownish() || t->kind == TypeKind::Bool;
}

bool isEntityIdish(const std::shared_ptr<Type>& t) {
  return t->isUnknownish() || t->kind == TypeKind::EntityId || t->kind == TypeKind::Self;
}

}  // namespace

void Checker::addProgram(std::unique_ptr<Program> program) {
  for (const auto& d : program->decls) declare(d);
  programs_.push_back(std::move(program));
}

void Checker::error(const SourceLoc& loc, const std::string& msg) {
  errors_.push_back(std::to_string(loc.line) + ":" + std::to_string(loc.col) + ": " + msg);
}

void Checker::declare(const Decl& d) {
  auto registerName = [&](const std::string& name) {
    if (components_.count(name) || systems_.count(name) || tags_.count(name) ||
        structs_.count(name) || enums_.count(name) || functions_.count(name)) {
      error(d.loc, "duplicate declaration '" + name + "'");
      return false;
    }
    return true;
  };

  switch (d.kind) {
    case Decl::Kind::Component:
      if (registerName(d.name)) components_[d.name] = &d;
      break;
    case Decl::Kind::System:
      if (registerName(d.name)) systems_[d.name] = &d;
      break;
    case Decl::Kind::Tag:
      if (registerName(d.name)) tags_[d.name] = &d;
      break;
    case Decl::Kind::Struct:
      if (registerName(d.name)) structs_[d.name] = &d;
      break;
    case Decl::Kind::Enum:
      if (registerName(d.name)) enums_[d.name] = &d;
      break;
    case Decl::Kind::Const: {
      if (!registerName(d.name)) break;
      bool ok = true;
      ConstValue v = evalConst(*d.constValue, ok);
      if (!ok) {
        error(d.loc, "const '" + d.name + "' must be a compile-time constant");
        break;
      }
      consts_[d.name] = v;
      break;
    }
    case Decl::Kind::Function:
      if (registerName(d.name)) functions_[d.name] = &d;
      if (d.name == "main") mainSeen_ = true;
      break;
  }
}

bool Checker::check() {
  if (mainSeen_ == false) errors_.push_back("0:0: program must declare exactly one 'main' function");

  for (const auto& [name, tag] : tags_) {
    if (!tag->parentTag.empty() && !tags_.count(tag->parentTag)) {
      error(tag->loc, "tag '" + name + "' extends unknown tag '" + tag->parentTag + "'");
    }
  }

  computeFieldTypes();

  for (auto& [name, d] : systems_) {
    Decl* sys = const_cast<Decl*>(d);
    inSystem_ = true;
    checkSystem(*sys);
    inSystem_ = false;
  }
  for (auto& [name, d] : functions_) {
    Decl* fn = const_cast<Decl*>(d);
    curFnName_ = fn->name;
    checkFunction(*fn);
  }

  return errors_.empty();
}

void Checker::computeFieldTypes() {
  auto compute = [&](const std::map<std::string, const Decl*>& decls,
                     std::map<std::string, std::map<std::string, std::shared_ptr<Type>>>& out) {
    for (const auto& [name, d] : decls) {
      for (const auto& f : d->fields) {
        if (out[name].count(f.first)) {
          error(f.second->loc, "duplicate field '" + f.first + "' in '" + name + "'");
          continue;
        }
        out[name][f.first] = infer(*f.second);
      }
    }
  };
  compute(components_, componentFields_);
  compute(structs_, structFields_);

  for (const auto& [name, d] : enums_) {
    for (const auto& m : d->enumMembers) {
      if (std::count(d->enumMembers.begin(), d->enumMembers.end(), m) > 1) {
        error(d->loc, "duplicate enum member '" + m + "' in '" + name + "'");
      }
    }
  }
}

std::shared_ptr<Type> Checker::typeFromTypeName(const std::string& name, const SourceLoc& loc) {
  if (name == "int") return Type::make(TypeKind::Int);
  if (name == "long") return Type::make(TypeKind::Long);
  if (name == "float") return Type::make(TypeKind::Float);
  if (name == "double") return Type::make(TypeKind::Double);
  if (name == "bool") return Type::make(TypeKind::Bool);
  if (name == "string") return Type::make(TypeKind::String);
  if (name == "byte") return Type::make(TypeKind::Byte);
  if (name == "EntityId") return Type::make(TypeKind::EntityId);
  if (components_.count(name)) return Type::component(name);
  if (structs_.count(name)) return Type::structType(name);
  if (enums_.count(name)) return Type::enumType(name);
  if (tags_.count(name)) return Type::make(TypeKind::EntityId);
  error(loc, "unknown type name '" + name + "'");
  return Type::make(TypeKind::Error);
}

const Decl* Checker::componentByName(const std::string& name) const {
  auto it = components_.find(name);
  return it == components_.end() ? nullptr : it->second;
}

const Decl* Checker::structByName(const std::string& name) const {
  auto it = structs_.find(name);
  return it == structs_.end() ? nullptr : it->second;
}

bool Checker::validateComponentName(const std::string& name, const SourceLoc& loc) {
  if (!componentByName(name)) {
    error(loc, "'" + name + "' is not a component");
    return false;
  }
  return true;
}

void Checker::checkAttributes(const Decl& d) {
  for (const auto& a : d.attributes) {
    if (a.name == "Order") {
      if (a.args.size() != 1 || a.args[0]->kind != Expr::Kind::IntLit) {
        error(d.loc, "[Order] requires one integer argument");
      }
    } else if (a.name == "FastMath") {
      if (!a.args.empty()) error(d.loc, "[FastMath] takes no arguments");
    } else {
      error(d.loc, "unknown attribute '[" + a.name + "]'");
    }
  }
}

const Decl* Checker::functionByName(const std::string& name) const {
  auto it = functions_.find(name);
  return it == functions_.end() ? nullptr : it->second;
}

bool Checker::constValue(const std::string& name, ConstValue* out) const {
  auto it = consts_.find(name);
  if (it == consts_.end()) return false;
  if (out) *out = it->second;
  return true;
}

std::shared_ptr<Type> Checker::reInferBody(
    const std::vector<StmtPtr>& body,
    const std::map<std::string, std::shared_ptr<Type>>& params) {
  size_t mark = errors_.size();
  auto savedRet = curFnRet_;
  auto savedVarRet = varRetType_;
  varRetType_ = nullptr;
  curFnRet_ = "var";
  pushScope();
  for (const auto& [n, t] : params) addLocal(n, t);
  for (const auto& s : body) checkStmt(*s);
  auto result = varRetType_;
  popScope();
  curFnRet_ = savedRet;
  varRetType_ = savedVarRet;
  errors_.resize(mark);
  return result;
}

void Checker::pushScope() { scopes_.emplace_back(); }

void Checker::popScope() { scopes_.pop_back(); }

void Checker::addLocal(const std::string& name, std::shared_ptr<Type> t) {
  if (scopes_.empty()) scopes_.emplace_back();
  scopes_.back().push_back(Local{name, std::move(t)});
}

std::shared_ptr<Type> Checker::lookupLocal(const std::string& name) const {
  for (auto it = scopes_.rbegin(); it != scopes_.rend(); ++it) {
    for (auto vit = it->rbegin(); vit != it->rend(); ++vit) {
      if (vit->name == name) return vit->type;
    }
  }
  return nullptr;
}

std::shared_ptr<Type> Checker::infer(Expr& e) {
  switch (e.kind) {
    case Expr::Kind::IntLit:
      e.type = Type::make(e.isLong ? TypeKind::Long : TypeKind::Int);
      return e.type;
    case Expr::Kind::FloatLit:
      e.type = Type::make(e.isFloat ? TypeKind::Float : TypeKind::Double);
      return e.type;
    case Expr::Kind::StringLit:
      e.type = Type::make(TypeKind::String);
      return e.type;
    case Expr::Kind::BoolLit:
      e.type = Type::make(TypeKind::Bool);
      return e.type;
    case Expr::Kind::Identifier: {
      if (auto local = lookupLocal(e.str)) {
        e.type = local;
        return e.type;
      }
      if (e.str == "self" && inSystem_) {
        e.type = Type::make(TypeKind::Self);
        return e.type;
      }
      if (e.str == "dt" && inSystem_) {
        e.type = Type::make(TypeKind::Double);
        return e.type;
      }
      if (e.str == "tick" && inSystem_) {
        e.type = Type::make(TypeKind::Long);
        return e.type;
      }
      if (components_.count(e.str)) {
        e.type = Type::component(e.str);
        return e.type;
      }
      if (structs_.count(e.str)) {
        e.type = Type::structType(e.str);
        return e.type;
      }
      if (enums_.count(e.str)) {
        e.type = Type::enumType(e.str);
        return e.type;
      }
      if (consts_.count(e.str)) {
        switch (consts_[e.str].kind) {
          case ConstValue::Kind::Int: e.type = Type::make(TypeKind::Int); break;
          case ConstValue::Kind::Float: e.type = Type::make(TypeKind::Double); break;
          case ConstValue::Kind::Bool: e.type = Type::make(TypeKind::Bool); break;
          case ConstValue::Kind::String: e.type = Type::make(TypeKind::String); break;
        }
        return e.type;
      }
      if (e.str == "EntityId") {
        e.type = Type::make(TypeKind::EntityId);
        return e.type;
      }
      error(e.loc, "unknown identifier '" + e.str + "'");
      e.type = Type::make(TypeKind::Error);
      return e.type;
    }
    case Expr::Kind::MemberAccess: {
      Expr* base = e.lhs.get();
      if (base->kind == Expr::Kind::Identifier && base->str == "EntityId") {
        if (e.member == "None") {
          e.type = Type::make(TypeKind::EntityId);
          return e.type;
        }
        error(e.loc, "'EntityId' has no member '" + e.member + "'");
        e.type = Type::make(TypeKind::Error);
        return e.type;
      }
      auto bt = infer(*base);
      switch (bt->kind) {
        case TypeKind::Self:
          if (e.member == "Id") {
            e.type = Type::make(TypeKind::EntityId);
            return e.type;
          }
          error(e.loc, "'self' has no member '" + e.member + "'");
          e.type = Type::make(TypeKind::Error);
          return e.type;
        case TypeKind::Component: {
          auto it = componentFields_.find(bt->name);
          if (it != componentFields_.end() && it->second.count(e.member)) {
            e.type = it->second[e.member];
            return e.type;
          }
          error(e.loc, "component '" + bt->name + "' has no field '" + e.member + "'");
          e.type = Type::make(TypeKind::Error);
          return e.type;
        }
        case TypeKind::Struct: {
          auto it = structFields_.find(bt->name);
          if (it != structFields_.end() && it->second.count(e.member)) {
            e.type = it->second[e.member];
            return e.type;
          }
          error(e.loc, "struct '" + bt->name + "' has no field '" + e.member + "'");
          e.type = Type::make(TypeKind::Error);
          return e.type;
        }
        case TypeKind::Enum: {
          auto it = enums_.find(bt->name);
          if (it != enums_.end() &&
              std::find(it->second->enumMembers.begin(), it->second->enumMembers.end(), e.member) !=
                  it->second->enumMembers.end()) {
            e.type = Type::enumType(bt->name);
            return e.type;
          }
          error(e.loc, "enum '" + bt->name + "' has no member '" + e.member + "'");
          e.type = Type::make(TypeKind::Error);
          return e.type;
        }
        case TypeKind::Snapshot: {
          if (e.member == "Id") {
            e.type = Type::make(TypeKind::EntityId);
            return e.type;
          }
          for (const auto& c : bt->componentNames) {
            if (c == e.member) {
              e.type = Type::component(c);
              return e.type;
            }
          }
          error(e.loc, "snapshot has no member '" + e.member + "'");
          e.type = Type::make(TypeKind::Error);
          return e.type;
        }
        default:
          if (bt->isUnknownish()) {
            e.type = Type::make(TypeKind::Unknown);
            return e.type;
          }
          if (base->kind == Expr::Kind::Identifier && base->str == "std") {
            e.type = Type::make(TypeKind::Unknown);
            return e.type;
          }
          error(e.loc, "cannot access member '" + e.member + "' on " + bt->describe());
          e.type = Type::make(TypeKind::Error);
          return e.type;
      }
    }
    case Expr::Kind::Call:
      return inferCall(e);
    case Expr::Kind::Binary: {
      auto lt = infer(*e.lhs);
      auto rt = infer(*e.rhs);
      switch (e.binOp) {
        case BinaryOp::And:
        case BinaryOp::Or:
          if (!isBoolish(lt) || !isBoolish(rt)) {
            error(e.loc, "logical operator requires bool operands");
            e.type = Type::make(TypeKind::Error);
            return e.type;
          }
          e.type = Type::make(TypeKind::Bool);
          return e.type;
        case BinaryOp::Eq:
        case BinaryOp::Ne:
          if (lt->kind == rt->kind || (lt->isNumeric() && rt->isNumeric()) || lt->isUnknownish() ||
              rt->isUnknownish()) {
            e.type = Type::make(TypeKind::Bool);
            return e.type;
          }
          error(e.loc, "cannot compare " + lt->describe() + " and " + rt->describe());
          e.type = Type::make(TypeKind::Error);
          return e.type;
        case BinaryOp::Lt:
        case BinaryOp::Gt:
        case BinaryOp::Le:
        case BinaryOp::Ge:
          if ((lt->isNumeric() && rt->isNumeric()) || lt->isUnknownish() || rt->isUnknownish()) {
            e.type = Type::make(TypeKind::Bool);
            return e.type;
          }
          error(e.loc, "comparison requires numeric operands");
          e.type = Type::make(TypeKind::Error);
          return e.type;
        case BinaryOp::Add:
          if (lt->kind == TypeKind::String && rt->kind == TypeKind::String) {
            e.type = Type::make(TypeKind::String);
            return e.type;
          }
          if ((lt->isNumeric() && rt->isNumeric()) || lt->isUnknownish() || rt->isUnknownish()) {
            e.type = promote(lt, rt);
            return e.type;
          }
          error(e.loc, "operator '+' requires numeric or two string operands");
          e.type = Type::make(TypeKind::Error);
          return e.type;
        default:
          if ((lt->isNumeric() && rt->isNumeric()) || lt->isUnknownish() || rt->isUnknownish()) {
            e.type = promote(lt, rt);
            return e.type;
          }
          error(e.loc, "arithmetic operator requires numeric operands");
          e.type = Type::make(TypeKind::Error);
          return e.type;
      }
    }
    case Expr::Kind::Unary: {
      auto ot = infer(*e.lhs);
      switch (e.unOp) {
        case UnaryOp::Not:
          if (!isBoolish(ot)) {
            error(e.loc, "'!' requires a bool operand");
            e.type = Type::make(TypeKind::Error);
            return e.type;
          }
          e.type = Type::make(TypeKind::Bool);
          return e.type;
        case UnaryOp::Neg:
          if (!ot->isNumeric() && !ot->isUnknownish()) {
            error(e.loc, "'-' requires a numeric operand");
            e.type = Type::make(TypeKind::Error);
            return e.type;
          }
          e.type = ot->isNumeric() ? ot : Type::make(TypeKind::Unknown);
          return e.type;
        case UnaryOp::Exact:
          e.type = Type::make(TypeKind::Generic);
          return e.type;
        case UnaryOp::PostInc:
        case UnaryOp::PostDec: {
          if (e.lhs->kind != Expr::Kind::Identifier && e.lhs->kind != Expr::Kind::MemberAccess) {
            error(e.loc, "++/-- requires an assignable operand");
            e.type = Type::make(TypeKind::Error);
            return e.type;
          }
          if (!ot->isNumeric() && !ot->isUnknownish()) {
            error(e.loc, "++/-- requires a numeric operand");
            e.type = Type::make(TypeKind::Error);
            return e.type;
          }
          e.type = ot->isNumeric() ? ot : Type::make(TypeKind::Unknown);
          return e.type;
        }
      }
      e.type = Type::make(TypeKind::Error);
      return e.type;
    }
    case Expr::Kind::Ternary: {
      auto ct = infer(*e.lhs);
      if (!isBoolish(ct)) {
        error(e.loc, "ternary condition must be bool");
        e.type = Type::make(TypeKind::Error);
        return e.type;
      }
      auto tt = infer(*e.mid);
      auto ft = infer(*e.rhs);
      e.type = promote(tt, ft);
      return e.type;
    }
    case Expr::Kind::Assign: {
      if (e.lhs->kind != Expr::Kind::Identifier && e.lhs->kind != Expr::Kind::MemberAccess) {
        error(e.loc, "left side of assignment must be a variable or field");
        e.type = Type::make(TypeKind::Error);
        return e.type;
      }
      auto lt = infer(*e.lhs);
      auto rt = infer(*e.rhs);
      if (e.asOp == AssignOp::Assign) {
        if (!assignable(lt, rt)) {
          error(e.loc, "cannot assign " + rt->describe() + " to " + lt->describe());
          e.type = Type::make(TypeKind::Error);
          return e.type;
        }
      } else {
        if (!((lt->isNumeric() && rt->isNumeric()) || lt->isUnknownish() || rt->isUnknownish())) {
          error(e.loc, "compound assignment requires numeric operands");
          e.type = Type::make(TypeKind::Error);
          return e.type;
        }
      }
      e.type = lt;
      return e.type;
    }
    case Expr::Kind::Is: {
      infer(*e.lhs);
      e.type = typeFromTypeName(e.patternType, e.loc);
      if (e.type->isError()) {
        e.type = Type::make(TypeKind::Bool);
        return e.type;
      }
      e.type = Type::make(TypeKind::Bool);
      return e.type;
    }
    case Expr::Kind::Interpolated: {
      for (auto& seg : e.interpExprs) infer(*seg);
      e.type = Type::make(TypeKind::String);
      return e.type;
    }
    case Expr::Kind::Spawn: {
      for (auto& ci : e.spawnInits) checkComponentInit(ci);
      for (const auto& t : e.spawnTags) {
        if (!tags_.count(t)) error(e.loc, "unknown tag '" + t + "'");
      }
      e.type = Type::make(TypeKind::EntityId);
      return e.type;
    }
    case Expr::Kind::StructInit: {
      e.type = checkComponentInit(e.structInit);
      return e.type;
    }
  }
  e.type = Type::make(TypeKind::Error);
  return e.type;
}

std::shared_ptr<Type> Checker::inferCall(Expr& call) {
  Expr* callee = call.lhs.get();

  if (callee->kind == Expr::Kind::Identifier) {
    const std::string& name = callee->str;

    if (name == "others") {
      if (call.typeArgs.empty()) {
        error(call.loc, "'others' requires a component type argument: others<Component>(tag: T)");
        call.type = Type::make(TypeKind::Error);
        return call.type;
      }
      for (const auto& ta : call.typeArgs) validateComponentName(ta, call.loc);
      bool hasTag = false;
      for (const auto& arg : call.args) {
        if (arg.name == "tag") {
          hasTag = true;
          if (arg.value->kind == Expr::Kind::Unary &&
              arg.value->unOp == UnaryOp::Exact) {
            if (arg.value->lhs->kind == Expr::Kind::Identifier) {
              const std::string& tname = arg.value->lhs->str;
              if (!tags_.count(tname)) error(call.loc, "unknown tag '" + tname + "'");
            }
          } else if (arg.value->kind == Expr::Kind::Identifier) {
            const std::string& tname = arg.value->str;
            if (!tags_.count(tname)) error(call.loc, "unknown tag '" + tname + "'");
          } else {
            error(call.loc, "tag argument must be a tag name");
          }
        } else {
          error(call.loc, "unexpected argument '" + arg.name + "' to 'others'");
        }
      }
      if (!hasTag) error(call.loc, "'others' requires a 'tag:' argument");
      call.type = Type::snapshot(call.typeArgs);
      return call.type;
    }

    if (name == "run") {
      call.type = Type::make(TypeKind::Void);
      return call.type;
    }
    if (name == "panic") {
      for (auto& a : call.args) infer(*a.value);
      call.type = Type::make(TypeKind::Void);
      return call.type;
    }

    auto it = functions_.find(name);
    if (it != functions_.end()) {
      const Decl& fn = *it->second;
      if (fn.params.size() != call.args.size()) {
        error(call.loc, "function '" + name + "' expects " + std::to_string(fn.params.size()) +
                            " arguments, got " + std::to_string(call.args.size()));
        call.type = Type::make(TypeKind::Error);
        return call.type;
      }
      for (auto& a : call.args) infer(*a.value);
      if (fn.retKind == "void") call.type = Type::make(TypeKind::Void);
      else if (fn.retKind == "int") call.type = Type::make(TypeKind::Int);
      else call.type = Type::make(TypeKind::Generic);
      return call.type;
    }

    error(call.loc, "unknown function '" + name + "'");
    call.type = Type::make(TypeKind::Error);
    return call.type;
  }

  if (callee->kind == Expr::Kind::MemberAccess) {
    Expr* base = callee->lhs.get();
    if (base->kind == Expr::Kind::Identifier && base->str == "std") {
      const std::string& m = callee->member;
      if (m == "println" || m == "print" || m == "log") {
        for (auto& a : call.args) infer(*a.value);
        call.type = Type::make(TypeKind::Void);
        return call.type;
      }
      if (m == "readln") {
        if (!call.args.empty()) error(call.loc, "std.readln takes no arguments");
        call.type = Type::option(Type::make(TypeKind::String));
        return call.type;
      }
      if (m == "stop") {
        if (!call.args.empty()) error(call.loc, "std.stop takes no arguments");
        call.type = Type::make(TypeKind::Void);
        return call.type;
      }
      if (m == "exit") {
        if (call.args.size() != 1) error(call.loc, "std.exit requires one argument");
        for (auto& a : call.args) infer(*a.value);
        call.type = Type::make(TypeKind::Void);
        return call.type;
      }
      if (m == "rng") {
        if (call.args.size() != 1) error(call.loc, "std.rng requires one seed argument");
        for (auto& a : call.args) infer(*a.value);
        call.type = Type::make(TypeKind::Generic);
        return call.type;
      }
      error(call.loc, "unknown std function 'std." + m + "'");
      call.type = Type::make(TypeKind::Error);
      return call.type;
    }

    if (base->kind == Expr::Kind::Identifier && base->str == "spatial") {
      for (auto& a : call.args) infer(*a.value);
      call.type = Type::make(TypeKind::Unknown);
      return call.type;
    }

    auto bt = infer(*base);
    if (bt->isUnknownish()) {
      for (auto& a : call.args) infer(*a.value);
      call.type = Type::make(TypeKind::Unknown);
      return call.type;
    }
    error(call.loc, "cannot call member on " + bt->describe());
    call.type = Type::make(TypeKind::Error);
    return call.type;
  }

  error(call.loc, "expression is not callable");
  call.type = Type::make(TypeKind::Error);
  return call.type;
}

std::shared_ptr<Type> Checker::checkComponentInit(const ComponentInit& ci) {
  const Decl* comp = componentByName(ci.type);
  const Decl* st = structByName(ci.type);
  if (!comp && !st) {
    error(SourceLoc{0, 0}, "'" + ci.type + "' is not a component or struct");
    return Type::make(TypeKind::Error);
  }
  const auto& fields = comp ? componentFields_[ci.type] : structFields_[ci.type];
  for (const auto& f : ci.fields) {
    auto fit = fields.find(f.first);
    if (fit == fields.end()) {
      error(SourceLoc{0, 0}, "'" + ci.type + "' has no field '" + f.first + "'");
      continue;
    }
    auto vt = infer(*f.second);
    if (!assignable(fit->second, vt)) {
      error(SourceLoc{0, 0}, "field '" + ci.type + "." + f.first + "' expects " +
                                 fit->second->describe() + ", got " + vt->describe());
    }
  }
  return comp ? Type::component(ci.type) : Type::structType(ci.type);
}

void Checker::checkBlock(std::vector<StmtPtr>& body) {
  pushScope();
  for (auto& s : body) checkStmt(*s);
  popScope();
}

void Checker::registerPatternVars(Expr& cond) {
  if (cond.kind == Expr::Kind::Is && !cond.patternVar.empty()) {
    auto t = typeFromTypeName(cond.patternType, cond.loc);
    addLocal(cond.patternVar, t->isError() ? Type::make(TypeKind::Unknown) : t);
  }
  if (cond.lhs) registerPatternVars(*cond.lhs);
  if (cond.rhs) registerPatternVars(*cond.rhs);
  if (cond.mid) registerPatternVars(*cond.mid);
}

void Checker::checkStmt(Stmt& s) {
  switch (s.kind) {
    case Stmt::Kind::Block:
      checkBlock(s.body);
      return;
    case Stmt::Kind::VarDecl:
      s.initExpr->type = infer(*s.initExpr);
      addLocal(s.varName, s.initExpr->type);
      return;
    case Stmt::Kind::Expr:
      infer(*s.value);
      return;
    case Stmt::Kind::If: {
      pushScope();
      auto ct = infer(*s.cond);
      if (!isBoolish(ct)) error(s.loc, "if condition must be bool");
      registerPatternVars(*s.cond);
      if (s.thenStmt) checkStmt(*s.thenStmt);
      popScope();
      if (s.elseStmt) checkStmt(*s.elseStmt);
      return;
    }
    case Stmt::Kind::While: {
      auto ct = infer(*s.cond);
      if (!isBoolish(ct)) error(s.loc, "while condition must be bool");
      loopDepth_++;
      if (s.bodyStmt) checkStmt(*s.bodyStmt);
      loopDepth_--;
      return;
    }
    case Stmt::Kind::For: {
      pushScope();
      if (s.initStmt) checkStmt(*s.initStmt);
      else if (s.initExpr) infer(*s.initExpr);
      if (s.cond) {
        auto ct = infer(*s.cond);
        if (!isBoolish(ct)) error(s.loc, "for condition must be bool");
      }
      if (s.inc) infer(*s.inc);
      loopDepth_++;
      if (s.bodyStmt) checkStmt(*s.bodyStmt);
      loopDepth_--;
      popScope();
      return;
    }
    case Stmt::Kind::Foreach: {
      auto ct = infer(*s.container);
      if (ct->kind == TypeKind::Snapshot) {
        addLocal(s.varName, ct);
      } else if (ct->isUnknownish()) {
        addLocal(s.varName, Type::make(TypeKind::Unknown));
      } else {
        error(s.loc, "foreach requires a snapshot ('others<...>') or collection, got " +
                         ct->describe());
        addLocal(s.varName, Type::make(TypeKind::Unknown));
      }
      loopDepth_++;
      if (s.bodyStmt) checkStmt(*s.bodyStmt);
      loopDepth_--;
      return;
    }
    case Stmt::Kind::Return: {
      if (s.value) {
        auto rt = infer(*s.value);
        if (curFnRet_ == "void") {
          error(s.loc, "void function cannot return a value");
        } else if (curFnRet_ == "var") {
          if (varRetType_) {
            if (!assignable(varRetType_, rt)) {
              error(s.loc, "inconsistent return types: " + varRetType_->describe() + " vs " +
                               rt->describe());
            }
          } else {
            varRetType_ = rt;
          }
        } else {
          if (!assignable(Type::make(TypeKind::Int), rt)) {
            error(s.loc, "main must return an int value");
          }
        }
      } else {
        if (curFnRet_ == "var") error(s.loc, "var function must return a value");
      }
      return;
    }
    case Stmt::Kind::Break:
      if (loopDepth_ == 0) error(s.loc, "'break' outside of a loop");
      return;
    case Stmt::Kind::Continue:
      if (loopDepth_ == 0) error(s.loc, "'continue' outside of a loop");
      return;
    case Stmt::Kind::Attach: {
      auto tt = infer(*s.target);
      if (!isEntityIdish(tt)) error(s.loc, "attach target must be an EntityId");
      checkComponentInit(s.attachInit);
      return;
    }
    case Stmt::Kind::Detach: {
      auto tt = infer(*s.target);
      if (!isEntityIdish(tt)) error(s.loc, "detach target must be an EntityId");
      validateComponentName(s.detachType, s.loc);
      return;
    }
    case Stmt::Kind::Despawn: {
      auto tt = infer(*s.target);
      if (!isEntityIdish(tt)) error(s.loc, "despawn target must be an EntityId");
      return;
    }
  }
}

void Checker::checkSystem(Decl& d) {
  for (const auto& w : d.withList) validateComponentName(w, d.loc);
  for (const auto& w : d.withoutList) validateComponentName(w, d.loc);
  checkAttributes(d);
  pushScope();
  addLocal("self", Type::make(TypeKind::Self));
  addLocal("dt", Type::make(TypeKind::Double));
  addLocal("tick", Type::make(TypeKind::Long));
  if (d.body) checkBlock(d.body->body);
  popScope();
}

void Checker::checkFunction(Decl& d) {
  if (d.name == "main") {
    if (d.retKind != "int" && d.retKind != "var") {
      error(d.loc, "main must be declared 'int main()'");
    }
    if (!d.params.empty()) error(d.loc, "main cannot take parameters");
  } else if (d.retKind == "int") {
    error(d.loc, "only main may declare an 'int' return type");
  }

  curFnRet_ = d.retKind;
  varRetType_ = nullptr;
  pushScope();
  for (const auto& p : d.params) addLocal(p, Type::make(TypeKind::Generic));
  if (d.body) checkBlock(d.body->body);
  popScope();

  if (d.retKind == "var" && varRetType_ == nullptr) {
    error(d.loc, "var function '" + d.name + "' must return a value");
  }
}

ConstValue Checker::evalConst(Expr& e, bool& ok) {
  auto fail = [&]() -> ConstValue {
    ok = false;
    return ConstValue{};
  };
  switch (e.kind) {
    case Expr::Kind::IntLit:
      return ConstValue{ConstValue::Kind::Int, e.intValue, 0.0, false, ""};
    case Expr::Kind::FloatLit:
      return ConstValue{ConstValue::Kind::Float, 0, e.floatValue, false, ""};
    case Expr::Kind::BoolLit:
      return ConstValue{ConstValue::Kind::Bool, 0, 0.0, e.intValue != 0, ""};
    case Expr::Kind::StringLit:
      return ConstValue{ConstValue::Kind::String, 0, 0.0, false, e.str};
    case Expr::Kind::Identifier: {
      auto it = consts_.find(e.str);
      if (it == consts_.end()) return fail();
      return it->second;
    }
    case Expr::Kind::Unary: {
      if (e.unOp == UnaryOp::Neg) {
        auto v = evalConst(*e.lhs, ok);
        if (!ok) return fail();
        if (v.kind == ConstValue::Kind::Int) { v.intVal = -v.intVal; return v; }
        if (v.kind == ConstValue::Kind::Float) { v.floatVal = -v.floatVal; return v; }
        return fail();
      }
      if (e.unOp == UnaryOp::Not) {
        auto v = evalConst(*e.lhs, ok);
        if (!ok || v.kind != ConstValue::Kind::Bool) return fail();
        v.boolVal = !v.boolVal;
        return v;
      }
      return fail();
    }
    case Expr::Kind::Binary: {
      auto l = evalConst(*e.lhs, ok);
      if (!ok) return fail();
      auto r = evalConst(*e.rhs, ok);
      if (!ok) return fail();
      bool f = l.kind == ConstValue::Kind::Float || r.kind == ConstValue::Kind::Float;
      bool i = l.kind == ConstValue::Kind::Int && r.kind == ConstValue::Kind::Int;
      if (e.binOp == BinaryOp::Eq || e.binOp == BinaryOp::Ne) {
        bool eq;
        if (f) eq = l.floatVal == r.floatVal;
        else if (i) eq = l.intVal == r.intVal;
        else if (l.kind == ConstValue::Kind::Bool) eq = l.boolVal == r.boolVal;
        else if (l.kind == ConstValue::Kind::String) eq = l.strVal == r.strVal;
        else return fail();
        if (e.binOp == BinaryOp::Ne) eq = !eq;
        return ConstValue{ConstValue::Kind::Bool, 0, 0.0, eq, ""};
      }
      if (e.binOp == BinaryOp::Lt || e.binOp == BinaryOp::Gt || e.binOp == BinaryOp::Le ||
          e.binOp == BinaryOp::Ge) {
        if (!f && !i) return fail();
        bool rlt;
        if (f) rlt = e.binOp == BinaryOp::Lt ? l.floatVal < r.floatVal
                 : e.binOp == BinaryOp::Gt ? l.floatVal > r.floatVal
                 : e.binOp == BinaryOp::Le ? l.floatVal <= r.floatVal
                                           : l.floatVal >= r.floatVal;
        else
          rlt = e.binOp == BinaryOp::Lt ? l.intVal < r.intVal
                : e.binOp == BinaryOp::Gt ? l.intVal > r.intVal
                : e.binOp == BinaryOp::Le ? l.intVal <= r.intVal
                                          : l.intVal >= r.intVal;
        return ConstValue{ConstValue::Kind::Bool, 0, 0.0, rlt, ""};
      }
      if (e.binOp == BinaryOp::And || e.binOp == BinaryOp::Or) {
        if (l.kind != ConstValue::Kind::Bool || r.kind != ConstValue::Kind::Bool) return fail();
        bool bv = e.binOp == BinaryOp::And ? l.boolVal && r.boolVal : l.boolVal || r.boolVal;
        return ConstValue{ConstValue::Kind::Bool, 0, 0.0, bv, ""};
      }
      if (f) {
        double lv = l.kind == ConstValue::Kind::Float ? l.floatVal : (double)l.intVal;
        double rv = r.kind == ConstValue::Kind::Float ? r.floatVal : (double)r.intVal;
        double res;
        switch (e.binOp) {
          case BinaryOp::Add: res = lv + rv; break;
          case BinaryOp::Sub: res = lv - rv; break;
          case BinaryOp::Mul: res = lv * rv; break;
          case BinaryOp::Div: res = lv / rv; break;
          case BinaryOp::Mod: res = (double)((long long)lv % (long long)rv); break;
          default: return fail();
        }
        return ConstValue{ConstValue::Kind::Float, 0, res, false, ""};
      }
      if (i) {
        long long res;
        switch (e.binOp) {
          case BinaryOp::Add: res = l.intVal + r.intVal; break;
          case BinaryOp::Sub: res = l.intVal - r.intVal; break;
          case BinaryOp::Mul: res = l.intVal * r.intVal; break;
          case BinaryOp::Div: res = r.intVal == 0 ? 0 : l.intVal / r.intVal; break;
          case BinaryOp::Mod: res = r.intVal == 0 ? 0 : l.intVal % r.intVal; break;
          default: return fail();
        }
        return ConstValue{ConstValue::Kind::Int, res, 0.0, false, ""};
      }
      return fail();
    }
    case Expr::Kind::Ternary: {
      auto c = evalConst(*e.lhs, ok);
      if (!ok || c.kind != ConstValue::Kind::Bool) return fail();
      return c.boolVal ? evalConst(*e.mid, ok) : evalConst(*e.rhs, ok);
    }
    default:
      return fail();
  }
}

}  // namespace kx