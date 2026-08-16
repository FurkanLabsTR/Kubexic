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
  llvm::Value* toStr(llvm::Value* v, const std::shared_ptr<Type>& t);
  llvm::Value* coerce(llvm::Value* v, llvm::Type* to);
  llvm::Value* valToI64(llvm::Value* v);
  llvm::Value* i64ToVal(llvm::Value* v, llvm::Type* ty);
  int kindCode(const std::shared_ptr<Type>& t);
  llvm::Type* structType(const std::string& name);

  llvm::Function* ensureFunction(const Decl& d,
                                const std::vector<std::shared_ptr<Type>>& paramTypes);
  void emitSystemFunction(const Decl& d);
  void emitInitCalls();
  void declareEcsRuntime();
  void computeMetadata();
  uint64_t tagBit(const std::string& name) const;
  uint64_t tagAncestors(const std::string& name) const;
  uint64_t tagSubtree(const std::string& name) const;
  int componentIndex(const std::string& name) const;
  int fieldIndex(const std::string& comp, const std::string& field) const;
  llvm::Function* runtimeFn(const std::string& name, llvm::Type* ret,
                            std::vector<llvm::Type*> params);
  std::shared_ptr<Type> fieldType(const std::string& comp, int fieldIdx);
  void emitCompWriteValue(llvm::Value* entity, int compIdx, int fieldIdx,
                          const std::shared_ptr<Type>& ft, llvm::Value* v);
  llvm::Value* emitCompReadValue(llvm::Value* entity, int compIdx, int fieldIdx,
                                 const std::shared_ptr<Type>& ft, llvm::Type* llvmTy);
  llvm::Value* snapReadValue(llvm::Value* handle, int compIdx, int fieldIdx,
                             const std::shared_ptr<Type>& ft, llvm::Type* llvmTy);
  llvm::Value* genComponentRead(const Expr& e, llvm::Value* entityId);
  void genComponentWrite(const Expr& e, llvm::Value* entityId, llvm::Value* val);
  void emitSpawn(const Expr& e);
  uint64_t maskOfNames(const std::vector<std::string>& names) const;
  void extractTagArg(const Expr& call, std::string* tag, bool* exact) const;
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
  llvm::AllocaInst* curSelf_ = nullptr;
  llvm::GlobalVariable* fieldCountsGlobal_ = nullptr;
  llvm::GlobalVariable* systemsGlobal_ = nullptr;
  llvm::Value* spawnResult_ = nullptr;

  std::vector<std::string> compNames_;
  std::map<std::string, std::vector<std::string>> compFields_;
  std::map<std::string, uint64_t> tagBits_;
  std::map<std::string, std::string> tagParents_;
  std::vector<std::string> tagOrder_;
  std::vector<std::string> systemOrder_;
  std::vector<std::string> errors_;
};

}  // namespace kx