cmake_minimum_required(VERSION 3.10)

# Set the project name and language
project(HelloWorld LANGUAGES CXX)

# Set the C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Add the executable for the main program
add_executable(HelloWorld main.cpp math_operations.cpp)

# Enable testing
enable_testing()

# GoogleTest
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/heads/main.zip
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# Add the test executable
add_executable(run_tests tests/unit_tests.cpp math_operations.cpp)

# Link GoogleTest to the test executable
target_link_libraries(run_tests PRIVATE gtest_main) # (Я додав слово PRIVATE, це гарна практика)

# Add a test to CTest
include(GoogleTest)
gtest_discover_tests(run_tests)