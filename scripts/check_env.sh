#!/usr/bin/env bash
set -euo pipefail
echo "== config.txt =="
ls -l /boot/config.txt /boot/firmware/config.txt 2>/dev/null || true
echo
echo "== cards =="
cat /proc/asound/cards 2>/dev/null || true
echo
echo "== arecord -l =="
arecord -l || true
