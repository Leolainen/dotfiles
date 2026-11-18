#!/usr/bin/env bash

set -e

info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*"; }

if ! command -v git >/dev/null 2>&1; then
    error "git is required to install Nerd Fonts."
    exit 1
fi

# nerd-fonts install.sh copies into ~/Library/Fonts on macOS and
# ~/.local/share/fonts on Linux, and refreshes the cache itself.
directory="$HOME/.ghq/github.com/ryanoasis"
repo="$directory/nerd-fonts"

mkdir -p "$directory"

if [ -d "$repo/.git" ]; then
    info "nerd-fonts already cloned, updating..."
    git -C "$repo" pull --ff-only || warn "Could not update nerd-fonts, using existing clone."
else
    info "Cloning nerd-fonts..."
    git clone --depth 1 https://github.com/ryanoasis/nerd-fonts "$repo"
fi

info "Installing Nerd Fonts..."
(cd "$repo" && ./install.sh)

success "Nerd Fonts installed."
