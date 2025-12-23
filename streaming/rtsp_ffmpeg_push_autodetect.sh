#!/bin/bash
# 自動偵測麥克風並使用 AAC 低延遲編碼
MIC_NAME=$(arecord -l | grep -oP 'card \K\d+' | head -1)
if [ -z "$MIC_NAME" ]; then
    MIC_NAME="0"
fi
MIC_NAME="hw:$MIC_NAME,0"

RTSP_URL="rtsp://127.0.0.1:8554/mic"

echo "使用麥克風裝置：$MIC_NAME"
ffmpeg -f alsa -i "$MIC_NAME" \
 -ar 8000 -ac 1 -c:a aac -b:a 24k \
 -flags +global_header -fflags nobuffer+flush_packets \
 -max_delay 0 -probesize 16 -analyzeduration 0 \
 -strict experimental \
 -f rtsp -rtsp_transport tcp \
 "$RTSP_URL"
