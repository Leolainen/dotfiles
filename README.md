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

The floating shortcut sheet is a small on-demand window, not a background service. Press
`ctrl + alt + space` to open or close it. To launch it directly, run
`~/.local/bin/dotfiles-shortcut-sheet`; run `pkill -TERM -f '/dotfiles-shortcut-sheet$'`
to close it.

Add a program by adding it to the `Brewfile`. Shared output helpers live in `lib/ui.sh`.
