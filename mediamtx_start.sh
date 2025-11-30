#!/bin/bash

if [ ! -f "mediamtx" ]; then
  echo "找不到 mediamtx，請先下載 ARM 版本："
  echo "wget https://github.com/bluenviron/mediamtx/releases/latest/download/mediamtx_$(uname -s | tr '[:upper:]' '[:lower:]')_$(uname -m | sed 's/aarch64/arm64v8/;s/armv7l/armv7/').tar.gz"
  echo "tar -xzf mediamtx_*.tar.gz"
  exit 1
fi

if [ ! -f "mediamtx.yml" ]; then
  echo "rtspAddress: :8554" > mediamtx.yml
fi

chmod +x mediamtx
./mediamtx mediamtx.yml
