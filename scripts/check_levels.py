#!/usr/bin/env python3

import sys, wave, struct, math

def rms_int32(samples):
    if not samples:
        return 0.0
    acc = 0.0
    for x in samples:
        acc += float(x) * float(x)
    return math.sqrt(acc / len(samples))

def main():
    if len(sys.argv) != 2:
        print("Usage: check_levels.py <stereo.wav>", file=sys.stderr)
        sys.exit(2)

    path = sys.argv[1]
    with wave.open(path, "rb") as wf:
        nch = wf.getnchannels()
        sampwidth = wf.getsampwidth()
        fr = wf.getframerate()
        nframes = wf.getnframes()

        if nch != 2:
            print(f"[ERROR] Expected 2 channels, got {nch}", file=sys.stderr)
            sys.exit(1)
        if sampwidth != 4:
            print(f"[WARN] Expected 32-bit PCM (4 bytes/sample), got {sampwidth} bytes/sample. Still trying...", file=sys.stderr)

        # Read up to ~2 seconds for quick check
        max_frames = min(nframes, fr * 2)
        raw = wf.readframes(max_frames)

    # Parse as little-endian signed int32 interleaved L,R
    # If sampwidth != 4, this parsing may be incorrect; user should re-record as S32_LE.
    if sampwidth != 4:
        print("[HINT] Re-record with: arecord ... -f S32_LE", file=sys.stderr)

    n = len(raw) // 4
    ints = struct.unpack("<" + "i"*n, raw[:n*4])

    left = ints[0::2]
    right = ints[1::2]

    l_rms = rms_int32(left)
    r_rms = rms_int32(right)

    # Convert to dBFS (relative to int32 full-scale)
    full_scale = float(2**31 - 1)
    l_db = 20.0 * math.log10(max(l_rms, 1e-12) / full_scale)
    r_db = 20.0 * math.log10(max(r_rms, 1e-12) / full_scale)

    print(f"[INFO] RMS(L): {l_rms:.1f}  ({l_db:.1f} dBFS)")
    print(f"[INFO] RMS(R): {r_rms:.1f}  ({r_db:.1f} dBFS)")

if __name__ == "__main__":
    main()
