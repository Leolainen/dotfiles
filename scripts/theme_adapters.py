"""Apply a validated manifest to the desktop apps managed by these dotfiles."""

import json
import os
from pathlib import Path
import platform
import shutil
import subprocess


def argb(color):
    return "0xff" + color[1:]


def shell_palette(theme):
    colors = theme["colors"]
    roles = {
        "background": "background", "foreground": "foreground", "cursor_color": "cursor",
        "selection_foreground": "foreground", "selection_background": "selection",
        "TEXT_PRIMARY": "foreground", "TEXT_SECONDARY": "muted", "TEXT_HIGHLIGHT": "selection",
        "ERROR": "error", "SUCCESS": "success", "WARNING": "warning", "ACCENT": "accent",
        "CANVAS": "background", "BACKGROUND": "background", "BACKGROUND_HIGHLIGHT": "selection",
        "BORDER": "border", "BORDER_HIGHLIGHT": "accent",
    }
    ansi = " ".join(argb(c) for c in theme["ansi"])
    lines = [f"export palette=({ansi})"]
    lines.extend(f"export {key}={argb(colors[role])}" for key, role in roles.items())
    return ("\n".join(lines) + "\n").encode()


def update_running(binary, arguments):
    if os.environ.get("DOTFILES_THEME_NO_RELOAD") == "1":
        return "manual step", "Palette saved. Live update disabled."
    if not shutil.which(binary):
        return "manual step", f"Palette saved. {binary} is unavailable."
    running = subprocess.run(["pgrep", "-u", str(os.getuid()), "-x", binary],
                             stdout=subprocess.DEVNULL, timeout=5)
    if running.returncode == 1:
        return "skipped", f"Palette saved. {binary} is closed."
    running.check_returncode()
    subprocess.run([binary, *arguments], capture_output=True, check=True, timeout=8)
    return "applied", f"Updated running {binary}."


def select_herdr_theme(app_home):
    if os.environ.get("DOTFILES_THEME_NO_RELOAD") == "1":
        return "manual step", "Palette saved. Live update disabled."
    if not (app_home / "herdr-app.sock").is_socket():
        return "manual step", "Palette saved. Open Herdr and apply again to select it for this layout."

    # skhd may launch the picker without ~/.local/bin on PATH.
    cli = shutil.which("herdr-app") or str(Path.home() / ".local/bin/herdr-app")
    if not os.access(cli, os.X_OK):
        return "manual step", "Palette saved. Select dotfiles in Herdr Settings > Look for this layout."
    result = subprocess.run([cli, "do", "app.theme", "--name", "dotfiles"],
                            capture_output=True, text=True, timeout=8)
    if result.returncode:
        detail = result.stderr.strip() or result.stdout.strip() or f"exit {result.returncode}"
        return "failed", f"Palette saved. Herdr could not select it: {detail}"
    return "applied", "Selected the dotfiles palette for the current Herdr layout."


def apply_extra(theme, config, write, report):
    colors = theme["colors"]
    mac = platform.system() == "Darwin"
    palette = config / "dotfiles/palette.sh"
    targets = (
        ("SketchyBar", "sketchybar/sketchybarrc", "sketchybar", ["--reload"]),
        ("Yabai borders", "yabai/borders_config", "borders", [
            "active_color=" + argb(colors["accent"]), "inactive_color=" + argb(colors["border"]),
            "background_color=" + argb(colors["background"]),
        ]),
    )
    for app, consumer, executable, args in targets:
        if not mac or not (config / consumer).is_file():
            report(app, "skipped", "Requires the managed macOS configuration.")
            continue
        try:
            write(palette, shell_palette(theme))
            report(app, *update_running(executable, args))
        except (OSError, ValueError, subprocess.SubprocessError) as exc:
            report(app, "failed", str(exc))

    app_home = config / "herdr-app"
    if (app_home / "themes").is_dir():
        custom = {key: colors[key] for key in ("background", "foreground", "selection", "cursor")}
        custom["ansi"] = theme["ansi"]
        custom["colors"] = {key: colors[key] for key in ("accent", "border", "surface")}
        try:
            write(app_home / "themes/dotfiles.json", (json.dumps(custom, indent=2) + "\n").encode())
            report("Herdr", *select_herdr_theme(app_home))
        except (OSError, ValueError, subprocess.SubprocessError) as exc:
            report("Herdr", "failed", str(exc))
    else:
        report("Herdr", "skipped", "Herdr Desktop theme directory is absent.")

    if not mac:
        report("System Appearance", "skipped", "Available on macOS.")
        return

    mode = theme["appearance"]
    colors_hint = f"Suggested accent {colors['accent']} and highlight {colors['selection']}."
    if mode == "system":
        report("System Appearance", "manual step", "For automatic mode, choose Auto in System Settings > Appearance. " + colors_hint)
        return
    if os.environ.get("DOTFILES_THEME_NO_RELOAD") == "1":
        report("System Appearance", "skipped", "Live update disabled.")
        return

    value = "true" if mode == "dark" else "false"
    script = f'tell application "System Events" to set dark mode of appearance preferences to {value}'
    try:
        result = subprocess.run(["osascript", "-e", script], capture_output=True, text=True, timeout=60)
        if result.returncode:
            report("System Appearance", "failed", f"Could not set {mode} mode. {result.stderr.strip()}")
        else:
            report("System Appearance", "applied", f"Set macOS to {mode} mode. {colors_hint}")
    except (OSError, subprocess.SubprocessError) as exc:
        report("System Appearance", "failed", str(exc))
