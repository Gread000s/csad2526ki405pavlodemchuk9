@echo off
setlocal

echo "--- 1. DELETING OLD BUILD CACHE ---"
if exist "build" (
    rmdir /s /q build
)

echo "--- 2. CREATING CLEAN BUILD DIRECTORY ---"
mkdir build
if %errorlevel% neq 0 ( exit /b %errorlevel% )
cd build
if %errorlevel% neq 0 ( exit /b %errorlevel% )

echo "--- 3. CONFIGURING CMAKE ---"
cmake ..
if %errorlevel% neq 0 (
    echo "!!!! CMAKE CONFIGURE FAILED !!!!"
    exit /b %errorlevel%
)

echo "--- 4. BUILDING PROJECT (Debug) ---"
cmake --build . --config Debug
if %errorlevel% neq 0 (
    echo "!!!! CMAKE BUILD FAILED !!!!"
    exit /b %errorlevel%
)

echo "--- 5. RUNNING TESTS WITH CTEST (Debug) ---"
ctest -C Debug --verbose
if %errorlevel% neq 0 (
    echo "!!!! CTEST FAILED !!!!"
    exit /b %errorlevel%
)

popd
echo "CI SCRIPT COMPLETED SUCCESSFULLY"