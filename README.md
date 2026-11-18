# dotfiles
My dotfiles. Based on https://github.com/AhmedAbdulrahman

Supports macOS, Ubuntu (apt) and Arch Linux (pacman). sketchybar, yabai and skhd are macOS only.

## Install

On a brand new machine, one command installs the programs, links the configs and sets up the shell:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Leolainen/dotfiles/master/installer.sh)" -- --all
```

It installs git if needed, clones this repo to `~/dotfiles` and runs everything unattended.
Drop `--all` to get a checklist of what to install instead.

From an existing clone:

```sh
./installer.sh                  # checklist, pick what to install
./installer.sh --all            # everything, no questions
./installer.sh --only zsh,nvim  # only some modules
./installer.sh --dry-run        # show what would happen
./installer.sh --list           # available modules
```

Modules: `packages`, `node`, `zsh`, `nvim`, `config`, `fonts`, `sketchybar` (macOS). Each one can
also be run on its own, e.g. `nvim/setup.sh`. The installer is safe to re-run: finished steps are
skipped, existing files are backed up (`*.bak.<timestamp>`) before being linked. Command output
is logged to `~/.dotfiles-install.log`.

## What it sets up
* macOS packages and apps from the [`Brewfile`](Brewfile) (`brew bundle`); the Linux equivalents
  are mapped in `scripts/brew.zsh`. Add a program by adding it to the Brewfile.
* Neovim (LazyVim); `nvim/setup.sh` installs its prerequisites (e.g. lazygit, ripgrep)
* sketchybar (macOS only)
* zsh using antidote plugin manager & p10k prompt
* config for ghostty, git, taskwarrior, colorls, herdr (settings, keys, layouts, themes),
  obsidian (per-vault `.obsidian` config, set `OBSIDIAN_VAULT` or enter the path) and
  yabai + skhd (macOS only)
* Node.js with npm (nodemon)
* herdr (its own install script)
* nerd fonts

Shared terminal output helpers live in `lib/ui.sh`.
