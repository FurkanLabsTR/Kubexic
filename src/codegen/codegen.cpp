#include "codegen.h"

#include <climits>

#include "clone.h"
#include "constval.h"

#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Verifier.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetOptions.h"
#include "llvm/TargetParser/Triple.h"

#include <cstdio>
#include <sstream>
#include <string>
#include <utility>

namespace kx {

namespace {

std::string typeSig(const std::shared_ptr<Type>& t) {
  switch (t->kind) {
    case TypeKind::Void: return "void";
    case TypeKind::Bool: return "bool";
    case TypeKind::Int: return "int";
    case TypeKind::Long: return "long";
    case TypeKind::Float: return "float";
    case TypeKind::Double: return "double";
    case TypeKind::Byte: return "byte";
    case TypeKind::String: return "string";
    case TypeKind::EntityId: return "entity";
    case TypeKind::Option: return "opt_" + (t->inner ? typeSig(t->inner) : std::string("?"));
    case TypeKind::Struct: return "struct_" + t->name;
    case TypeKind::Enum: return "enum_" + t->name;
    case TypeKind::Rng: return "rng";
    case TypeKind::List: return "list_" + (t->inner ? typeSig(t->inner) : std::string("x"));
    case TypeKind::Map:
      return "map_" + (t->inner ? typeSig(t->inner) : std::string("x")) + "_" +
             (t->inner2 ? typeSig(t->inner2) : std::string("x"));
    default: return "x";
  }
}

std::string mangle(const std::string& name, const std::vector<std::shared_ptr<Type>>& params) {
  if (name == "main") return "main";
  std::string s = name + "#";
  for (const auto& p : params) s += typeSig(p) + ":";
  return s;
}

void maybeBr(llvm::IRBuilder<>& b, llvm::BasicBlock* target) {
  auto cur = b.GetInsertBlock();
  if (cur && !cur->getTerminator()) b.CreateBr(target);
}

}  // namespace

Codegen::Codegen(Checker& checker, const Mir& mir, const std::string& triple)
    : checker_(checker), mir_(mir), triple_(triple), builder_(ctx_) {
  module_ = std::make_unique<llvm::Module>("kubexic", ctx_);
  module_->setSourceFileName("kubexic");
  llvm::InitializeNativeTarget();
  llvm::InitializeNativeTargetAsmPrinter();
  computeMetadata();
}

void Codegen::computeMetadata() {
  compNames_.clear();
  compIndexMap_.clear();
  fieldIndexMap_.clear();
  for (const auto& [name, d] : checker_.components()) compNames_.push_back(name);
  std::sort(compNames_.begin(), compNames_.end());
  if (compNames_.size() > 64) errors_.push_back("codegen: too many components (max 64)");
  for (size_t i = 0; i < compNames_.size(); i++) {
    compIndexMap_[compNames_[i]] = (int)i;
    const Decl* d = checker_.components().at(compNames_[i]);
    std::vector<std::string> fields;
    std::map<std::string, int> fmap;
    for (size_t fi = 0; fi < d->fields.size(); fi++) {
      fields.push_back(d->fields[fi].first);
      fmap[d->fields[fi].first] = (int)fi;
    }
    compFields_[compNames_[i]] = fields;
    fieldIndexMap_[compNames_[i]] = fmap;
  }

  tagOrder_.clear();
  for (const auto& [name, d] : checker_.tags()) {
    tagOrder_.push_back(name);
    tagParents_[name] = d->parentTag;
  }
  std::sort(tagOrder_.begin(), tagOrder_.end());
  if (tagOrder_.size() > 64) errors_.push_back("codegen: too many tags (max 64)");
  for (size_t i = 0; i < tagOrder_.size(); i++) tagBits_[tagOrder_[i]] = 1ULL << i;

  systemOrder_.clear();
  for (const auto& [name, d] : checker_.systems()) systemOrder_.push_back(name);
  std::sort(systemOrder_.begin(), systemOrder_.end());
}

uint64_t Codegen::tagBit(const std::string& name) const {
  auto it = tagBits_.find(name);
  return it == tagBits_.end() ? 0 : it->second;
}

uint64_t Codegen::tagAncestors(const std::string& name) const {
  uint64_t m = 0;
  std::string cur = name;
  for (;;) {
    auto it = tagParents_.find(cur);
    if (it == tagParents_.end()) break;
    m |= tagBit(it->second);
    cur = it->second;
  }
  return m;
}

uint64_t Codegen::tagSubtree(const std::string& name) const {
  uint64_t m = tagBit(name);
  for (const auto& t : tagOrder_) {
    if (t == name) continue;
    std::string cur = t;
    for (;;) {
      auto it = tagParents_.find(cur);
      if (it == tagParents_.end()) break;
      if (it->second == name) {
        m |= tagBit(t);
        break;
      }
      cur = it->second;
    }
  }
  return m;
}

int Codegen::componentIndex(const std::string& name) const {
  auto it = compIndexMap_.find(name);
  return it != compIndexMap_.end() ? it->second : -1;
}

int Codegen::fieldIndex(const std::string& comp, const std::string& field) const {
  auto ci = fieldIndexMap_.find(comp);
  if (ci == fieldIndexMap_.end()) return -1;
  auto fi = ci->second.find(field);
  return fi != ci->second.end() ? fi->second : -1;
}

llvm::Function* Codegen::runtimeFn(const std::string& name, llvm::Type* ret,
                                   std::vector<llvm::Type*> params) {
  auto it = runtimeCache_.find(name);
  if (it != runtimeCache_.end()) return it->second;
  return declareRuntime(name, ret, std::move(params));
}

void Codegen::declareEcsRuntime() {
  auto voidTy = llvm::Type::getVoidTy(ctx_);
  auto i32 = llvm::Type::getInt32Ty(ctx_);
  auto i64 = llvm::Type::getInt64Ty(ctx_);
  auto f64 = llvm::Type::getDoubleTy(ctx_);
  auto i1 = llvm::Type::getInt1Ty(ctx_);
  auto ptr = llvm::PointerType::get(ctx_, 0);
  runtimeFn("kx_init", voidTy, {i32, ptr, ptr});
  runtimeFn("kx_set_systems", voidTy, {i32, ptr});
  runtimeFn("kx_spawn", i64, {i64});
  runtimeFn("kx_despawn", voidTy, {i64});
  runtimeFn("kx_ensure_comp", voidTy, {i64, i32});
  runtimeFn("kx_detach_comp", voidTy, {i64, i32});
  runtimeFn("kx_comp_read_i64", i64, {i64, i32, i32});
  runtimeFn("kx_comp_write_i64", voidTy, {i64, i32, i32, i64});
  runtimeFn("kx_comp_read_f64", f64, {i64, i32, i32});
  runtimeFn("kx_comp_write_f64", voidTy, {i64, i32, i32, f64});
  runtimeFn("kx_comp_read_str", ptr, {i64, i32, i32});
  runtimeFn("kx_comp_write_str", voidTy, {i64, i32, i32, ptr});
  runtimeFn("kx_others_begin", i64, {i64, i32});
  runtimeFn("kx_others_next", i64, {i64, i64, i32});
  runtimeFn("kx_snap_id", i64, {i64});
  runtimeFn("kx_snap_read_i64", i64, {i64, i32, i32});
  runtimeFn("kx_snap_read_f64", f64, {i64, i32, i32});
  runtimeFn("kx_snap_read_str", ptr, {i64, i32, i32});
  runtimeFn("kx_list_new", i64, {i32});
  runtimeFn("kx_list_add", voidTy, {i64, i64});
  runtimeFn("kx_list_get", i64, {i64, i64});
  runtimeFn("kx_list_set", voidTy, {i64, i64, i64});
  runtimeFn("kx_list_remove_at", voidTy, {i64, i64});
  runtimeFn("kx_list_clear", voidTy, {i64});
  runtimeFn("kx_list_size", i64, {i64});
  runtimeFn("kx_list_begin", i64, {i64});
  runtimeFn("kx_list_next", i64, {i64, i64});
  runtimeFn("kx_map_new", i64, {i32, i32});
  runtimeFn("kx_map_set", voidTy, {i64, i64, i64});
  runtimeFn("kx_map_get", i64, {i64, i64});
  runtimeFn("kx_map_has", i1, {i64, i64});
  runtimeFn("kx_map_remove", voidTy, {i64, i64});
  runtimeFn("kx_map_clear", voidTy, {i64});
  runtimeFn("kx_map_size", i64, {i64});
  runtimeFn("kx_run", voidTy, {i32, i64, f64});
  runtimeFn("kx_stop", voidTy, {});
  runtimeFn("kx_get_dt", f64, {});
  runtimeFn("kx_get_tick", i64, {});
  runtimeFn("kx_spatial_set_cell_size", voidTy, {f64});
  runtimeFn("kx_spatial_set_comp", voidTy, {i32, i32, i32, i32, i32});
  runtimeFn("kx_spatial_set_tag_mask", voidTy, {i64});
  runtimeFn("kx_spatial_query_begin", i64, {f64, f64, f64, f64});
  runtimeFn("kx_spatial_query_next", i64, {i64, f64, f64, f64, f64});
  runtimeFn("kx_spatial_query_count", i64, {f64, f64, f64, f64});
}

std::shared_ptr<Type> Codegen::fieldType(const std::string& comp, int fieldIdx) {
  const Decl* d = checker_.components().at(comp);
  if (fieldIdx >= 0 && fieldIdx < (int)d->fields.size() && d->fields[fieldIdx].second->type) {
    return d->fields[fieldIdx].second->type;
  }
  return Type::make(TypeKind::Int);
}

void Codegen::emitCompWriteValue(llvm::Value* entity, int compIdx, int fieldIdx,
                                 const std::shared_ptr<Type>& ft, llvm::Value* v) {
  auto i32 = llvm::Type::getInt32Ty(ctx_);
  auto compC = llvm::ConstantInt::get(i32, compIdx);
  auto fieldC = llvm::ConstantInt::get(i32, fieldIdx);
  switch (ft->kind) {
    case TypeKind::Double: {
      auto f = runtimeFn("kx_comp_write_f64", llvm::Type::getVoidTy(ctx_),
                         {llvm::Type::getInt64Ty(ctx_), i32, i32, llvm::Type::getDoubleTy(ctx_)});
      builder_.CreateCall(f, {entity, compC, fieldC, coerce(v, llvm::Type::getDoubleTy(ctx_))});
      break;
    }
    case TypeKind::Float: {
      auto f = runtimeFn("kx_comp_write_f64", llvm::Type::getVoidTy(ctx_),
                         {llvm::Type::getInt64Ty(ctx_), i32, i32, llvm::Type::getDoubleTy(ctx_)});
      builder_.CreateCall(f, {entity, compC, fieldC,
                              builder_.CreateFPExt(v, llvm::Type::getDoubleTy(ctx_))});
      break;
    }
    case TypeKind::String: {
      auto f = runtimeFn("kx_comp_write_str", llvm::Type::getVoidTy(ctx_),
                         {llvm::Type::getInt64Ty(ctx_), i32, i32, llvm::PointerType::get(ctx_, 0)});
      builder_.CreateCall(f, {entity, compC, fieldC, v});
      break;
    }
    default: {
      auto f = runtimeFn("kx_comp_write_i64", llvm::Type::getVoidTy(ctx_),
                         {llvm::Type::getInt64Ty(ctx_), i32, i32, llvm::Type::getInt64Ty(ctx_)});
      builder_.CreateCall(f, {entity, compC, fieldC,
                              coerce(v, llvm::Type::getInt64Ty(ctx_))});
      break;
    }
  }
}

llvm::Value* Codegen::emitCompReadValue(llvm::Value* entity, int compIdx, int fieldIdx,
                                        const std::shared_ptr<Type>& ft, llvm::Type* llvmTy) {
  auto i32 = llvm::Type::getInt32Ty(ctx_);
  auto compC = llvm::ConstantInt::get(i32, compIdx);
  auto fieldC = llvm::ConstantInt::get(i32, fieldIdx);
  switch (ft->kind) {
    case TypeKind::Double: {
      auto f = runtimeFn("kx_comp_read_f64", llvm::Type::getDoubleTy(ctx_),
                         {llvm::Type::getInt64Ty(ctx_), i32, i32});
      return builder_.CreateCall(f, {entity, compC, fieldC});
    }
    case TypeKind::Float: {
      auto f = runtimeFn("kx_comp_read_f64", llvm::Type::getDoubleTy(ctx_),
                         {llvm::Type::getInt64Ty(ctx_), i32, i32});
      auto d = builder_.CreateCall(f, {entity, compC, fieldC});
      return builder_.CreateFPTrunc(d, llvmTy);
    }
    case TypeKind::String: {
      auto f = runtimeFn("kx_comp_read_str", llvm::PointerType::get(ctx_, 0),
                         {llvm::Type::getInt64Ty(ctx_), i32, i32});
      return builder_.CreateCall(f, {entity, compC, fieldC});
    }
    default: {
      auto f = runtimeFn("kx_comp_read_i64", llvm::Type::getInt64Ty(ctx_),
                         {llvm::Type::getInt64Ty(ctx_), i32, i32});
      auto v = builder_.CreateCall(f, {entity, compC, fieldC});
      return coerce(v, llvmTy);
    }
  }
}

llvm::Value* Codegen::genComponentRead(const Expr& e, llvm::Value* entityId) {
  if (e.kind != Expr::Kind::MemberAccess || !e.lhs || e.lhs->kind != Expr::Kind::Identifier)
    return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
  int c = componentIndex(e.lhs->str);
  int f = fieldIndex(e.lhs->str, e.member);
  if (c < 0 || f < 0) return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
  auto ft = fieldType(e.lhs->str, f);
  return emitCompReadValue(entityId, c, f, ft, llvmType(e.type));
}

void Codegen::genComponentWrite(const Expr& e, llvm::Value* entityId, llvm::Value* val) {
  if (e.kind != Expr::Kind::MemberAccess || !e.lhs || e.lhs->kind != Expr::Kind::Identifier)
    return;
  int c = componentIndex(e.lhs->str);
  int f = fieldIndex(e.lhs->str, e.member);
  if (c < 0 || f < 0) return;
  auto ft = fieldType(e.lhs->str, f);
  emitCompWriteValue(entityId, c, f, ft, val);
}

llvm::Value* Codegen::snapReadValue(llvm::Value* handle, int compIdx, int fieldIdx,
                                    const std::shared_ptr<Type>& ft, llvm::Type* llvmTy) {
  auto i32 = llvm::Type::getInt32Ty(ctx_);
  auto compC = llvm::ConstantInt::get(i32, compIdx);
  auto fieldC = llvm::ConstantInt::get(i32, fieldIdx);
  switch (ft->kind) {
    case TypeKind::Double: {
      auto f = runtimeFn("kx_snap_read_f64", llvm::Type::getDoubleTy(ctx_),
                         {llvm::Type::getInt64Ty(ctx_), i32, i32});
      return builder_.CreateCall(f, {handle, compC, fieldC});
    }
    case TypeKind::Float: {
      auto f = runtimeFn("kx_snap_read_f64", llvm::Type::getDoubleTy(ctx_),
                         {llvm::Type::getInt64Ty(ctx_), i32, i32});
      auto d = builder_.CreateCall(f, {handle, compC, fieldC});
      return builder_.CreateFPTrunc(d, llvmTy);
    }
    case TypeKind::String: {
      auto f = runtimeFn("kx_snap_read_str", llvm::PointerType::get(ctx_, 0),
                         {llvm::Type::getInt64Ty(ctx_), i32, i32});
      return builder_.CreateCall(f, {handle, compC, fieldC});
    }
    default: {
      auto f = runtimeFn("kx_snap_read_i64", llvm::Type::getInt64Ty(ctx_),
                         {llvm::Type::getInt64Ty(ctx_), i32, i32});
      auto v = builder_.CreateCall(f, {handle, compC, fieldC});
      return coerce(v, llvmTy);
    }
  }
}

static bool isFreshCollection(const Expr* e) {
  return e && e->kind == Expr::Kind::Call && e->lhs &&
         e->lhs->kind == Expr::Kind::Identifier &&
         (e->lhs->str == "List" || e->lhs->str == "Map");
}

void Codegen::emitSpawn(const Expr& e) {
  uint64_t mask = 0;
  for (const auto& t : e.spawnTags) mask |= tagBit(t) | tagAncestors(t);
  auto i64 = llvm::Type::getInt64Ty(ctx_);
  auto spawnFn = runtimeFn("kx_spawn", i64, {i64});
  auto entity = builder_.CreateCall(spawnFn, {llvm::ConstantInt::get(i64, mask)});
  for (const auto& ci : e.spawnInits) {
    int c = componentIndex(ci.type);
    if (c < 0) continue;
    auto ensure = runtimeFn("kx_ensure_comp", llvm::Type::getVoidTy(ctx_),
                            {i64, llvm::Type::getInt32Ty(ctx_)});
    builder_.CreateCall(ensure,
                        {entity, llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), c)});
    for (const auto& f : ci.fields) {
      int fi = fieldIndex(ci.type, f.first);
      if (fi < 0) continue;
      auto ft = fieldType(ci.type, fi);
      auto v = genExpr(*f.second);
      if (isFreshCollection(f.second.get()) && ft->isCollection()) {
        auto take = runtimeFn("kx_comp_take_i64", llvm::Type::getVoidTy(ctx_),
                              {llvm::Type::getInt64Ty(ctx_), llvm::Type::getInt32Ty(ctx_),
                               llvm::Type::getInt32Ty(ctx_), llvm::Type::getInt64Ty(ctx_)});
        builder_.CreateCall(take, {entity,
                                   llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), c),
                                   llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), fi),
                                   valToI64(v)});
      } else {
        emitCompWriteValue(entity, c, fi, ft, v);
      }
    }
  }
  spawnResult_ = entity;
}

