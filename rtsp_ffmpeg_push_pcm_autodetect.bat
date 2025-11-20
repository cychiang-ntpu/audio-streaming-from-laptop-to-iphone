@echo off
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "$d=Get-PnpDevice -Class AudioEndpoint -Status OK | Where-Object {$_.FriendlyName -match 'Microphone'} | Select-Object -First 1 -ExpandProperty FriendlyName; if(-not $d){$d='Microphone (Default)'}; Write-Output $d"`) do set MIC_NAME=%%I

set RTSP_URL=rtsp://127.0.0.1:8554/mic

echo 使用麥克風裝置：%MIC_NAME%
ffmpeg -f dshow -audio_buffer_size 20 -i audio="%MIC_NAME%" ^
 -ar 48000 -ac 1 -c:a pcm_s16le ^
 -fflags nobuffer ^
 -probesize 32 -analyzeduration 0 ^
 -flush_packets 1 ^
 -f rtsp -rtsp_transport tcp ^
 "%RTSP_URL%"
