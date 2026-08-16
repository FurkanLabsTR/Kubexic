#pragma once

#include "ast.h"
#include "constval.h"
#include "types.h"

#include <map>
#include <memory>
#include <string>
#include <vector>

namespace kx {

class Checker {
 public:
  void addProgram(std::unique_ptr<Program> program);
  bool check();
  const std::vector<std::string>& errors() const { return errors_; }
  const std::map<std::string, const Decl*>& components() const { return components_; }
  const std::map<std::string, const Decl*>& systems() const { return systems_; }
  const std::map<std::string, const Decl*>& tags() const { return tags_; }
  const std::map<std::string, const Decl*>& structs() const { return structs_; }
  const std::map<std::string, const Decl*>& enums() const { return enums_; }
  const Decl* functionByName(const std::string& name) const;
  bool constValue(const std::string& name, ConstValue* out) const;
  std::shared_ptr<Type> reInferBody(const std::vector<StmtPtr>& body,
                                    const std::map<std::string, std::shared_ptr<Type>>& params);

 private:
  struct Local {
    std::string name;
    std::shared_ptr<Type> type;
  };

  std::vector<std::unique_ptr<Program>> programs_;
  std::map<std::string, const Decl*> components_;
  std::map<std::string, const Decl*> systems_;
  std::map<std::string, const Decl*> tags_;
  std::map<std::string, const Decl*> structs_;
  std::map<std::string, const Decl*> enums_;
  std::map<std::string, ConstValue> consts_;
  std::map<std::string, const Decl*> functions_;
  std::map<std::string, std::map<std::string, std::shared_ptr<Type>>> componentFields_;
  std::map<std::string, std::map<std::string, std::shared_ptr<Type>>> structFields_;

  std::vector<std::vector<Local>> scopes_;
  std::vector<std::string> errors_;

  std::string curFnName_;
  std::string curFnRet_;
  std::shared_ptr<Type> varRetType_;
  bool inSystem_ = false;
  bool mainSeen_ = false;
  int loopDepth_ = 0;

  void error(const SourceLoc& loc, const std::string& msg);
  void declare(const Decl& d);
  void pushScope();
  void popScope();
  void addLocal(const std::string& name, std::shared_ptr<Type> t);
  std::shared_ptr<Type> lookupLocal(const std::string& name) const;

  std::shared_ptr<Type> infer(Expr& e);
  std::shared_ptr<Type> checkComponentInit(const ComponentInit& ci);
  std::shared_ptr<Type> inferCall(Expr& call);
  void checkStmt(Stmt& s);
  void checkBlock(std::vector<StmtPtr>& body);
  void checkSystem(Decl& d);
  void checkFunction(Decl& d);
  ConstValue evalConst(Expr& e, bool& ok);
  void registerPatternVars(Expr& cond);

  const Decl* componentByName(const std::string& name) const;
  const Decl* structByName(const std::string& name) const;
  bool validateComponentName(const std::string& name, const SourceLoc& loc);
  void checkAttributes(const Decl& d);
  void computeFieldTypes();
  std::shared_ptr<Type> typeFromTypeName(const std::string& name, const SourceLoc& loc);
};

}  // namespace kx