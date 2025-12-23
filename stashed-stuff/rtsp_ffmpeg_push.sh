#!/bin/bash
# === 手動設定 ===
MIC_NAME="hw:1,0"
RTSP_URL="rtsp://127.0.0.1:8554/mic"

ffmpeg -f alsa -i "$MIC_NAME" \
 -ar 48000 -ac 1 -c:a pcm_s16le \
 -fflags nobuffer \
 -probesize 32 -analyzeduration 0 \
 -flush_packets 1 \
 -f rtsp -rtsp_transport tcp \
 "$RTSP_URL"
