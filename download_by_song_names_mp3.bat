@echo off
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0download_by_song_names_mp3.ps1"

echo.
pause

