#!/bin/bash
# === HTTP PCM/WAV 串流 - 手動設定 ===
MIC_NAME="hw:1,0"
PORT=8080

echo "啟動 HTTP PCM 串流伺服器在埠 $PORT..."
echo "在 iPhone 上播放: http://<Pi_IP>:$PORT/"
echo ""

ffmpeg -f alsa -i "$MIC_NAME" \
 -ar 48000 -ac 2 -f wav \
 -fflags nobuffer \
 -listen 1 http://0.0.0.0:$PORT/
