#include "checker.h"

#include <algorithm>
#include <cmath>
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

bool isIndexish(const std::shared_ptr<Type>& t) {
  return t->isUnknownish() || t->kind == TypeKind::Int || t->kind == TypeKind::Long ||
         t->kind == TypeKind::Byte;
}

bool isFrozenAccess(const Expr* e) {
  if (!e) return false;
  switch (e->kind) {
    case Expr::Kind::Identifier:
      return e->type && e->type->kind == TypeKind::Snapshot;
    case Expr::Kind::MemberAccess:
      return isFrozenAccess(e->lhs.get());
    case Expr::Kind::Call:
      return isFrozenAccess(e->lhs.get());
    default:
      return false;
  }
}

}  // namespace

void Checker::addProgram(std::unique_ptr<Program> program, const std::string& sourceRoot) {
  if (!sourceRoot.empty()) {
    currentSourceRoot_ = sourceRoot;
  }
  if (!program->sourceRoot.empty()) {
    currentSourceRoot_ = program->sourceRoot;
  }
  // Compute namespace from file path relative to source root
  if (!currentSourceRoot_.empty()) {
    std::string filePath = program->file;
    // Normalize: find sourceRoot in filePath and extract relative path
    auto pos = filePath.rfind(currentSourceRoot_);
    if (pos != std::string::npos) {
      std::string relPath = filePath.substr(pos + currentSourceRoot_.size());
      // Remove leading slash
      if (!relPath.empty() && (relPath[0] == '/' || relPath[0] == '\\')) {
        relPath = relPath.substr(1);
      }
      // Take the directory part as namespace
      auto slashPos = relPath.find_last_of("/\\");
      if (slashPos != std::string::npos) {
        std::string ns = relPath.substr(0, slashPos);
        // Convert path separators to dots
        for (char& c : ns) {
          if (c == '/' || c == '\\') c = '.';
        }
        program->namespaceName = ns;
      }
    }
  }
  for (const auto& d : program->decls) declare(d);
  resolveNamespaces();
  programs_.push_back(std::move(program));
}

void Checker::resolveNamespaces() {
  if (programs_.empty()) return;
  const auto& prog = programs_.back();
  for (const auto& ns : prog->usings) {
    // For each using directive, find all pub declarations from that namespace
    // and make them available unqualified
    for (const auto& [qname, decl] : components_) {
      if (qname.size() > ns.size() + 1 && qname.substr(0, ns.size()) == ns &&
          qname[ns.size()] == '.') {
        std::string shortName = qname.substr(ns.size() + 1);
        if (decl->isPublic && !components_.count(shortName)) {
          components_[shortName] = decl;
        }
      }
    }
    for (const auto& [qname, decl] : systems_) {
      if (qname.size() > ns.size() + 1 && qname.substr(0, ns.size()) == ns &&
          qname[ns.size()] == '.') {
        std::string shortName = qname.substr(ns.size() + 1);
        if (decl->isPublic && !systems_.count(shortName)) {
          systems_[shortName] = decl;
        }
      }
    }
    for (const auto& [qname, decl] : tags_) {
      if (qname.size() > ns.size() + 1 && qname.substr(0, ns.size()) == ns &&
          qname[ns.size()] == '.') {
        std::string shortName = qname.substr(ns.size() + 1);
        if (decl->isPublic && !tags_.count(shortName)) {
          tags_[shortName] = decl;
        }
      }
    }
    for (const auto& [qname, decl] : structs_) {
      if (qname.size() > ns.size() + 1 && qname.substr(0, ns.size()) == ns &&
          qname[ns.size()] == '.') {
        std::string shortName = qname.substr(ns.size() + 1);
        if (decl->isPublic && !structs_.count(shortName)) {
          structs_[shortName] = decl;
        }
      }
    }
    for (const auto& [qname, decl] : enums_) {
      if (qname.size() > ns.size() + 1 && qname.substr(0, ns.size()) == ns &&
          qname[ns.size()] == '.') {
        std::string shortName = qname.substr(ns.size() + 1);
        if (decl->isPublic && !enums_.count(shortName)) {
          enums_[shortName] = decl;
        }
      }
    }
  }
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

  // Register in the flat (unqualified) namespace
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
    case Decl::Kind::Function: {
      bool nameConflict = components_.count(d.name) || systems_.count(d.name) ||
                          tags_.count(d.name) || structs_.count(d.name) ||
                          enums_.count(d.name) || consts_.count(d.name);
      if (nameConflict) {
        error(d.loc, "duplicate declaration '" + d.name + "'");
        break;
      }
      for (const auto* existing : functions_[d.name]) {
        if (existing->params.size() == d.params.size()) {
          error(d.loc, "duplicate function '" + d.name + "' with " +
                           std::to_string(d.params.size()) + " parameter(s)");
        }
      }
      functions_[d.name].push_back(&d);
      if (d.name == "main") mainSeen_ = true;
      break;
    }
  }

  // Also register under namespace-qualified name if the program has a namespace
  if (!programs_.empty() && !programs_.back()->namespaceName.empty()) {
    std::string qname = programs_.back()->namespaceName + "." + d.name;
    switch (d.kind) {
      case Decl::Kind::Component:
        components_[qname] = &d;
        break;
      case Decl::Kind::System:
        systems_[qname] = &d;
        break;
      case Decl::Kind::Tag:
        tags_[qname] = &d;
        break;
      case Decl::Kind::Struct:
        structs_[qname] = &d;
        break;
      case Decl::Kind::Enum:
        enums_[qname] = &d;
        break;
      case Decl::Kind::Const:
        consts_[qname] = consts_[d.name];
        break;
      case Decl::Kind::Function:
        functions_[qname].push_back(&d);
        break;
    }
  }
}

