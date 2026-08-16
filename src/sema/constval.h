#pragma once

#include <string>

namespace kx {

struct ConstValue {
  enum class Kind { Int, Float, Bool, String };
  Kind kind = Kind::Int;
  long long intVal = 0;
  double floatVal = 0.0;
  bool boolVal = false;
  std::string strVal;
};

}  // namespace kx