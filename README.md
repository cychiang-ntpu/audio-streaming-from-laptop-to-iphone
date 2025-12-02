
# Raspberry Pi → iPhone 音訊串流專案

將 Raspberry Pi Zero 2W 變成無線麥克風，透過 iPhone 熱點即時串流音訊到手機播放。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi-red.svg)](https://www.raspberrypi.org/)
[![Shell](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)

## 📖 目錄

- [專案簡介](#專案簡介)
- [快速開始](#快速開始)
- [完整安裝指南](#完整安裝指南)
  - [系統準備](#系統準備)
  - [安裝依賴套件](#安裝依賴套件)
  - [音訊裝置設定](#音訊裝置設定)
  - [下載專案腳本](#下載專案腳本)
- [串流方案](#串流方案)
- [使用說明](#使用說明)
- [常見問題與疑難排解](#常見問題與疑難排解)
- [進階設定](#進階設定)
- [效能優化](#效能優化)

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
#### 硬體
- Raspberry Pi Zero 2W（或其他型號）
- USB 麥克風
- iPhone（作為熱點）
- MicroSD 卡（16GB+，已安裝 Raspberry Pi OS）
- Desktop/laptop (用於連線至 Raspberry Pi Zero 2W)
#### 軟體
- Raspberry Pi OS on Raspberry Pi Zero 2W (see details at https://www.raspberrypi.com/software/)
  - 沒有螢幕的 headless 怎麼用使用? https://linnote.com/raspberrypi-headless-setup/ 
- [VNC](https://www.realvnc.com/en/?lai_vid=53KVGk8BPtKy&lai_sr=10-14&lai_sl=l) (用於由 Desktop/laptop 連線至 Raspberry Pi Zero 2W)

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

> 💡 **提示**：若遇到問題，請參考下方[完整安裝指南](#完整安裝指南)和[常見問題](#常見問題與疑難排解)

---

## 📚 完整安裝指南

### 系統準備

#### 安裝 Raspberry Pi OS
```bash
# 建議使用 Raspberry Pi OS Lite（64-bit）以節省資源
# 使用 Raspberry Pi Imager 燒錄到 SD 卡
# 下載：https://www.raspberrypi.com/software/
```

#### 首次啟動設定
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
# 建議開啟 iPhone「最大相容性」模式

# 查看 Pi IP 位址（通常是 172.20.10.x）
hostname -I
# 或更詳細：
ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1
```

### 安裝依賴套件

```bash
# 基礎套件：FFmpeg 和音訊工具
sudo apt-get install -y ffmpeg alsa-utils

# Icecast（用於 Icecast 串流方案）
sudo apt-get install -y icecast2

# Git（用於克隆此專案）
sudo apt-get install -y git

# 下載 MediaMTX（用於 RTSP 串流方案）
cd ~
wget https://github.com/bluenviron/mediamtx/releases/latest/download/mediamtx_linux_arm64v8.tar.gz
tar -xzf mediamtx_linux_arm64v8.tar.gz
chmod +x mediamtx

# 如果是 32-bit 系統（Raspberry Pi OS 32-bit），使用：
# wget https://github.com/bluenviron/mediamtx/releases/latest/download/mediamtx_linux_armv7.tar.gz
# tar -xzf mediamtx_linux_armv7.tar.gz
```

### 音訊裝置設定

#### 連接 USB 麥克風
```bash
# 檢查 USB 麥克風是否被識別
lsusb
# 應該看到類似 "USB Audio Device" 的裝置

# 列出音訊裝置
arecord -l

# 範例輸出：
# **** List of CAPTURE Hardware Devices ****
# card 1: Device [USB Audio Device], device 0: USB Audio [USB Audio]
#   Subdevices: 1/1
# 代表裝置名稱為 hw:1,0（card 1, device 0）
```

#### 測試錄音
```bash
# 錄製 5 秒測試音訊（使用上面查到的裝置編號）
arecord -D hw:1,0 -f cd -d 5 test.wav

# 播放測試（如果有連接喇叭或耳機）
aplay test.wav

# 刪除測試檔案
rm test.wav
```

#### 調整音量
```bash
# 開啟 ALSA 混音器
alsamixer

# 操作說明：
# - 按 F4 切換到錄音裝置（Capture）
# - 使用方向鍵（↑↓）調整音量
# - 按 M 取消/設定靜音（避免 "MM" 標記）
# - 按 ESC 離開
```

### 下載專案腳本

```bash
# 方法 1: 使用 Git（推薦）
cd ~
git clone https://github.com/cychiang-ntpu/audio-streaming-from-laptop-to-iphone.git
cd audio-streaming-from-laptop-to-iphone
git checkout raspberry-pi

# 方法 2: 手動下載（無需 Git）
# 從 GitHub 下載 ZIP：
# https://github.com/cychiang-ntpu/audio-streaming-from-laptop-to-iphone/archive/refs/heads/raspberry-pi.zip
# 解壓縮並進入目錄
```

### 設定 Icecast（選用，僅 Icecast 方案需要）

```bash
# 編輯 Icecast 設定
sudo nano /etc/icecast2/icecast.xml

# 找到並修改以下內容：
# <source-password>hackme</source-password>  <!-- 與腳本中的密碼一致 -->
# <hostname>0.0.0.0</hostname>               <!-- 允許外部連線 -->

# 儲存並離開（Ctrl+X, Y, Enter）

# 啟動 Icecast
sudo systemctl start icecast2
sudo systemctl enable icecast2  # 開機自動啟動
```

### 設定防火牆（選用）

```bash
cd ~/audio-streaming-from-laptop-to-iphone
chmod +x set_firewall_rules.sh
./set_firewall_rules.sh

# 如需啟用防火牆，執行：
# sudo ufw enable
```

### 賦予腳本執行權限

```bash
cd ~/audio-streaming-from-laptop-to-iphone
chmod +x *.sh
```

---

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

---

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

---

## ❓ 常見問題與疑難排解

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

<details>
<summary><strong>網路連線不穩定</strong></summary>

```bash
# 檢查 WiFi 訊號強度
iwconfig wlan0

# 固定 IP 位址（防止 DHCP 變動）
sudo nano /etc/dhcpcd.conf
# 加入以下內容：
# interface wlan0
# static ip_address=172.20.10.100/24
# static routers=172.20.10.1
# static domain_name_servers=8.8.8.8

# 重新啟動網路服務
sudo systemctl restart dhcpcd
```
</details>

<details>
<summary><strong>音訊有雜音或斷斷續續</strong></summary>

**可能原因與解決方案**：

1. **電源供應不足**：
   ```bash
   # 檢查系統訊息
   dmesg | grep -i usb
   # 如果看到 "under-voltage" 警告，請使用 2.5A 以上電源
   ```

2. **CPU 負載過高**：
   ```bash
   # 監控 CPU 使用率
   top
   # 降低音訊品質或停用其他服務
   ```

3. **WiFi 干擾**：
   ```bash
   # 切換到 5GHz 頻段（如 iPhone 支援）
   # 或減少附近其他 WiFi 裝置
   ```
</details>

---

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

防止 DHCP 變動導致連線中斷：
```bash
sudo nano /etc/dhcpcd.conf
```

在檔案末尾加入：
```ini
interface wlan0
static ip_address=172.20.10.100/24
static routers=172.20.10.1
static domain_name_servers=8.8.8.8
```

重新啟動網路：
```bash
sudo systemctl restart dhcpcd
# 或重新開機
sudo reboot
```

---

## 🚀 效能優化

### Pi Zero 2W 特定優化

```bash
# 1. 停用不必要的服務
sudo systemctl disable bluetooth       # 停用藍牙
sudo systemctl disable triggerhappy    # 停用熱鍵服務
sudo systemctl disable hciuart         # 停用藍牙 UART

# 2. 減少 GPU 記憶體（適用於無桌面環境）
sudo raspi-config
# Advanced Options → Memory Split → 設為 16MB

# 3. 降低音訊品質以節省 CPU
# 編輯對應的 .sh 腳本，將參數修改為：
-ar 8000 -b:a 16k -ac 1  # 8kHz 單聲道，最低品質但最省資源

# 4. 超頻（僅適用於 Pi Zero 2W，需注意散熱）
sudo nano /boot/config.txt
# 加入：
# over_voltage=2
# arm_freq=1200
# 注意：超頻可能導致不穩定，請謹慎使用
```

### 監控系統資源

```bash
# CPU 溫度和時脈
vcgencmd measure_temp
vcgencmd measure_clock arm

# CPU 使用率（即時）
htop  # 需先安裝：sudo apt-get install htop

# 記憶體使用情況
free -h

# 網路流量
iftop  # 需先安裝：sudo apt-get install iftop
```

### 自動重啟腳本（防止當機）

```bash
# 建立監控腳本
sudo nano /usr/local/bin/stream_watchdog.sh
```

內容：
```bash
#!/bin/bash
# 檢查串流是否運作，若停止則自動重啟

if ! pgrep -f "ffmpeg.*rtsp" > /dev/null; then
    echo "$(date): Stream stopped, restarting..." >> /var/log/stream_watchdog.log
    cd /home/pi/audio-streaming-from-laptop-to-iphone
    ./rtsp_ffmpeg_push_autodetect.sh &
fi
```

設定權限並加入 crontab：
```bash
sudo chmod +x /usr/local/bin/stream_watchdog.sh
crontab -e
# 加入以下行（每 5 分鐘檢查一次）：
# */5 * * * * /usr/local/bin/stream_watchdog.sh
```

---

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

## 🎓 使用案例

### 案例 1：家庭嬰兒監視器
```bash
# 將 Pi 放在嬰兒房，iPhone 在手邊隨時監聽
./rtsp_ffmpeg_push_autodetect.sh
# 延遲低至 30-100ms，即時掌握寶寶狀況
```

### 案例 2：導覽解說系統
```bash
# 導遊使用 Pi + 麥克風，遊客使用 iPhone 收聽
./icecast_ffmpeg_push_autodetect.sh
# 支援多人同時收聽，適合團體導覽
```

### 案例 3：居家練唱監聽
```bash
# 在練習室使用 Pi 收音，客廳用 iPhone 監聽
./http_ffmpeg_push_pcm_autodetect.sh
# 無損音質，準確評估歌聲表現
```

### 案例 4：遠端會議麥克風
```bash
# Pi 當作高品質麥克風，透過 iPhone 加入會議
./rtsp_ffmpeg_push_autodetect.sh
# 低延遲，適合即時對話
```

---

## 🛠️ 開發與除錯

### 查看詳細日誌

```bash
# FFmpeg 詳細日誌（加入 -loglevel debug）
ffmpeg -loglevel debug -f alsa -i hw:1,0 [其他參數...]

# 或將輸出導向檔案
./rtsp_ffmpeg_push_autodetect.sh 2>&1 | tee stream.log

# 即時查看 systemd 服務日誌
journalctl -u audio-stream -f

# 查看過去的日誌
journalctl -u audio-stream --since "1 hour ago"
```

### 測試網路連線

```bash
# 測試 RTSP 串流是否正常
ffplay rtsp://localhost:8554/mic

# 測試 HTTP 串流
curl -I http://localhost:8080/

# 測試 Icecast
curl -I http://localhost:8000/stream.mp3

# 檢查埠是否開放
sudo netstat -tlnp | grep -E '8000|8080|8554'
```

### 手動編輯麥克風設定

如果自動偵測失敗，可手動編輯腳本：
```bash
nano rtsp_ffmpeg_push.sh

# 修改這一行：
MIC_NAME="hw:1,0"  # 改為你的裝置編號
```

---

## 🤝 貢獻

歡迎提交 Issue 或 Pull Request！

### 如何貢獻
1. Fork 此專案
2. 建立你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的修改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟 Pull Request

### 回報問題
請在 [Issues](https://github.com/cychiang-ntpu/audio-streaming-from-laptop-to-iphone/issues) 頁面描述：
- 你的硬體配置（Pi 型號、USB 麥克風型號）
- 使用的串流方案
- 完整的錯誤訊息
- 已嘗試的解決方法

---

## 📄 授權

本專案採用 [MIT License](LICENSE)。

---

## 🔗 相關連結

- [MediaMTX 官方文件](https://github.com/bluenviron/mediamtx)
- [FFmpeg 官方文件](https://ffmpeg.org/documentation.html)
- [Raspberry Pi 官網](https://www.raspberrypi.org/)
- [Icecast 官網](https://icecast.org/)
- [ALSA 專案](https://www.alsa-project.org/)

---

## 📊 專案統計

![GitHub stars](https://img.shields.io/github/stars/cychiang-ntpu/audio-streaming-from-laptop-to-iphone)
![GitHub forks](https://img.shields.io/github/forks/cychiang-ntpu/audio-streaming-from-laptop-to-iphone)
![GitHub issues](https://img.shields.io/github/issues/cychiang-ntpu/audio-streaming-from-laptop-to-iphone)
![GitHub last commit](https://img.shields.io/github/last-commit/cychiang-ntpu/audio-streaming-from-laptop-to-iphone)

---

**Made with ❤️ for Raspberry Pi & iPhone**

*如有任何問題或建議，歡迎開啟 Issue 討論！*
