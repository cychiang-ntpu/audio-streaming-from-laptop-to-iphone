# 01 Raspberry Pi OS（Headless）安裝與基本設定

## 寫入 OS
用 Raspberry Pi Imager 選 Raspberry Pi OS Lite，並在設定中：
- Enable SSH
- 設定 Wi‑Fi（Zero 2 W）
- 設定 locale/timezone

## 更新與工具
```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y alsa-utils sox git
```

## config.txt 在哪裡？
```bash
ls -l /boot/config.txt /boot/firmware/config.txt 2>/dev/null
```
