# Raspberry Pi 快速安裝指南

## 1. 系統準備

### 安裝 Raspberry Pi OS
```bash
# 建議使用 Raspberry Pi OS Lite（64-bit）以節省資源
# 使用 Raspberry Pi Imager 燒錄到 SD 卡
```

### 首次啟動設定
```bash
# 更新系統
sudo apt-get update
sudo apt-get upgrade -y

# 設定時區和地區
sudo raspi-config
# 選擇: Localisation Options → Timezone

# 連接 WiFi（iPhone 熱點）
sudo raspi-config
# 選擇: System Options → Wireless LAN
```

## 2. 安裝依賴套件

```bash
# 安裝 FFmpeg 和音訊工具
sudo apt-get install -y ffmpeg alsa-utils

# 安裝 Icecast（用於 Icecast 串流）
sudo apt-get install -y icecast2

# 安裝 Git（選用，用於克隆此專案）
sudo apt-get install -y git

# 下載 MediaMTX（用於 RTSP 串流）
cd ~
wget https://github.com/bluenviron/mediamtx/releases/latest/download/mediamtx_linux_arm64v8.tar.gz
tar -xzf mediamtx_linux_arm64v8.tar.gz
chmod +x mediamtx

# 如果是 32-bit 系統，使用以下指令：
# wget https://github.com/bluenviron/mediamtx/releases/latest/download/mediamtx_linux_armv7.tar.gz
```

## 3. 音訊裝置設定

### 連接 USB 麥克風
```bash
# 檢查 USB 麥克風是否被識別
lsusb

# 列出音訊裝置
arecord -l

# 範例輸出：
# card 1: Device [USB Audio Device], device 0: USB Audio [USB Audio]
# 代表裝置名稱為 hw:1,0
```

### 測試錄音
```bash
# 錄製 5 秒測試音訊
arecord -D hw:1,0 -f cd -d 5 test.wav

# 播放測試（如果有喇叭）
aplay test.wav
```

### 調整音量
```bash
# 開啟 ALSA 混音器
alsamixer

# 按 F4 切換到錄音裝置
# 使用方向鍵調整音量
# 按 ESC 離開
```

## 4. 下載專案腳本

```bash
# 方法 1: 使用 Git
cd ~
git clone https://github.com/cychiang-ntpu/audio-streaming-from-laptop-to-iphone.git
cd audio-streaming-from-laptop-to-iphone
git checkout raspberry-pi

# 方法 2: 手動下載
# 將所有 .sh 腳本和 mediamtx.yml 複製到 Pi
```

## 5. 設定 Icecast（選用）

```bash
# 編輯 Icecast 設定
sudo nano /etc/icecast2/icecast.xml

# 修改以下內容：
# <source-password>hackme</source-password>
# <hostname>0.0.0.0</hostname>

# 啟動 Icecast
sudo systemctl start icecast2
sudo systemctl enable icecast2
```

## 6. 設定防火牆（選用）

```bash
cd ~/audio-streaming-from-laptop-to-iphone
chmod +x set_firewall_rules.sh
./set_firewall_rules.sh
```

## 7. 賦予腳本執行權限

```bash
cd ~/audio-streaming-from-laptop-to-iphone
chmod +x *.sh
```

## 8. 查看 Pi IP 位址

```bash
hostname -I
# 或
ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1
```

## 9. 開始串流

### RTSP（推薦：最低延遲）
```bash
# 終端 1: 啟動 MediaMTX
./mediamtx_start.sh

# 終端 2: 開始推流
./rtsp_ffmpeg_push_autodetect.sh

# iPhone 播放: rtsp://<Pi_IP>:8554/mic
```

### Icecast（最簡單）
```bash
./icecast_ffmpeg_push_autodetect.sh

# iPhone 播放: http://<Pi_IP>:8000/stream.mp3
```

### HTTP-WAV（無損音質）
```bash
./http_ffmpeg_push_pcm_autodetect.sh

# iPhone 播放: http://<Pi_IP>:8080/
```

## 10. 開機自動啟動（選用）

```bash
# 建立 systemd 服務
sudo nano /etc/systemd/system/audio-stream.service

# 貼上以下內容：
[Unit]
Description=Audio Streaming Service
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/audio-streaming-from-laptop-to-iphone
ExecStart=/bin/bash /home/pi/audio-streaming-from-laptop-to-iphone/rtsp_ffmpeg_push_autodetect.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target

# 啟用服務
sudo systemctl daemon-reload
sudo systemctl enable audio-stream
sudo systemctl start audio-stream
```

## 效能優化建議

### Pi Zero 2W 特定優化
```bash
# 1. 停用不必要的服務
sudo systemctl disable bluetooth
sudo systemctl disable triggerhappy

# 2. 減少 GPU 記憶體（如不需桌面環境）
sudo raspi-config
# Advanced Options → Memory Split → 設為 16

# 3. 降低音訊品質以節省 CPU
# 編輯對應腳本，修改：
-ar 8000 -b:a 16k  # 最低品質，最省資源
```

## 疑難排解

### 問題 1: 找不到音訊裝置
```bash
# 重新載入 ALSA
sudo alsa force-reload

# 檢查 USB 供電是否足夠（建議使用 2.5A 電源）
```

### 問題 2: MediaMTX 無法啟動
```bash
# 檢查埠是否被佔用
sudo lsof -i :8554

# 如果有佔用，停止該程序
sudo kill -9 <PID>
```

### 問題 3: 網路連線不穩定
```bash
# 檢查 WiFi 訊號強度
iwconfig wlan0

# 固定 IP（防止 DHCP 變動）
sudo nano /etc/dhcpcd.conf
# 加入：
# interface wlan0
# static ip_address=172.20.10.100/24
```

### 問題 4: 音訊延遲高
```bash
# 1. 使用 RTSP 協定
# 2. 降低取樣率（-ar 8000）
# 3. 確保 iPhone VLC 設定 Network caching = 0-50ms
# 4. 減少 buffer size（腳本中已優化）
```

## 完成！

現在您的 Raspberry Pi Zero 2W 已經設定完成，可以作為無線音訊串流裝置使用了。
