@echo off
setlocal
chcp 65001 >nul

set "SCRIPT_DIR=%~dp0"
set "TARGET=%~1"

if "%TARGET%"=="" (
  set "TARGET=%SCRIPT_DIR%"
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%fix_dashes.ps1" -Root "%TARGET%"

echo.
pause
