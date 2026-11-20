# dotfiles
My dotfiles. Based on https://github.com/AhmedAbdulrahman

Supports macOS, Ubuntu (apt) and Arch Linux (pacman). sketchybar, yabai and skhd are macOS only.

## Quick start

New machine, one command (installs git if needed, clones to `~/dotfiles`, runs everything):

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Leolainen/dotfiles/master/installer.sh)" -- --all
```

Drop `--all` to get an interactive checklist instead.

## Usage

From an existing clone:

```sh
./installer.sh                         # checklist, pick modules
./installer.sh --all                   # everything, no questions
./installer.sh --only zsh,nvim         # only some modules
./installer.sh --dry-run --all         # preview, changes nothing
./installer.sh --list                  # list modules
./installer.sh --dir ~/code/dotfiles   # clone location (remote mode)
./installer.sh --no-color              # plain output
```

Environment: `DOTFILES_YES=1` (no prompts), `DOTFILES_DRY_RUN=1`, `DOTFILES_LOG=<file>`,
`OBSIDIAN_VAULT=<path>` (vault whose `.obsidian` config gets tracked).

## What it does

1. **Prerequisites**: Command Line Tools + Homebrew (macOS), `apt update` (Ubuntu) or pacman sync (Arch), then git, zsh, curl.
2. **Modules**, in order:

| Module | Sets up |
| --- | --- |
| `packages` | CLI tools and apps from the [`Brewfile`](Brewfile) (Linux equivalents mapped in `scripts/brew.zsh`), colorls, herdr |
| `node` | Node.js, npm defaults, nodemon |
| `zsh` | zsh, antidote plugins, p10k prompt, aliases, default shell |
| `nvim` | Neovim (LazyVim) and its prerequisites |
| `config` | Stows ghostty, git, taskwarrior, herdr, obsidian, and yabai + skhd (macOS) |
| `fonts` | Nerd Fonts |
| `sketchybar` | SketchyBar config (macOS only) |

3. **Summary** with per-module status, elapsed time and log path (`~/.dotfiles-install.log`).

Re-running is safe: finished steps are skipped, and existing files that would conflict are
backed up as `*.bak.<timestamp>` before linking. Each module also runs alone, e.g. `bash nvim/setup.sh`.

### macOS window-management services

Yabai, skhd, and SketchyBar should stay running for window management, keyboard shortcuts,
and the menu bar. Start or restart them from Terminal:

```sh
yabai --start-service
yabai --restart-service || yabai --start-service

skhd --start-service
skhd --restart-service
skhd --reload  # reload the config without restarting the service

