#!/usr/bin/env python3
"""Build AppIcon.icns from the master 1024×1024 logo using sips + iconutil."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MASTER = ROOT / "SimpleNotes" / "Resources" / "AppIcon-1024.png"
MASKER = ROOT / "scripts" / "apply-mac-icon-mask.swift"
ICONSET = ROOT / "build" / "icon.iconset"
MASKED = ROOT / "build" / "AppIcon-1024-squircle.png"
DEST = ROOT / "SimpleNotes" / "Resources" / "AppIcon.icns"

SIZES = {
    "icon_16x16.png": 16,
    "icon_16x16@2x.png": 32,
    "icon_32x32.png": 32,
    "icon_32x32@2x.png": 64,
    "icon_128x128.png": 128,
    "icon_128x128@2x.png": 256,
    "icon_256x256.png": 256,
    "icon_256x256@2x.png": 512,
    "icon_512x512.png": 512,
    "icon_512x512@2x.png": 1024,
}


def main() -> None:
    if not MASTER.exists():
        sys.exit(f"Missing master icon: {MASTER}")

    MASKED.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(["swift", str(MASKER), str(MASTER), str(MASKED)], check=True)

    if ICONSET.exists():
        for child in ICONSET.iterdir():
            child.unlink()
    ICONSET.mkdir(parents=True, exist_ok=True)

    for name, size in SIZES.items():
        out = ICONSET / name
        subprocess.run(
            ["sips", "-z", str(size), str(size), str(MASKED), "--out", str(out)],
            check=True,
            capture_output=True,
        )

    DEST.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(["iconutil", "-c", "icns", str(ICONSET), "-o", str(DEST)], check=True)
    print(f"Wrote {DEST}")


if __name__ == "__main__":
    main()
