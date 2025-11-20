
# Windows → iPhone 熱點：音訊推流完整範例（Icecast / RTSP / HTTP-WAV）

## 專案簡介

本專案提供完整的批次腳本工具組，讓你能夠透過 iPhone 個人熱點將 Windows 電腦的麥克風音訊即時串流到 iPhone 上播放。適用於以下場景：

- **無線麥克風替代方案**：將筆電變成無線麥克風，透過 iPhone 擴音
- **遠端監聽**：在同一區域網路內監聽房間聲音
- **音訊轉播**：將電腦音訊串流到行動裝置
- **低延遲通話測試**：測試不同串流協定的延遲表現

**主要特色：**
- 🎯 **三種串流方案**：Icecast（簡單）、RTSP（低延遲）、HTTP-WAV（無損）
- 🔧 **開箱即用**：批次腳本自動化設定，無需複雜配置
- 🎤 **自動偵測麥克風**：智慧識別系統音訊裝置
- ⚡ **極低延遲優化**：RTSP 方案可達 30-100ms 延遲
- 📱 **iPhone 熱點最佳化**：專為行動熱點環境設計

---

## 串流方案選擇

提供三條路線：
- **A. Icecast（最簡單）**：`http://<Windows_IP>:8000/stream.mp3`（iOS 用 VLC / Broadcasts）。
- **B. RTSP（最低延遲）**：`rtsp://<Windows_IP>:8554/mic`（iOS 用 VLC）。
- **C. HTTP-WAV（無損音質）**：`http://<Windows_IP>:8080/`（iOS 用 VLC，雙聲道 PCM）。

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

## 0) 前置
1. 連上 **iPhone 個人熱點**（建議 iPhone → 個人熱點 → 開啟「最大相容性」）。
2. 查 IP：`ipconfig | findstr /R /C:"IPv4"`（通常是 172.20.10.x）。
3. 防火牆放行：雙擊 `set_firewall_rules.bat`（會開放 8000、8080、8554 埠）。
4. 安裝：
   - FFmpeg https://www.ffmpeg.org/download.html（加入 PATH）。
   - Icecast（Icecast 路線）。
   - MediaMTX https://github.com/bluenviron/mediamtx（RTSP 路線；把 `mediamtx.exe` 放到本資料夾或 PATH）。

## A. Icecast 路線（MP3 壓縮）
- 手動指定麥克風：`icecast_ffmpeg_push.bat`（編輯 `MIC_NAME` 與 `SOURCE_PASS`）。
- 自動偵測麥克風：`icecast_ffmpeg_push_autodetect.bat`（抓第一個「Microphone」端點）。

iPhone 播放：`http://<Windows_IP>:8000/stream.mp3`。

**特點：** 簡單、相容性高、延遲約 500-1000ms。

## B. RTSP 路線（最低延遲）
1) 啟動 RTSP 伺服器：`mediamtx_start.bat`  
2) 推流：
   - 手動：`rtsp_ffmpeg_push.bat`（編輯 `MIC_NAME`）。
   - 自動：`rtsp_ffmpeg_push_autodetect.bat`。

iPhone 播放：`rtsp://<Windows_IP>:8554/mic`。

**特點：** 
- 延遲最低（30-100ms，需調整 VLC 設定）
- 使用 AAC 編碼（24kbps @ 8kHz 或 32kbps @ 16kHz）
- **VLC 必須設定：** 工具 → 偏好設定 → 顯示全部 → 輸入/編解碼器 → Network caching 改為 **0-50ms**

## C. HTTP-WAV 路線（無損音質）
- 手動指定麥克風：`http_ffmpeg_push_pcm.bat`（編輯 `MIC_NAME`）。
- 自動偵測麥克風：`http_ffmpeg_push_pcm_autodetect.bat`。

iPhone 播放：`http://<Windows_IP>:8080/`。

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
- **播不出**：先確認 Windows 與 iPhone 在同一熱點、IP 是否正確、埠已放行。
- **找不到麥克風**：可執行 `ffmpeg -list_devices true -f dshow -i dummy` 查名稱，填入批次檔。
- **音量小**：在命令中加 `-filter:a "volume=+6dB"` 或調整 Windows 錄音裝置增益。
- **延遲太高（RTSP）**：
  1. VLC 設定 Network caching 改為 0-50ms（最重要！）
  2. 確認使用 `rtsp_ffmpeg_push_autodetect.bat`（已優化）
  3. 考慮降低取樣率（編輯腳本改 `-ar 8000`）
- **HTTP-WAV 斷斷續續**：頻寬不足，改用 RTSP 或 Icecast。
- **RTSP 顯示「400 Bad Request」**：MediaMTX 不支援 PCM，必須使用 AAC 編碼。

## 腳本說明

| 檔案 | 協定 | 編碼 | 麥克風設定 |
|------|------|------|------------|
| `icecast_ffmpeg_push.bat` | Icecast | MP3 | 手動 |
| `icecast_ffmpeg_push_autodetect.bat` | Icecast | MP3 | 自動偵測 |
| `rtsp_ffmpeg_push.bat` | RTSP | AAC | 手動 |
| `rtsp_ffmpeg_push_autodetect.bat` | RTSP | AAC | 自動偵測 |
| `rtsp_ffmpeg_push_pcm.bat` | RTSP | AAC | 手動（註：已改用 AAC）|
| `rtsp_ffmpeg_push_pcm_autodetect.bat` | RTSP | AAC | 自動偵測 |
| `http_ffmpeg_push_pcm.bat` | HTTP | PCM/WAV | 手動 |
| `http_ffmpeg_push_pcm_autodetect.bat` | HTTP | PCM/WAV | 自動偵測 |
| `mediamtx_start.bat` | - | - | 啟動 RTSP 伺服器 |
| `set_firewall_rules.bat` | - | - | 防火牆設定 |

## 進階調整

**降低延遲（RTSP）：**
```batch
REM 編輯 rtsp_ffmpeg_push_autodetect.bat
-ar 8000    # 8kHz 電話品質（最低延遲）
-ar 16000   # 16kHz 可接受品質
-ar 48000   # 48kHz 高品質（較高延遲）
```

**調整音質（HTTP-WAV）：**
```batch
REM 編輯 http_ffmpeg_push_pcm.bat
-ac 1       # 單聲道（省一半頻寬）
-ac 2       # 雙聲道（立體聲）
-ar 44100   # CD 品質
-ar 48000   # 高品質
```

**調整音量：**
```batch
REM 在 ffmpeg 命令中加入
-filter:a "volume=+6dB"  # 增加 6dB
-filter:a "volume=0.5"   # 減半音量
```
