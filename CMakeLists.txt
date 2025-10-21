cmake_minimum_required(VERSION 3.16)
project(HelloWorld LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# --- Головна програма ---
add_executable(HelloWorld main.cpp math_operations.cpp)

# --- GoogleTest ---
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/heads/main.zip
)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
# set(GTEST_DISCOVER_TESTS_POST_BUILD OFF) - НЕ ПОТРІБНО
FetchContent_MakeAvailable(googletest) # Це створює цілі gtest та gtest_main

# --- Тестова програма ---
add_executable(run_tests
    tests/unit_tests.cpp # Цей файл тепер містить main()
    math_operations.cpp
)

# Лінкуємо ТІЛЬКИ бібліотеку gtest (БЕЗ gtest_main),

target_link_libraries(run_tests PRIVATE gtest)