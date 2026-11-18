#!/usr/bin/env bash

set -e

info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*"; }

# get dir of current script
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
            warn "No apt package for $brew_pkg, install it manually."
        elif dpkg -s "$apt_pkg" >/dev/null 2>&1; then
            success "$apt_pkg already installed."
        else
            info "Installing $apt_pkg..."
            sudo apt-get install -y "$apt_pkg"
        fi
        ;;
    arch)
        if [ -z "$pacman_pkg" ]; then
            warn "No pacman package for $brew_pkg, install it manually."
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

# Link a file into $HOME, backing up an existing regular file first.
link_file() {
    local src="$1" dest="$2"
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        success "$dest already linked."
        return
    fi
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        local backup
        backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
        warn "Backing up existing $dest to $backup"
        mv "$dest" "$backup"
    fi
    ln -s "$src" "$dest"
    success "Linked $dest"
}

detect_os
info "Detected OS: $OS"

pkg_install zsh zsh zsh

# antidote: brew formula on macOS, git clone fallback elsewhere (not in apt)
if [ "$OS" = "macos" ]; then
    pkg_install antidote "" ""
else
    if [ -d "$HOME/.antidote" ]; then
        success "antidote already cloned."
    elif command -v git >/dev/null 2>&1; then
        info "Cloning antidote to ~/.antidote..."
        git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"
    else
        warn "git not found, install antidote manually: https://antidote.sh"
    fi
fi

# link_file "$SCRIPT_DIR/zsh_env"          ~/.zsh_env
# link_file "$SCRIPT_DIR/zsh_keybinds"     ~/.zsh_keybinds
# link_file "$SCRIPT_DIR/zsh_functions"    ~/.zsh_functions
# link_file "$SCRIPT_DIR/zsh_misc"         ~/.zsh_misc
# link_file "$SCRIPT_DIR/zsh_fzf_extra"    ~/.zsh_fzf_extra
link_file "$SCRIPT_DIR/zshrc" "$HOME/.zshrc"
link_file "$SCRIPT_DIR/zsh_aliases" "$HOME/.zsh_aliases"
link_file "$SCRIPT_DIR/zsh_plug" "$HOME/.zsh_plug"
link_file "$SCRIPT_DIR/zsh_plugins" "$HOME/.zsh_plugins.txt"

# mkdir -p ~/.zsh_completions
# link_file "$SCRIPT_DIR/completions/_jq" ~/.zsh_completions/_jq

if [[ "$SHELL" != *zsh* ]]; then
    if command -v zsh >/dev/null 2>&1; then
        info "Changing default shell to zsh..."
        chsh -s "$(command -v zsh)" || warn "chsh failed, run 'chsh -s $(command -v zsh)' manually."
    else
        warn "zsh not found, default shell not changed."
    fi
fi

success "zsh setup complete!"
