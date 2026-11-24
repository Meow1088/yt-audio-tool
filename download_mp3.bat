@echo off
setlocal

rem Use this only for videos/playlists you own, public domain, Creative Commons,
rem YouTube Audio Library, or content where the uploader permits downloading.

set "ROOT=%~dp0"
set "YTDLP=%ROOT%tools\yt-dlp.exe"
set "FFMPEG_DIR=%ROOT%tools\ffmpeg\bin"
set "LINKS=%ROOT%links.txt"
set "OUTDIR=%ROOT%downloads"

if not exist "%YTDLP%" (
  echo Missing yt-dlp: "%YTDLP%"
  pause
  exit /b 1
)

if not exist "%FFMPEG_DIR%\ffmpeg.exe" (
  echo Missing ffmpeg: "%FFMPEG_DIR%\ffmpeg.exe"
  echo Cannot convert to MP3 without ffmpeg.
  pause
  exit /b 1
)

if not exist "%LINKS%" (
  echo Missing links file: "%LINKS%"
  pause
  exit /b 1
)

if not exist "%OUTDIR%" mkdir "%OUTDIR%"

echo.
echo Reading links from:
echo %LINKS%
echo.
echo Saving MP3 files to:
echo %OUTDIR%
echo.

"%YTDLP%" ^
  --ignore-errors ^
  --no-abort-on-error ^
  --js-runtimes node ^
  --download-archive "%ROOT%downloaded_archive.txt" ^
  --ffmpeg-location "%FFMPEG_DIR%" ^
  -f "bestaudio/best" ^
  -x --audio-format mp3 --audio-quality 0 ^
  --embed-metadata ^
  --no-write-thumbnail ^
  -o "%OUTDIR%\%%(playlist_title|Single Videos)s\%%(playlist_index|000)s - %%(title).200B [%%(id)s].%%(ext)s" ^
  -a "%LINKS%"

echo.
echo Done. Check the downloads folder.
pause
