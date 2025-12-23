# Raspberry Pi Zero 2 + 2×SEN0526 (MSM261) I2S MEMS Mic：立體聲接線與錄音（超詳細）

本教學以 **Raspberry Pi Zero 2 W** 搭配 **兩顆 DFRobot SEN0526（Fermion I2S MEMS Mic）** 為例，
在同一條 I2S 匯流排上取得 **雙聲道（L/R）** 音訊，並用 ALSA 直接錄成 WAV。

---

## 0. 你會用到什麼

### 硬體
- Raspberry Pi Zero 2 W（或 Zero W/3/4，GPIO I2S 腳位一致）
- 2× DFRobot SEN0526
- 麵包板＋杜邦線（建議最後改用焊線/排線）
- **100 kΩ 電阻 ×1**（建議：DO 匯流排下拉，避免 tri-state 浮動）

### 軟體
- Raspberry Pi OS Lite（Bookworm 或 Bullseye 皆可）
- 套件：`alsa-utils`、`sox`

---

## 1. I2S 觀念（兩顆麥克風共用一條 DO 的理由）
- 兩顆麥克風共用 **同一組** `SCK(BCLK)` 與 `WS(LRCLK)`。
- 兩顆麥克風的 `DO(SD)` **可以併在一起** 接到 Raspberry Pi 的 `PCM_DIN(GPIO20)`：
  麥克風在「不是自己那個聲道」時會讓 `DO` tri-state。
- `SEL` 決定它輸出在 Left 或 Right 時槽。

---

## 2. 接線（Pi Zero 2 W ↔ SEN0526）

### 2.1 Pi 的 I2S（PCM）腳位（BCM 編號）
- **GPIO18**：PCM_CLK → `SCK`
- **GPIO19**：PCM_FS  → `WS`
- **GPIO20**：PCM_DIN → `DO`（兩顆 DO 併線）
- 3V3 → `VCC`
- GND → `GND`

> 注意：麥克風輸入到 Pi，所以用 `PCM_DIN(GPIO20)`，不是 `PCM_DOUT(GPIO21)`。

### 2.2 SEL（兩顆麥克風分 Left/Right）
- Mic-L：`SEL → GND`（Left）
- Mic-R：`SEL → 3V3`（Right）

### 2.3 DO 下拉（建議）
- DO 匯流排（兩顆 DO 併線後）→ 用 **100 kΩ** 下拉到 GND

---

## 3. OS 與驅動（建議用 googlevoicehat-soundcard）
> 詳細步驟請看 `docs/02_driver_setup.md`

---

## 4. 快速驗證（錄 5 秒立體聲）

```bash
sudo apt update
sudo apt install -y alsa-utils sox
arecord -l
```

查硬體支援參數（把 `hw:1,0` 換成你的卡號）：
```bash
arecord -D hw:1,0 --dump-hw-params -d 1 /dev/null
```

錄音：
```bash
arecord -D hw:1,0 -c 2 -r 48000 -f S32_LE -d 5 test_stereo.wav
```

拆左右聲道：
```bash
sox test_stereo.wav left.wav  remix 1
sox test_stereo.wav right.wav remix 2
```

---

## 5. 常見問題排除
- DO 接錯到 GPIO21（PCM_DOUT）會錄不到
- Bookworm 的 `config.txt` 在 `/boot/firmware/config.txt`
- googlevoicehat 常固定 48k：請用 48000 錄
