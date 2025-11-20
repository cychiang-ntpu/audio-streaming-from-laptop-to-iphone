
@echo off
netsh advfirewall firewall add rule name="Icecast 8000" dir=in action=allow protocol=TCP localport=8000
netsh advfirewall firewall add rule name="HTTP-WAV 8080" dir=in action=allow protocol=TCP localport=8080
netsh advfirewall firewall add rule name="RTSP 8554"   dir=in action=allow protocol=TCP localport=8554
echo 防火牆規則已新增（8000/8080/8554）。
pause