uint64_t Codegen::maskOfNames(const std::vector<std::string>& names) const {
  uint64_t m = 0;
  for (const auto& n : names) {
    int c = componentIndex(n);
    if (c >= 0) m |= 1ULL << c;
  }
  return m;
}

void Codegen::extractTagArg(const Expr& call, std::string* tag, bool* exact) const {
  *tag = "";
  *exact = false;
  for (const auto& arg : call.args) {
    if (arg.name == "tag" && arg.value) {
      if (arg.value->kind == Expr::Kind::Unary && arg.value->unOp == UnaryOp::Exact &&
          arg.value->lhs && arg.value->lhs->kind == Expr::Kind::Identifier) {
        *tag = arg.value->lhs->str;
        *exact = true;
      } else if (arg.value->kind == Expr::Kind::Identifier) {
        *tag = arg.value->str;
      }
    }
  }
}

void Codegen::emitInitCalls() {
  auto i32 = llvm::Type::getInt32Ty(ctx_);
  auto i64 = llvm::Type::getInt64Ty(ctx_);
  auto ptr = llvm::PointerType::get(ctx_, 0);

  std::vector<llvm::Constant*> counts;
  std::vector<llvm::Constant*> types;
  for (const auto& name : compNames_) {
    counts.push_back(llvm::ConstantInt::get(i32, (uint64_t)compFields_[name].size()));
    for (size_t fi = 0; fi < compFields_[name].size(); fi++) {
      types.push_back(llvm::ConstantInt::get(i32, (uint64_t)kindCode(fieldType(name, (int)fi))));
    }
  }
  auto countsArrTy = llvm::ArrayType::get(i32, counts.size());
  auto countsGv = new llvm::GlobalVariable(
      *module_, countsArrTy, true, llvm::GlobalValue::InternalLinkage,
      llvm::ConstantArray::get(countsArrTy, counts), "kx_field_counts");
  auto typesArrTy = llvm::ArrayType::get(i32, types.size());
  auto typesGv = new llvm::GlobalVariable(
      *module_, typesArrTy, true, llvm::GlobalValue::InternalLinkage,
      llvm::ConstantArray::get(typesArrTy, types), "kx_field_types");
  auto initFn = runtimeFn("kx_init", llvm::Type::getVoidTy(ctx_), {i32, ptr, ptr});
  builder_.CreateCall(initFn, {llvm::ConstantInt::get(i32, (uint64_t)compNames_.size()),
                               builder_.CreateConstGEP2_32(countsArrTy, countsGv, 0, 0),
                               builder_.CreateConstGEP2_32(typesArrTy, typesGv, 0, 0)});
  if (!compNames_.empty()) {
    std::vector<llvm::Constant*> names;
    for (const auto& n : compNames_) {
      names.push_back(builder_.CreateGlobalStringPtr(n));
    }
    auto namesArrTy = llvm::ArrayType::get(ptr, names.size());
    auto namesGv = new llvm::GlobalVariable(
        *module_, namesArrTy, true, llvm::GlobalValue::InternalLinkage,
        llvm::ConstantArray::get(namesArrTy, names), "kx_comp_names");
    auto namesFn = runtimeFn("kx_set_comp_names", llvm::Type::getVoidTy(ctx_), {i32, ptr});
    builder_.CreateCall(namesFn, {llvm::ConstantInt::get(i32, (uint64_t)names.size()),
                                  builder_.CreateConstGEP2_32(namesArrTy, namesGv, 0, 0)});
  }

  if (!systemOrder_.empty()) {
    auto sysTy = llvm::StructType::get(ctx_, {i64, i64, ptr});
    std::vector<llvm::Constant*> entries;
    for (const auto& name : systemOrder_) {
      const SystemAnalysis* sa = nullptr;
      for (const auto& s : mir_.systems()) {
        if (s.name == name) { sa = &s; break; }
      }
      uint64_t matchMask = sa ? maskOfNames(sa->matchComponents) : 0;
      uint64_t withoutMask = sa ? maskOfNames(sa->withoutComponents) : 0;
      auto body = module_->getFunction("kx_system_" + name);
      entries.push_back(llvm::ConstantStruct::get(
          sysTy, {llvm::ConstantInt::get(i64, matchMask),
                  llvm::ConstantInt::get(i64, withoutMask), body}));
    }
    auto sysArrTy = llvm::ArrayType::get(sysTy, entries.size());
    auto sysGv = new llvm::GlobalVariable(
        *module_, sysArrTy, true, llvm::GlobalValue::InternalLinkage,
        llvm::ConstantArray::get(sysArrTy, entries), "kx_systems");
    auto setFn = runtimeFn("kx_set_systems", llvm::Type::getVoidTy(ctx_), {i32, ptr});
    builder_.CreateCall(setFn,
                        {llvm::ConstantInt::get(i32, (uint64_t)entries.size()),
                         builder_.CreateConstGEP2_32(sysArrTy, sysGv, 0, 0)});
  }
}

llvm::Type* Codegen::llvmTypeFromName(const std::string& name) {
  if (name == "void") return llvm::Type::getVoidTy(ctx_);
  if (name == "bool") return llvm::Type::getInt1Ty(ctx_);
  if (name == "int") return llvm::Type::getInt32Ty(ctx_);
  if (name == "long") return llvm::Type::getInt64Ty(ctx_);
  if (name == "float") return llvm::Type::getFloatTy(ctx_);
  if (name == "double") return llvm::Type::getDoubleTy(ctx_);
  if (name == "byte") return llvm::Type::getInt8Ty(ctx_);
  if (name == "string") return llvm::PointerType::get(ctx_, 0);
  if (name == "EntityId") return llvm::Type::getInt64Ty(ctx_);
  auto st = checker_.structs().find(name);
  if (st != checker_.structs().end()) return structType(name);
  return llvm::Type::getInt64Ty(ctx_);
}

llvm::Function* Codegen::ensureExtern(const Decl& d) {
  std::string key = "extern_" + d.name;
  auto it = runtimeCache_.find(key);
  if (it != runtimeCache_.end()) return it->second;
  std::vector<llvm::Type*> params;
  for (const auto& pt : d.paramTypes) params.push_back(llvmTypeFromName(pt));
  auto ft = llvm::FunctionType::get(llvmTypeFromName(d.retKind), params, false);
  auto fn = llvm::Function::Create(ft, llvm::GlobalValue::ExternalLinkage, d.name, *module_);
  runtimeCache_[key] = fn;
  return fn;
}

std::vector<std::string> Codegen::linkLibraries() const {
  std::vector<std::string> libs;
  for (const Decl* d : checker_.externDecls()) {
    for (const auto& a : d->attributes) {
      if (a.name == "Link" && !a.args.empty() && a.args[0]->kind == Expr::Kind::StringLit) {
        libs.push_back(a.args[0]->str);
      }
    }
  }
  return libs;
}

llvm::Function* Codegen::ensureFunction(const Decl& d,
                                         const std::vector<std::shared_ptr<Type>>& paramTypes) {
  std::string key = mangle(d.name, paramTypes);
  auto it = specializations_.find(key);
  if (it != specializations_.end()) return it->second;
  auto saveBlock = builder_.GetInsertBlock();
  auto savedLocals = locals_;
  auto savedFn = curFn_;
  auto savedRet = curRetType_;
  auto savedLoops = loops_;
  emitFunction(d, paramTypes);
  locals_ = savedLocals;
  curFn_ = savedFn;
  curRetType_ = savedRet;
  loops_ = savedLoops;
  builder_.SetInsertPoint(saveBlock);
  return specializations_[key];
}

