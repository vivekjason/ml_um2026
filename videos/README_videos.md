# Offline prep videos — how to get them onto your laptop

**Double-click `download_videos.cmd`** (this folder) while you are on Wi-Fi. It fetches two open-source tools into
this folder only (yt-dlp and ffmpeg — nothing is installed system-wide, no admin rights needed), then downloads
every video in `urls_statquest.txt` and `urls_alternatives.txt` at 720p with English subtitles embedded, numbered in
watch order, into `statquest\` and `alternatives\`. Budget 20–40 minutes and ~4–6 GB on a normal connection.
Re-running the file resumes; finished videos are skipped.

Then copy the two folders to the laptop/tablet you will have on the flight. Any player opens them (VLC, Windows
Media Player, Films & TV, iPad Files app).

## If Windows shows a blue "Windows protected your PC" box

That is SmartScreen reacting to an unsigned program it has not seen before (yt-dlp.exe). Click **More info → Run
anyway**. yt-dlp is the standard open-source YouTube downloader (https://github.com/yt-dlp/yt-dlp, 100k+ GitHub
stars); the script downloads it straight from that project's own release page.

## If the download of the tools fails (network blocks GitHub)

Windows 11 has `winget` built in. Open **Terminal** (right-click Start → Terminal) and run:

```
winget install --id yt-dlp.yt-dlp -e --accept-source-agreements --accept-package-agreements
winget install --id Gyan.FFmpeg   -e --accept-source-agreements --accept-package-agreements
```

Close and reopen Terminal (so the new programs are on the PATH), then:

```
cd C:\codex\training\ml_um2026\videos
yt-dlp -a urls_statquest.txt    -P statquest    -o "%(autonumber)02d - %(title)s.%(ext)s" -f "bv*[height<=720][ext=mp4]+ba[ext=m4a]/b[height<=720][ext=mp4]/b" --merge-output-format mp4 --write-subs --write-auto-subs --sub-langs en --embed-subs --download-archive downloaded.txt --no-playlist --ignore-errors
yt-dlp -a urls_alternatives.txt -P alternatives -o "%(autonumber)02d - %(title)s.%(ext)s" -f "bv*[height<=720][ext=mp4]+ba[ext=m4a]/b[height<=720][ext=mp4]/b" --merge-output-format mp4 --write-subs --write-auto-subs --sub-langs en --embed-subs --download-archive downloaded.txt --no-playlist --ignore-errors
```

## Smaller files / fewer videos

- Open `download_videos.cmd` in Notepad and change `set HEIGHT=720` to `480` — about half the size; the slides stay legible.
- Delete lines from `urls_statquest.txt` to skip videos; remove the leading `#` from the "Optional" lines to add them.

## Why this folder is gitignored

`videos/statquest/`, `videos/alternatives/`, the `.exe` files and `downloaded.txt` are in `.gitignore`, so pushing
the project to GitHub will not upload gigabytes of video.

## Flight list

`urls_flight_priority.txt` is downloaded **first**, into `flight\`, numbered 01–31 in the order to watch them
(01–14 flight out: the neural-network session; 15–29 flight back: RF/SVM/XGBoost refresh and evaluation; 30–31 if
time remains). If the download tonight gets interrupted, this is the folder that will be complete.
