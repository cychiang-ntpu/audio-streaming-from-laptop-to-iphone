#!/usr/bin/env bash
set -euo pipefail
DEV="${1:-hw:1,0}"
DUR="${2:-5}"
RATE="${3:-48000}"
OUT="test_stereo_${RATE}Hz_${DUR}s.wav"
arecord -D "${DEV}" -c 2 -r "${RATE}" -f S32_LE -d "${DUR}" "${OUT}"
sox "${OUT}" left.wav  remix 1
sox "${OUT}" right.wav remix 2
echo "Wrote: ${OUT}, left.wav, right.wav"