void Codegen::emitSystemFunction(const Decl& d) {
  auto voidTy = llvm::Type::getVoidTy(ctx_);
  auto i64 = llvm::Type::getInt64Ty(ctx_);
  auto ft = llvm::FunctionType::get(voidTy, {i64}, false);
  auto fn = llvm::Function::Create(ft, llvm::GlobalValue::ExternalLinkage,
                                   "kx_system_" + d.name, *module_);
  curFn_ = fn;
  curRetType_ = voidTy;
  locals_.clear();
  loops_.clear();
  spawnResult_ = nullptr;

  auto entry = llvm::BasicBlock::Create(ctx_, "entry", fn);
  builder_.SetInsertPoint(entry);
  auto selfAlloca = builder_.CreateAlloca(i64);
  builder_.CreateStore(&*fn->arg_begin(), selfAlloca);
  locals_["self"] = selfAlloca;
  curSelf_ = selfAlloca;

  if (d.body) {
    for (const auto& s : d.body->body) genStmt(*s);
  }
  auto block = builder_.GetInsertBlock();
  if (block && !block->getTerminator()) builder_.CreateRetVoid();
}

void Codegen::error(const SourceLoc& loc, const std::string& msg) {
  errors_.push_back(std::to_string(loc.line) + ":" + std::to_string(loc.col) + ": " + msg);
}

llvm::Type* Codegen::llvmType(const std::shared_ptr<Type>& t) {
  switch (t->kind) {
    case TypeKind::Void: return llvm::Type::getVoidTy(ctx_);
    case TypeKind::Bool: return llvm::Type::getInt1Ty(ctx_);
    case TypeKind::Int: return llvm::Type::getInt32Ty(ctx_);
    case TypeKind::Long: return llvm::Type::getInt64Ty(ctx_);
    case TypeKind::Float: return llvm::Type::getFloatTy(ctx_);
    case TypeKind::Double: return llvm::Type::getDoubleTy(ctx_);
    case TypeKind::Byte: return llvm::Type::getInt8Ty(ctx_);
    case TypeKind::String: return llvm::PointerType::get(ctx_, 0);
    case TypeKind::EntityId: return llvm::Type::getInt64Ty(ctx_);
    case TypeKind::Option: {
      auto inner = llvmType(t->inner ? t->inner : Type::make(TypeKind::Int));
      return llvm::StructType::get(ctx_, {llvm::Type::getInt1Ty(ctx_), inner});
    }
    case TypeKind::Struct: return structType(t->name);
    case TypeKind::Enum: return llvm::Type::getInt32Ty(ctx_);
    case TypeKind::List:
    case TypeKind::Map:
    case TypeKind::Rng:
      return llvm::Type::getInt64Ty(ctx_);
    default: return llvm::Type::getInt64Ty(ctx_);
  }
}

llvm::Type* Codegen::structType(const std::string& name) {
  auto it = structCache_.find(name);
  if (it != structCache_.end()) return it->second;

  std::vector<llvm::Type*> fields;
  auto it2 = checker_.structs().find(name);
  if (it2 != checker_.structs().end()) {
    for (const auto& f : it2->second->fields) {
      fields.push_back(llvmType(f.second->type ? f.second->type : Type::make(TypeKind::Int)));
    }
  }
  auto st = llvm::StructType::create(ctx_, "struct." + name);
  st->setBody(fields);
  structCache_[name] = st;
  return st;
}

llvm::Function* Codegen::declareRuntime(const std::string& name, llvm::Type* ret,
                                        std::vector<llvm::Type*> params) {
  auto ft = llvm::FunctionType::get(ret, params, false);
  auto fn = llvm::Function::Create(ft, llvm::GlobalValue::ExternalLinkage, name, *module_);
  runtimeCache_[name] = fn;
  return fn;
}

llvm::Function* Codegen::getRuntime(const std::string& name) {
  auto it = runtimeCache_.find(name);
  if (it != runtimeCache_.end()) return it->second;
  return nullptr;
}

llvm::Value* Codegen::coerce(llvm::Value* v, llvm::Type* to) {
  if (!v || v->getType() == to) return v;
  auto from = v->getType();
  if (from->isIntegerTy() && to->isIntegerTy()) {
    unsigned fw = from->getIntegerBitWidth(), tw = to->getIntegerBitWidth();
    if (fw < tw) return builder_.CreateSExt(v, to);
    if (fw > tw) return builder_.CreateTrunc(v, to);
  }
  if (from->isFloatingPointTy() && to->isFloatingPointTy()) {
    return builder_.CreateFPExt(v, to);
  }
  if (from->isIntegerTy() && to->isFloatingPointTy()) {
    return builder_.CreateSIToFP(v, to);
  }
  return v;
}

int Codegen::kindCode(const std::shared_ptr<Type>& t) {
  if (!t) return 0;
  if (t->kind == TypeKind::Float || t->kind == TypeKind::Double) return 1;
  if (t->kind == TypeKind::String) return 2;
  if (t->isCollection()) return 3;
  return 0;
}

llvm::Value* Codegen::valToI64(llvm::Value* v) {
  auto i64 = llvm::Type::getInt64Ty(ctx_);
  if (!v) return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
  if (v->getType() == i64) return v;
  if (v->getType()->isIntegerTy()) return builder_.CreateSExt(v, i64);
  if (v->getType()->isFloatingPointTy()) {
    auto d = builder_.CreateFPExt(v, llvm::Type::getDoubleTy(ctx_));
    return builder_.CreateBitCast(d, i64);
  }
  if (v->getType()->isPointerTy()) return builder_.CreatePtrToInt(v, i64);
  return v;
}

llvm::Value* Codegen::i64ToVal(llvm::Value* v, llvm::Type* ty) {
  if (!v || !ty) return v;
  if (v->getType() == ty) return v;
  if (ty->isIntegerTy()) return builder_.CreateTrunc(v, ty);
  if (ty->isFloatingPointTy()) {
    auto d = builder_.CreateBitCast(v, llvm::Type::getDoubleTy(ctx_));
    return builder_.CreateFPTrunc(d, ty);
  }
  if (ty->isPointerTy()) return builder_.CreateIntToPtr(v, ty);
  return v;
}

llvm::Value* Codegen::toStr(llvm::Value* v, const std::shared_ptr<Type>& t) {
  auto i8p = llvm::PointerType::get(ctx_, 0);
  switch (t->kind) {
    case TypeKind::String:
      return v;
    case TypeKind::Int:
    case TypeKind::Long:
    case TypeKind::Byte: {
      auto f = getRuntime("kx_str_from_i64");
      if (!f) f = declareRuntime("kx_str_from_i64", i8p, {llvm::Type::getInt64Ty(ctx_)});
      return builder_.CreateCall(f, {builder_.CreateSExt(v, llvm::Type::getInt64Ty(ctx_))});
    }
    case TypeKind::Float:
    case TypeKind::Double: {
      auto f = getRuntime("kx_str_from_double");
      if (!f) f = declareRuntime("kx_str_from_double", i8p, {llvm::Type::getDoubleTy(ctx_)});
      return builder_.CreateCall(f, {builder_.CreateFPExt(v, llvm::Type::getDoubleTy(ctx_))});
    }
    case TypeKind::Bool: {
      auto sTrue = builder_.CreateGlobalStringPtr("true");
      auto sFalse = builder_.CreateGlobalStringPtr("false");
      return builder_.CreateSelect(v, sTrue, sFalse);
    }
    case TypeKind::EntityId: {
      auto f = getRuntime("kx_str_from_entity");
      if (!f) f = declareRuntime("kx_str_from_entity", i8p, {llvm::Type::getInt64Ty(ctx_)});
      return builder_.CreateCall(f, {builder_.CreateTrunc(v, llvm::Type::getInt64Ty(ctx_))});
    }
    case TypeKind::Option: {
      if (t->inner && t->inner->kind == TypeKind::String) {
        auto ptr = builder_.CreateExtractValue(v, 1);
        auto present = builder_.CreateExtractValue(v, 0);
        auto sNull = builder_.CreateGlobalStringPtr("");
        return builder_.CreateSelect(present, ptr, sNull);
      }
      return builder_.CreateGlobalStringPtr("?");
    }
    default:
      return builder_.CreateGlobalStringPtr("?");
  }
}

void Codegen::storeTo(const Expr& lhs, llvm::Value* val) {
  if (lhs.kind == Expr::Kind::Identifier) {
    auto it = locals_.find(lhs.str);
    if (it == locals_.end()) return;
    auto allocTy = it->second->getAllocatedType();
    if (val && val->getType() != allocTy) {
      if (val->getType()->isIntegerTy() && allocTy->isIntegerTy()) {
        val = builder_.CreateSExt(val, allocTy);
      } else if (val->getType()->isFloatingPointTy() && allocTy->isFloatingPointTy()) {
        val = builder_.CreateFPExt(val, allocTy);
      } else if (val->getType()->isIntegerTy() && allocTy->isFloatingPointTy()) {
        val = builder_.CreateSIToFP(val, allocTy);
      }
    }
    builder_.CreateStore(val, it->second);
    return;
  }
  if (lhs.kind == Expr::Kind::MemberAccess) {
    Expr* base = lhs.lhs.get();
    if (base && base->kind == Expr::Kind::Identifier &&
        checker_.components().count(base->str)) {
      if (curSelf_) {
        auto self = builder_.CreateLoad(llvm::Type::getInt64Ty(ctx_), curSelf_);
        genComponentWrite(lhs, self, val);
      }
      return;
    }
    if (base && base->kind == Expr::Kind::Identifier && base->type &&
        base->type->kind == TypeKind::Struct) {
      auto it = locals_.find(base->str);
      if (it != locals_.end() && it->second->getAllocatedType()->isStructTy()) {
        auto st = llvm::cast<llvm::StructType>(it->second->getAllocatedType());
        int idx = 0;
        auto sit = checker_.structs().find(base->type->name);
        if (sit != checker_.structs().end()) {
          for (size_t i = 0; i < sit->second->fields.size(); ++i) {
            if (sit->second->fields[i].first == lhs.member) { idx = (int)i; break; }
          }
        }
        auto gep = builder_.CreateStructGEP(st, it->second, idx);
        auto fieldTy = st->getElementType(idx);
        if (val && val->getType() != fieldTy) {
          if (val->getType()->isIntegerTy() && fieldTy->isIntegerTy()) {
            val = builder_.CreateSExt(val, fieldTy);
          } else if (val->getType()->isFloatingPointTy() && fieldTy->isFloatingPointTy()) {
            val = builder_.CreateFPExt(val, fieldTy);
          } else if (val->getType()->isIntegerTy() && fieldTy->isFloatingPointTy()) {
            val = builder_.CreateSIToFP(val, fieldTy);
          }
        }
        builder_.CreateStore(val, gep);
      }
    }
  }
}

