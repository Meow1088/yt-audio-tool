@echo off
setlocal

rem Downloads the best available original audio stream without converting to MP3.
rem This is faster and avoids quality loss from re-encoding.
rem Use only for content you are allowed to download.

set "ROOT=%~dp0"
set "YTDLP=%ROOT%tools\yt-dlp.exe"
set "LINKS=%ROOT%links.txt"
set "OUTDIR=%ROOT%downloads"

if not exist "%YTDLP%" (
  echo Missing yt-dlp: "%YTDLP%"
  pause
  exit /b 1
)

if not exist "%LINKS%" (
  echo Missing links file: "%LINKS%"
  pause
  exit /b 1
)

if not exist "%OUTDIR%" mkdir "%OUTDIR%"

"%YTDLP%" ^
  --ignore-errors ^
  --no-abort-on-error ^
  --js-runtimes node ^
  --download-archive "%ROOT%downloaded_archive.txt" ^
  -f bestaudio ^
  -o "%OUTDIR%\%%(playlist_title|Single Videos)s\%%(playlist_index|000)s - %%(title).200B [%%(id)s].%%(ext)s" ^
  -a "%LINKS%"

echo.
echo Done. Check the downloads folder.
pause

