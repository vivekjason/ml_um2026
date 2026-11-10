@echo off
setlocal
cd /d "%~dp0"
REM =====================================================================================
REM  download_videos.cmd  -  one-click offline copy of the workshop prep videos
REM  Tools, fetched on first run into THIS folder only: yt-dlp (Unlicense) and ffmpeg (GPL build).
REM  Output: videos\flight\ FIRST, then videos\statquest\ and videos\alternatives\ - numbered in watch order.
REM  Re-running is safe: finished videos are skipped.
REM  Optional: if YouTube says "Sign in to confirm you're not a bot", run this file from a Terminal as
REM      download_videos.cmd edge      (or chrome / firefox)  - it then uses that browser's YouTube cookies.
REM  Change HEIGHT to 480 for smaller files, 1080 for sharper slides.
REM =====================================================================================
set HEIGHT=720
set COOKIES=
if not "%~1"=="" set COOKIES=--cookies-from-browser %~1

echo.
echo === Step 1 of 3: yt-dlp ===
if not exist yt-dlp.exe curl -L --fail --retry 3 -o yt-dlp.exe https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe
if not exist yt-dlp.exe goto :no_ytdlp

echo.
echo === Step 2 of 3: ffmpeg - about 190 MB, one time only ===
if exist ffmpeg.exe goto :have_ffmpeg
curl -L --fail --retry 3 -o ffmpeg.zip https://github.com/yt-dlp/FFmpeg-Builds/releases/latest/download/ffmpeg-master-latest-win64-gpl.zip
if not exist ffmpeg.zip goto :have_ffmpeg
tar -xf ffmpeg.zip
copy /y ffmpeg-master-latest-win64-gpl\bin\ffmpeg.exe . >nul
copy /y ffmpeg-master-latest-win64-gpl\bin\ffprobe.exe . >nul
rmdir /s /q ffmpeg-master-latest-win64-gpl
del ffmpeg.zip
:have_ffmpeg
if not exist ffmpeg.exe echo !! ffmpeg not available - continuing anyway, quality may be limited to 360p/720p pre-merged files.

echo.
echo === Step 3 of 3: downloading - roughly 4 to 6 GB at 720p, 20 to 40 minutes ===
set "FMT=bv*[height<=%HEIGHT%][ext=mp4]+ba[ext=m4a]/b[height<=%HEIGHT%][ext=mp4]/b"
set "TEMPLATE=%%(autonumber)02d - %%(title)s.%%(ext)s"
set OPTS=--ffmpeg-location . --merge-output-format mp4 --write-subs --write-auto-subs --sub-langs en --embed-subs --embed-metadata --no-overwrites --no-playlist --ignore-errors --retries 5 %COOKIES%

echo.
echo --- 3a: flight priority set, into videos\flight ---
yt-dlp.exe %OPTS% -f "%FMT%" --download-archive downloaded_flight.txt -a urls_flight_priority.txt -P flight -o "%TEMPLATE%"

echo.
echo --- 3b: full StatQuest set, into videos\statquest ---
yt-dlp.exe %OPTS% -f "%FMT%" --download-archive downloaded.txt -a urls_statquest.txt -P statquest -o "%TEMPLATE%"

echo.
echo --- 3c: alternatives, into videos\alternatives ---
yt-dlp.exe %OPTS% -f "%FMT%" --download-archive downloaded.txt -a urls_alternatives.txt -P alternatives -o "%TEMPLATE%"

echo.
echo === Done. Open the flight, statquest and alternatives folders. Re-run this file to resume anything that failed. ===
pause
exit /b 0

:no_ytdlp
echo.
echo !! Could not download yt-dlp.exe. See README_videos.md for the winget fallback.
pause
exit /b 1