llvm::Value* Codegen::genExpr(const Expr& e) {
  switch (e.kind) {
    case Expr::Kind::IntLit:
      return llvm::ConstantInt::get(llvmType(e.type), (uint64_t)e.intValue, true);
    case Expr::Kind::FloatLit:
      return llvm::ConstantFP::get(llvmType(e.type), e.floatValue);
    case Expr::Kind::StringLit:
      return builder_.CreateGlobalStringPtr(e.str);
    case Expr::Kind::BoolLit:
      return llvm::ConstantInt::get(llvm::Type::getInt1Ty(ctx_), e.intValue != 0);
    case Expr::Kind::Identifier: {
      auto it = locals_.find(e.str);
      if (it != locals_.end()) {
        return builder_.CreateLoad(it->second->getAllocatedType(), it->second);
      }
      if (e.str == "dt") {
        auto f = runtimeFn("kx_get_dt", llvm::Type::getDoubleTy(ctx_), {});
        return builder_.CreateCall(f, {});
      }
      if (e.str == "tick") {
        auto f = runtimeFn("kx_get_tick", llvm::Type::getInt64Ty(ctx_), {});
        return builder_.CreateCall(f, {});
      }
      ConstValue cv;
      if (checker_.constValue(e.str, &cv)) {
        switch (cv.kind) {
          case ConstValue::Kind::Int: {
            if (e.type && e.type->kind == TypeKind::Long) {
              return llvm::ConstantInt::get(llvm::Type::getInt64Ty(ctx_), (uint64_t)cv.intVal, true);
            }
            return llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), (uint64_t)cv.intVal, true);
          }
          case ConstValue::Kind::Float: {
            if (e.type && e.type->kind == TypeKind::Float) {
              return llvm::ConstantFP::get(llvm::Type::getFloatTy(ctx_), cv.floatVal);
            }
            return llvm::ConstantFP::get(llvm::Type::getDoubleTy(ctx_), cv.floatVal);
          }
          case ConstValue::Kind::Bool:
            return llvm::ConstantInt::get(llvm::Type::getInt1Ty(ctx_), cv.boolVal);
          case ConstValue::Kind::String:
            return builder_.CreateGlobalStringPtr(cv.strVal);
        }
      }
      return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
    }
    case Expr::Kind::MemberAccess: {
      Expr* base = e.lhs.get();
      if (base && base->type && base->type->kind == TypeKind::String) {
        auto obj = genExpr(*base);
        if (e.member == "Length") {
          auto f = runtimeFn("kx_str_len", llvm::Type::getInt64Ty(ctx_),
                             {llvm::PointerType::get(ctx_, 0)});
          return builder_.CreateCall(f, {obj});
        }
        return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
      }
      if (base && base->type && base->type->isCollection()) {
        auto obj = genExpr(*base);
        if (e.member == "Count") {
          auto i64 = llvm::Type::getInt64Ty(ctx_);
          if (base->type->kind == TypeKind::List) {
            auto f = runtimeFn("kx_list_size", i64, {i64});
            return builder_.CreateCall(f, {obj});
          }
          auto f = runtimeFn("kx_map_size", i64, {i64});
          return builder_.CreateCall(f, {obj});
        }
        return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
      }
      if (base && base->type && base->type->kind == TypeKind::Struct &&
          !(base->kind == Expr::Kind::Identifier && locals_.count(base->str))) {
        auto val = genExpr(*base);
        auto st = llvm::cast<llvm::StructType>(llvmType(base->type));
        auto tmp = builder_.CreateAlloca(st);
        builder_.CreateStore(val, tmp);
        int idx = 0;
        auto sit = checker_.structs().find(base->type->name);
        if (sit != checker_.structs().end()) {
          for (size_t i = 0; i < sit->second->fields.size(); ++i) {
            if (sit->second->fields[i].first == e.member) { idx = (int)i; break; }
          }
        }
        auto gep = builder_.CreateStructGEP(st, tmp, idx);
        return builder_.CreateLoad(st->getElementType(idx), gep);
      }
      if (base && base->kind == Expr::Kind::MemberAccess) {
        Expr* bb = base->lhs.get();
        if (bb && bb->kind == Expr::Kind::Identifier && bb->type &&
            bb->type->kind == TypeKind::Snapshot) {
          int c = componentIndex(base->member);
          int f = fieldIndex(base->member, e.member);
          if (c >= 0 && f >= 0) {
            auto handle = builder_.CreateLoad(llvm::Type::getInt64Ty(ctx_),
                                              locals_[bb->str]);
            auto ft = fieldType(base->member, f);
            return snapReadValue(handle, c, f, ft, llvmType(e.type));
          }
          return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
        }
      }
      if (base && base->kind == Expr::Kind::Identifier) {
        if (base->str == "EntityId" && e.member == "None")
          return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
        if (base->str == "self") {
          auto it = locals_.find("self");
          if (it != locals_.end()) {
            return builder_.CreateLoad(llvm::Type::getInt64Ty(ctx_), it->second);
          }
          return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
        }
        if (checker_.components().count(base->str)) {
          if (curSelf_) {
            auto self = builder_.CreateLoad(llvm::Type::getInt64Ty(ctx_), curSelf_);
            return genComponentRead(e, self);
          }
          return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
        }
        auto it = locals_.find(base->str);
        if (it != locals_.end()) {
          auto allocTy = it->second->getAllocatedType();
          if (allocTy->isStructTy()) {
            auto st = llvm::cast<llvm::StructType>(allocTy);
            int idx = 0;
            auto sit = checker_.structs().find(base->type ? base->type->name : std::string());
            if (sit != checker_.structs().end()) {
              for (size_t i = 0; i < sit->second->fields.size(); ++i) {
                if (sit->second->fields[i].first == e.member) { idx = (int)i; break; }
              }
            }
            auto gep = builder_.CreateStructGEP(st, it->second, idx);
            return builder_.CreateLoad(st->getElementType(idx), gep);
          }
          if (base->type && base->type->kind == TypeKind::Snapshot) {
            auto handle = builder_.CreateLoad(llvm::Type::getInt64Ty(ctx_), it->second);
            if (e.member == "Id") {
              auto f = runtimeFn("kx_snap_id", llvm::Type::getInt64Ty(ctx_),
                                 {llvm::Type::getInt64Ty(ctx_)});
              return builder_.CreateCall(f, {handle});
            }
            for (const auto& cn : base->type->componentNames) {
              if (cn == e.member) return handle;
            }
            return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
          }
        }
      }
      return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
    }
    case Expr::Kind::Call:
      return genCall(e);
    case Expr::Kind::Binary: {
      if (e.binOp == BinaryOp::And || e.binOp == BinaryOp::Or) {
        auto lhs = genExpr(*e.lhs);
        auto fn = curFn_;
        auto lhsBlock = builder_.GetInsertBlock();
        auto rhsBlock = llvm::BasicBlock::Create(ctx_, "logic.rhs", fn);
        auto mergeBlock = llvm::BasicBlock::Create(ctx_, "logic.merge", fn);
        if (e.binOp == BinaryOp::And) {
          builder_.CreateCondBr(lhs, rhsBlock, mergeBlock);
        } else {
          builder_.CreateCondBr(lhs, mergeBlock, rhsBlock);
        }
        builder_.SetInsertPoint(rhsBlock);
        auto rhs = genExpr(*e.rhs);
        auto rhsEnd = builder_.GetInsertBlock();
        maybeBr(builder_, mergeBlock);
        builder_.SetInsertPoint(mergeBlock);
        auto phi = builder_.CreatePHI(llvm::Type::getInt1Ty(ctx_), 0);
        auto shortVal = e.binOp == BinaryOp::And
                            ? llvm::ConstantInt::getFalse(ctx_)
                            : llvm::ConstantInt::getTrue(ctx_);
        phi->addIncoming(shortVal, lhsBlock);
        phi->addIncoming(rhs, rhsEnd);
        return phi;
      }
      auto ltRaw = genExpr(*e.lhs);
      auto rtRaw = genExpr(*e.rhs);
      if (e.lhs->type && e.rhs->type &&
          (e.lhs->type->kind == TypeKind::Struct || e.rhs->type->kind == TypeKind::Struct)) {
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
        if (opName) {
          const Decl* op = checker_.functionByName(opName, 2);
          if (op) {
            std::vector<std::shared_ptr<Type>> ptypes = {e.lhs->type, e.rhs->type};
            auto opFn = ensureFunction(*op, ptypes);
            auto retIt = specRetTypes_.find(mangle(opName, ptypes));
            if (retIt != specRetTypes_.end()) {
              const_cast<Expr&>(e).type = retIt->second;
            }
            return builder_.CreateCall(opFn, {ltRaw, rtRaw});
          }
        }
      }
      if (e.binOp == BinaryOp::Add && e.type && e.type->kind == TypeKind::String) {
        auto f = getRuntime("kx_str_cat");
        if (!f) f = declareRuntime("kx_str_cat", llvm::PointerType::get(ctx_, 0),
                                   {llvm::PointerType::get(ctx_, 0), llvm::PointerType::get(ctx_, 0)});
        return builder_.CreateCall(f, {ltRaw, rtRaw});
      }
      auto resTy = llvmType(e.type);
      bool floating = resTy->isFloatingPointTy();
      llvm::Value* lt = ltRaw;
      llvm::Value* rt = rtRaw;
      if (e.binOp != BinaryOp::Eq && e.binOp != BinaryOp::Ne &&
          e.binOp != BinaryOp::Lt && e.binOp != BinaryOp::Gt &&
          e.binOp != BinaryOp::Le && e.binOp != BinaryOp::Ge) {
        lt = coerce(ltRaw, resTy);
        rt = coerce(rtRaw, resTy);
      } else {
        auto cmpTy = promote(e.lhs->type, e.rhs->type);
        auto cTy = llvmType(cmpTy);
        lt = coerce(ltRaw, cTy);
        rt = coerce(rtRaw, cTy);
      }
      switch (e.binOp) {
        case BinaryOp::Add: return floating ? builder_.CreateFAdd(lt, rt) : builder_.CreateAdd(lt, rt);
        case BinaryOp::Sub: return floating ? builder_.CreateFSub(lt, rt) : builder_.CreateSub(lt, rt);
        case BinaryOp::Mul: return floating ? builder_.CreateFMul(lt, rt) : builder_.CreateMul(lt, rt);
        case BinaryOp::Div: return floating ? builder_.CreateFDiv(lt, rt) : builder_.CreateSDiv(lt, rt);
        case BinaryOp::Mod: return floating ? builder_.CreateFRem(lt, rt) : builder_.CreateSRem(lt, rt);
        case BinaryOp::Eq:
        case BinaryOp::Ne: {
          if (e.lhs->type && e.lhs->type->kind == TypeKind::String) {
            auto f = runtimeFn("kx_str_eq", llvm::Type::getInt1Ty(ctx_),
                               {llvm::PointerType::get(ctx_, 0),
                                llvm::PointerType::get(ctx_, 0)});
            auto eqv = builder_.CreateCall(f, {lt, rt});
            if (e.binOp == BinaryOp::Ne) return builder_.CreateNot(eqv);
            return eqv;
          }
          if (lt->getType()->isFloatingPointTy()) {
            auto p = e.binOp == BinaryOp::Eq ? llvm::CmpInst::FCMP_OEQ : llvm::CmpInst::FCMP_ONE;
            return builder_.CreateFCmp(p, lt, rt);
          }
          auto p = e.binOp == BinaryOp::Eq ? llvm::CmpInst::ICMP_EQ : llvm::CmpInst::ICMP_NE;
          return builder_.CreateICmp(p, lt, rt);
        }
        case BinaryOp::Lt:
        case BinaryOp::Gt:
        case BinaryOp::Le:
        case BinaryOp::Ge: {
          if (lt->getType()->isFloatingPointTy()) {
            llvm::CmpInst::Predicate p = llvm::CmpInst::FCMP_OLT;
            if (e.binOp == BinaryOp::Gt) p = llvm::CmpInst::FCMP_OGT;
            if (e.binOp == BinaryOp::Le) p = llvm::CmpInst::FCMP_OLE;
            if (e.binOp == BinaryOp::Ge) p = llvm::CmpInst::FCMP_OGE;
            return builder_.CreateFCmp(p, lt, rt);
          }
          llvm::CmpInst::Predicate p = llvm::CmpInst::ICMP_SLT;
          if (e.binOp == BinaryOp::Gt) p = llvm::CmpInst::ICMP_SGT;
          if (e.binOp == BinaryOp::Le) p = llvm::CmpInst::ICMP_SLE;
          if (e.binOp == BinaryOp::Ge) p = llvm::CmpInst::ICMP_SGE;
          return builder_.CreateICmp(p, lt, rt);
        }
        default:
          return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
      }
    }
    case Expr::Kind::Unary: {
      if (e.unOp == UnaryOp::Exact) return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
      auto op = genExpr(*e.lhs);
      if (e.unOp == UnaryOp::Not) return builder_.CreateNot(op);
      if (e.unOp == UnaryOp::Neg) {
        if (op->getType()->isFloatingPointTy()) return builder_.CreateFNeg(op);
        return builder_.CreateNeg(op);
      }
      if (e.unOp == UnaryOp::PostInc || e.unOp == UnaryOp::PostDec) {
        bool inc = e.unOp == UnaryOp::PostInc;
        auto one = op->getType()->isFloatingPointTy()
                       ? llvm::ConstantFP::get(op->getType(), 1.0)
                       : llvm::ConstantInt::get(op->getType(), 1);
        auto nv = op->getType()->isFloatingPointTy()
                      ? (inc ? builder_.CreateFAdd(op, one) : builder_.CreateFSub(op, one))
                      : (inc ? builder_.CreateAdd(op, one) : builder_.CreateSub(op, one));
        storeTo(*e.lhs, nv);
        return op;
      }
      return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
    }
    case Expr::Kind::Ternary: {
      auto cond = genExpr(*e.lhs);
      auto fn = curFn_;
      auto thenBlock = llvm::BasicBlock::Create(ctx_, "tern.then", fn);
      auto elseBlock = llvm::BasicBlock::Create(ctx_, "tern.else", fn);
      auto mergeBlock = llvm::BasicBlock::Create(ctx_, "tern.merge", fn);
      builder_.CreateCondBr(cond, thenBlock, elseBlock);
      builder_.SetInsertPoint(thenBlock);
      auto tv = genExpr(*e.mid);
      maybeBr(builder_, mergeBlock);
      auto thenEnd = builder_.GetInsertBlock();
      builder_.SetInsertPoint(elseBlock);
      auto fv = genExpr(*e.rhs);
      maybeBr(builder_, mergeBlock);
      auto elseEnd = builder_.GetInsertBlock();
      builder_.SetInsertPoint(mergeBlock);
      auto phi = builder_.CreatePHI(llvmType(e.type), 0);
      phi->addIncoming(tv, thenEnd);
      phi->addIncoming(fv, elseEnd);
      return phi;
    }
    case Expr::Kind::Assign: {
      llvm::Value* val = genExpr(*e.rhs);
      if (e.asOp != AssignOp::Assign) {
        auto resTy = llvmType(e.type);
        auto l = coerce(genExpr(*e.lhs), resTy);
        auto r = coerce(val, resTy);
        bool floating = resTy->isFloatingPointTy();
        switch (e.asOp) {
          case AssignOp::Add:
            val = floating ? builder_.CreateFAdd(l, r) : builder_.CreateAdd(l, r);
            break;
          case AssignOp::Sub:
            val = floating ? builder_.CreateFSub(l, r) : builder_.CreateSub(l, r);
            break;
          case AssignOp::Mul:
            val = floating ? builder_.CreateFMul(l, r) : builder_.CreateMul(l, r);
            break;
          case AssignOp::Div:
            val = floating ? builder_.CreateFDiv(l, r) : builder_.CreateSDiv(l, r);
            break;
          case AssignOp::Mod:
            val = floating ? builder_.CreateFRem(l, r) : builder_.CreateSRem(l, r);
            break;
          default:
            break;
        }
      }
      auto promoted = coerce(val, llvmType(e.lhs->type));
      storeTo(*e.lhs, promoted);
      return promoted;
    }
    case Expr::Kind::Is: {
      auto lhsVal = genExpr(*e.lhs);
      llvm::Value* result;
      llvm::Value* bindVal = lhsVal;
      if (e.lhs->type && e.lhs->type->kind == TypeKind::Option) {
        auto present = builder_.CreateExtractValue(lhsVal, 0);
        bindVal = builder_.CreateExtractValue(lhsVal, 1);
        result = present;
      } else {
        result = llvm::ConstantInt::getTrue(ctx_);
      }
      if (!e.patternVar.empty()) {
        auto allocTy = e.lhs->type && e.lhs->type->kind == TypeKind::Option
                           ? llvmType(e.lhs->type->inner)
                           : llvmType(e.type);
        auto alloca = builder_.CreateAlloca(allocTy);
        locals_[e.patternVar] = alloca;
        builder_.CreateStore(coerce(bindVal, allocTy), alloca);
      }
      return result;
    }
    case Expr::Kind::Interpolated: {
      llvm::Value* acc = builder_.CreateGlobalStringPtr(e.interpText.empty() ? "" : e.interpText[0]);
      auto cat = getRuntime("kx_str_cat");
      if (!cat) cat = declareRuntime("kx_str_cat", llvm::PointerType::get(ctx_, 0),
                                     {llvm::PointerType::get(ctx_, 0), llvm::PointerType::get(ctx_, 0)});
      for (size_t i = 0; i < e.interpExprs.size(); ++i) {
        auto ev = genExpr(*e.interpExprs[i]);
        auto sv = toStr(ev, e.interpExprs[i]->type);
        acc = builder_.CreateCall(cat, {acc, sv});
        if (i + 1 < e.interpText.size() && !e.interpText[i + 1].empty()) {
          acc = builder_.CreateCall(cat, {acc, builder_.CreateGlobalStringPtr(e.interpText[i + 1])});
        }
      }
      return acc;
    }
    case Expr::Kind::Spawn: {
      emitSpawn(e);
      return spawnResult_ ? spawnResult_ : llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
    }
    case Expr::Kind::StructInit: {
      auto st = llvm::cast<llvm::StructType>(structType(e.structInit.type));
      llvm::Value* val = llvm::UndefValue::get(st);
      auto sit = checker_.structs().find(e.structInit.type);
      if (sit != checker_.structs().end()) {
        for (size_t i = 0; i < sit->second->fields.size(); ++i) {
          auto dv = genExpr(*sit->second->fields[i].second);
          val = builder_.CreateInsertValue(val, coerce(dv, st->getElementType(i)), i);
        }
      }
      for (const auto& f : e.structInit.fields) {
        int idx = 0;
        if (sit != checker_.structs().end()) {
          for (size_t i = 0; i < sit->second->fields.size(); ++i) {
            if (sit->second->fields[i].first == f.first) { idx = (int)i; break; }
          }
        }
        auto fv = genExpr(*f.second);
        val = builder_.CreateInsertValue(val, coerce(fv, st->getElementType(idx)), idx);
      }
      return val;
    }
  }
  return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
}

