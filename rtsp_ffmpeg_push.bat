
@echo off
REM === 手動設定 ===
set MIC_NAME=@device_cm_{33D9A762-90C8-11D0-BD43-00A0C911CE86}\wave_{7CD6B6AA-B1E1-405F-8B3E-05687A6011E4}
set RTSP_URL=rtsp://172.20.10.8:8554/mic
ffmpeg -f dshow -audio_buffer_size 20 -i audio="%MIC_NAME%" ^
 -ar 48000 -ac 1 -c:a pcm_s16le ^
 -fflags nobuffer ^
 -probesize 32 -analyzeduration 0 ^
 -flush_packets 1 ^
 -f rtsp -rtsp_transport tcp ^
 "%RTSP_URL%"