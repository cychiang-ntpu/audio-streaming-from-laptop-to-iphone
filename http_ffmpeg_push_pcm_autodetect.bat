@echo off
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "$d=Get-PnpDevice -Class AudioEndpoint -Status OK | Where-Object {$_.FriendlyName -match 'Microphone'} | Select-Object -First 1 -ExpandProperty FriendlyName; if(-not $d){$d='Microphone (Default)'}; Write-Output $d"`) do set MIC_NAME=%%I

set PORT=8080

echo 使用麥克風裝置：%MIC_NAME%
echo 啟動 HTTP PCM 串流伺服器在埠 %PORT%...
echo 在 iPhone 上播放: http://172.20.10.8:%PORT%/
echo.

ffmpeg -f dshow -audio_buffer_size 20 -i audio="%MIC_NAME%" ^
 -ar 48000 -ac 1 -f wav ^
 -fflags nobuffer ^
 -listen 1 http://0.0.0.0:%PORT%/
