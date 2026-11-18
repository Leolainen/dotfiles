#!/usr/bin/env bash
################################################################################
#  Author: Ahmed Abdulrahman
#  Email: a.kasapbashi@gmail.com
#  Created: 2019-10-12 22:20
################################################################################

set -e

info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*"; }

# get the dir of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || exit 1

detect_os() {
    case "$(uname -s)" in
    Darwin) OS="macos" ;;
    Linux)
        OS="linux"
        if [ -r /etc/os-release ]; then
            # shellcheck disable=SC1091
            . /etc/os-release
            case " $ID $ID_LIKE " in
            *" arch "*) OS="arch" ;;
            *" ubuntu "* | *" debian "*) OS="ubuntu" ;;
            esac
        fi
        ;;
    *) OS="unknown" ;;
    esac
}

# usage: pkg_install <brew-name> <apt-name> <pacman-name>; empty name = unavailable
pkg_install() {
    local brew_pkg="$1" apt_pkg="$2" pacman_pkg="$3"
    case "$OS" in
    macos)
        if brew list --formula "$brew_pkg" >/dev/null 2>&1; then
            success "$brew_pkg already installed."
        else
            info "Installing $brew_pkg..."
            brew install "$brew_pkg"
        fi
        ;;
    ubuntu)
        if [ -z "$apt_pkg" ]; then
            warn "No apt package for $brew_pkg, skipping."
        elif dpkg -s "$apt_pkg" >/dev/null 2>&1; then
            success "$apt_pkg already installed."
        else
            info "Installing $apt_pkg..."
            sudo apt-get install -y "$apt_pkg"
        fi
        ;;
    arch)
        if [ -z "$pacman_pkg" ]; then
            warn "No pacman package for $brew_pkg, skipping."
        elif pacman -Qi "$pacman_pkg" >/dev/null 2>&1; then
            success "$pacman_pkg already installed."
        else
            info "Installing $pacman_pkg..."
            sudo pacman -S --needed --noconfirm "$pacman_pkg"
        fi
        ;;
    *)
        warn "Unsupported OS, install $brew_pkg manually."
        ;;
    esac
}

detect_os
info "Detected OS: $OS"

# stow must exist before anything is linked
pkg_install stow stow stow
command -v stow >/dev/null 2>&1 || {
    exit 1
}

info "Create some required folders..."
mkdir -p "$HOME/.config"

info "Symlink .gitconfig, .gitconfig.local, .gitignore files"
stow --restow -vv --target="$HOME" --dir="$SCRIPT_DIR" git

# Taskwarrior; package names differ per distro
info "Installing Taskwarrior"
pkg_install task taskwarrior task
pkg_install tasksh "" ""
pkg_install timewarrior timewarrior timew

info "Symlink .taskrc file"
stow --restow -vv --target="$HOME" --dir="$SCRIPT_DIR" taskwarrior

info "Create timewarrior folder..."
mkdir -p "$HOME/.timewarrior"

# Currently don't use custom configs
# info "Symlink timewarrior.cfg file"
# stow --restow -vv --target="$HOME/.timewarrior" --dir="$SCRIPT_DIR" timewarrior

# yabai and skhd are macOS only
if [ "$OS" = "macos" ]; then
    mkdir -p "$HOME/.config/yabai"
    stow --restow -vv --target="$HOME/.config/yabai" --dir="$SCRIPT_DIR" yabai

    mkdir -p "$HOME/.config/skhd"
    stow --restow -vv --target="$HOME/.config/skhd" --dir="$SCRIPT_DIR" skhd
else
    warn "Skipping yabai and skhd (macOS only)."
fi

# ghostty
mkdir -p "$HOME/.config/ghostty"
stow --restow -vv --target="$HOME/.config/ghostty" --dir="$SCRIPT_DIR" ghostty

# usage: adopt_into_repo <package> <target-dir> <name>...
# Moves existing real files/dirs from the target into the repo (first run on a
# machine that already has the config) so stow can replace them with symlinks.
adopt_into_repo() {
    local package="$1" target="$2" name
    shift 2
    mkdir -p "$SCRIPT_DIR/$package"
    for name in "$@"; do
        if [ -e "$target/$name" ] && [ ! -L "$target/$name" ] && [ ! -e "$SCRIPT_DIR/$package/$name" ]; then
            info "Adopting $target/$name into config/$package"
            mv "$target/$name" "$SCRIPT_DIR/$package/$name"
        fi
    done
}

# herdr: only user config is tracked, runtime state (socket, data, icons, mods, ...) is not
HERDR_DIR="$HOME/.config/herdr-app"
HERDR_TRACKED=(settings.json keys.json layouts themes)
mkdir -p "$HERDR_DIR"
adopt_into_repo herdr "$HERDR_DIR" "${HERDR_TRACKED[@]}"
stow --restow -vv --target="$HERDR_DIR" --dir="$SCRIPT_DIR" herdr

# obsidian: config lives in each vault's .obsidian dir; workspace*.json is per-device state and not tracked
OBSIDIAN_TRACKED=(app.json appearance.json hotkeys.json core-plugins.json community-plugins.json snippets themes)
OBSIDIAN_VAULT="${OBSIDIAN_VAULT:-}"
if [ -z "$OBSIDIAN_VAULT" ] && [ -t 0 ]; then
    read -r -p "Path to your Obsidian vault (empty to skip linking its config): " OBSIDIAN_VAULT
fi
OBSIDIAN_VAULT="${OBSIDIAN_VAULT/#\~/$HOME}"
if [ -n "$OBSIDIAN_VAULT" ] && [ -d "$OBSIDIAN_VAULT" ]; then
    mkdir -p "$OBSIDIAN_VAULT/.obsidian"
    adopt_into_repo obsidian "$OBSIDIAN_VAULT/.obsidian" "${OBSIDIAN_TRACKED[@]}"
    stow --restow -vv --target="$OBSIDIAN_VAULT/.obsidian" --dir="$SCRIPT_DIR" obsidian
else
    warn "Skipping Obsidian config (no vault given; set OBSIDIAN_VAULT=/path/to/vault)."
fi

success "Config setup complete!"
