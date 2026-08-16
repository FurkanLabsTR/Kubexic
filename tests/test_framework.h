#pragma once

#include <cstdio>
#include <functional>
#include <string>
#include <vector>

namespace kxtest {

struct TestCase {
  std::string name;
  std::function<void()> fn;
};

inline std::vector<TestCase>& registry() {
  static std::vector<TestCase> tests;
  return tests;
}

struct Registrar {
  Registrar(const std::string& name, std::function<void()> fn) {
    registry().push_back(TestCase{name, std::move(fn)});
  }
};

#define KX_TEST(name)                                              \
  static void kx_test_##name();                                    \
  static ::kxtest::Registrar kx_reg_##name(#name, kx_test_##name); \
  static void kx_test_##name()

inline int runAll(const char* suite) {
  int failures = 0;
  for (auto& t : registry()) {
    try {
      t.fn();
      std::printf("[PASS] %s\n", t.name.c_str());
    } catch (const std::string& e) {
      failures++;
      std::printf("[FAIL] %s: %s\n", t.name.c_str(), e.c_str());
    } catch (const char* e) {
      failures++;
      std::printf("[FAIL] %s: %s\n", t.name.c_str(), e);
    } catch (const std::exception& e) {
      failures++;
      std::printf("[FAIL] %s: %s\n", t.name.c_str(), e.what());
    } catch (...) {
      failures++;
      std::printf("[FAIL] %s: unknown exception\n", t.name.c_str());
    }
  }
  std::printf("---\n%s: %zu tests, %d failures\n", suite, registry().size(), failures);
  return failures == 0 ? 0 : 1;
}

struct Expect {
  static void eq(long a, long b, const char* msg) {
    if (a != b) throw std::string(msg) + " (expected " + std::to_string(a) + ", got " + std::to_string(b) + ")";
  }
  static void strEq(const std::string& a, const std::string& b, const char* msg) {
    if (a != b) throw std::string(msg) + " (expected \"" + b + "\", got \"" + a + "\")";
  }
  static void true_(bool v, const char* msg) {
    if (!v) throw std::string(msg);
  }
  static void false_(bool v, const char* msg) {
    if (v) throw std::string(msg);
  }
  static void close(double a, double b, const char* msg) {
    double d = a - b;
    if (d < 0) d = -d;
    if (d > 1e-12) throw std::string(msg) + " (expected " + std::to_string(b) + ", got " + std::to_string(a) + ")";
  }
};

}  // namespace kxtest