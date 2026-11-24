@echo off
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0check_downloads.ps1"

echo.
pause

