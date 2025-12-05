@echo off
echo Running download_installers.ps1...
powershell -ExecutionPolicy Bypass -File "%~dp0download_installers.ps1"
echo.

echo PowerShell exit code: %ERRORLEVEL%

if %ERRORLEVEL% EQU 0 (
    echo [OK] All installers completed successfully or were already installed.
) else (
    echo [ERROR] One or more installers failed. Check the log:
    echo        "%~dp0download_installers.log"
)

echo.
pause
