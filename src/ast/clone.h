#pragma once

#include "ast.h"

#include <vector>

namespace kx {

std::vector<StmtPtr> cloneStmts(const std::vector<StmtPtr>& body);

}  // namespace kx