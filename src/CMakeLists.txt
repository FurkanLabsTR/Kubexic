add_library(kubexic_core STATIC
  lexer/lexer.cpp
  parser/parser.cpp
)
target_include_directories(kubexic_core PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/lexer
  ${CMAKE_CURRENT_SOURCE_DIR}/parser
  ${CMAKE_CURRENT_SOURCE_DIR}/ast
)