@echo off
REM === 手動設定 - AAC 低延遲（RTSP 不支援 PCM）===
set MIC_NAME=@device_cm_{33D9A762-90C8-11D0-BD43-00A0C911CE86}\wave_{7CD6B6AA-B1E1-405F-8B3E-05687A6011E4}
set RTSP_URL=rtsp://172.20.10.8:8554/mic
ffmpeg -f dshow -audio_buffer_size 5 -rtbufsize 16 -thread_queue_size 1 -i audio="%MIC_NAME%" ^
 -ar 8000 -ac 1 -c:a aac -b:a 24k ^
 -flags +global_header -fflags nobuffer+flush_packets ^
 -max_delay 0 -probesize 16 -analyzeduration 0 ^
 -frame_size 128 -strict experimental ^
 -f rtsp -rtsp_transport tcp ^
 "%RTSP_URL%"
