
@echo off
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "$d=Get-PnpDevice -Class AudioEndpoint -Status OK | Where-Object {$_.FriendlyName -match 'Microphone'} | Select-Object -First 1 -ExpandProperty FriendlyName; if(-not $d){$d='Microphone (Default)'}; Write-Output $d"`) do set MIC_NAME=%%I

set SOURCE_PASS=hackme
set ICECAST_URL=icecast://source:%SOURCE_PASS%@127.0.0.1:8000/stream.mp3

echo 使用麥克風裝置：%MIC_NAME%
ffmpeg -f dshow -i audio="%MIC_NAME%" ^
 -ar 48000 -ac 1 -c:a libmp3lame -b:a 128k ^
 -content_type audio/mpeg -legacy_icecast 1 -f mp3 ^
 "%ICECAST_URL%"
