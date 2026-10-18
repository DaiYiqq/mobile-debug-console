#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""生成 icons/ 下 PWA 图标（纯几何绘制，无字体依赖）。需要 Pillow。"""
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
ICONS = ROOT / "icons"

BG = (11, 16, 22, 255)          # #0b1016
FG = (34, 197, 94, 255)         # #22c55e
FG_DIM = (34, 197, 94, 120)
DOTS = [(255, 95, 86, 255), (255, 189, 46, 255), (40, 205, 65, 255)]


def draw(size: int, maskable: bool) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if maskable:
        d.rounded_rectangle([0, 0, size - 1, size - 1], radius=int(size * 0.12), fill=BG)
        pad = size * 0.22
    else:
        d.rounded_rectangle([0, 0, size - 1, size - 1], radius=int(size * 0.22), fill=BG)
        pad = size * 0.16
    box = [pad, pad, size - pad, size - pad]
    d.rounded_rectangle(box, radius=int(size * 0.06), outline=FG_DIM, width=max(2, size // 96))
    r = max(2, size // 160)
    y = pad + size * 0.06
    for i, c in enumerate(DOTS):
        x = pad + size * 0.07 + i * size * 0.09
        d.ellipse([x - r, y - r, x + r, y + r], fill=c)
    cx = pad + size * 0.10
    cy = pad + size * 0.36
    w = size * 0.10
    pts = [(cx, cy - w * 0.6), (cx + w * 0.8, cy), (cx, cy + w * 0.6)]
    d.line(pts, fill=FG, width=max(3, size // 48), joint="curve")
    ux = cx + w * 1.25
    d.line([(ux, cy + w * 0.55), (ux + w * 1.6, cy + w * 0.55)], fill=FG, width=max(3, size // 48))
    return img


def main() -> None:
    ICONS.mkdir(exist_ok=True)
    draw(192, False).save(ICONS / "icon-192.png")
    draw(512, False).save(ICONS / "icon-512.png")
    draw(512, True).save(ICONS / "icon-maskable-512.png")
    print("icons generated")


if __name__ == "__main__":
    main()
