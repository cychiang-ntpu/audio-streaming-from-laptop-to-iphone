#!/bin/bash
# Raspberry Pi 防火牆設定（使用 ufw）

echo "開放防火牆埠 8000, 8080, 8554..."

# 檢查是否安裝 ufw
if ! command -v ufw &> /dev/null; then
    echo "ufw 未安裝，正在安裝..."
    sudo apt-get update
    sudo apt-get install -y ufw
fi

# 開放埠
sudo ufw allow 8000/tcp comment "Icecast"
sudo ufw allow 8080/tcp comment "HTTP-WAV"
sudo ufw allow 8554/tcp comment "RTSP"

# 確保 SSH 不被封鎖
sudo ufw allow 22/tcp comment "SSH"

echo "防火牆規則已新增（8000/8080/8554）。"
echo "如需啟用防火牆，請執行: sudo ufw enable"
