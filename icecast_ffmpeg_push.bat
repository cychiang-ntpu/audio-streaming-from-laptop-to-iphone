
@echo off
REM === 手動設定 ===
set MIC_NAME=Microphone (Realtek(R) Audio)
set SOURCE_PASS=hackme
set ICECAST_URL=icecast://source:%SOURCE_PASS%@127.0.0.1:8000/stream.mp3

ffmpeg -f dshow -i audio="%MIC_NAME%" ^
 -ar 48000 -ac 1 -c:a libmp3lame -b:a 128k ^
 -content_type audio/mpeg -legacy_icecast 1 -f mp3 ^
 "%ICECAST_URL%"
