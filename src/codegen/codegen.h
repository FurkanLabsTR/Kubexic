#pragma once

#include "checker.h"
#include "mir.h"
#include "types.h"

#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"

#include <map>
#include <memory>
#include <string>
#include <vector>

namespace kx {

class Codegen {
 public:
  Codegen(Checker& checker, const Mir& mir, const std::string& triple);

  bool emitObject(const std::string& objectPath);
  bool emitExecutable(const std::string& objectPath, const std::string& runtimeObject,
                      const std::string& outputPath);
  const std::vector<std::string>& errors() const { return errors_; }

 private:
  struct LoopCtx {
    llvm::BasicBlock* continueTarget = nullptr;
    llvm::BasicBlock* breakTarget = nullptr;
  };

  llvm::Type* llvmType(const std::shared_ptr<Type>& t);
  llvm::Function* declareRuntime(const std::string& name, llvm::Type* ret,
                                 std::vector<llvm::Type*> params);
  llvm::Function* getRuntime(const std::string& name);

  void emitFunction(const Decl& d, const std::vector<std::shared_ptr<Type>>& paramTypes);
  llvm::Value* genExpr(const Expr& e);
  llvm::Value* genCall(const Expr& call);
  void genStmt(const Stmt& s);
  void genBlock(const std::vector<StmtPtr>& body);
  void storeTo(const Expr& lhs, llvm::Value* val);
  llvm::Value* loadLocal(const std::string& name);
  llvm::Value* toStr(llvm::Value* v, const std::shared_ptr<Type>& t);
  llvm::Value* coerce(llvm::Value* v, llvm::Type* to);
  llvm::Type* structType(const std::string& name);
  void error(const SourceLoc& loc, const std::string& msg);

  Checker& checker_;
  const Mir& mir_;
  std::string triple_;
  llvm::LLVMContext ctx_;
  std::unique_ptr<llvm::Module> module_;
  llvm::IRBuilder<> builder_;

  std::map<std::string, llvm::Function*> runtimeCache_;
  std::map<std::string, llvm::Type*> structCache_;
  std::map<std::string, llvm::Function*> specializations_;
  std::map<std::string, std::shared_ptr<Type>> specRetTypes_;
  std::map<std::string, llvm::AllocaInst*> locals_;
  std::vector<LoopCtx> loops_;
  llvm::Function* curFn_ = nullptr;
  llvm::Type* curRetType_ = nullptr;
  std::string curFnName_;
  std::vector<std::string> errors_;
};

}  // namespace kx