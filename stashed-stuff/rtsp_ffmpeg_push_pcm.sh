#!/bin/bash
# === 手動設定 - AAC 低延遲（RTSP 不支援 PCM）===
MIC_NAME="hw:1,0"
RTSP_URL="rtsp://127.0.0.1:8554/mic"

ffmpeg -f alsa -i "$MIC_NAME" \
 -ar 8000 -ac 1 -c:a aac -b:a 24k \
 -flags +global_header -fflags nobuffer+flush_packets \
 -max_delay 0 -probesize 16 -analyzeduration 0 \
 -strict experimental \
 -f rtsp -rtsp_transport tcp \
 "$RTSP_URL"
