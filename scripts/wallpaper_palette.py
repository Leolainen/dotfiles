"""Local wallpaper palette providers. Each returns sixteen ANSI hex colors."""
import colorsys
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import shutil
import struct
import subprocess
import sys
import tempfile


def aether_palette(path):
    result = subprocess.run(["aether", "--extract-palette", str(path), "--json"],
                            capture_output=True, timeout=30, check=True)
    colors = json.loads(result.stdout)
    if isinstance(colors, dict):
        colors = colors.get("palette", colors.get("colors"))
    if not isinstance(colors, list) or len(colors) != 16 or not all(
        isinstance(c, str) and re.fullmatch(r"#[\da-fA-F]{6}", c) for c in colors
    ):
        raise ValueError("incompatible Aether palette")
    return colors


def sample_pixels(path):
    if sys.platform != "darwin":
        try:
            from PIL import Image
        except ImportError as exc:
            raise ValueError("Wallpaper import requires Pillow or a compatible Aether CLI on Linux") from exc
        with Image.open(path) as image:
            image.thumbnail((64, 64))
            return list(image.convert("RGB").getdata())

    # sips decodes with ImageIO; use a fixed-width bitmap without row padding.
    with tempfile.TemporaryDirectory() as directory:
        sample = Path(directory) / "sample.bmp"
        subprocess.run(["/usr/bin/sips", "-z", "64", "64", "-s", "format", "bmp",
                        str(path), "--out", str(sample)], capture_output=True, check=True, timeout=30)
        data = sample.read_bytes()
    offset = int.from_bytes(data[10:14], "little")
    width, height, planes, bits = struct.unpack_from("<iiHH", data, 18)
    stride = bits // 8
    if (width, abs(height), planes) != (64, 64, 1) or bits not in (24, 32) or len(data) < offset + 4096 * stride:
        raise ValueError("unexpected decoded bitmap layout")
    return [tuple(data[i:i + 3][::-1]) for i in range(offset, offset + 4096 * stride, stride)]


def local_palette(path):
    buckets = Counter(tuple(min(255, (v // 32) * 32 + 16) for v in p) for p in sample_pixels(path))
    samples = [rgb for rgb, count in buckets.most_common(16)]

    def tint(rgb, amount, target):
        return "#" + "".join(f"{round(v + (target - v) * amount):02x}" for v in rgb)

    base = samples[0]
    # Match ANSI red through cyan to the nearest prominent image hue.
    hsv = [colorsys.rgb_to_hsv(*(v / 255 for v in rgb)) for rgb in samples]
    accents = []
    for hue in (0, 1/3, 1/6, 2/3, 5/6, 1/2):
        def distance(i):
            delta = abs(hsv[i][0] - hue)
            return min(delta, 1 - delta) + (1 - hsv[i][1]) * .25
        rgb = samples[min(range(len(samples)), key=distance)]
        accents.append(rgb)
    return ([tint(base, .75, 0)] + [tint(rgb, .25, 255) for rgb in accents] +
            [tint(base, .8, 255), tint(base, .45, 255)] +
            [tint(rgb, .5, 255) for rgb in accents] + [tint(base, .95, 255)])


def theme_from_image(path, luminance):
    path = path.expanduser().resolve(strict=True)
    if not path.is_file():
        raise ValueError("select a local image file")
    provider = "local"
    colors = None
    if shutil.which("aether"):
        try:
            colors = aether_palette(path)
            provider = "aether"
        except (OSError, ValueError, subprocess.SubprocessError):
            pass
    if colors is None:
        try:
            colors = local_palette(path)
        except (OSError, subprocess.SubprocessError, struct.error) as exc:
            raise ValueError(f"cannot decode image: {path.name}") from exc
    bg, fg = colors[0], colors[7]
    low, high = sorted((luminance(bg), luminance(fg)))
    if (high + .05) / (low + .05) < 4.5:
        fg = "#ffffff" if luminance(bg) < .179 else "#000000"
    key = hashlib.sha256(bytes(path)).hexdigest()[:20]
    name = " ".join(path.stem.split()) or "Wallpaper"
    return dict(id="wallpaper-" + key, name=name, appearance="dark" if luminance(bg) < luminance(fg) else "light",
                source=dict(type="wallpaper", provider=provider), wallpaper=dict(path=str(path)), ansi=colors,
                colors=dict(background=bg, surface=colors[8], foreground=fg, muted=colors[8],
                            selection=colors[4], cursor=fg, accent=colors[6], border=colors[4],
                            error=colors[1], success=colors[2], warning=colors[3]))
