@echo off
REM === HTTP PCM/WAV 串流 - 手動設定 ===
set MIC_NAME=@device_cm_{33D9A762-90C8-11D0-BD43-00A0C911CE86}\wave_{7CD6B6AA-B1E1-405F-8B3E-05687A6011E4}
set PORT=8080

echo 啟動 HTTP PCM 串流伺服器在埠 %PORT%...
echo 在 iPhone 上播放: http://172.20.10.8:%PORT%/
echo.

ffmpeg -f dshow -audio_buffer_size 5 -i audio="%MIC_NAME%" ^
 -ar 48000 -ac 2 -f wav ^
 -fflags nobuffer ^
 -listen 1 http://0.0.0.0:%PORT%/

