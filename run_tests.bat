@echo off
REM Run all tests for Minecraft Survivors
REM Usage: run_tests.bat

echo Running Minecraft Survivors Test Suite...
echo.

REM Try to find Godot in common locations
set GODOT_CMD=

REM Check if godot is in PATH
where godot >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set GODOT_CMD=godot
    goto :run_tests
)

REM Check common installation paths
if exist "C:\Program Files\Godot\godot.exe" (
    set GODOT_CMD="C:\Program Files\Godot\godot.exe"
    goto :run_tests
)

if exist "C:\Program Files (x86)\Godot\godot.exe" (
    set GODOT_CMD="C:\Program Files (x86)\Godot\godot.exe"
    goto :run_tests
)

if exist "%LOCALAPPDATA%\Godot\godot.exe" (
    set GODOT_CMD="%LOCALAPPDATA%\Godot\godot.exe"
    goto :run_tests
)

REM Check for Godot 4 specific names
where godot4 >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set GODOT_CMD=godot4
    goto :run_tests
)

where Godot_v4.5-stable_win64.exe >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set GODOT_CMD=Godot_v4.5-stable_win64.exe
    goto :run_tests
)

REM Godot not found
echo ERROR: Godot not found in PATH or common locations.
echo Please ensure Godot is installed and added to PATH.
echo.
echo You can also set GODOT_PATH environment variable:
echo   set GODOT_PATH=C:\path\to\godot.exe
echo   run_tests.bat
exit /b 1

:run_tests
REM Use GODOT_PATH if set
if defined GODOT_PATH (
    set GODOT_CMD=%GODOT_PATH%
)

echo Using Godot: %GODOT_CMD%
echo.

%GODOT_CMD% --headless --script "%~dp0tests\test_runner.gd"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [32m✓ All tests passed![0m
) else (
    echo.
    echo [31m✗ Some tests failed![0m
)

exit /b %ERRORLEVEL%
