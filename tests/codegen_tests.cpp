#include "codegen.h"
#include "checker.h"
#include "lexer.h"
#include "mir.h"
#include "parser.h"
#include "test_framework.h"

#include <sstream>

using namespace kx;
using namespace kxtest;

static std::string codegenSrc(const std::string& src) {
  std::vector<ParseError> parseErrors;
  auto program = parseSource(src, "<test>", &parseErrors);
  if (!program) {
    std::string err = "PARSE_ERROR";
    for (const auto& e : parseErrors) err += " " + e.message;
    return err;
  }
  Checker checker;
  checker.addProgram(std::move(program));
  if (!checker.check()) {
    std::string err = "SEMA_ERROR";
    for (const auto& e : checker.errors()) err += " " + e;
    return err;
  }
  Mir mir;
  mir.analyze(checker);
  Codegen codegen(checker, mir, "x86_64-unknown-linux-gnu");
  bool ok = codegen.emitObject("/tmp/codegen_test.o");
  if (!ok) {
    std::string err = "CODEGEN_ERROR";
    for (const auto& e : codegen.errors()) err += " " + e;
    return err;
  }
  return "OK";
}

static void expectOk(const std::string& src) {
  std::string result = codegenSrc(src);
  Expect::strEq(result, "OK", "expected successful codegen");
}

static void expectError(const std::string& src) {
  std::string result = codegenSrc(src);
  Expect::true_(result.find("ERROR") != std::string::npos, "expected codegen error");
}

KX_TEST(codegen_int_return) {
  expectOk("int main() { return 0; }");
}

KX_TEST(codegen_var_declaration) {
  expectOk("int main() { var x = 42; return x; }");
}

KX_TEST(codegen_arithmetic) {
  expectOk("int main() { var x = 1 + 2 * 3; return x; }");
}

KX_TEST(codegen_if_else) {
  expectOk(R"(
    int main() {
      var x = 10;
      if (x > 5) {
        x = 1;
      } else {
        x = 2;
      }
      return x;
    }
  )");
}

KX_TEST(codegen_while_loop) {
  expectOk(R"(
    int main() {
      var i = 0;
      while (i < 10) {
        i += 1;
      }
      return i;
    }
  )");
}

KX_TEST(codegen_function_call) {
  expectOk(R"(
    var add(a, b) {
      return a + b;
    }
    int main() {
      return add(1, 2);
    }
  )");
}

KX_TEST(codegen_string_literal) {
  expectOk(R"(
    int main() {
      var s = "hello";
      return 0;
    }
  )");
}

KX_TEST(codegen_float_arithmetic) {
  expectOk(R"(
    int main() {
      var x = 3.14 * 2.0;
      return 0;
    }
  )");
}

KX_TEST(codegen_expression_body) {
  expectOk(R"(
    var add(a, b) -> a + b;
    int main() { return add(1, 2); }
  )");
}

int main() {
  return kxtest::runAll("codegen_tests");
}
