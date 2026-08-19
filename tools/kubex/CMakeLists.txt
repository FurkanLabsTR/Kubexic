add_executable(kubex
  main.cpp
  kxconf.cpp
  project.cpp
  deps.cpp
  build.cpp
  init.cpp
  semver.cpp
  auth_manager.cpp
  registry_client.cpp
  archive_build.cpp
)
target_compile_features(kubex PRIVATE cxx_std_17)
