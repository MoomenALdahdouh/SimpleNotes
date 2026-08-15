#!/usr/bin/env python3
"""Generate a simple paper-with-lines PNG set and compile AppIcon.icns."""

from __future__ import annotations

import math
import struct
import zlib
from pathlib import Path


def write_png(path: Path, size: int, rgba: bytes) -> None:
    def chunk(tag: bytes, data: bytes) -> bytes:
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    raw = b"".join(b"\x00" + rgba[y * size * 4 : (y + 1) * size * 4] for y in range(size))
    ihdr = struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0)
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
    path.write_bytes(png)


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def mix(c1, c2, t):
    return tuple(int(lerp(a, b, t)) for a, b in zip(c1, c2))


def rounded_rect(px: float, py: float, x: float, y: float, w: float, h: float, r: float) -> float:
    # Signed distance to rounded rectangle centered-style using top-left origin.
    qx = abs(px - (x + w / 2)) - (w / 2 - r)
    qy = abs(py - (y + h / 2)) - (h / 2 - r)
    qx, qy = max(qx, 0.0), max(qy, 0.0)
    outside = math.hypot(qx, qy)
    inside = min(max(abs(px - (x + w / 2)) - (w / 2 - r), abs(py - (y + h / 2)) - (h / 2 - r)), 0.0)
    return outside + inside - r


def generate(size: int) -> bytes:
    pixels = bytearray(size * size * 4)
    # Colors chosen for a calm native macOS note, not a branded look.
    paper = (250, 248, 243, 255)
    paper_shadow = (210, 206, 196, 255)
    line = (176, 196, 214, 255)
    fold = (236, 232, 222, 255)
    margin = (214, 120, 110, 220)
    bg = (0, 0, 0, 0)

    pad = size * 0.14
    x, y = pad, pad
    w = h = size - pad * 2
    radius = size * 0.08
    fold_size = w * 0.22

    for j in range(size):
        for i in range(size):
            px, py = i + 0.5, j + 0.5
            idx = (j * size + i) * 4

            # Drop shadow
            shadow = rounded_rect(px, py - size * 0.018, x, y, w, h, radius)
            dist = rounded_rect(px, py, x, y, w, h, radius)

            color = list(bg)
            if shadow < 1.5:
                alpha = max(0.0, min(1.0, 1.0 - shadow / 1.5)) * 0.18
                color = [int(40 * alpha), int(36 * alpha), int(30 * alpha), int(255 * alpha)]

            if dist < 1.2:
                cover = max(0.0, min(1.0, 0.5 - dist * 0.8 + 0.5))
                # Paper fill with slight vertical warmth
                t = py / size
                fill = mix(paper, paper_shadow, t * 0.12)
                # Folded corner
                fx = (x + w) - px
                fy = py - y
                if fx >= 0 and fy >= 0 and (fx + fy) < fold_size:
                    fill = mix(fold, paper_shadow, 0.25)
                # Ruled lines
                content_top = y + h * 0.28
                content_bottom = y + h * 0.86
                if content_top < py < content_bottom:
                    rel = (py - content_top) / (content_bottom - content_top)
                    line_count = 5
                    for n in range(line_count):
                        ly = content_top + (n + 0.5) * (content_bottom - content_top) / line_count
                        if abs(py - ly) < max(1.0, size * 0.008) and x + w * 0.16 < px < x + w * 0.86:
                            fill = mix(fill, line, 0.55)
                # Left margin
                mx = x + w * 0.14
                if abs(px - mx) < max(1.0, size * 0.007) and y + h * 0.22 < py < y + h * 0.88:
                    fill = mix(fill, margin, 0.7)

                if dist > 0:
                    fill = mix(fill, (170, 166, 156, 255), min(1.0, dist))

                out_a = int(255 * cover)
                color = [fill[0], fill[1], fill[2], out_a]

            pixels[idx : idx + 4] = bytes(color)

    return bytes(pixels)


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    iconset = root / "build" / "icon.iconset"
    iconset.mkdir(parents=True, exist_ok=True)

    specs = {
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

    cache: dict[int, bytes] = {}
    for name, size in specs.items():
        if size not in cache:
            cache[size] = generate(size)
        write_png(iconset / name, size, cache[size])

    dest = root / "SimpleNotes" / "Resources" / "AppIcon.icns"
    dest.parent.mkdir(parents=True, exist_ok=True)
    import subprocess

    subprocess.run(["iconutil", "-c", "icns", str(iconset), "-o", str(dest)], check=True)
    print(f"Wrote {dest}")


if __name__ == "__main__":
    main()
