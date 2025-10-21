@echo off
setlocal

echo "--- 1. DELETING OLD BUILD CACHE ---"
if exist "build" (
    rmdir /s /q build
)

echo "--- 2. CREATING CLEAN BUILD DIRECTORY ---"
mkdir build
cd build

echo "--- 3. CONFIGURING CMAKE ---"
:: Ми запускаємо CTest з конфігурацією, тому тут вона не потрібна
cmake ..

echo "--- 4. BUILDING PROJECT (Debug) ---"
:: Збираємо конфігурацію Debug
cmake --build . --config Debug

echo "--- 5. RUNNING TESTS WITH CTEST (Debug) ---"
:: Запускаємо CTest, вказуючи йому конфігурацію для тестування
ctest -C Debug --verbose

popd
pause