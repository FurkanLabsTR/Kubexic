cmake_minimum_required(VERSION 3.20)
project(kubexic LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug)
endif()

find_package(LLVM REQUIRED CONFIG)
message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
include_directories(${LLVM_INCLUDE_DIRS})

add_subdirectory(src)
add_subdirectory(tools/kxc)
add_subdirectory(tools/kubex)
enable_testing()
add_subdirectory(tests)