llvm::Value* Codegen::genCall(const Expr& call) {
  const Expr* callee = call.lhs.get();
  if (!callee) return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));

  if (callee->kind == Expr::Kind::Identifier) {
    const std::string& name = callee->str;
    if (name == "others") {
      std::string tag;
      bool exact = false;
      extractTagArg(call, &tag, &exact);
      uint64_t mask = tag.empty() ? 0 : tagSubtree(tag);
      auto f = runtimeFn("kx_others_begin", llvm::Type::getInt64Ty(ctx_),
                         {llvm::Type::getInt64Ty(ctx_), llvm::Type::getInt32Ty(ctx_)});
      return builder_.CreateCall(
          f, {llvm::ConstantInt::get(ctx_, llvm::APInt(64, mask)),
              llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), exact ? 1 : 0)});
    }
    if (name == "run") {
      int tps = 0;
      long long ticks = -1;
      double cores = -1.0;
      if (!call.args.empty() && call.args[0].value->kind == Expr::Kind::IntLit) {
        tps = (int)call.args[0].value->intValue;
      }
      for (const auto& a : call.args) {
        if (a.name == "ticks" && a.value->kind == Expr::Kind::IntLit) {
          ticks = a.value->intValue;
        }
        if (a.name == "cores") {
          if (a.value->kind == Expr::Kind::IntLit) cores = (double)a.value->intValue;
          else if (a.value->kind == Expr::Kind::FloatLit) cores = a.value->floatValue;
        }
      }
      auto f = runtimeFn("kx_run", llvm::Type::getVoidTy(ctx_),
                         {llvm::Type::getInt32Ty(ctx_), llvm::Type::getInt64Ty(ctx_),
                          llvm::Type::getDoubleTy(ctx_)});
      builder_.CreateCall(f, {llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), tps),
                              llvm::ConstantInt::get(llvm::Type::getInt64Ty(ctx_), ticks),
                              llvm::ConstantFP::get(llvm::Type::getDoubleTy(ctx_), cores)});
      return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
    }
    if (name == "panic") {
      llvm::Value* arg = nullptr;
      if (!call.args.empty()) arg = toStr(genExpr(*call.args[0].value), call.args[0].value->type);
      auto f = getRuntime("kx_panic");
      if (!f) f = declareRuntime("kx_panic", llvm::Type::getVoidTy(ctx_),
                                 {llvm::PointerType::get(ctx_, 0)});
      builder_.CreateCall(f, {arg ? arg : builder_.CreateGlobalStringPtr("panic")});
      return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
    }
    if (name == "List") {
      auto f = runtimeFn("kx_list_new", llvm::Type::getInt64Ty(ctx_),
                         {llvm::Type::getInt32Ty(ctx_)});
      int kind = (call.type && call.type->inner) ? kindCode(call.type->inner) : 0;
      return builder_.CreateCall(
          f, {llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), kind)});
    }
    if (name == "Map") {
      auto f = runtimeFn("kx_map_new", llvm::Type::getInt64Ty(ctx_),
                         {llvm::Type::getInt32Ty(ctx_), llvm::Type::getInt32Ty(ctx_)});
      int kk = (call.type && call.type->inner) ? kindCode(call.type->inner) : 0;
      int vk = (call.type && call.type->inner2) ? kindCode(call.type->inner2) : 0;
      return builder_.CreateCall(
          f, {llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), kk),
              llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), vk)});
    }
    const Decl* fn = checker_.functionByName(name, call.args.size());
    if (fn) {
      std::vector<std::shared_ptr<Type>> ptypes;
      for (const auto& a : call.args) {
        ptypes.push_back(a.value->type ? a.value->type : Type::make(TypeKind::Int));
      }
      std::vector<llvm::Value*> argv;
      for (const auto& a : call.args) argv.push_back(genExpr(*a.value));
      if (fn->isExtern) {
        auto ext = ensureExtern(*fn);
        size_t i = 0;
        for (auto& arg : ext->args()) {
          if (i < argv.size()) {
            auto pt = llvmTypeFromName(fn->paramTypes[i]);
            argv[i] = coerce(argv[i], pt);
          }
          i++;
        }
        return builder_.CreateCall(ext, argv);
      }
      auto calleeFn = ensureFunction(*fn, ptypes);
      auto retIt = specRetTypes_.find(mangle(name, ptypes));
      if (retIt != specRetTypes_.end()) {
        const_cast<Expr&>(call).type = retIt->second;
      }
      return builder_.CreateCall(calleeFn, argv);
    }
    return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
  }

  if (callee->kind == Expr::Kind::MemberAccess) {
    Expr* base = callee->lhs.get();
    const std::string& member = callee->member;

    if (base && base->kind == Expr::Kind::Identifier && base->str == "std") {
      if (member == "println" || member == "print") {
        llvm::Value* arg = call.args.empty()
                               ? builder_.CreateGlobalStringPtr("")
                               : toStr(genExpr(*call.args[0].value), call.args[0].value->type);
        auto f = getRuntime(member == "println" ? "kx_println" : "kx_print");
        if (!f) f = declareRuntime(member == "println" ? "kx_println" : "kx_print",
                                   llvm::Type::getVoidTy(ctx_), {llvm::PointerType::get(ctx_, 0)});
        builder_.CreateCall(f, {arg});
        return nullptr;
      }
      if (member == "readln") {
        auto f = getRuntime("kx_readln");
        if (!f) f = declareRuntime("kx_readln", llvm::PointerType::get(ctx_, 0), {});
        auto val = builder_.CreateCall(f, {});
        auto present = builder_.CreateIsNotNull(val);
        auto optTy = llvm::StructType::get(ctx_, {llvm::Type::getInt1Ty(ctx_),
                                                  llvm::PointerType::get(ctx_, 0)});
        llvm::Value* opt = llvm::UndefValue::get(optTy);
        opt = builder_.CreateInsertValue(opt, present, 0);
        opt = builder_.CreateInsertValue(opt, val, 1);
        return opt;
      }
      if (member == "exit") {
        llvm::Value* arg = call.args.empty()
                               ? llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), 0)
                               : coerce(genExpr(*call.args[0].value), llvm::Type::getInt32Ty(ctx_));
        auto f = getRuntime("kx_exit");
        if (!f) f = declareRuntime("kx_exit", llvm::Type::getVoidTy(ctx_),
                                   {llvm::Type::getInt32Ty(ctx_)});
        builder_.CreateCall(f, {arg});
        return nullptr;
      }
      if (member == "stop") {
        auto f = getRuntime("kx_stop");
        if (!f) f = declareRuntime("kx_stop", llvm::Type::getVoidTy(ctx_), {});
        builder_.CreateCall(f, {});
        return nullptr;
      }
      if (member == "log") {
        llvm::Value* lvl = call.args.empty()
                               ? llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0))
                               : valToI64(genExpr(*call.args[0].value));
        llvm::Value* msg = call.args.size() < 2
                               ? builder_.CreateGlobalStringPtr("")
                               : toStr(genExpr(*call.args[1].value), call.args[1].value->type);
        auto f = runtimeFn("kx_log", llvm::Type::getVoidTy(ctx_),
                           {llvm::Type::getInt64Ty(ctx_), llvm::PointerType::get(ctx_, 0)});
        builder_.CreateCall(f, {lvl, msg});
        return nullptr;
      }
      if (member == "pollLine") {
        auto f = runtimeFn("kx_poll_line", llvm::PointerType::get(ctx_, 0), {});
        auto val = builder_.CreateCall(f, {});
        auto present = builder_.CreateIsNotNull(val);
        auto optTy = llvm::StructType::get(ctx_, {llvm::Type::getInt1Ty(ctx_),
                                                  llvm::PointerType::get(ctx_, 0)});
        llvm::Value* opt = llvm::UndefValue::get(optTy);
        opt = builder_.CreateInsertValue(opt, present, 0);
        opt = builder_.CreateInsertValue(opt, val, 1);
        return opt;
      }
      if (member == "rng") {
        llvm::Value* arg = call.args.empty()
                               ? llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0))
                               : coerce(genExpr(*call.args[0].value), llvm::Type::getInt64Ty(ctx_));
        auto f = getRuntime("kx_rng_seed");
        if (!f) f = declareRuntime("kx_rng_seed", llvm::Type::getInt64Ty(ctx_),
                                   {llvm::Type::getInt64Ty(ctx_)});
        return builder_.CreateCall(f, {arg});
      }
      {
        static const char* kMath1[] = {"sqrt",  "sin",  "cos",  "tan",  "asin", "acos",
                                       "atan",  "exp",  "log",  "log2", "log10",
                                       "floor", "ceil", "round"};
        for (const char* f : kMath1) {
          if (member == f) {
            auto arg = call.args.empty()
                           ? llvm::ConstantFP::get(llvm::Type::getDoubleTy(ctx_), 0.0)
                           : coerce(genExpr(*call.args[0].value),
                                    llvm::Type::getDoubleTy(ctx_));
            auto fn = runtimeFn(f, llvm::Type::getDoubleTy(ctx_),
                                {llvm::Type::getDoubleTy(ctx_)});
            return builder_.CreateCall(fn, {arg});
          }
        }
        static const char* kMath2[] = {"atan2", "pow"};
        for (const char* f : kMath2) {
          if (member == f) {
            auto a = coerce(genExpr(*call.args[0].value), llvm::Type::getDoubleTy(ctx_));
            auto b = coerce(genExpr(*call.args[1].value), llvm::Type::getDoubleTy(ctx_));
            auto fn = runtimeFn(f, llvm::Type::getDoubleTy(ctx_),
                                {llvm::Type::getDoubleTy(ctx_), llvm::Type::getDoubleTy(ctx_)});
            return builder_.CreateCall(fn, {a, b});
          }
        }
      }
      if (member == "min" || member == "max") {
        auto at = call.args[0].value->type;
        auto a = genExpr(*call.args[0].value);
        auto b = genExpr(*call.args[1].value);
        auto ty = llvmType(at);
        a = coerce(a, ty);
        b = coerce(b, ty);
        llvm::Value* lt;
        if (ty->isFloatingPointTy()) {
          lt = builder_.CreateFCmp(llvm::CmpInst::FCMP_OLT, a, b);
        } else {
          lt = builder_.CreateICmp(llvm::CmpInst::ICMP_SLT, a, b);
        }
        return builder_.CreateSelect(member == "min" ? lt : builder_.CreateNot(lt), a, b);
      }
      if (member == "abs") {
        auto at = call.args[0].value->type;
        auto a = genExpr(*call.args[0].value);
        if (at && at->kind == TypeKind::Int) {
          auto neg = builder_.CreateNeg(a);
          auto isNeg = builder_.CreateICmp(llvm::CmpInst::ICMP_SLT, a,
                                           llvm::ConstantInt::get(a->getType(), 0));
          return builder_.CreateSelect(isNeg, neg, a);
        }
        auto f = runtimeFn("fabs", llvm::Type::getDoubleTy(ctx_),
                           {llvm::Type::getDoubleTy(ctx_)});
        return builder_.CreateCall(f, {coerce(a, llvm::Type::getDoubleTy(ctx_))});
      }
      if (member == "clamp" || member == "lerp") {
        auto f = member == "clamp"
                     ? runtimeFn("kx_clamp", llvm::Type::getDoubleTy(ctx_),
                                 {llvm::Type::getDoubleTy(ctx_), llvm::Type::getDoubleTy(ctx_),
                                  llvm::Type::getDoubleTy(ctx_)})
                     : runtimeFn("kx_lerp", llvm::Type::getDoubleTy(ctx_),
                                 {llvm::Type::getDoubleTy(ctx_), llvm::Type::getDoubleTy(ctx_),
                                  llvm::Type::getDoubleTy(ctx_)});
        std::vector<llvm::Value*> args;
        for (auto& a : call.args) {
          args.push_back(coerce(genExpr(*a.value), llvm::Type::getDoubleTy(ctx_)));
        }
        while (args.size() < 3) {
          args.push_back(llvm::ConstantFP::get(llvm::Type::getDoubleTy(ctx_), 0.0));
        }
        return builder_.CreateCall(f, args);
      }
      return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
    }
    if (base && base->kind == Expr::Kind::Identifier && base->str == "spatial") {
      auto f = runtimeFn("kx_others_begin", llvm::Type::getInt64Ty(ctx_),
                         {llvm::Type::getInt64Ty(ctx_), llvm::Type::getInt32Ty(ctx_)});
      return builder_.CreateCall(
          f, {llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0)),
              llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), 0)});
    }
    if (base && base->type && base->type->kind == TypeKind::String) {
      llvm::Value* obj = genExpr(*base);
      auto ptr = llvm::PointerType::get(ctx_, 0);
      auto i64 = llvm::Type::getInt64Ty(ctx_);
      const std::string& m = member;
      if (m == "Substring") {
        auto f = runtimeFn("kx_str_substr", ptr, {ptr, i64, i64});
        llvm::Value* len = call.args.size() < 2
                               ? llvm::ConstantInt::get(ctx_, llvm::APInt(64, INT64_MAX))
                               : valToI64(genExpr(*call.args[1].value));
        return builder_.CreateCall(f, {obj, valToI64(genExpr(*call.args[0].value)), len});
      }
      if (m == "Contains") {
        auto f = runtimeFn("kx_str_contains", llvm::Type::getInt1Ty(ctx_), {ptr, ptr});
        return builder_.CreateCall(f, {obj, genExpr(*call.args[0].value)});
      }
      if (m == "StartsWith") {
        auto f = runtimeFn("kx_str_starts_with", llvm::Type::getInt1Ty(ctx_), {ptr, ptr});
        return builder_.CreateCall(f, {obj, genExpr(*call.args[0].value)});
      }
      if (m == "EndsWith") {
        auto f = runtimeFn("kx_str_ends_with", llvm::Type::getInt1Ty(ctx_), {ptr, ptr});
        return builder_.CreateCall(f, {obj, genExpr(*call.args[0].value)});
      }
      if (m == "Upper") {
        auto f = runtimeFn("kx_str_upper", ptr, {ptr});
        return builder_.CreateCall(f, {obj});
      }
      if (m == "Lower") {
        auto f = runtimeFn("kx_str_lower", ptr, {ptr});
        return builder_.CreateCall(f, {obj});
      }
      return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
    }
    if (base && base->type && base->type->kind == TypeKind::Option) {
      llvm::Value* obj = genExpr(*base);
      if (member == "ValueOr") {
        auto dflt = genExpr(*call.args[0].value);
        auto present = builder_.CreateExtractValue(obj, 0);
        auto value = builder_.CreateExtractValue(obj, 1);
        return builder_.CreateSelect(present, value, dflt);
      }
      return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
    }
    if (base && base->type && base->type->kind == TypeKind::Rng) {
      llvm::Value* obj = genExpr(*base);
      auto nextFn = runtimeFn("kx_rng_next", llvm::Type::getInt64Ty(ctx_),
                              {llvm::Type::getInt64Ty(ctx_)});
      auto nxt = builder_.CreateCall(nextFn, {obj});
      storeTo(*base, nxt);
      if (member == "Next") {
        return nxt;
      }
      if (member == "NextInt") {
        auto n = valToI64(genExpr(*call.args[0].value));
        auto zero = llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
        auto rem = builder_.CreateSRem(nxt, n);
        auto safe = builder_.CreateICmp(llvm::CmpInst::ICMP_SLT, rem, zero);
        return builder_.CreateSelect(safe, builder_.CreateAdd(rem, n), rem);
      }
      if (member == "NextDouble") {
        auto f = runtimeFn("kx_rng_next_double", llvm::Type::getDoubleTy(ctx_),
                           {llvm::Type::getInt64Ty(ctx_)});
        return builder_.CreateCall(f, {nxt});
      }
      return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
    }
    if (base && base->type && base->type->isCollection()) {

      llvm::Value* obj = genExpr(*base);
      auto i64 = llvm::Type::getInt64Ty(ctx_);
      const std::string& m = member;
      if (base->type->kind == TypeKind::List) {
        if (m == "Add") {
          auto f = runtimeFn("kx_list_add", llvm::Type::getVoidTy(ctx_), {i64, i64});
          builder_.CreateCall(f, {obj, valToI64(genExpr(*call.args[0].value))});
          return nullptr;
        }
        if (m == "Get") {
          auto f = runtimeFn("kx_list_get", i64, {i64, i64});
          auto v = builder_.CreateCall(f, {obj, valToI64(genExpr(*call.args[0].value))});
          return i64ToVal(v, llvmType(base->type->inner));
        }
        if (m == "Set") {
          auto f = runtimeFn("kx_list_set", llvm::Type::getVoidTy(ctx_), {i64, i64, i64});
          builder_.CreateCall(f, {obj, valToI64(genExpr(*call.args[0].value)),
                                  valToI64(genExpr(*call.args[1].value))});
          return nullptr;
        }
        if (m == "RemoveAt") {
          auto f = runtimeFn("kx_list_remove_at", llvm::Type::getVoidTy(ctx_), {i64, i64});
          builder_.CreateCall(f, {obj, valToI64(genExpr(*call.args[0].value))});
          return nullptr;
        }
        if (m == "Clear") {
          auto f = runtimeFn("kx_list_clear", llvm::Type::getVoidTy(ctx_), {i64});
          builder_.CreateCall(f, {obj});
          return nullptr;
        }
      }
      if (base->type->kind == TypeKind::Map) {
        if (m == "Set") {
          auto f = runtimeFn("kx_map_set", llvm::Type::getVoidTy(ctx_), {i64, i64, i64});
          builder_.CreateCall(f, {obj, valToI64(genExpr(*call.args[0].value)),
                                  valToI64(genExpr(*call.args[1].value))});
          return nullptr;
        }
        if (m == "Get") {
          auto f = runtimeFn("kx_map_get", i64, {i64, i64});
          auto v = builder_.CreateCall(f, {obj, valToI64(genExpr(*call.args[0].value))});
          return i64ToVal(v, llvmType(base->type->inner2));
        }
        if (m == "Has") {
          auto f = runtimeFn("kx_map_has", llvm::Type::getInt1Ty(ctx_), {i64, i64});
          return builder_.CreateCall(f, {obj, valToI64(genExpr(*call.args[0].value))});
        }
        if (m == "Remove") {
          auto f = runtimeFn("kx_map_remove", llvm::Type::getVoidTy(ctx_), {i64, i64});
          builder_.CreateCall(f, {obj, valToI64(genExpr(*call.args[0].value))});
          return nullptr;
        }
        if (m == "Clear") {
          auto f = runtimeFn("kx_map_clear", llvm::Type::getVoidTy(ctx_), {i64});
          builder_.CreateCall(f, {obj});
          return nullptr;
        }
      }
      return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
    }
    if (base) genExpr(*base);
    return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
  }

  return llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
}

