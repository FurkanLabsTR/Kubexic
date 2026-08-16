add_executable(lexer_tests lexer_tests.cpp)
target_link_libraries(lexer_tests PRIVATE kubexic_core)
target_include_directories(lexer_tests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
add_test(NAME lexer_tests COMMAND lexer_tests)

add_executable(parser_tests parser_tests.cpp)
target_link_libraries(parser_tests PRIVATE kubexic_core)
target_include_directories(parser_tests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
add_test(NAME parser_tests COMMAND parser_tests)

add_executable(sema_tests sema_tests.cpp)
target_link_libraries(sema_tests PRIVATE kubexic_core)
target_include_directories(sema_tests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
add_test(NAME sema_tests COMMAND sema_tests)

add_executable(mir_tests mir_tests.cpp)
target_link_libraries(mir_tests PRIVATE kubexic_core)
target_include_directories(mir_tests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
add_test(NAME mir_tests COMMAND mir_tests)