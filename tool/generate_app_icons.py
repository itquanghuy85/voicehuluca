"""Generates every app icon for VietVoice Studio from one vector-ish drawing.

Run from the project root:

    python tool/generate_app_icons.py

Outputs
    assets/branding/app_icon_1024.png     master artwork
    assets/branding/play_store_512.png    Google Play listing icon
    android/app/src/main/res/mipmap-*/     legacy + adaptive + monochrome
    ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png

The mark is a microphone: capsule, cradle arc, stem and base. Everything is
drawn on a supersampled canvas and downscaled with LANCZOS, so the curves stay
clean at 48px as well as at 1024px.
"""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
BRANDING = ROOT / "assets" / "branding"
ANDROID_RES = ROOT / "android" / "app" / "src" / "main" / "res"
IOS_APPICON = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"

# From lib/core/design_system/app_colors.dart
PRIMARY = (0x63, 0x66, 0xF1)
SECONDARY = (0x8B, 0x5C, 0xF6)
WHITE = (0xFF, 0xFF, 0xFF)
BLACK = (0x00, 0x00, 0x00)

CANVAS = 1024
SUPERSAMPLE = 3
CORNER_RADIUS = 224

# Mark geometry in its own local space, y pointing down, centred on x = 150.
MARK_W = 300.0
MARK_H = 556.0
CAPSULE = (44.0, 0.0, 256.0, 300.0)  # x0, y0, x1, y1
CAPSULE_RADIUS = 106.0
CRADLE_CENTRE = (150.0, 290.0)
CRADLE_OUTER_R = 162.0
CRADLE_STROKE = 52.0
STEM = (124.0, 400.0, 176.0, 500.0)
BASE = (38.0, 500.0, 262.0, 556.0)
BASE_RADIUS = 28.0


def gradient(size: int, start: tuple, end: tuple) -> Image.Image:
    """Diagonal two-stop gradient, built small then scaled up."""
    small = Image.new("RGB", (64, 64))
    pixels = small.load()
    span = 63
    for y in range(64):
        for x in range(64):
            t = (x + y) / (2 * span)
            pixels[x, y] = tuple(
                round(start[i] + (end[i] - start[i]) * t) for i in range(3)
            )
    return small.resize((size, size), Image.Resampling.BICUBIC)


def draw_mark(size: int, color: tuple) -> Image.Image:
    """The microphone mark centred on a transparent `size` x `size` canvas."""
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    unit = size / CANVAS
    scale = 0.46 * unit
    left = (size - MARK_W * scale) / 2
    top = (size - MARK_H * scale) / 2

    def x(value: float) -> int:
        return round(left + value * scale)

    def y(value: float) -> int:
        return round(top + value * scale)

    def rect(box: tuple) -> list[int]:
        return [x(box[0]), y(box[1]), x(box[2]), y(box[3])]

    draw.rounded_rectangle(
        rect(CAPSULE), radius=round(CAPSULE_RADIUS * scale), fill=color
    )
    path_r = CRADLE_OUTER_R - CRADLE_STROKE / 2
    draw.arc(
        [
            x(CRADLE_CENTRE[0] - path_r),
            y(CRADLE_CENTRE[1] - path_r),
            x(CRADLE_CENTRE[0] + path_r),
            y(CRADLE_CENTRE[1] + path_r),
        ],
        start=0,
        end=180,
        fill=color,
        width=round(CRADLE_STROKE * scale),
    )
    draw.rectangle(rect(STEM), fill=color)
    draw.rounded_rectangle(rect(BASE), radius=round(BASE_RADIUS * scale), fill=color)
    return image


def _mark_at(
    size: int, color: tuple, scale: float, left: float, top: float
) -> Image.Image:
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    def x(value: float) -> int:
        return round(left + value * scale)

    def y(value: float) -> int:
        return round(top + value * scale)

    def rect(box: tuple) -> list[int]:
        return [x(box[0]), y(box[1]), x(box[2]), y(box[3])]

    draw.rounded_rectangle(
        rect(CAPSULE), radius=round(CAPSULE_RADIUS * scale), fill=color
    )
    path_r = CRADLE_OUTER_R - CRADLE_STROKE / 2
    draw.arc(
        [
            x(CRADLE_CENTRE[0] - path_r),
            y(CRADLE_CENTRE[1] - path_r),
            x(CRADLE_CENTRE[0] + path_r),
            y(CRADLE_CENTRE[1] + path_r),
        ],
        start=0,
        end=180,
        fill=color,
        width=round(CRADLE_STROKE * scale),
    )
    draw.rectangle(rect(STEM), fill=color)
    draw.rounded_rectangle(rect(BASE), radius=round(BASE_RADIUS * scale), fill=color)
    return image