bool Checker::check() {
  if (requireMain_ && mainSeen_ == false) errors_.push_back("0:0: program must declare exactly one 'main' function");

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
  for (auto& [name, vec] : functions_) {
    for (const Decl* dp : vec) {
      Decl* fn = const_cast<Decl*>(dp);
      curFnName_ = fn->name;
      checkFunction(*fn);
    }
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

std::vector<const Decl*> Checker::externDecls() const {
  std::vector<const Decl*> out;
  for (const auto& [name, vec] : functions_) {
    for (const Decl* d : vec) {
      if (d->isExtern) out.push_back(d);
    }
  }
  return out;
}

const Decl* Checker::functionByName(const std::string& name, size_t arity) const {
  auto it = functions_.find(name);
  if (it == functions_.end()) return nullptr;
  for (const auto* d : it->second) {
    if (d->params.size() == arity) return d;
  }
  return nullptr;
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
        case TypeKind::List:
        case TypeKind::Map:
          if (e.member == "Count") {
            e.type = Type::make(TypeKind::Long);
            return e.type;
          }
          error(e.loc, (bt->kind == TypeKind::List ? "'List'" : "'Map'") +
                           std::string(" has no member '") + e.member + "'");
          e.type = Type::make(TypeKind::Error);
          return e.type;
        case TypeKind::String:
          if (e.member == "Length") {
            e.type = Type::make(TypeKind::Long);
            return e.type;
          }
          error(e.loc, "'string' has no member '" + e.member + "'");
          e.type = Type::make(TypeKind::Error);
          return e.type;
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
      if (e.binOp == BinaryOp::And || e.binOp == BinaryOp::Or) {
        if (!isBoolish(lt) || !isBoolish(rt)) {
          error(e.loc, "logical operator requires bool operands");
          e.type = Type::make(TypeKind::Error);
          return e.type;
        }
        e.type = Type::make(TypeKind::Bool);
        return e.type;
      }
      const char* opName = nullptr;
      switch (e.binOp) {
        case BinaryOp::Add: opName = "op_add"; break;
        case BinaryOp::Sub: opName = "op_sub"; break;
        case BinaryOp::Mul: opName = "op_mul"; break;
        case BinaryOp::Div: opName = "op_div"; break;
        case BinaryOp::Mod: opName = "op_mod"; break;
        case BinaryOp::Eq: opName = "op_eq"; break;
        case BinaryOp::Ne: opName = "op_ne"; break;
        case BinaryOp::Lt: opName = "op_lt"; break;
        case BinaryOp::Le: opName = "op_le"; break;
        case BinaryOp::Gt: opName = "op_gt"; break;
        case BinaryOp::Ge: opName = "op_ge"; break;
        default: break;
      }
      bool anyStruct = lt->kind == TypeKind::Struct || rt->kind == TypeKind::Struct;
      if (anyStruct && opName) {
        const Decl* op = functionByName(opName, 2);
        if (!op) {
          error(e.loc, "no operator '" + std::string(opName) + "' defined for struct '" +
                           lt->name + "'");
          e.type = Type::make(TypeKind::Error);
          return e.type;
        }
        std::map<std::string, std::shared_ptr<Type>> params;
        params[op->params[0]] = lt;
        params[op->params[1]] = rt;
        std::vector<StmtPtr> emptyOpBody;
        auto ret = reInferBody(op->body ? op->body->body : emptyOpBody, params);
        e.type = ret ? ret : Type::make(TypeKind::Unknown);
        return e.type;
      }
      if (e.binOp == BinaryOp::Eq || e.binOp == BinaryOp::Ne) {
        if (lt->kind == rt->kind || (lt->isNumeric() && rt->isNumeric()) || lt->isUnknownish() ||
            rt->isUnknownish()) {
          e.type = Type::make(TypeKind::Bool);
          return e.type;
        }
        error(e.loc, "cannot compare " + lt->describe() + " and " + rt->describe());
        e.type = Type::make(TypeKind::Error);
        return e.type;
      }
      if (e.binOp == BinaryOp::Lt || e.binOp == BinaryOp::Gt || e.binOp == BinaryOp::Le ||
          e.binOp == BinaryOp::Ge) {
        if ((lt->isNumeric() && rt->isNumeric()) || lt->isUnknownish() || rt->isUnknownish()) {
          e.type = Type::make(TypeKind::Bool);
          return e.type;
        }
        error(e.loc, "comparison requires numeric operands");
        e.type = Type::make(TypeKind::Error);
        return e.type;
      }
      if (e.binOp == BinaryOp::Add) {
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
      }
      if ((lt->isNumeric() && rt->isNumeric()) || lt->isUnknownish() || rt->isUnknownish()) {
        e.type = promote(lt, rt);
        return e.type;
      }
      error(e.loc, "arithmetic operator requires numeric operands");
      e.type = Type::make(TypeKind::Error);
      return e.type;
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
        bool strConcat = e.asOp == AssignOp::Add &&
                         ((lt && lt->kind == TypeKind::String) ||
                          (rt && rt->kind == TypeKind::String));
        if (!strConcat && !((lt->isNumeric() && rt->isNumeric()) || lt->isUnknownish() ||
                            rt->isUnknownish())) {
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

    if (name == "List") {
      if (call.typeArgs.size() != 1) {
        error(call.loc, "'List' requires one type argument: List<T>");
        call.type = Type::make(TypeKind::Error);
        return call.type;
      }
      if (!call.args.empty()) error(call.loc, "'List' constructor takes no arguments");
      auto inner = typeFromTypeName(call.typeArgs[0], call.loc);
      call.type = Type::list(inner);
      return call.type;
    }

    if (name == "Map") {
      if (call.typeArgs.size() != 2) {
        error(call.loc, "'Map' requires two type arguments: Map<K, V>");
        call.type = Type::make(TypeKind::Error);
        return call.type;
      }
      if (!call.args.empty()) error(call.loc, "'Map' constructor takes no arguments");
      auto key = typeFromTypeName(call.typeArgs[0], call.loc);
      auto val = typeFromTypeName(call.typeArgs[1], call.loc);
      call.type = Type::map(key, val);
      return call.type;
    }

    const Decl* fnPtr = functionByName(name, call.args.size());
    if (fnPtr) {
      const Decl& fn = *fnPtr;
      if (fn.params.size() != call.args.size()) {
        error(call.loc, "function '" + name + "' expects " + std::to_string(fn.params.size()) +
                            " argument(s), got " + std::to_string(call.args.size()));
        call.type = Type::make(TypeKind::Error);
        return call.type;
      }
      for (auto& a : call.args) infer(*a.value);
      if (fn.isExtern) {
        for (size_t i = 0; i < call.args.size() && i < fn.paramTypes.size(); i++) {
          auto pt = typeFromTypeName(fn.paramTypes[i], call.loc);
          if (pt->isError()) continue;
          auto at = call.args[i].value->type;
          if (at && !at->isUnknownish() && !assignable(pt, at)) {
            error(call.loc, "extern argument " + std::to_string(i + 1) + " expects " +
                                pt->describe() + ", got " + at->describe());
          }
        }
        call.type = typeFromTypeName(fn.retKind, call.loc);
        return call.type;
      }
      if (fn.retKind == "void") call.type = Type::make(TypeKind::Void);
      else if (fn.retKind == "int") call.type = Type::make(TypeKind::Int);
      else if (fn.isExtern) {
        call.type = typeFromTypeName(fn.retKind, call.loc);
      } else {
        std::map<std::string, std::shared_ptr<Type>> params;
        bool allKnown = true;
        std::string sig;
        for (size_t i = 0; i < fn.params.size() && i < call.args.size(); i++) {
          auto at = call.args[i].value->type;
          if (!at || at->isUnknownish()) allKnown = false;
          params[fn.params[i]] = at ? at : Type::make(TypeKind::Unknown);
          sig += at ? at->describe() : "?";
          sig += ",";
        }
        std::string key = name + "#" + sig;
        auto cacheIt = reInferCache_.find(key);
        if (cacheIt == reInferCache_.end()) {
          reInferCache_[key] = nullptr;
          std::vector<StmtPtr> emptyBody;
          auto ret = allKnown ? reInferBody(fn.body ? fn.body->body : emptyBody, params)
                              : nullptr;
          reInferCache_[key] = ret ? ret : Type::make(TypeKind::Generic);
        }
        auto cached = reInferCache_[key];
        call.type = cached ? cached : Type::make(TypeKind::Generic);
      }
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
      if (m == "println" || m == "print") {
        for (auto& a : call.args) infer(*a.value);
        call.type = Type::make(TypeKind::Void);
        return call.type;
      }
      if (m == "log") {
        if (call.args.size() != 2) error(call.loc, "std.log requires (level, message)");
        for (auto& a : call.args) infer(*a.value);
        call.type = Type::make(TypeKind::Void);
        return call.type;
      }
      if (m == "readln") {
        if (!call.args.empty()) error(call.loc, "std.readln takes no arguments");
        call.type = Type::option(Type::make(TypeKind::String));
        return call.type;
      }
      if (m == "pollLine") {
        if (!call.args.empty()) error(call.loc, "std.pollLine takes no arguments");
        call.type = Type::option(Type::make(TypeKind::String));
        return call.type;
      }
      if (m == "args") {
        if (!call.args.empty()) error(call.loc, "std.args takes no arguments");
        call.type = Type::list(Type::make(TypeKind::String));
        return call.type;
      }
      if (m == "readFile") {
        if (call.args.size() != 1) error(call.loc, "std.readFile requires one argument");
        for (auto& a : call.args) infer(*a.value);
        call.type = Type::make(TypeKind::String);
        return call.type;
      }
      if (m == "writeFile") {
        if (call.args.size() != 2) error(call.loc, "std.writeFile requires two arguments");
        for (auto& a : call.args) infer(*a.value);
        call.type = Type::make(TypeKind::Bool);
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
        call.type = Type::make(TypeKind::Rng);
        return call.type;
      }
      {
        static const char* kMath1[] = {"sqrt",  "sin",  "cos",  "tan",  "asin", "acos",
                                       "atan",  "exp",  "log",  "log2", "log10",
                                       "floor", "ceil", "round"};
        for (const char* f : kMath1) {
          if (m == f) {
            if (call.args.size() != 1) {
              error(call.loc, std::string("std.") + f + " requires one argument");
            }
            auto at = call.args.empty() ? Type::make(TypeKind::Unknown)
                                        : infer(*call.args[0].value);
            if (!at->isNumeric() && !at->isUnknownish()) {
              error(call.loc, std::string("std.") + f + " requires a numeric argument");
            }
            call.type = Type::make(TypeKind::Double);
            return call.type;
          }
        }
        static const char* kMath2[] = {"atan2", "pow"};
        for (const char* f : kMath2) {
          if (m == f) {
            if (call.args.size() != 2) {
              error(call.loc, std::string("std.") + f + " requires two arguments");
            }
            for (auto& a : call.args) infer(*a.value);
            call.type = Type::make(TypeKind::Double);
            return call.type;
          }
        }
      }
      if (m == "min" || m == "max") {
        if (call.args.size() != 2) {
          error(call.loc, std::string("std.") + m + " requires two arguments");
        }
        auto a = infer(*call.args[0].value);
        auto b = infer(*call.args[1].value);
        call.type = promote(a, b);
        return call.type;
      }
      if (m == "abs") {
        if (call.args.size() != 1) error(call.loc, "std.abs requires one argument");
        auto a = call.args.empty() ? Type::make(TypeKind::Unknown)
                                   : infer(*call.args[0].value);
        if (a->kind == TypeKind::Int || a->kind == TypeKind::Long ||
            a->kind == TypeKind::Byte) {
          call.type = a;
        } else {
          call.type = Type::make(TypeKind::Double);
        }
        return call.type;
      }
      if (m == "clamp") {
        if (call.args.size() != 3) error(call.loc, "std.clamp requires three arguments");
        for (auto& a : call.args) infer(*a.value);
        call.type = Type::make(TypeKind::Double);
        return call.type;
      }
      if (m == "lerp") {
        if (call.args.size() != 3) error(call.loc, "std.lerp requires three arguments");
        for (auto& a : call.args) infer(*a.value);
        call.type = Type::make(TypeKind::Double);
        return call.type;
      }
      error(call.loc, "unknown std function 'std." + m + "'");
      call.type = Type::make(TypeKind::Error);
      return call.type;
    }

    if (base->kind == Expr::Kind::Identifier && base->str == "spatial") {
      for (auto& a : call.args) infer(*a.value);
      std::vector<std::string> comps;
      if (!call.args.empty() && call.args[0].value->kind == Expr::Kind::Identifier) {
        comps.push_back(call.args[0].value->str);
      }
      call.type = Type::snapshot(comps);
      return call.type;
    }

    auto bt = infer(*base);
    if (bt->kind == TypeKind::Option) {
      if (callee->member == "ValueOr") {
        if (call.args.size() != 1) {
          error(call.loc, "ValueOr requires one default argument");
        } else {
          auto at = infer(*call.args[0].value);
          if (!assignable(bt->inner, at)) {
            error(call.loc, "ValueOr default expects " + bt->inner->describe() +
                                ", got " + at->describe());
          }
        }
        call.type = bt->inner ? bt->inner : Type::make(TypeKind::Unknown);
        return call.type;
      }
      error(call.loc, "'Option' has no method '" + callee->member + "'");
      call.type = Type::make(TypeKind::Error);
      return call.type;
    }
    if (bt->kind == TypeKind::Rng) {
      const std::string& m = callee->member;
      if (m == "Next") {
        if (!call.args.empty()) error(call.loc, "Rng.Next takes no arguments");
        call.type = Type::make(TypeKind::Long);
        return call.type;
      }
      if (m == "NextInt") {
        if (call.args.size() != 1) error(call.loc, "Rng.NextInt requires one argument");
        if (!call.args.empty()) infer(*call.args[0].value);
        call.type = Type::make(TypeKind::Long);
        return call.type;
      }
      if (m == "NextDouble") {
        if (!call.args.empty()) error(call.loc, "Rng.NextDouble takes no arguments");
        call.type = Type::make(TypeKind::Double);
        return call.type;
      }
      error(call.loc, "'Rng' has no method '" + m + "'");
      call.type = Type::make(TypeKind::Error);
      return call.type;
    }
    if (bt->kind == TypeKind::String) {
      const std::string& m = callee->member;
      auto checkInt = [&](size_t i, const char* what) {
        if (call.args.size() <= i) {
          error(call.loc, std::string(what) + " requires " + std::to_string(i + 1) +
                              " argument(s)");
          return;
        }
        infer(*call.args[i].value);
      };
      auto checkStr = [&](size_t i, const char* what) {
        if (call.args.size() <= i) {
          error(call.loc, std::string(what) + " requires " + std::to_string(i + 1) +
                              " argument(s)");
          return;
        }
        auto at = infer(*call.args[i].value);
        if (!assignable(Type::make(TypeKind::String), at)) {
          error(call.loc, std::string(what) + " expects a string, got " + at->describe());
        }
      };
      if (m == "Substring") {
        checkInt(0, "Substring");
        checkInt(1, "Substring");
        call.type = Type::make(TypeKind::String);
        return call.type;
      }
      if (m == "Contains") {
        checkStr(0, "Contains");
        call.type = Type::make(TypeKind::Bool);
        return call.type;
      }
      if (m == "StartsWith") {
        checkStr(0, "StartsWith");
        call.type = Type::make(TypeKind::Bool);
        return call.type;
      }
      if (m == "EndsWith") {
        checkStr(0, "EndsWith");
        call.type = Type::make(TypeKind::Bool);
        return call.type;
      }
      if (m == "Upper" || m == "Lower" || m == "Trim") {
        if (!call.args.empty()) error(call.loc, "string." + m + " takes no arguments");
        call.type = Type::make(TypeKind::String);
        return call.type;
      }
      if (m == "IndexOf") {
        checkStr(0, "IndexOf");
        call.type = Type::make(TypeKind::Int);
        return call.type;
      }
      error(call.loc, "'string' has no method '" + m + "'");
      call.type = Type::make(TypeKind::Error);
      return call.type;
    }
    if (bt->kind == TypeKind::List || bt->kind == TypeKind::Map) {
      const std::string& m = callee->member;
      bool mutating = m == "Add" || m == "Set" || m == "RemoveAt" || m == "Remove" ||
                      m == "Clear";
      if (mutating && isFrozenAccess(base)) {
        error(call.loc, "cannot mutate another entity's data through a frozen snapshot");
        call.type = Type::make(TypeKind::Error);
        return call.type;
      }
      auto checkArg = [&](size_t i, const std::shared_ptr<Type>& want, const char* what) {
        if (call.args.size() <= i) {
          error(call.loc, std::string(what) + " requires " + std::to_string(i + 1) +
                              " argument(s)");
          return;
        }
        auto at = infer(*call.args[i].value);
        if (!assignable(want, at)) {
          error(call.loc, std::string(what) + " argument " + std::to_string(i + 1) +
                              " expects " + want->describe() + ", got " + at->describe());
        }
      };
      if (bt->kind == TypeKind::List) {
        if (m == "Add") {
          checkArg(0, bt->inner ? bt->inner : Type::make(TypeKind::Int), "List.Add");
          call.type = Type::make(TypeKind::Void);
          return call.type;
        }
        if (m == "Get") {
          checkArg(0, Type::make(TypeKind::Long), "List.Get");
          call.type = bt->inner ? bt->inner : Type::make(TypeKind::Unknown);
          return call.type;
        }
        if (m == "Set") {
          checkArg(0, Type::make(TypeKind::Long), "List.Set");
          checkArg(1, bt->inner ? bt->inner : Type::make(TypeKind::Int), "List.Set");
          call.type = Type::make(TypeKind::Void);
          return call.type;
        }
        if (m == "RemoveAt") {
          checkArg(0, Type::make(TypeKind::Long), "List.RemoveAt");
          call.type = Type::make(TypeKind::Void);
          return call.type;
        }
        if (m == "Clear") {
          if (!call.args.empty()) error(call.loc, "List.Clear takes no arguments");
          call.type = Type::make(TypeKind::Void);
          return call.type;
        }
        error(call.loc, "'List' has no method '" + m + "'");
        call.type = Type::make(TypeKind::Error);
        return call.type;
      }
      if (m == "Set") {
        checkArg(0, bt->inner ? bt->inner : Type::make(TypeKind::Int), "Map.Set");
        checkArg(1, bt->inner2 ? bt->inner2 : Type::make(TypeKind::Int), "Map.Set");
        call.type = Type::make(TypeKind::Void);
        return call.type;
      }
      if (m == "Get") {
        checkArg(0, bt->inner ? bt->inner : Type::make(TypeKind::Int), "Map.Get");
        call.type = bt->inner2 ? bt->inner2 : Type::make(TypeKind::Unknown);
        return call.type;
      }
      if (m == "Has") {
        checkArg(0, bt->inner ? bt->inner : Type::make(TypeKind::Int), "Map.Has");
        call.type = Type::make(TypeKind::Bool);
        return call.type;
      }
      if (m == "Remove") {
        checkArg(0, bt->inner ? bt->inner : Type::make(TypeKind::Int), "Map.Remove");
        call.type = Type::make(TypeKind::Void);
        return call.type;
      }
      if (m == "Clear") {
        if (!call.args.empty()) error(call.loc, "Map.Clear takes no arguments");
        call.type = Type::make(TypeKind::Void);
        return call.type;
      }
      error(call.loc, "'Map' has no method '" + m + "'");
      call.type = Type::make(TypeKind::Error);
      return call.type;
    }

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
      } else if (ct->kind == TypeKind::List) {
        addLocal(s.varName, ct->inner ? ct->inner : Type::make(TypeKind::Unknown));
      } else if (ct->isUnknownish()) {
        addLocal(s.varName, Type::make(TypeKind::Unknown));
      } else {
        error(s.loc, "foreach requires a snapshot ('others<...>'), a List, or a collection, "
                         "got " + ct->describe());
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
    case Stmt::Kind::Switch: {
      auto ct = infer(*s.cond);
      std::shared_ptr<Type> valueType;
      bool first = true;
      for (auto& sc : s.switchCases) {
        for (auto& v : sc.values) {
          auto vt = infer(*v);
          if (!(v->kind == Expr::Kind::IntLit || v->kind == Expr::Kind::StringLit ||
                v->kind == Expr::Kind::BoolLit || v->kind == Expr::Kind::FloatLit)) {
            error(v->loc, "switch case value must be a literal");
            continue;
          }
          if (first) {
            valueType = vt;
            first = false;
          } else if (!assignable(valueType, vt)) {
            error(v->loc, "switch case value type does not match the condition");
          }
        }
        if (!sc.body) continue;
        if (sc.body->body.empty()) continue;
        switchDepth_++;
        checkStmt(*sc.body);
        switchDepth_--;
        const Stmt* last = nullptr;
        if (!sc.body->body.empty()) last = sc.body->body.back().get();
        bool terminates = false;
        if (last) {
          if (last->kind == Stmt::Kind::Break || last->kind == Stmt::Kind::Return ||
              last->kind == Stmt::Kind::Continue) {
            terminates = true;
          } else if (last->kind == Stmt::Kind::Block && !last->body.empty()) {
            const Stmt* inner = last->body.back().get();
            terminates = inner && (inner->kind == Stmt::Kind::Break ||
                                   inner->kind == Stmt::Kind::Return ||
                                   inner->kind == Stmt::Kind::Continue);
          }
        }
        if (!terminates) {
          error(sc.body->loc, "switch case must end with 'break' or 'return'");
        }
      }
      return;
    }
    case Stmt::Kind::Break:
      if (loopDepth_ == 0 && switchDepth_ == 0) {
        error(s.loc, "'break' outside of a loop or switch");
      }
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
  if (d.isExtern) return;
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
          case BinaryOp::Mod: res = fmod(lv, rv); break;
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