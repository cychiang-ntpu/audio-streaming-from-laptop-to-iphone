
# Raspberry Pi Zero 2W → iPhone 熱點：音訊推流完整範例（Icecast / RTSP / HTTP-WAV）

## 專案簡介

本專案提供完整的 Shell 腳本工具組，讓你能夠透過 iPhone 個人熱點將 Raspberry Pi 的麥克風音訊即時串流到 iPhone 上播放。適用於以下場景：

- **無線麥克風替代方案**：將 Raspberry Pi 變成無線麥克風，透過 iPhone 擴音
- **遠端監聽**：在同一區域網路內監聽房間聲音
- **音訊轉播**：將 Pi 音訊串流到行動裝置
- **低延遲通話測試**：測試不同串流協定的延遲表現
- **IoT 音訊應用**：輕量級音訊串流解決方案

**主要特色：**
- 🎯 **三種串流方案**：Icecast（簡單）、RTSP（低延遲）、HTTP-WAV（無損）
- 🔧 **開箱即用**：Shell 腳本自動化設定，無需複雜配置
- 🎤 **自動偵測麥克風**：智慧識別 ALSA 音訊裝置
- ⚡ **極低延遲優化**：RTSP 方案可達 30-100ms 延遲
- 📱 **iPhone 熱點最佳化**：專為行動熱點環境設計
- 💡 **低功耗設計**：適合 Raspberry Pi Zero 2W 長時間運作

---

## 串流方案選擇

提供三條路線：
- **A. Icecast（最簡單）**：`http://<Pi_IP>:8000/stream.mp3`（iOS 用 VLC / Broadcasts）。
- **B. RTSP（最低延遲）**：`rtsp://<Pi_IP>:8554/mic`（iOS 用 VLC）。
- **C. HTTP-WAV（無損音質）**：`http://<Pi_IP>:8080/`（iOS 用 VLC，雙聲道 PCM）。

### 協定背景知識

**Icecast (HTTP + MP3)**
- 基於 HTTP 協定的串流伺服器，類似網路電台
- 使用 MP3 編碼壓縮音訊，相容性最高
- 單向推送，適合多人收聽
- 延遲較高（500-1000ms），因為需要較大緩衝區確保連續播放

**RTSP (Real-Time Streaming Protocol)**
- 專為即時音視訊設計的串流協定
- 支援雙向通訊，可動態調整串流參數
- 使用 RTP/RTCP 傳輸實際資料，延遲極低
- 需要專用伺服器（MediaMTX），但延遲可達 30-100ms

**HTTP-WAV (HTTP + PCM)**
- 使用 HTTP 協定直接傳輸未壓縮的 WAV 音訊
- FFmpeg 內建 HTTP 伺服器模式（`-listen 1`）
- 無損音質但頻寬需求高（48kHz 雙聲道 ≈ 1.5 Mbps）
- 延遲介於 Icecast 和 RTSP 之間（200-500ms）

**選擇建議：**
- 🎯 需要最低延遲 → **RTSP**
- 🎵 需要最佳音質 → **HTTP-WAV**
- 🔧 需要最簡單設定 → **Icecast**

## 0) 前置準備

### 硬體需求
- **Raspberry Pi Zero 2W**（建議）或其他 Pi 型號
- **USB 麥克風**或 USB 音效卡（Pi Zero 2W 無內建麥克風）
- **MicroSD 卡**（建議 16GB 以上，Raspberry Pi OS Lite）
- **電源供應**（5V 2.5A 以上）

### 軟體安裝
1. **連接 iPhone 熱點**：
   ```bash
   # 編輯 WiFi 設定
   sudo raspi-config
   # 或直接編輯 wpa_supplicant.conf
   ```
   建議開啟 iPhone「最大相容性」模式。

2. **查看 Pi IP 位址**：
   ```bash
   hostname -I
   # 或
   ip addr show wlan0
   ```
   通常是 172.20.10.x

3. **安裝必要套件**：
   ```bash
   # 更新系統
   sudo apt-get update
   sudo apt-get upgrade -y
   
   # 安裝 FFmpeg（音訊處理核心）
   sudo apt-get install -y ffmpeg alsa-utils
   
   # 安裝 Icecast（Icecast 路線）
   sudo apt-get install -y icecast2
   
   # 下載 MediaMTX（RTSP 路線）
   wget https://github.com/bluenviron/mediamtx/releases/latest/download/mediamtx_linux_arm64v8.tar.gz
   tar -xzf mediamtx_linux_arm64v8.tar.gz
   chmod +x mediamtx
   ```

