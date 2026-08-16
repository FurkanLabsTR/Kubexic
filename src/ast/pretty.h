#pragma once

#include "ast.h"

#include <ostream>
#include <string>

namespace kx {

void printSource(const Program& program, std::ostream& out);

}  // namespace kx