def place_mark(
    canvas: Image.Image, color: tuple, share: float, lift: float = 0.0
) -> None:
    """Draw the mark over `canvas` at `share` of its height, nudged up."""
    size = canvas.width
    unit = size / CANVAS
    scale = share * unit
    left = (size - MARK_W * scale) / 2
    top = (size - MARK_H * scale) / 2 - lift * unit
    canvas.alpha_composite(_mark_at(size, color, scale, left, top))


def legacy_icon(size: int) -> Image.Image:
    """Rounded square, transparent outside the corners."""
    big = size * SUPERSAMPLE
    base = gradient(big, PRIMARY, SECONDARY).convert("RGBA")
    mask = Image.new("L", (big, big), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, big - 1, big - 1],
        radius=round(CORNER_RADIUS * big / CANVAS),
        fill=255,
    )
    base.putalpha(mask)
    place_mark(base, WHITE, share=0.58, lift=0.012)
    return base.resize((size, size), Image.Resampling.LANCZOS)


def adaptive_foreground(size: int, color: tuple) -> Image.Image:
    """Mark only, kept inside the 72/108dp safe zone."""
    big = size * SUPERSAMPLE
    image = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    place_mark(image, color, share=0.44, lift=0.0)
    return image.resize((size, size), Image.Resampling.LANCZOS)


def flat_icon(size: int) -> Image.Image:
    """Opaque square, for iOS and the store (both apply their own mask)."""
    big = size * SUPERSAMPLE
    base = gradient(big, PRIMARY, SECONDARY).convert("RGBA")
    place_mark(base, WHITE, share=0.56, lift=0.014)
    return base.convert("RGB").resize((size, size), Image.Resampling.LANCZOS)


ANDROID_DENSITIES = {
    "mdpi": 1,
    "hdpi": 1.5,
    "xhdpi": 2,
    "xxhdpi": 3,
    "xxxhdpi": 4,
}

ADAPTIVE_XML = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
    <monochrome android:drawable="@mipmap/ic_launcher_monochrome" />
</adaptive-icon>
"""

BACKGROUND_XML = """<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <gradient
        android:angle="135"
        android:endColor="#8B5CF6"
        android:startColor="#6366F1"
        android:type="linear" />
</shape>
"""


def write_android() -> list[Path]:
    written = []
    for density, factor in ANDROID_DENSITIES.items():
        folder = ANDROID_RES / f"mipmap-{density}"
        folder.mkdir(parents=True, exist_ok=True)

        legacy = legacy_icon(round(48 * factor))
        legacy.save(folder / "ic_launcher.png")
        legacy.save(folder / "ic_launcher_round.png")
        written += [folder / "ic_launcher.png", folder / "ic_launcher_round.png"]

        foreground = adaptive_foreground(round(108 * factor), WHITE)
        foreground.save(folder / "ic_launcher_foreground.png")
        written.append(folder / "ic_launcher_foreground.png")

        monochrome = adaptive_foreground(round(108 * factor), BLACK)
        monochrome.save(folder / "ic_launcher_monochrome.png")
        written.append(folder / "ic_launcher_monochrome.png")

    anydpi = ANDROID_RES / "mipmap-anydpi-v26"
    anydpi.mkdir(parents=True, exist_ok=True)
    (anydpi / "ic_launcher.xml").write_text(ADAPTIVE_XML, encoding="utf-8")
    (anydpi / "ic_launcher_round.xml").write_text(ADAPTIVE_XML, encoding="utf-8")
    written += [anydpi / "ic_launcher.xml", anydpi / "ic_launcher_round.xml"]

    drawable = ANDROID_RES / "drawable"
    drawable.mkdir(parents=True, exist_ok=True)
    (drawable / "ic_launcher_background.xml").write_text(BACKGROUND_XML, encoding="utf-8")
    written.append(drawable / "ic_launcher_background.xml")
    return written


def write_ios() -> list[Path]:
    manifest = json.loads((IOS_APPICON / "Contents.json").read_text(encoding="utf-8"))
    written = []
    for image in manifest["images"]:
        filename = image.get("filename")
        if not filename:
            continue
        points = float(image["size"].split("x")[0])
        scale = int(image["scale"].rstrip("x"))
        size = round(points * scale)
        flat_icon(size).save(IOS_APPICON / filename, optimize=True)
        written.append(IOS_APPICON / filename)
    return written


def main() -> None:
    BRANDING.mkdir(parents=True, exist_ok=True)

    master = flat_icon(1024)
    master.save(BRANDING / "app_icon_1024.png", optimize=True)
    flat_icon(512).save(BRANDING / "play_store_512.png", optimize=True)
    legacy_icon(512).save(BRANDING / "app_icon_rounded_512.png", optimize=True)

    written = [
        BRANDING / "app_icon_1024.png",
        BRANDING / "play_store_512.png",
        BRANDING / "app_icon_rounded_512.png",
        *write_android(),
        *write_ios(),
    ]
    print(f"generated {len(written)} files")


if __name__ == "__main__":
    main()
