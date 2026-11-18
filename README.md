# dotfiles
My dotfiles. Based on https://github.com/AhmedAbdulrahman

Supports macOS, Ubuntu (apt) and Arch Linux (pacman). sketchybar, yabai and skhd are macOS only.

## Install

```sh
git clone --recursive https://github.com/leolainen/dotfiles.git ~/dotfiles
~/dotfiles/installer.sh [path/to/dotfiles]
```

The installer asks before installing anything. It detects the OS, installs git and zsh
with Homebrew (macOS), apt (Ubuntu) or pacman (Arch), lets you pick which configs to
link (`zsh`, `fonts`, `config`, `nvim`, plus `sketchybar` on macOS) and can run
`scripts/bootstrap.zsh` to install CLI tools, apps and Node.js. Each config can also be
set up on its own with `<dir>/setup.sh`.

## What it sets up
* Neovim (LazyVim); `nvim/setup.sh` installs its prerequisites (e.g. lazygit, ripgrep)
* sketchybar (macOS only)
* zsh using antidote plugin manager & p10k prompt
* config for ghostty, git, taskwarrior, colorls, herdr (settings, keys, layouts, themes),
  obsidian (per-vault `.obsidian` config, set `OBSIDIAN_VAULT` or enter the path) and
  yabai + skhd (macOS only)
* cli tools installed by `scripts/bootstrap.zsh`:
  * tree, wget, yarn, fd, gh
  * zsh, git, htop, fzf
  * ruby + colorls
  * Node.js with npm (nodemon)
* apps (macOS casks; on Linux only what the distro packages): docker, ghostty, obsidian,
  slack, spotify, visual studio code, vlc, browsers, plus herdr (its own install script)
* nerd fonts
