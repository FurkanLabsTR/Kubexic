#include "project.h"

#include <filesystem>
#include <fstream>
#include <iostream>

namespace kubex {

static void writeToFile(const std::filesystem::path& path, const std::string& content) {
  std::ofstream out(path);
  if (!out) {
    std::cerr << "kubex: cannot create " << path << "\n";
    std::exit(1);
  }
  out << content;
}

int cmdInit(const std::string& dirName, const std::string& templateName) {
  namespace fs = std::filesystem;
  fs::path dir = fs::absolute(dirName.empty() ? "." : dirName);

  if (fs::exists(dir / ".kxconf")) {
    std::cerr << "kubex: " << dir << " already has a .kxconf\n";
    return 1;
  }

  if (!fs::exists(dir)) {
    fs::create_directories(dir);
  }

  std::string name = dir.filename().string();
  if (name == "." || name == "/") {
    name = "my-project";
  }

  // generate .kxconf
  std::string kxconf;
  kxconf += "// .kxconf — Kubexic project manifest\n\n";
  kxconf += "[package]\n";
  kxconf += "name = \"" + name + "\"\n";
  kxconf += "version = \"0.1.0\"\n";
  kxconf += "description = \"\"\n";
  kxconf += "license = \"MIT\"\n\n";
  kxconf += "[target]\n";

  if (templateName == "library") {
    kxconf += "kind = \"library\"\n";
    kxconf += "entry = \"lib.kx\"\n";
    kxconf += "output = \"lib" + name + ".so\"\n\n";
    kxconf += "[build]\n";
    kxconf += "optimization = \"release\"\n";
    writeToFile(dir / ".kxconf", kxconf);

    // library template
    writeToFile(dir / "lib.kx",
      "// " + name + " library\n\n"
      "pub fn hello() -> string {\n"
      "    return \"hello from " + name + "\";\n"
      "}\n");

    std::cout << "created library project '" << name << "'\n"
              << "  files: .kxconf, lib.kx\n"
              << "  build: kubex build\n";
  } else {
    kxconf += "kind = \"binary\"\n";
    kxconf += "entry = \"main.kx\"\n";
    kxconf += "output = \"" + name + "\"\n\n";
    kxconf += "[build]\n";
    kxconf += "optimization = \"release\"\n";
    writeToFile(dir / ".kxconf", kxconf);

    // binary template
    writeToFile(dir / "main.kx",
      "int main() {\n"
      "    std.println(\"Hello from " + name + "!\");\n"
      "    return 0;\n"
      "}\n");

    std::cout << "created project '" << name << "'\n"
              << "  files: .kxconf, main.kx\n"
              << "  build: kubex build\n"
              << "  run:   kubex run\n";
  }

  return 0;
}

}  // namespace kubex
