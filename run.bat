@echo off
cd /d "%~dp0"

echo Running download_installers.ps1...
powershell -ExecutionPolicy Bypass -File "%~dp0download_installers.ps1"
echo.

echo PowerShell exit code: %ERRORLEVEL%

if %ERRORLEVEL% EQU 0 (
    echo [OK] Discord installed successfully or was already installed.
) else (
    echo [ERROR] Discord install failed. Check the log:
    echo        "%~dp0download_installers.log"
)

echo.
pause
