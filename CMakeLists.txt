cmake_minimum_required(VERSION 3.16)
project(HelloWorld LANGUAGES CXX)

# --- УВІМКНУТИ CTEST ---
# Додай цей рядок:
include(CTest)

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

# --- РІШЕННЯ ДЛЯ MSB3073: ---
# Кажемо GoogleTest НЕ додавати "post-build event" для запуску тестів
set(GTEST_ADD_TESTS_POST_BUILD OFF) 

FetchContent_MakeAvailable(googletest) # Це створює цілі gtest та gtest_main

# --- Тестова програма ---
add_executable(unit_tests
    tests/unit_tests.cpp
    math_operations.cpp
)

# --- РІШЕННЯ ДЛЯ ***Not Run: ---
set_property(TARGET unit_tests PROPERTY EXCLUDE_FROM_ALL FALSE)

# --- Лінкування ---
target_link_libraries(unit_tests PRIVATE gtest gtest_main)

# --- Додаємо наш виконуваний файл як тест для CTest ---
add_test(NAME BasicAdditionTest COMMAND unit_tests)