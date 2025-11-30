#!/bin/bash
# === 手動設定 ===
MIC_NAME="hw:1,0"  # 通常是 USB 麥克風，執行 arecord -l 查看
SOURCE_PASS="hackme"
ICECAST_URL="icecast://source:${SOURCE_PASS}@127.0.0.1:8000/stream.mp3"

ffmpeg -f alsa -i "$MIC_NAME" \
 -ar 48000 -ac 1 -c:a libmp3lame -b:a 128k \
 -content_type audio/mpeg -legacy_icecast 1 -f mp3 \
 "$ICECAST_URL"
