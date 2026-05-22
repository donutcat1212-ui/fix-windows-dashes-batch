@echo off
setlocal
chcp 65001 >nul

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

set "TARGET=%~1"

if "%TARGET%"=="" (
  set "TARGET=%SCRIPT_DIR%"
)
if "%TARGET:~-1%"=="\" set "TARGET=%TARGET:~0,-1%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\fix_dashes.ps1" -Root "%TARGET%"

echo.
pause
