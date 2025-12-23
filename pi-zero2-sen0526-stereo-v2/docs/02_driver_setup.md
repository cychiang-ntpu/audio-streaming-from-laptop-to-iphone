# 02 驅動：googlevoicehat-soundcard（最常見）

## 1) 編輯 config.txt（Bookworm：/boot/firmware/config.txt）
加入：
```ini
dtparam=audio=off
dtparam=i2s=on
dtoverlay=googlevoicehat-soundcard
```

## 2) 重開機
```bash
sudo reboot
```

## 3) 檢查是否出現新音效卡
```bash
cat /proc/asound/cards
arecord -l
```

## 4) 錄音測試（常見固定 48k）
```bash
arecord -D hw:1,0 -c 2 -r 48000 -f S32_LE -d 5 test_stereo.wav
```
