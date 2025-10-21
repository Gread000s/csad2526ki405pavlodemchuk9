@echo off
setlocal

echo "--- 1. DELETING OLD BUILD CACHE (rmdir /s /q build) ---"
if exist "build" (
    rmdir /s /q build
)

echo "--- 2. CREATING CLEAN BUILD DIRECTORY ---"
mkdir build
cd build

echo "--- 3. CONFIGURING CMAKE (Defaulting to Debug) ---"
REM Забираємо -DCMAKE_BUILD_TYPE=Release, CMake за замовчуванням використає Debug
cmake ..

echo "--- 4. BUILDING PROJECT (Debug) ---"
REM Явно збираємо конфігурацію Debug
cmake --build . --config Debug

echo "--- 5. RUNNING TESTS DIRECTLY (./Debug/run_tests.exe) ---"
REM Запускаємо Debug версію тесту напряму
.\Debug\run_tests.exe

popd
pause