brew services start sketchybar
brew services restart sketchybar
```

Press **⇧ Shift + ⌃ Control + ⌥ Option + ⌫ Delete** (Backspace) to restart
Yabai, reload SketchyBar, running Ghostty windows and skhd, and refresh the
shortcut sheet and theme picker. Missing or outdated panels are built with
Swift; open panels reopen and closed panels stay ready for their own shortcuts.
Ghostty opacity changes still require quitting and reopening Ghostty. Existing
Neovim sessions remain under manual control.

The floating shortcut sheet is a small on-demand window, not a background service. Press
`ctrl + alt + space` (**⌃ Control + ⌥ Option + Space** on a Mac keyboard) to open or close it. To launch it directly, run
`~/.local/bin/dotfiles-shortcut-sheet`; run `pkill -TERM -f '/dotfiles-shortcut-sheet$'`
to close it.

Add a program by adding it to the `Brewfile`. Shared output helpers live in `lib/ui.sh`.

### Cross-app themes

On macOS, the config setup builds `~/.local/bin/dotfiles-theme-picker` with Swift.
Press `shift + ctrl + alt + space` (**⇧ Shift + ⌃ Control + ⌥ Option + Space** on a Mac keyboard)
to toggle the panel, or run that executable
directly. Filter by **All**, **Light**, or **Dark** and search by theme name or ID, choose a match to preview its colors and
local wallpaper when available, then click **Apply theme** to see each app’s
result. Escape closes the panel. The picker uses the theme command in the
checkout it was built from.

**Apply theme** writes Herdr’s `dotfiles` palette and selects it for the current
layout through `herdr-app` when Herdr is open. If Herdr is closed, open it and
apply again. File restore restores the palette file; Herdr remembers its layout
selection separately.

Applying a light or dark theme also sets the matching macOS appearance. macOS
may ask for permission to control System Events on first use. Browsing only
previews themes. Themes marked `system` keep the current appearance setting.
File restore covers managed files; you can reselect Auto in System Settings → Appearance.

#### Find a matching wallpaper on Pixabay

Store your personal API key in **`~/.config/dotfiles/pixabay-api-key`**, outside
the Git checkout. If the picker uses `XDG_CONFIG_HOME`, the path is
`$XDG_CONFIG_HOME/dotfiles/pixabay-api-key`. Get your key from the
[Pixabay API page](https://pixabay.com/api/docs/).

```sh
key_dir="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
mkdir -p "$key_dir"
(umask 077 && touch "$key_dir/pixabay-api-key")
chmod 600 "$key_dir/pixabay-api-key"
nano "$key_dir/pixabay-api-key"
```

Paste only the key on the first line. In nano, press **Control‑O**, **Return**,
then **Control‑X** to save and exit. The picker reads the file when you search.
A direct launch can also use the `PIXABAY_API_KEY` environment variable.

To test, select **Darkearth** and click **Find wallpaper…**. Its accent and
background map to Pixabay’s brown and black filters for horizontal nature
photos. Search results are cached for 24 hours. Use **Next match** to browse
photos and photographer credits, then **Download & Set Desktop Picture** to save the match and apply it
to the display containing the picker. The result shows the saved file path.
Downloads and credits live in `~/Library/Application Support/dotfiles-theme/wallpapers/`
and are separate from exported manifests.

#### Import a local wallpaper

Choose **Import image…** to create and preview a theme from a local picture.
**Apply theme** applies its palette. **Set desktop picture** sets the image on
the display containing the picker. Keep the image at its original path.
From the CLI, run `scripts/dotfiles-theme import-wallpaper "/path/to/image"`.
Reimporting the same path refreshes its generated theme. Extraction tries
Aether’s local palette command when available, then macOS ImageIO via `sips`
or an existing Pillow installation on Linux.

#### Theme commands and manifests

Run `scripts/dotfiles-theme list` from the checkout, then `show ID`, `validate ID`,
or `apply ID` with the same command. `status` reports the last apply attempt and
each adapter’s result. `restore` returns managed files to their pre-apply contents.
Restore stops at conflicts to protect subsequent edits. Reload the affected apps
after restoring. Set `DOTFILES_THEME_NO_RELOAD=1` to write files without a live update.

Built-in JSON manifests live in `config/theme-picker/themes/`. Personal manifests
in `$XDG_CONFIG_HOME/dotfiles/themes/` take precedence (default `~/.config`).
Use the ID as the filename stem. Each manifest supplies a name, source type
(`preset`, `neovim`, `wallpaper`, or `file`), appearance (`light`, `dark`, or
`system`), the eleven named color roles shown in the presets, and sixteen ANSI
colors in index order. Use six-digit hex colors and at least 4.5:1 contrast
between foreground and background. Optional `apps.ghostty.background-opacity`
ranges from 0 to 1. Omitting it preserves the current Ghostty setting. Other adapters use opaque colors.
The Snacks colorscheme picker also exports and applies manifests through this CLI.
Backups and adapter results live under `$XDG_STATE_HOME/dotfiles/theme/`
(default `~/.local/state`). The CLI requires Python 3.8 or later.


The picker reports foreground, surface, selection, muted text, cursor, and border
contrast, plus estimated text contrast over black and white for translucent
Ghostty themes. Run `scripts/dotfiles-theme check ID` for the same report.

Use **Export theme…** and **Import theme…** to exchange JSON manifests. In a
terminal, use `scripts/dotfiles-theme export ID > theme.json` and
`scripts/dotfiles-theme import theme.json`. Import validates before saving.
An identical ID and manifest can be imported again. Choose a different ID for a
changed theme. Wallpaper themes carry their local path; transfer the image and
adjust its path when moving the manifest to another machine.

**Restore original files…** restores the baseline saved before the first managed
write to each file. Existing conflicts are reported before restoration starts.
Reload the affected apps afterward. Desktop pictures and manual app selections
are managed separately.
