#!/bin/bash
# 自動偵測第一個可用的音訊輸入裝置
MIC_NAME=$(arecord -l | grep -oP 'card \K\d+' | head -1)
if [ -z "$MIC_NAME" ]; then
    MIC_NAME="0"
fi
MIC_NAME="hw:$MIC_NAME,0"

SOURCE_PASS="hackme"
ICECAST_URL="icecast://source:${SOURCE_PASS}@127.0.0.1:8000/stream.mp3"

echo "使用麥克風裝置：$MIC_NAME"
ffmpeg -f alsa -i "$MIC_NAME" \
 -ar 48000 -ac 1 -c:a libmp3lame -b:a 128k \
 -content_type audio/mpeg -legacy_icecast 1 -f mp3 \
 "$ICECAST_URL"