void Codegen::genBlock(const std::vector<StmtPtr>& body) {
  auto saved = locals_;
  for (const auto& s : body) genStmt(*s);
  locals_ = saved;
}

void Codegen::genStmt(const Stmt& s) {
  switch (s.kind) {
    case Stmt::Kind::Block:
      genBlock(s.body);
      return;
    case Stmt::Kind::VarDecl: {
      llvm::Value* v = s.initExpr ? genExpr(*s.initExpr) : nullptr;
      auto ty = llvmType(s.initExpr && s.initExpr->type ? s.initExpr->type
                                                        : Type::make(TypeKind::Int));
      auto alloca = builder_.CreateAlloca(ty);
      locals_[s.varName] = alloca;
      if (v) builder_.CreateStore(coerce(v, ty), alloca);
      return;
    }
    case Stmt::Kind::Expr:
      genExpr(*s.value);
      return;
    case Stmt::Kind::If: {
      auto cond = genExpr(*s.cond);
      auto fn = curFn_;
      auto thenBlock = llvm::BasicBlock::Create(ctx_, "if.then", fn);
      auto mergeBlock = llvm::BasicBlock::Create(ctx_, "if.merge", fn);
      if (s.elseStmt) {
        auto elseBlock = llvm::BasicBlock::Create(ctx_, "if.else", fn);
        builder_.CreateCondBr(cond, thenBlock, elseBlock);
        builder_.SetInsertPoint(thenBlock);
        genStmt(*s.thenStmt);
        maybeBr(builder_, mergeBlock);
        builder_.SetInsertPoint(elseBlock);
        genStmt(*s.elseStmt);
        maybeBr(builder_, mergeBlock);
      } else {
        builder_.CreateCondBr(cond, thenBlock, mergeBlock);
        builder_.SetInsertPoint(thenBlock);
        genStmt(*s.thenStmt);
        maybeBr(builder_, mergeBlock);
      }
      builder_.SetInsertPoint(mergeBlock);
      return;
    }
    case Stmt::Kind::While: {
      auto fn = curFn_;
      auto condBlock = llvm::BasicBlock::Create(ctx_, "while.cond", fn);
      auto bodyBlock = llvm::BasicBlock::Create(ctx_, "while.body", fn);
      auto exitBlock = llvm::BasicBlock::Create(ctx_, "while.exit", fn);
      maybeBr(builder_, condBlock);
      builder_.SetInsertPoint(condBlock);
      auto cond = genExpr(*s.cond);
      builder_.CreateCondBr(cond, bodyBlock, exitBlock);
      builder_.SetInsertPoint(bodyBlock);
      loops_.push_back({condBlock, exitBlock});
      genStmt(*s.bodyStmt);
      loops_.pop_back();
      maybeBr(builder_, condBlock);
      builder_.SetInsertPoint(exitBlock);
      return;
    }
    case Stmt::Kind::For: {
      if (s.initStmt) genStmt(*s.initStmt);
      else if (s.initExpr) genExpr(*s.initExpr);
      auto fn = curFn_;
      auto condBlock = llvm::BasicBlock::Create(ctx_, "for.cond", fn);
      auto bodyBlock = llvm::BasicBlock::Create(ctx_, "for.body", fn);
      auto incBlock = llvm::BasicBlock::Create(ctx_, "for.inc", fn);
      auto exitBlock = llvm::BasicBlock::Create(ctx_, "for.exit", fn);
      maybeBr(builder_, condBlock);
      builder_.SetInsertPoint(condBlock);
      if (s.cond) {
        auto cond = genExpr(*s.cond);
        builder_.CreateCondBr(cond, bodyBlock, exitBlock);
      } else {
        builder_.CreateBr(bodyBlock);
      }
      builder_.SetInsertPoint(bodyBlock);
      loops_.push_back({incBlock, exitBlock});
      genStmt(*s.bodyStmt);
      loops_.pop_back();
      maybeBr(builder_, incBlock);
      builder_.SetInsertPoint(incBlock);
      if (s.inc) genExpr(*s.inc);
      maybeBr(builder_, condBlock);
      builder_.SetInsertPoint(exitBlock);
      return;
    }
    case Stmt::Kind::Foreach: {
      if (s.container && s.container->type &&
          s.container->type->kind == TypeKind::List) {
        auto handle = genExpr(*s.container);
        auto elemTy = llvmType(s.container->type->inner);
        auto fn = curFn_;
        auto varAlloca = builder_.CreateAlloca(elemTy);
        auto idxAlloca = builder_.CreateAlloca(llvm::Type::getInt64Ty(ctx_));
        auto beginFn = runtimeFn("kx_list_begin", llvm::Type::getInt64Ty(ctx_),
                                 {llvm::Type::getInt64Ty(ctx_)});
        builder_.CreateStore(builder_.CreateCall(beginFn, {handle}), idxAlloca);
        auto condBlock = llvm::BasicBlock::Create(ctx_, "li.cond", fn);
        auto bodyBlock = llvm::BasicBlock::Create(ctx_, "li.body", fn);
        auto exitBlock = llvm::BasicBlock::Create(ctx_, "li.exit", fn);
        builder_.CreateBr(condBlock);
        builder_.SetInsertPoint(condBlock);
        auto idx = builder_.CreateLoad(llvm::Type::getInt64Ty(ctx_), idxAlloca);
        auto done = builder_.CreateICmpEQ(
            idx, llvm::ConstantInt::get(ctx_, llvm::APInt(64, (uint64_t)-1)));
        builder_.CreateCondBr(done, exitBlock, bodyBlock);
        builder_.SetInsertPoint(bodyBlock);
        auto getFn = runtimeFn("kx_list_get", llvm::Type::getInt64Ty(ctx_),
                               {llvm::Type::getInt64Ty(ctx_), llvm::Type::getInt64Ty(ctx_)});
        auto raw = builder_.CreateCall(getFn, {handle, idx});
        builder_.CreateStore(i64ToVal(raw, elemTy), varAlloca);
        locals_[s.varName] = varAlloca;
        loops_.push_back({condBlock, exitBlock});
        genStmt(*s.bodyStmt);
        loops_.pop_back();
        auto nextFn = runtimeFn("kx_list_next", llvm::Type::getInt64Ty(ctx_),
                                {llvm::Type::getInt64Ty(ctx_), llvm::Type::getInt64Ty(ctx_)});
        auto nxt = builder_.CreateCall(nextFn, {handle, idx});
        builder_.CreateStore(nxt, idxAlloca);
        maybeBr(builder_, condBlock);
        builder_.SetInsertPoint(exitBlock);
        return;
      }
      std::string tag;
      bool exact = false;
      uint64_t mask = 0;
      bool spatialQuery = false;
      int posComp = -1;
      int posDim = 0;
      llvm::Value* center[3] = {nullptr, nullptr, nullptr};
      llvm::Value* radius = nullptr;

      if (s.container && s.container->kind == Expr::Kind::Call) {
        const Expr* callee = s.container->lhs.get();
        if (callee && callee->kind == Expr::Kind::MemberAccess && callee->lhs &&
            callee->lhs->kind == Expr::Kind::Identifier && callee->lhs->str == "spatial" &&
            (callee->member == "Overlap" || callee->member == "Nearby")) {
          spatialQuery = true;
          if (tagBits_.find("Spatial") == tagBits_.end()) {
            error(s.loc, "spatial query requires a 'Spatial' tag");
            break;
          }
          mask = tagSubtree("Spatial");
          if (s.container->args.size() >= 1 && s.container->args[0].value->kind ==
                                                      Expr::Kind::Identifier &&
              checker_.components().count(s.container->args[0].value->str)) {
            posComp = componentIndex(s.container->args[0].value->str);
            posDim = (int)compFields_[s.container->args[0].value->str].size();
            auto i32 = llvm::Type::getInt32Ty(ctx_);
            llvm::Value* self;
            if (curSelf_) {
              self = builder_.CreateLoad(llvm::Type::getInt64Ty(ctx_), curSelf_);
            } else {
              self = llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
            }
            auto readFn = runtimeFn("kx_comp_read_f64", llvm::Type::getDoubleTy(ctx_),
                                    {llvm::Type::getInt64Ty(ctx_), i32, i32});
            auto compC = llvm::ConstantInt::get(i32, posComp);
            center[0] = builder_.CreateCall(
                readFn, {self, compC, llvm::ConstantInt::get(i32, 0)});
            center[1] = builder_.CreateCall(
                readFn, {self, compC, llvm::ConstantInt::get(i32, 1)});
            if (posDim > 2) {
              center[2] = builder_.CreateCall(
                  readFn, {self, compC, llvm::ConstantInt::get(i32, 2)});
            } else {
              center[2] = llvm::ConstantFP::get(llvm::Type::getDoubleTy(ctx_), 0.0);
            }
          } else {
            error(s.loc, "spatial query position must be a component identifier (e.g. Pos3)");
            break;
          }
          if (s.container->args.size() >= 2) {
            radius = coerce(genExpr(*s.container->args[1].value),
                            llvm::Type::getDoubleTy(ctx_));
          } else {
            radius = llvm::ConstantFP::get(llvm::Type::getDoubleTy(ctx_), 1.0);
          }
        } else if (callee && callee->kind == Expr::Kind::Identifier &&
                   callee->str == "others") {
          extractTagArg(*s.container, &tag, &exact);
          if (!tag.empty()) mask = tagSubtree(tag);
        }
      }

      auto handle = spatialQuery ? builder_.CreateCall(
                                       runtimeFn("kx_others_begin", llvm::Type::getInt64Ty(ctx_),
                                                 {llvm::Type::getInt64Ty(ctx_),
                                                  llvm::Type::getInt32Ty(ctx_)}),
                                       {llvm::ConstantInt::get(ctx_, llvm::APInt(64, mask)),
                                        llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), 0)})
                                 : genExpr(*s.container);
      auto fn = curFn_;
      auto varAlloca = builder_.CreateAlloca(llvm::Type::getInt64Ty(ctx_));
      builder_.CreateStore(handle, varAlloca);
      auto condBlock = llvm::BasicBlock::Create(ctx_, "fe.cond", fn);
      auto filterBlock = llvm::BasicBlock::Create(ctx_, "fe.filter", fn);
      auto bodyBlock = llvm::BasicBlock::Create(ctx_, "fe.body", fn);
      auto skipBlock = llvm::BasicBlock::Create(ctx_, "fe.skip", fn);
      auto exitBlock = llvm::BasicBlock::Create(ctx_, "fe.exit", fn);
      builder_.CreateBr(condBlock);
      builder_.SetInsertPoint(condBlock);
      auto cur = builder_.CreateLoad(llvm::Type::getInt64Ty(ctx_), varAlloca);
      auto done = builder_.CreateICmpEQ(
          cur, llvm::ConstantInt::get(ctx_, llvm::APInt(64, (uint64_t)-1)));
      builder_.CreateCondBr(done, exitBlock, filterBlock);

      builder_.SetInsertPoint(filterBlock);
      if (spatialQuery) {
        auto i32 = llvm::Type::getInt32Ty(ctx_);
        auto readFn = runtimeFn("kx_snap_read_f64", llvm::Type::getDoubleTy(ctx_),
                                {llvm::Type::getInt64Ty(ctx_), i32, i32});
        llvm::Value* cand[3];
        for (int d = 0; d < 3; d++) {
          cand[d] = builder_.CreateCall(
              readFn, {cur, llvm::ConstantInt::get(i32, posComp),
                       llvm::ConstantInt::get(i32, d)});
        }
        auto dx = builder_.CreateFSub(cand[0], center[0]);
        auto dy = builder_.CreateFSub(cand[1], center[1]);
        auto dz = builder_.CreateFSub(cand[2], center[2]);
        auto d2 = builder_.CreateFAdd(builder_.CreateFMul(dx, dx),
                                      builder_.CreateFAdd(builder_.CreateFMul(dy, dy),
                                                          builder_.CreateFMul(dz, dz)));
        auto r2 = builder_.CreateFMul(radius, radius);
        auto inRange = builder_.CreateFCmpOLE(d2, r2);
        llvm::Value* pass = inRange;
        if (curSelf_) {
          auto self = builder_.CreateLoad(llvm::Type::getInt64Ty(ctx_), curSelf_);
          auto snapIdFn = runtimeFn("kx_snap_id", llvm::Type::getInt64Ty(ctx_),
                                    {llvm::Type::getInt64Ty(ctx_)});
          auto candId = builder_.CreateCall(snapIdFn, {cur});
          auto notSelf = builder_.CreateICmpNE(candId, self);
          pass = builder_.CreateAnd(inRange, notSelf);
        }
        builder_.CreateCondBr(pass, bodyBlock, skipBlock);
      } else {
        builder_.CreateBr(bodyBlock);
      }

      builder_.SetInsertPoint(skipBlock);
      auto next = runtimeFn("kx_others_next", llvm::Type::getInt64Ty(ctx_),
                            {llvm::Type::getInt64Ty(ctx_), llvm::Type::getInt64Ty(ctx_),
                             llvm::Type::getInt32Ty(ctx_)});
      auto cur2 = builder_.CreateLoad(llvm::Type::getInt64Ty(ctx_), varAlloca);
      builder_.CreateStore(
          builder_.CreateCall(next, {cur2, llvm::ConstantInt::get(ctx_, llvm::APInt(64, mask)),
                                     llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_),
                                                            exact ? 1 : 0)}),
          varAlloca);
      maybeBr(builder_, condBlock);

      builder_.SetInsertPoint(bodyBlock);
      locals_[s.varName] = varAlloca;
      loops_.push_back({skipBlock, exitBlock});
      genStmt(*s.bodyStmt);
      loops_.pop_back();
      maybeBr(builder_, skipBlock);

      builder_.SetInsertPoint(exitBlock);
      return;
    }
    case Stmt::Kind::Return: {
      if (s.value) {
        auto v = genExpr(*s.value);
        builder_.CreateRet(coerce(v, curRetType_));
      } else {
        builder_.CreateRetVoid();
      }
      return;
    }
    case Stmt::Kind::Switch: {
      auto condVal = genExpr(*s.cond);
      auto condAlloca = builder_.CreateAlloca(condVal->getType());
      builder_.CreateStore(condVal, condAlloca);
      auto fn = curFn_;
      auto exitBlock = llvm::BasicBlock::Create(ctx_, "sw.exit", fn);
      std::vector<std::pair<const Stmt::SwitchCase*, llvm::BasicBlock*>> cmpBlocks;
      std::vector<llvm::BasicBlock*> bodyBlocks;
      llvm::BasicBlock* defaultBlock = nullptr;
      auto contTarget = loops_.empty() ? nullptr : loops_.back().continueTarget;
      for (auto& sc : s.switchCases) {
        if (sc.values.empty()) {
          defaultBlock = llvm::BasicBlock::Create(ctx_, "sw.default", fn);
        } else {
          cmpBlocks.emplace_back(&sc, llvm::BasicBlock::Create(ctx_, "sw.cmp", fn));
          bodyBlocks.push_back(sc.body && !sc.body->body.empty()
                                   ? llvm::BasicBlock::Create(ctx_, "sw.body", fn)
                                   : nullptr);
        }
      }
      llvm::BasicBlock* fallBody = exitBlock;
      for (size_t i = cmpBlocks.size(); i-- > 0;) {
        if (bodyBlocks[i]) {
          fallBody = bodyBlocks[i];
        } else {
          bodyBlocks[i] = fallBody;
        }
      }
      if (cmpBlocks.empty()) {
        builder_.CreateBr(defaultBlock ? defaultBlock : exitBlock);
      } else {
        builder_.CreateBr(cmpBlocks[0].second);
      }
      for (size_t i = 0; i < cmpBlocks.size(); i++) {
        const auto& sc = *cmpBlocks[i].first;
        auto cmpBlk = cmpBlocks[i].second;
        auto bodyBlk = bodyBlocks[i];
        builder_.SetInsertPoint(cmpBlk);
        llvm::Value* matched = nullptr;
        for (auto& v : sc.values) {
          auto vv = genExpr(*v);
          auto cc = builder_.CreateLoad(condAlloca->getAllocatedType(), condAlloca);
          llvm::Value* eq;
          if (cc->getType()->isFloatingPointTy()) {
            eq = builder_.CreateFCmp(llvm::CmpInst::FCMP_OEQ, cc, vv);
          } else if (cc->getType()->isPointerTy()) {
            auto f = runtimeFn("kx_str_eq", llvm::Type::getInt1Ty(ctx_),
                               {llvm::PointerType::get(ctx_, 0),
                                llvm::PointerType::get(ctx_, 0)});
            eq = builder_.CreateCall(f, {cc, vv});
          } else {
            eq = builder_.CreateICmp(llvm::CmpInst::ICMP_EQ, cc, vv);
          }
          matched = matched ? builder_.CreateOr(matched, eq) : eq;
        }
        auto next = (i + 1 < cmpBlocks.size()) ? cmpBlocks[i + 1].second
                     : (defaultBlock ? defaultBlock : exitBlock);
        builder_.CreateCondBr(matched, bodyBlk, next);
      }
      if (defaultBlock) {
        builder_.SetInsertPoint(defaultBlock);
        for (auto& sc : s.switchCases) {
          if (sc.values.empty()) {
            loops_.push_back({contTarget, exitBlock});
            genStmt(*sc.body);
            loops_.pop_back();
          }
        }
        maybeBr(builder_, exitBlock);
      }
      for (size_t i = 0; i < cmpBlocks.size(); i++) {
        const auto& sc = *cmpBlocks[i].first;
        if (!sc.body || sc.body->body.empty()) continue;
        builder_.SetInsertPoint(bodyBlocks[i]);
        loops_.push_back({contTarget, exitBlock});
        genStmt(*sc.body);
        loops_.pop_back();
        maybeBr(builder_, exitBlock);
      }
      builder_.SetInsertPoint(exitBlock);
      return;
    }
    case Stmt::Kind::Break:
      if (!loops_.empty()) builder_.CreateBr(loops_.back().breakTarget);
      return;
    case Stmt::Kind::Continue:
      if (!loops_.empty()) builder_.CreateBr(loops_.back().continueTarget);
      return;
    case Stmt::Kind::Attach: {
      llvm::Value* target = s.target ? coerce(genExpr(*s.target), llvm::Type::getInt64Ty(ctx_))
                                     : llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
      int c = componentIndex(s.attachInit.type);
      if (c >= 0) {
        auto ensure = runtimeFn("kx_ensure_comp", llvm::Type::getVoidTy(ctx_),
                                {llvm::Type::getInt64Ty(ctx_), llvm::Type::getInt32Ty(ctx_)});
        builder_.CreateCall(
            ensure, {target, llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), c)});
        for (const auto& f : s.attachInit.fields) {
          int fi = fieldIndex(s.attachInit.type, f.first);
          if (fi < 0) continue;
          auto ft = fieldType(s.attachInit.type, fi);
          auto v = genExpr(*f.second);
          if (isFreshCollection(f.second.get()) && ft->isCollection()) {
            auto take = runtimeFn("kx_comp_take_i64", llvm::Type::getVoidTy(ctx_),
                                  {llvm::Type::getInt64Ty(ctx_), llvm::Type::getInt32Ty(ctx_),
                                   llvm::Type::getInt32Ty(ctx_), llvm::Type::getInt64Ty(ctx_)});
            builder_.CreateCall(take, {target,
                                       llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), c),
                                       llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), fi),
                                       valToI64(v)});
          } else {
            emitCompWriteValue(target, c, fi, ft, v);
          }
        }
      }
      return;
    }
    case Stmt::Kind::Detach: {
      llvm::Value* target = s.target ? coerce(genExpr(*s.target), llvm::Type::getInt64Ty(ctx_))
                                     : llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
      int c = componentIndex(s.detachType);
      if (c >= 0) {
        auto f = runtimeFn("kx_detach_comp", llvm::Type::getVoidTy(ctx_),
                           {llvm::Type::getInt64Ty(ctx_), llvm::Type::getInt32Ty(ctx_)});
        builder_.CreateCall(
            f, {target, llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx_), c)});
      }
      return;
    }
    case Stmt::Kind::Despawn: {
      llvm::Value* target = s.target ? coerce(genExpr(*s.target), llvm::Type::getInt64Ty(ctx_))
                                     : llvm::ConstantInt::get(ctx_, llvm::APInt(64, 0));
      auto f = runtimeFn("kx_despawn", llvm::Type::getVoidTy(ctx_),
                         {llvm::Type::getInt64Ty(ctx_)});
      builder_.CreateCall(f, {target});
      return;
    }
  }
}

