#include "types.h"

namespace kx {

std::shared_ptr<Type> Type::make(TypeKind k) {
  auto t = std::make_shared<Type>();
  t->kind = k;
  return t;
}

std::shared_ptr<Type> Type::component(const std::string& n) {
  auto t = make(TypeKind::Component);
  t->name = n;
  return t;
}

std::shared_ptr<Type> Type::structType(const std::string& n) {
  auto t = make(TypeKind::Struct);
  t->name = n;
  return t;
}

std::shared_ptr<Type> Type::enumType(const std::string& n) {
  auto t = make(TypeKind::Enum);
  t->name = n;
  return t;
}

std::shared_ptr<Type> Type::option(std::shared_ptr<Type> inner) {
  auto t = make(TypeKind::Option);
  t->inner = std::move(inner);
  return t;
}

std::shared_ptr<Type> Type::snapshot(std::vector<std::string> components) {
  auto t = make(TypeKind::Snapshot);
  t->componentNames = std::move(components);
  return t;
}

std::shared_ptr<Type> Type::list(std::shared_ptr<Type> inner) {
  auto t = make(TypeKind::List);
  t->inner = std::move(inner);
  return t;
}

std::shared_ptr<Type> Type::map(std::shared_ptr<Type> key, std::shared_ptr<Type> val) {
  auto t = make(TypeKind::Map);
  t->inner = std::move(key);
  t->inner2 = std::move(val);
  return t;
}

bool Type::isCollection() const {
  return kind == TypeKind::List || kind == TypeKind::Map;
}

bool Type::isNumeric() const {
  return kind == TypeKind::Int || kind == TypeKind::Long || kind == TypeKind::Float ||
         kind == TypeKind::Double || kind == TypeKind::Byte;
}

bool Type::isError() const { return kind == TypeKind::Error; }

bool Type::isUnknownish() const {
  return kind == TypeKind::Unknown || kind == TypeKind::Generic || kind == TypeKind::Error;
}

std::string Type::describe() const {
  switch (kind) {
    case TypeKind::Void: return "void";
    case TypeKind::Bool: return "bool";
    case TypeKind::Int: return "int";
    case TypeKind::Long: return "long";
    case TypeKind::Float: return "float";
    case TypeKind::Double: return "double";
    case TypeKind::Byte: return "byte";
    case TypeKind::String: return "string";
    case TypeKind::EntityId: return "EntityId";
    case TypeKind::Option:
      return inner ? inner->describe() + "?" : "?";
    case TypeKind::Component: return "component " + name;
    case TypeKind::Struct: return "struct " + name;
    case TypeKind::Enum: return "enum " + name;
    case TypeKind::Function: return "function";
    case TypeKind::Snapshot:
      return "snapshot";
    case TypeKind::List:
      return inner ? "List<" + inner->describe() + ">" : "List<?>";
    case TypeKind::Map:
      return "Map<" + (inner ? inner->describe() : std::string("?")) + ", " +
             (inner2 ? inner2->describe() : std::string("?")) + ">";
    case TypeKind::Rng: return "Rng";
    case TypeKind::Self: return "self";
    case TypeKind::Generic: return "any";
    case TypeKind::Unknown: return "unknown";
    case TypeKind::Error: return "<error>";
  }
  return "?";
}

int numericRank(const std::shared_ptr<Type>& t) {
  switch (t->kind) {
    case TypeKind::Byte: return 0;
    case TypeKind::Int: return 1;
    case TypeKind::Long: return 2;
    case TypeKind::Float: return 3;
    case TypeKind::Double: return 4;
    default: return -1;
  }
}

std::shared_ptr<Type> promote(const std::shared_ptr<Type>& a, const std::shared_ptr<Type>& b) {
  if (a->isUnknownish()) return a;
  if (b->isUnknownish()) return b;
  if (a->isNumeric() && b->isNumeric()) {
    int ra = numericRank(a), rb = numericRank(b);
    if (ra >= rb) return a;
    return b;
  }
  if (a->kind == b->kind) return a;
  return Type::make(TypeKind::Unknown);
}

bool assignable(const std::shared_ptr<Type>& dst, const std::shared_ptr<Type>& src) {
  if (dst->isUnknownish() || src->isUnknownish()) return true;
  if (dst->kind == src->kind) {
    if (dst->kind == TypeKind::List) return assignable(dst->inner, src->inner);
    if (dst->kind == TypeKind::Map) {
      return assignable(dst->inner, src->inner) && assignable(dst->inner2, src->inner2);
    }
    return true;
  }
  if (dst->isNumeric() && src->isNumeric()) return numericRank(src) <= numericRank(dst);
  return false;
}

}  // namespace kx