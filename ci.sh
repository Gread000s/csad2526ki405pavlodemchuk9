#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Create the 'build' directory if it doesn't exist
if [ ! -d "build" ]; then
  mkdir build
fi

# Navigate to the 'build' directory
cd build

# Run CMake to configure the project
cmake ..

# Build the project
cmake --build .

# Run tests
ctest