void Codegen::emitFunction(const Decl& d, const std::vector<std::shared_ptr<Type>>& paramTypes) {
  std::map<std::string, std::shared_ptr<Type>> params;
  for (size_t i = 0; i < d.params.size() && i < paramTypes.size(); ++i) {
    params[d.params[i]] = paramTypes[i];
  }

  std::shared_ptr<Type> retType = Type::make(TypeKind::Void);
  std::vector<StmtPtr> emptyBody;
  std::vector<StmtPtr> clone;
  const std::vector<StmtPtr>* body = d.body ? &d.body->body : &emptyBody;
  if (!params.empty() || d.retKind == "var") {
    curFnName_ = d.name;
    clone = cloneStmts(*body);
    body = &clone;
    if (d.retKind != "void") {
      retType = checker_.reInferBody(*body, params);
      if (!retType) retType = Type::make(TypeKind::Int);
    } else {
      checker_.reInferBody(*body, params);
    }
  } else if (d.retKind == "int") {
    retType = Type::make(TypeKind::Int);
  }

  std::vector<llvm::Type*> lparams;
  for (const auto& p : paramTypes) lparams.push_back(llvmType(p));
  auto ft = llvm::FunctionType::get(llvmType(retType), lparams, false);
  auto fn = llvm::Function::Create(ft, llvm::GlobalValue::ExternalLinkage,
                                   mangle(d.name, paramTypes), *module_);
  specializations_[mangle(d.name, paramTypes)] = fn;
  specRetTypes_[mangle(d.name, paramTypes)] = retType;
  curFn_ = fn;
  curRetType_ = llvmType(retType);
  locals_.clear();

  auto entry = llvm::BasicBlock::Create(ctx_, "entry", fn);
  builder_.SetInsertPoint(entry);
  if (d.name == "main") emitInitCalls();
  size_t i = 0;
  for (auto& arg : fn->args()) {
    if (i < d.params.size()) {
      auto alloca = builder_.CreateAlloca(arg.getType());
      builder_.CreateStore(&arg, alloca);
      locals_[d.params[i]] = alloca;
    }
    ++i;
  }

  for (const auto& s : *body) genStmt(*s);
  auto block = builder_.GetInsertBlock();
  if (block && !block->getTerminator()) {
    if (curRetType_ == llvm::Type::getVoidTy(ctx_)) {
      builder_.CreateRetVoid();
    } else {
      builder_.CreateRet(llvm::Constant::getNullValue(curRetType_));
    }
  }
}

