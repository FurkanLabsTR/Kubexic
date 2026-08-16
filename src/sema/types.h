#pragma once

#include <memory>
#include <string>
#include <vector>

namespace kx {

enum class TypeKind {
  Void,
  Bool,
  Int,
  Long,
  Float,
  Double,
  Byte,
  String,
  EntityId,
  Option,
  Component,
  Struct,
  Enum,
  Function,
  Snapshot,
  Self,
  Generic,
  Unknown,
  Error,
};

struct Type {
  TypeKind kind = TypeKind::Unknown;
  std::string name;
  std::shared_ptr<Type> inner;
  std::shared_ptr<Type> ret;
  std::vector<std::shared_ptr<Type>> params;
  std::vector<std::string> componentNames;

  static std::shared_ptr<Type> make(TypeKind k);
  static std::shared_ptr<Type> component(const std::string& name);
  static std::shared_ptr<Type> structType(const std::string& name);
  static std::shared_ptr<Type> enumType(const std::string& name);
  static std::shared_ptr<Type> option(std::shared_ptr<Type> inner);
  static std::shared_ptr<Type> snapshot(std::vector<std::string> components);

  bool isNumeric() const;
  bool isError() const;
  bool isUnknownish() const;
  std::string describe() const;
};

std::shared_ptr<Type> promote(const std::shared_ptr<Type>& a, const std::shared_ptr<Type>& b);
bool assignable(const std::shared_ptr<Type>& dst, const std::shared_ptr<Type>& src);
int numericRank(const std::shared_ptr<Type>& t);

}  // namespace kx