4. **設定防火牆**（選用）：
   ```bash
   chmod +x set_firewall_rules.sh
   ./set_firewall_rules.sh
   ```

5. **查看音訊裝置**：
   ```bash
   arecord -l  # 列出所有錄音裝置
   # 記下 card 編號，如 card 1 → 使用 hw:1,0
   ```

## A. Icecast 路線（MP3 壓縮）

### 設定 Icecast 伺服器
編輯 Icecast 設定檔：
```bash
sudo nano /etc/icecast2/icecast.xml
```
找到並修改以下內容：
```xml
<source-password>hackme</source-password>  <!-- 與腳本中的密碼一致 -->
<hostname>0.0.0.0</hostname>
```

啟動 Icecast：
```bash
sudo systemctl start icecast2
sudo systemctl enable icecast2  # 開機自動啟動
```

### 推流到 Icecast
```bash
# 賦予執行權限
chmod +x icecast_ffmpeg_push.sh
chmod +x icecast_ffmpeg_push_autodetect.sh

# 手動指定麥克風（需編輯腳本中的 MIC_NAME）
./icecast_ffmpeg_push.sh

# 自動偵測第一個麥克風
./icecast_ffmpeg_push_autodetect.sh
```

**iPhone 播放**：`http://<Pi_IP>:8000/stream.mp3`

**特點：** 簡單、相容性高、延遲約 500-1000ms。

## B. RTSP 路線（最低延遲）

### 啟動 RTSP 伺服器
```bash
chmod +x mediamtx_start.sh
./mediamtx_start.sh
```

### 推流
```bash
# 賦予執行權限
chmod +x rtsp_ffmpeg_push.sh
chmod +x rtsp_ffmpeg_push_autodetect.sh

# 手動指定（需編輯腳本中的 MIC_NAME）
./rtsp_ffmpeg_push.sh

# 自動偵測（推薦）
./rtsp_ffmpeg_push_autodetect.sh
```

**iPhone 播放**：`rtsp://<Pi_IP>:8554/mic`

**特點：** 
- 延遲最低（30-100ms，需調整 VLC 設定）
- 使用 AAC 編碼（24kbps @ 8kHz 或 32kbps @ 16kHz）
- **VLC 必須設定：** 工具 → 偏好設定 → 顯示全部 → 輸入/編解碼器 → Network caching 改為 **0-50ms**

## C. HTTP-WAV 路線（無損音質）

```bash
# 賦予執行權限
chmod +x http_ffmpeg_push_pcm.sh
chmod +x http_ffmpeg_push_pcm_autodetect.sh

# 手動指定（需編輯腳本中的 MIC_NAME）
./http_ffmpeg_push_pcm.sh

# 自動偵測
./http_ffmpeg_push_pcm_autodetect.sh
```

**iPhone 播放**：`http://<Pi_IP>:8080/`

**特點：**
- 無損 PCM 音訊（48kHz 雙聲道）
- 不需要額外伺服器（FFmpeg 內建 HTTP 伺服器）
- 延遲約 200-500ms
- 頻寬需求高（約 1.5 Mbps）

## 延遲對比

| 方案 | 延遲 | 音質 | 頻寬 | 適用場景 |
|------|------|------|------|----------|
| HTTP-WAV | 200-500ms | 無損 | 1.5 Mbps | 音質優先、區域網路 |
| RTSP | 30-100ms | 良好 | 24-64 kbps | 延遲敏感、即時監聽 |
| Icecast | 500-1000ms | 良好 | 128 kbps | 簡單設定、背景播放 |

## 常見問題

### 音訊裝置相關
- **找不到麥克風**：執行 `arecord -l` 查看裝置列表，確認 card 編號後編輯腳本。
  ```bash
  # 範例輸出
  card 1: Device [USB Audio Device], device 0: USB Audio [USB Audio]
  # 則使用 hw:1,0
  ```
- **無聲音輸入**：檢查麥克風是否被靜音：
  ```bash
  alsamixer  # 按 F4 切換到錄音裝置，調整音量
  ```
