@echo off
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0organize_existing_by_queries.ps1"

echo.
pause

