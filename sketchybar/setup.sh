#!/usr/bin/env bash

set -e

info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*"; }

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || exit 1

# SketchyBar is macOS only
if [ "$(uname -s)" != "Darwin" ]; then
    warn "SketchyBar is macOS only, skipping."
    exit 0
fi

install_sketchybar() {
    info "If problems; read how to setup here -> https://felixkratz.github.io/SketchyBar/setup"

    if brew list --formula sketchybar >/dev/null 2>&1; then
        success "SketchyBar already installed."
    else
        info "Installing SketchyBar ..."
        brew tap FelixKratz/formulae
        brew install sketchybar
        success "SketchyBar has finished installing."
    fi

    read -r -p "Symlink existing configs? [y/N] " -n 1 answer
    echo

    if [[ $answer =~ ^[Yy]$ ]]; then
        if ! command -v stow >/dev/null 2>&1; then
            info "Installing stow..."
            brew install stow
        fi
        mkdir -p "$HOME/.config/sketchybar"
        stow --restow -vv --target="$HOME/.config/sketchybar" --dir="$SCRIPT_DIR" sketchybar
    fi

    # run bar automatically on startup
    info "Starting sketchybar"
    brew services start sketchybar
}

read -r -p "Would you like to install SketchyBar? [y/N] " -n 1 answer
echo

if [[ $answer =~ ^[Yy]$ ]]; then
    install_sketchybar
else
    warn "SketchyBar setup skipped."
fi