- **音量太小**：在腳本中的 ffmpeg 命令加入音量濾鏡（見「進階調整」）。

### 網路連線相關
- **播不出聲音**：
  1. 確認 Pi 與 iPhone 在同一熱點
  2. 檢查 IP 位址：`hostname -I`
  3. 測試埠是否開放：`sudo netstat -tlnp | grep -E '8000|8080|8554'`
  4. 檢查防火牆：`sudo ufw status`

- **延遲太高（RTSP）**：
  1. ⭐ VLC 設定 Network caching 改為 0-50ms（最重要！）
  2. 確認使用 `rtsp_ffmpeg_push_autodetect.sh`（已優化）
  3. 降低取樣率（編輯腳本改 `-ar 8000`）
  4. 檢查 WiFi 訊號強度

- **HTTP-WAV 斷斷續續**：頻寬不足，改用 RTSP 或 Icecast。

### MediaMTX 相關
- **RTSP 顯示「400 Bad Request」**：MediaMTX 不支援 PCM，必須使用 AAC 編碼（使用 `rtsp_ffmpeg_push_autodetect.sh`）。
- **MediaMTX 啟動失敗**：確認 8554 埠未被佔用：`sudo lsof -i :8554`

### 系統資源相關
- **Pi Zero 2W 效能不足**：
  1. 降低取樣率（`-ar 8000` 或 `-ar 16000`）
  2. 使用單聲道（`-ac 1`）
  3. 降低位元率（AAC 用 `-b:a 16k`）
  4. 關閉不必要的服務：`sudo systemctl disable <service>`

## 腳本說明

| 檔案 | 協定 | 編碼 | 麥克風設定 |
|------|------|------|------------|
| `icecast_ffmpeg_push.sh` | Icecast | MP3 | 手動 |
| `icecast_ffmpeg_push_autodetect.sh` | Icecast | MP3 | 自動偵測 |
| `rtsp_ffmpeg_push.sh` | RTSP | PCM | 手動 |
| `rtsp_ffmpeg_push_autodetect.sh` | RTSP | AAC | 自動偵測（推薦）|
| `rtsp_ffmpeg_push_pcm.sh` | RTSP | AAC | 手動 |
| `rtsp_ffmpeg_push_pcm_autodetect.sh` | RTSP | PCM | 自動偵測 |
| `http_ffmpeg_push_pcm.sh` | HTTP | PCM/WAV | 手動 |
| `http_ffmpeg_push_pcm_autodetect.sh` | HTTP | PCM/WAV | 自動偵測 |
| `mediamtx_start.sh` | - | - | 啟動 RTSP 伺服器 |
| `set_firewall_rules.sh` | - | - | 防火牆設定 |

## 進階調整

### 降低延遲（RTSP）
編輯對應的 `.sh` 腳本：
```bash
-ar 8000    # 8kHz 電話品質（最低延遲）
-ar 16000   # 16kHz 可接受品質
-ar 48000   # 48kHz 高品質（較高延遲）
```

### 調整音質（HTTP-WAV）
```bash
-ac 1       # 單聲道（省一半頻寬）
-ac 2       # 雙聲道（立體聲）
-ar 44100   # CD 品質
-ar 48000   # 高品質
```

### 調整音量
在 ffmpeg 命令中的 `-i "$MIC_NAME"` 之後加入：
```bash
-filter:a "volume=+6dB"  # 增加 6dB
-filter:a "volume=0.5"   # 減半音量
-filter:a "volume=2.0"   # 加倍音量
```

### 開機自動啟動（systemd 服務）

建立服務檔案（以 RTSP 為例）：
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
WorkingDirectory=/home/pi/audio-streaming
ExecStart=/bin/bash /home/pi/audio-streaming/rtsp_ffmpeg_push_autodetect.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

啟用服務：
```bash
sudo systemctl daemon-reload
sudo systemctl enable audio-stream
sudo systemctl start audio-stream
sudo systemctl status audio-stream  # 檢查狀態
```

### 查看即時日誌
```bash
# MediaMTX 日誌
./mediamtx mediamtx.yml

# FFmpeg 推流（加上 -loglevel debug）
ffmpeg -loglevel debug -f alsa -i hw:1,0 ...

# 系統日誌
journalctl -u audio-stream -f
```