bool Codegen::emitObject(const std::string& objectPath) {
  if (errors_.empty()) {
    declareEcsRuntime();
    for (const auto& name : systemOrder_) {
      const Decl* d = checker_.systems().at(name);
      emitSystemFunction(*d);
    }
    auto mainDecl = checker_.functionByName("main");
    if (mainDecl) {
      emitFunction(*mainDecl, {});
    }
    // Library mode: no main required, emit all other functions
  }
  if (!errors_.empty()) return false;
  if (const char* dump = std::getenv("KX_DUMP_IR")) {
    std::fprintf(stderr, "codegen: dumping IR to %s\n", dump);
    std::error_code ec2;
    llvm::raw_fd_ostream dos(dump, ec2, llvm::sys::fs::OF_None);
    module_->print(dos, nullptr);
  }

  std::string verifyMsg;
  llvm::raw_string_ostream verr(verifyMsg);
  if (llvm::verifyModule(*module_, &verr)) {
    errors_.push_back("codegen: module failed verification: " + verifyMsg);
    return false;
  }

  std::string err;
  module_->setTargetTriple(llvm::Triple(triple_));
  const llvm::Target* target = llvm::TargetRegistry::lookupTarget(triple_, err);
  if (!target) {
    errors_.push_back("codegen: " + err);
    return false;
  }
  auto tm = target->createTargetMachine(llvm::Triple(triple_), "generic", "",
                                        llvm::TargetOptions(), llvm::Reloc::PIC_);
  module_->setDataLayout(tm->createDataLayout());
  std::error_code ec;
  llvm::raw_fd_ostream os(objectPath, ec, llvm::sys::fs::OF_None);
  if (ec) {
    errors_.push_back("codegen: cannot open " + objectPath);
    return false;
  }
  llvm::legacy::PassManager pm;
  if (tm->addPassesToEmitFile(pm, os, nullptr, llvm::CodeGenFileType::ObjectFile)) {
    errors_.push_back("codegen: target does not support object emission");
    return false;
  }
  pm.run(*module_);
  os.flush();
  return true;
}

bool Codegen::emitExecutable(const std::string& objectPath, const std::string& runtimeObject,
                             const std::string& outputPath, const std::string& crossCompiler) {
  if (!emitObject(objectPath)) return false;
  std::string cmd = crossCompiler + " " + objectPath + " " + runtimeObject + " -lpthread -lm";
  for (const auto& lib : linkLibraries()) cmd += " -l" + lib;
  cmd += " -o " + outputPath;
  int rc = std::system(cmd.c_str());
  if (rc != 0) {
    errors_.push_back("codegen: linking failed");
    return false;
  }
  return true;
}

bool Codegen::emitSharedLibrary(const std::string& objectPath, const std::string& runtimeObject,
                                const std::string& outputPath, const std::string& crossCompiler) {
  if (!emitObject(objectPath)) return false;
  // Add .so extension if not already present
  std::string out = outputPath;
  if (out.find(".so") == std::string::npos) out += ".so";
  std::string cmd = crossCompiler + " -shared " + objectPath + " " + runtimeObject + " -lpthread -lm";
  for (const auto& lib : linkLibraries()) cmd += " -l" + lib;
  cmd += " -o " + out;
  int rc = std::system(cmd.c_str());
  if (rc != 0) {
    errors_.push_back("codegen: shared library linking failed");
    return false;
  }
  return true;
}

bool Codegen::emitStaticLibrary(const std::string& objectPath, const std::string& outputPath) {
  if (!emitObject(objectPath)) return false;
  std::string cmd = "ar rcs " + outputPath + " " + objectPath;
  int rc = std::system(cmd.c_str());
  if (rc != 0) {
    errors_.push_back("codegen: static library creation failed");
    return false;
  }
  return true;
}

}  // namespace kx