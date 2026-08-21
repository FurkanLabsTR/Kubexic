// llvm_shim.c — C shim for complex LLVM C API operations
// Wraps operations that are hard to express via pure extern declarations

#include <llvm-c/Core.h>
#include <llvm-c/TargetMachine.h>
#include <llvm-c/Analysis.h>
#include <llvm-c/BitWriter.h>
#include <llvm-c/Transforms/PassBuilder.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Initialize all targets (call once at startup)
void kx_llvm_init_targets() {
    LLVMInitializeX86TargetInfo();
    LLVMInitializeX86Target();
    LLVMInitializeX86TargetMC();
    LLVMInitializeX86AsmPrinter();
    LLVMInitializeAArch64TargetInfo();
    LLVMInitializeAArch64Target();
    LLVMInitializeAArch64TargetMC();
    LLVMInitializeAArch64AsmPrinter();
}

// Create a target machine for the given triple
LLVMTargetMachineRef kx_llvm_create_target_machine(const char* triple) {
    char* error = NULL;
    LLVMTargetRef target = NULL;

    if (LLVMGetTargetFromTriple(triple, &target, &error) != 0) {
        fprintf(stderr, "kx: failed to get target: %s\n", error ? error : "unknown");
        if (error) LLVMDisposeMessage(error);
        return NULL;
    }

    return LLVMCreateTargetMachine(target, triple, "generic", "",
                                   LLVMRelocPIC, LLVMCodeModelDefault, LLVMCodeGenLevelNone);
}

// Emit object file to path
int kx_llvm_emit_object(LLVMModuleRef m, const char* triple, const char* outpath) {
    LLVMTargetMachineRef tm = kx_llvm_create_target_machine(triple);
    if (!tm) return 0;

    char* error = NULL;
    if (LLVMTargetMachineEmitToFile(tm, m, outpath, LLVMObjectFile, &error) != 0) {
        fprintf(stderr, "kx: failed to emit object: %s\n", error ? error : "unknown");
        if (error) LLVMDisposeMessage(error);
        LLVMDisposeTargetMachine(tm);
        return 0;
    }

    LLVMDisposeTargetMachine(tm);
    return 1;
}

// Emit LLVM IR text to path
int kx_llvm_emit_ir(LLVMModuleRef m, const char* outpath) {
    char* error = NULL;
    if (LLVMPrintModuleToFile(m, outpath, &error) != 0) {
        fprintf(stderr, "kx: failed to emit IR: %s\n", error ? error : "unknown");
        if (error) LLVMDisposeMessage(error);
        return 0;
    }
    return 1;
}

// Verify module and return error message if any
int kx_llvm_verify(LLVMModuleRef m, char** error_out) {
    char* error = NULL;
    int result = LLVMVerifyModule(m, LLVMPrintMessageAction, &error);
    if (error_out) *error_out = error;
    return result == 0;
}

// Create a function with N i64 params returning i64
LLVMValueRef kx_llvm_make_i64_fn(LLVMModuleRef m, const char* name, int param_count) {
    LLVMTypeRef params[256];
    for (int i = 0; i < param_count && i < 256; i++) {
        params[i] = LLVMInt64Type();
    }
    LLVMTypeRef fn_type = LLVMFunctionType(LLVMInt64Type(), params, param_count, 0);
    return LLVMAddFunction(m, name, fn_type);
}

// Create a function with N i64 params returning void
LLVMValueRef kx_llvm_make_void_fn(LLVMModuleRef m, const char* name, int param_count) {
    LLVMTypeRef params[256];
    for (int i = 0; i < param_count && i < 256; i++) {
        params[i] = LLVMInt64Type();
    }
    LLVMTypeRef fn_type = LLVMFunctionType(LLVMVoidType(), params, param_count, 0);
    return LLVMAddFunction(m, name, fn_type);
}

// Get function parameter by index
LLVMValueRef kx_llvm_get_param(LLVMValueRef fn, int index) {
    return LLVMGetParam(fn, index);
}

// Build a call with i64 args
LLVMValueRef kx_llvm_build_call_i64(LLVMBuilderRef b, LLVMValueRef fn,
                                     LLVMValueRef* args, int argc, const char* name) {
    return LLVMBuildCall2(b, LLVMGetElementType(LLVMTypeOf(fn)), fn, args, argc, name);
}

// Get the size of a struct type
unsigned kx_llvm_struct_size(LLVMTypeRef ty) {
    return LLVMCountStructElementTypes(ty);
}

// Create a named struct type
LLVMTypeRef kx_llvm_create_struct(const char* name, LLVMTypeRef* elements, int count) {
    LLVMTypeRef ty = LLVMStructCreateNamed(LLVMGetGlobalContext(), name);
    LLVMStructSetBody(ty, elements, count, 0);
    return ty;
}

// Initialize pass builder (for optimization)
void kx_llvm_init_pass_builder() {
    LLVMInitializePasses();
}
