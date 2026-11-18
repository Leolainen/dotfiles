#!/usr/bin/env bash

set -e

info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*"; }

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

install_prereq() {
    info "Checking and installing Neovim dependencies..."

    # Ubuntu's neovim/lazygit/stylua are missing or too old for LazyVim; warn instead.
    pkg_install neovim neovim neovim
    pkg_install stylua "" stylua
    pkg_install lazygit "" lazygit
    pkg_install ripgrep ripgrep ripgrep
    pkg_install cmake cmake cmake
    if [ "$OS" = "ubuntu" ]; then
        pkg_install "" build-essential ""
        pkg_install "" curl ""
        warn "On Ubuntu install a recent neovim (>= 0.9), lazygit and stylua manually (release tarballs, snap or cargo)."
    fi

    # requires cargo to install tree-sitter-cli
    if ! command -v cargo >/dev/null 2>&1; then
        if [ -x "$HOME/.cargo/bin/cargo" ]; then
            export PATH="$HOME/.cargo/bin:$PATH"
            success "cargo already installed."
        else
            info "Installing Rust (cargo)..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            export PATH="$HOME/.cargo/bin:$PATH"
        fi
    else
        success "cargo already installed."
    fi

    # Checks for tree-sitter-cli and installs it
    if ! command -v tree-sitter >/dev/null 2>&1; then
        info "Installing tree-sitter-cli..."
        cargo install --locked tree-sitter-cli
    else
        success "tree-sitter-cli already installed."
    fi

    success "All prerequisites are installed."
}

symlink_nvim() {
    if ! command -v stow >/dev/null 2>&1; then
        info "stow not found, installing..."
        pkg_install stow stow stow
    fi
    command -v stow >/dev/null 2>&1 || {
        error "stow is not available."
        exit 1
    }

    info "Symlinking nvim config with stow..."
    mkdir -p "$HOME/.config/nvim"
    stow --restow -vv --target="$HOME/.config/nvim" --dir="$SCRIPT_DIR" nvim

    success "nvim config has been symlinked."
}

main() {
    detect_os
    info "Detected OS: $OS"

    read -r -p "Would you like to set up Neovim (LazyVim)? [y/N] " -n 1 answer
    echo
    if [[ $answer =~ ^[Yy]$ ]]; then
        install_prereq
        symlink_nvim
        success "Neovim setup complete!"
    else
        warn "Neovim setup skipped."
    fi
}

main "$@"
