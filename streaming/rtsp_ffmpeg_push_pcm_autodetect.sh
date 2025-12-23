#!/bin/bash
# 自動偵測麥克風（PCM 版本，MediaMTX 可能不支援）
MIC_NAME=$(arecord -l | grep -oP 'card \K\d+' | head -1)
if [ -z "$MIC_NAME" ]; then
    MIC_NAME="0"
fi
MIC_NAME="hw:$MIC_NAME,0"

RTSP_URL="rtsp://127.0.0.1:8554/mic"

echo "使用麥克風裝置：$MIC_NAME"
ffmpeg -f alsa -i "$MIC_NAME" \
 -ar 48000 -ac 1 -c:a pcm_s16le \
 -fflags nobuffer \
 -probesize 32 -analyzeduration 0 \
 -flush_packets 1 \
 -f rtsp -rtsp_transport tcp \
 "$RTSP_URL"
