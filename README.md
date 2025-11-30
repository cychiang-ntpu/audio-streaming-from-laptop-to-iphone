
# Raspberry Pi → iPhone 音訊串流專案

將 Raspberry Pi Zero 2W 變成無線麥克風，透過 iPhone 熱點即時串流音訊到手機播放。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi-red.svg)](https://www.raspberrypi.org/)
[![Shell](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)

## 📖 目錄

- [專案簡介](#專案簡介)
- [快速開始](#快速開始)
- [串流方案](#串流方案)
- [詳細安裝](#詳細安裝)
- [使用說明](#使用說明)
- [常見問題](#常見問題)
- [進階設定](#進階設定)

## 🎯 專案簡介

本專案提供完整的 Shell 腳本工具組，讓 Raspberry Pi 能透過 iPhone 個人熱點將麥克風音訊即時串流到 iPhone 播放。

### 適用場景
- 🎤 **無線麥克風**：Pi + USB 麥克風 → iPhone 擴音
- 👂 **遠端監聽**：區域網路內即時音訊監控
- 📡 **音訊轉播**：將 Pi 音訊串流到行動裝置
- ⚡ **低延遲測試**：測試不同協定的延遲表現
- 🤖 **IoT 應用**：輕量級音訊串流解決方案

### 主要特色
- ⚡ **極低延遲**：RTSP 方案可達 30-100ms
- 🎵 **三種協定**：Icecast (簡單) / RTSP (低延遲) / HTTP-WAV (無損)
- 🔌 **自動偵測**：智慧識別 ALSA 音訊裝置
- 💡 **低功耗**：針對 Pi Zero 2W 優化
- 📱 **行動優先**：專為 iPhone 熱點環境設計
- 🔧 **開箱即用**：Shell 腳本無需複雜配置

## ⚡ 快速開始

### 前置需求
- Raspberry Pi Zero 2W（或其他型號）
- USB 麥克風
- iPhone（作為熱點）
- MicroSD 卡（16GB+，已安裝 Raspberry Pi OS）

### 5 分鐘快速部署

```bash
# 1. 更新系統並安裝必要套件
sudo apt-get update && sudo apt-get install -y ffmpeg alsa-utils git

# 2. 下載專案
git clone https://github.com/cychiang-ntpu/audio-streaming-from-laptop-to-iphone.git
cd audio-streaming-from-laptop-to-iphone
git checkout raspberry-pi

# 3. 賦予執行權限
chmod +x *.sh

# 4. 查看 Pi IP 位址
hostname -I

# 5. 開始串流（RTSP 最低延遲）
./rtsp_ffmpeg_push_autodetect.sh

# 6. iPhone 開啟 VLC 播放
# 網路 → 輸入: rtsp://<Pi_IP>:8554/mic
```

> 💡 **提示**：完整安裝步驟請參考 [RASPBERRY_PI_SETUP.md](RASPBERRY_PI_SETUP.md)

## 🎛️ 串流方案

### 方案對比

| 方案 | 延遲 | 音質 | 頻寬 | 複雜度 | 推薦場景 |
|------|------|------|------|--------|----------|
| **RTSP** | 30-100ms | 良好 | 24-64 kbps | 中 | 即時監聽、對講 |
| **HTTP-WAV** | 200-500ms | 無損 | 1.5 Mbps | 低 | 音質優先、區網 |
| **Icecast** | 500-1000ms | 良好 | 128 kbps | 低 | 背景播放、多人 |

### 協定說明

#### 🔴 RTSP（推薦：最低延遲）
```bash
# 啟動 MediaMTX 伺服器
./mediamtx_start.sh

# 開始推流（自動偵測麥克風）
./rtsp_ffmpeg_push_autodetect.sh

# iPhone 播放網址
rtsp://<Pi_IP>:8554/mic
```

**特點**：
- ✅ 延遲 30-100ms（需調整 VLC Network caching = 0-50ms）
- ✅ AAC 編碼，頻寬需求低（24kbps @ 8kHz）
- ✅ 支援即時雙向通訊
- ❌ 需要額外安裝 MediaMTX

#### 🟢 HTTP-WAV（無損音質）
```bash
# 一鍵啟動（內建 HTTP 伺服器）
./http_ffmpeg_push_pcm_autodetect.sh

# iPhone 播放網址
http://<Pi_IP>:8080/
```

**特點**：
- ✅ 無損 PCM 音訊（48kHz 雙聲道）
- ✅ 不需額外伺服器
- ✅ 延遲 200-500ms
- ❌ 頻寬需求高（約 1.5 Mbps）

#### 🟡 Icecast（最簡單）
```bash
# 安裝 Icecast
sudo apt-get install -y icecast2

# 設定 Icecast（編輯 /etc/icecast2/icecast.xml）
sudo systemctl start icecast2

# 開始推流
./icecast_ffmpeg_push_autodetect.sh

# iPhone 播放網址
http://<Pi_IP>:8000/stream.mp3
```

**特點**：
- ✅ 設定簡單，相容性最高
- ✅ MP3 編碼，適合多人收聽
- ✅ 類似網路電台
- ❌ 延遲較高（500-1000ms）

## 📦 詳細安裝

### 1. 系統準備

```bash
# 連接 iPhone 熱點
sudo raspi-config
# System Options → Wireless LAN

# 查看 IP（通常是 172.20.10.x）
hostname -I

# 更新系統
sudo apt-get update && sudo apt-get upgrade -y
```

### 2. 安裝依賴

```bash
# 基礎套件
sudo apt-get install -y ffmpeg alsa-utils

# Icecast（選用）
sudo apt-get install -y icecast2

# MediaMTX（RTSP 必需）
wget https://github.com/bluenviron/mediamtx/releases/latest/download/mediamtx_linux_arm64v8.tar.gz
tar -xzf mediamtx_linux_arm64v8.tar.gz
chmod +x mediamtx
```

### 3. 音訊裝置設定

```bash
# 查看麥克風裝置
arecord -l

# 範例輸出：
# card 1: Device [USB Audio Device], device 0: USB Audio
# → 使用 hw:1,0

# 測試錄音（5 秒）
arecord -D hw:1,0 -f cd -d 5 test.wav

# 調整音量
alsamixer  # 按 F4 切換到錄音裝置
```

### 4. 防火牆設定（選用）

```bash
chmod +x set_firewall_rules.sh
./set_firewall_rules.sh
```

## 📱 使用說明

### 腳本總覽

| 腳本 | 協定 | 編碼 | 偵測 | 說明 |
|------|------|------|------|------|
| `rtsp_ffmpeg_push_autodetect.sh` | RTSP | AAC | ✅ | **推薦**：最低延遲 |
| `http_ffmpeg_push_pcm_autodetect.sh` | HTTP | WAV | ✅ | 無損音質 |
| `icecast_ffmpeg_push_autodetect.sh` | Icecast | MP3 | ✅ | 最簡單 |
| `rtsp_ffmpeg_push.sh` | RTSP | AAC | ❌ | 手動指定麥克風 |
| `http_ffmpeg_push_pcm.sh` | HTTP | WAV | ❌ | 手動指定 |
| `icecast_ffmpeg_push.sh` | Icecast | MP3 | ❌ | 手動指定 |
| `mediamtx_start.sh` | - | - | - | 啟動 RTSP 伺服器 |
| `set_firewall_rules.sh` | - | - | - | 設定防火牆 |

### iPhone VLC 播放器設定

> ⚠️ **重要**：使用 RTSP 時必須調整此設定以達到最低延遲！

1. 開啟 VLC → **工具** → **偏好設定**
2. 左下角選擇「**顯示全部**」
3. 展開「**輸入 / 編解碼器**」
4. 找到「**Network caching (ms)**」
5. 將值改為 **0** 或 **50**
6. 重啟 VLC

## ❓ 常見問題

<details>
<summary><strong>找不到麥克風裝置</strong></summary>

```bash
# 1. 檢查 USB 裝置
lsusb

# 2. 列出音訊裝置
arecord -l

# 3. 重新載入 ALSA
sudo alsa force-reload

# 4. 檢查電源（建議 2.5A 以上）
```
</details>

<details>
<summary><strong>無聲音輸入</strong></summary>

```bash
# 開啟混音器
alsamixer

# 按 F4 切換到錄音裝置
# 用方向鍵調整音量
# 確認沒有 "MM" 靜音標記
```
</details>

<details>
<summary><strong>延遲太高</strong></summary>

**RTSP 延遲優化（按優先順序）：**
1. ⭐ **最重要**：VLC 設定 Network caching = 0-50ms
2. 使用 `rtsp_ffmpeg_push_autodetect.sh`（已優化）
3. 降低取樣率：編輯腳本改 `-ar 8000`
4. 檢查 WiFi 訊號：`iwconfig wlan0`
</details>

<details>
<summary><strong>播不出聲音</strong></summary>

**檢查清單**：
```bash
# 1. 確認 Pi 與 iPhone 在同一熱點
hostname -I

# 2. 測試埠是否開放
sudo netstat -tlnp | grep -E '8000|8080|8554'

# 3. 檢查防火牆
sudo ufw status

# 4. 查看 FFmpeg 錯誤訊息
# 腳本執行時會顯示詳細錯誤
```
</details>

<details>
<summary><strong>MediaMTX 啟動失敗</strong></summary>

```bash
# 檢查埠佔用
sudo lsof -i :8554

# 停止佔用程序
sudo kill -9 <PID>

# 檢查 MediaMTX 版本
./mediamtx --version
```
</details>

<details>
<summary><strong>Pi Zero 2W 效能不足</strong></summary>

**優化建議**：
```bash
# 1. 降低取樣率（編輯腳本）
-ar 8000 -b:a 16k  # 最省 CPU

# 2. 停用不必要服務
sudo systemctl disable bluetooth
sudo systemctl disable triggerhappy

# 3. 減少 GPU 記憶體
sudo raspi-config
# Advanced Options → Memory Split → 16
```
</details>

## ⚙️ 進階設定

### 調整音訊參數

#### 降低延遲（編輯腳本）
```bash
-ar 8000    # 8kHz 電話品質（最低延遲，最省 CPU）
-ar 16000   # 16kHz 可接受品質
-ar 48000   # 48kHz 高品質（延遲較高）
```

#### 調整音質
```bash
-ac 1       # 單聲道（省一半頻寬）
-ac 2       # 雙聲道（立體聲）
-b:a 16k    # 低位元率（省頻寬）
-b:a 128k   # 高位元率（高音質）
```

#### 調整音量
在腳本的 `-i "$MIC_NAME"` 後加入：
```bash
-filter:a "volume=+6dB"   # 增加 6dB
-filter:a "volume=2.0"    # 加倍音量
-filter:a "volume=0.5"    # 減半音量
```

### 開機自動啟動

建立 systemd 服務：
```bash
sudo nano /etc/systemd/system/audio-stream.service
```

內容：
```ini
[Unit]
Description=Audio Streaming to iPhone
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/audio-streaming-from-laptop-to-iphone
ExecStart=/bin/bash rtsp_ffmpeg_push_autodetect.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

啟用：
```bash
sudo systemctl daemon-reload
sudo systemctl enable audio-stream
sudo systemctl start audio-stream
sudo systemctl status audio-stream
```

### 查看日誌

```bash
# FFmpeg 詳細日誌
./rtsp_ffmpeg_push_autodetect.sh 2>&1 | tee stream.log

# systemd 服務日誌
journalctl -u audio-stream -f

# MediaMTX 日誌
./mediamtx mediamtx.yml
```

### 固定 IP 位址

防止 DHCP 變動：
```bash
sudo nano /etc/dhcpcd.conf
```

加入：
```ini
interface wlan0
static ip_address=172.20.10.100/24
static routers=172.20.10.1
static domain_name_servers=8.8.8.8
```

## 📚 技術架構

### 串流流程
```
USB 麥克風 → ALSA → FFmpeg 編碼 → 串流協定 → iPhone VLC
           (hw:x,0)  (AAC/MP3/PCM)  (RTSP/HTTP/Icecast)
```

### 使用的技術
- **FFmpeg**：音訊擷取與編碼
- **ALSA**：Linux 音訊子系統
- **MediaMTX**：RTSP 伺服器
- **Icecast**：HTTP 串流伺服器
- **Bash**：自動化腳本

## 🤝 貢獻

歡迎提交 Issue 或 Pull Request！

## 📄 授權

本專案採用 [MIT License](LICENSE)。

## 🔗 相關連結

- [完整安裝指南](RASPBERRY_PI_SETUP.md)
- [MediaMTX 官網](https://github.com/bluenviron/mediamtx)
- [FFmpeg 文件](https://ffmpeg.org/documentation.html)
- [Raspberry Pi 官網](https://www.raspberrypi.org/)

---

**Made with ❤️ for Raspberry Pi & iPhone**
