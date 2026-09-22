#!/usr/bin/env python3
"""Turn the supplied Finix Systems logo into the full set of site assets.

The source is a wordmark centred on a large white field. Two different crops
are needed:

  * the full wordmark  -> header logo (wide, legible at 32-40px tall)
  * the "F" glyph only -> favicon and PWA icons, because a full wordmark
    squeezed into 32x32 is an unreadable smudge

Everything is emitted with a transparent background so the marks sit correctly
on both the light landing page and the dark dashboard sidebar. A white variant
is produced for dark surfaces.

Usage: python3 scripts/make_brand_assets.py <source.png>
"""
from __future__ import annotations

import pathlib
import sys

from PIL import Image

OUT_PUBLIC = pathlib.Path("public")
OUT_ICONS = OUT_PUBLIC / "icons"


def bbox_of_ink(img: Image.Image, tol: int = 235) -> tuple[int, int, int, int]:
    """Bounding box of non-white pixels."""
    grey = img.convert("L")
    mask = grey.point(lambda p: 255 if p < tol else 0)
    box = mask.getbbox()
    if not box:
        raise SystemExit("source image looks blank")
    return box


def to_transparent(img: Image.Image, tol: int = 235) -> Image.Image:
    """White -> transparent, keeping anti-aliased edges soft."""
    img = img.convert("RGBA")
    px = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if r >= tol and g >= tol and b >= tol:
                px[x, y] = (r, g, b, 0)
            else:
                # Feather: near-white pixels become partly transparent so the
                # glyph edge does not carry a white halo on dark backgrounds.
                lum = (r + g + b) / 3
                if lum > 200:
                    px[x, y] = (r, g, b, int(a * (tol - lum) / (tol - 200)))
    return img


def recolour_white(img: Image.Image) -> Image.Image:
    """Keep alpha, force RGB to white — for dark surfaces."""
    img = img.convert("RGBA")
    px = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a:
                px[x, y] = (255, 255, 255, a)
    return img


def padded_square(mark: Image.Image, size: int, pad_ratio: float,
                  bg: tuple[int, int, int, int] | None = None) -> Image.Image:
    """Centre `mark` on a square canvas with proportional padding."""
    canvas = Image.new("RGBA", (size, size), bg or (0, 0, 0, 0))
    inner = int(size * (1 - 2 * pad_ratio))
    m = mark.copy()
    m.thumbnail((inner, inner), Image.LANCZOS)
    canvas.paste(m, ((size - m.width) // 2, (size - m.height) // 2), m)
    return canvas


def main() -> int:
    src_path = sys.argv[1] if len(sys.argv) > 1 else None
    if not src_path:
        print("usage: make_brand_assets.py <source.png>")
        return 1

    OUT_ICONS.mkdir(parents=True, exist_ok=True)
    src = Image.open(src_path).convert("RGB")

    # 1. Trim the white field down to the wordmark itself.
    box = bbox_of_ink(src)
    word = src.crop(box)
    print(f"source {src.size} -> wordmark crop {word.size} at {box}")

    # 2. The "F" glyph: leading portion of the wordmark. Its right edge is the
    #    gap before the "I", found by scanning for the first fully blank column
    #    after some ink has been seen.
    grey = word.convert("L")
    w, h = word.size
    cols = []
    for x in range(w):
        col_has_ink = any(grey.getpixel((x, y)) < 235 for y in range(h))
        cols.append(col_has_ink)
    seen_ink = False
    cut = w
    for x, has in enumerate(cols):
        if has:
            seen_ink = True
        elif seen_ink:
            # require a real gap, not a 1px antialiasing artefact
            if all(not c for c in cols[x:x + max(4, w // 60)]):
                cut = x
                break
    f_mark = word.crop((0, 0, cut, h))
    # the F glyph is shorter than the full lockup (no SYSTEMS line) — retrim
    f_mark = f_mark.crop(bbox_of_ink(f_mark))
    print(f"F glyph crop {f_mark.size} (cut at x={cut})")

    word_t = to_transparent(word)
    f_t = to_transparent(f_mark)

    # 3. Header logos — full wordmark, dark and white variants.
    word_t.save(OUT_PUBLIC / "logo.png")
    recolour_white(word_t).save(OUT_PUBLIC / "logo-light.png")

    # 4. Favicon: multi-resolution .ico from the F glyph.
    #    Transparent background so it sits on any browser chrome.
    ico_sizes = [16, 32, 48, 64, 128, 256]
    ico_frames = [padded_square(f_t, s, 0.06) for s in ico_sizes]
    ico_frames[0].save(
        OUT_PUBLIC / "favicon.ico",
        format="ICO",
        sizes=[(s, s) for s in ico_sizes],
        append_images=ico_frames[1:],
    )

    # 5. PWA icons. "any" icons keep transparency; the maskable icon needs an
    #    opaque background and a safe zone, or Android crops into the glyph.
    padded_square(f_t, 192, 0.10).save(OUT_ICONS / "icon-192.png")
    padded_square(f_t, 512, 0.10).save(OUT_ICONS / "icon-512.png")
    padded_square(f_t, 512, 0.22, bg=(255, 255, 255, 255)).save(
        OUT_ICONS / "icon-maskable-512.png")
    # Apple does not honour transparency — give it a solid white plate.
    padded_square(f_t, 180, 0.12, bg=(255, 255, 255, 255)).save(
        OUT_ICONS / "apple-touch-icon.png")

    for p in [OUT_PUBLIC / "logo.png", OUT_PUBLIC / "logo-light.png",
              OUT_PUBLIC / "favicon.ico", OUT_ICONS / "icon-192.png",
              OUT_ICONS / "icon-512.png", OUT_ICONS / "icon-maskable-512.png",
              OUT_ICONS / "apple-touch-icon.png"]:
        print(f"  wrote {p}  ({p.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
