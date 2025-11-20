
@echo off
for /f "usebackq delims=" %I in (`powershell -NoProfile -Command "$d=Get-PnpDevice -Class AudioEndpoint -Status OK | Where-Object {$_.FriendlyName -match 'Microphone'} | Select-Object -First 1 -ExpandProperty FriendlyName; if(-not $d){$d='Microphone (Default)'}; Write-Output $d"`) do set MIC_NAME=%I

set RTSP_URL=rtsp://127.0.0.1:8554/mic

echo 使用麥克風裝置：%MIC_NAME%
ffmpeg -f dshow -audio_buffer_size 5 -rtbufsize 16 -thread_queue_size 1 -i audio="%MIC_NAME%" ^
 -ar 8000 -ac 1 -c:a aac -b:a 24k ^
 -flags +global_header -fflags nobuffer+flush_packets ^
 -max_delay 0 -probesize 16 -analyzeduration 0 ^
 -frame_size 128 -strict experimental ^
 -f rtsp -rtsp_transport tcp ^
 "%RTSP_URL%"
