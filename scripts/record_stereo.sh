#!/usr/bin/env bash
set -euo pipefail

DURATION="${1:-5}"

CARD="${CARD:-0}"
DEV="${DEV:-0}"

OUTDIR="recordings"
mkdir -p "${OUTDIR}"

TS="$(date +%Y%m%d_%H%M%S)"
OUT="${OUTDIR}/stereo_${TS}.wav"

echo "[INFO] Recording ${DURATION}s -> ${OUT}"
echo "[INFO] Using device: plughw:${CARD},${DEV}"

# -f S32_LE: common for I2S MEMS (24-bit data in 32-bit container)
arecord -D "plughw:${CARD},${DEV}" -c 2 -r 48000 -f S32_LE -t wav -d "${DURATION}" "${OUT}"

echo "[OK] Saved: ${OUT}"
