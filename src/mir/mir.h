#pragma once

#include "ast.h"
#include "checker.h"

#include <map>
#include <ostream>
#include <string>
#include <vector>

namespace kx {

struct SystemAnalysis {
  std::string name;
  std::vector<std::string> matchComponents;
  std::vector<std::string> withoutComponents;

  struct Read {
    std::string component;
    std::string tag;
    bool exact = false;
  };
  std::vector<Read> reads;
};

class Mir {
 public:
  bool analyze(const Checker& checker);

  const std::vector<SystemAnalysis>& systems() const { return systems_; }
  const std::vector<std::string>& errors() const { return errors_; }
  const std::map<std::string, std::vector<std::string>>& publishQueries() const {
    return publishQueries_;
  }

 private:
  void analyzeSystem(const Decl& d, const Checker& c);
  void walkStmt(const Stmt& s, const Checker& c, SystemAnalysis& out);
  void walkExpr(const Expr& e, const Checker& c, SystemAnalysis& out);
  void addComponent(const std::string& name, const Checker& c, SystemAnalysis& out);
  void addRead(const std::string& component, const std::string& tag, bool exact);

  std::vector<SystemAnalysis> systems_;
  std::map<std::string, std::vector<std::string>> publishQueries_;
  std::vector<std::string> errors_;
};

void dumpMir(const Mir& mir, std::ostream& out);

}  // namespace kx