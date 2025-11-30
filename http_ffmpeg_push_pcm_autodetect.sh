#!/bin/bash
# 自動偵測麥克風
MIC_NAME=$(arecord -l | grep -oP 'card \K\d+' | head -1)
if [ -z "$MIC_NAME" ]; then
    MIC_NAME="0"
fi
MIC_NAME="hw:$MIC_NAME,0"

PORT=8080

echo "使用麥克風裝置：$MIC_NAME"
echo "啟動 HTTP PCM 串流伺服器在埠 $PORT..."
echo "在 iPhone 上播放: http://<Pi_IP>:$PORT/"
echo ""

ffmpeg -f alsa -i "$MIC_NAME" \
 -ar 48000 -ac 1 -f wav \
 -fflags nobuffer \
 -listen 1 http://0.0.0.0:$PORT/
