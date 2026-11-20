#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || exit 1
# shellcheck source=../lib/ui.sh
. "$SCRIPT_DIR/../lib/ui.sh"

detect_os || exit 1
FAILED=0

if ! _exists git; then
    error "git is required to install Nerd Fonts."
    exit 1
fi

# nerd-fonts install.sh copies into ~/Library/Fonts on macOS and
# ~/.local/share/fonts on Linux, and refreshes the cache itself.
directory="$HOME/.ghq/github.com/ryanoasis"
repo="$directory/nerd-fonts"

[ "${DOTFILES_DRY_RUN:-0}" = 1 ] || mkdir -p "$directory"

if [ -d "$repo/.git" ]; then
    ui_run "Updating nerd-fonts" git -C "$repo" pull --ff-only || warn "Could not update nerd-fonts, using existing clone."
else
    ui_run "Cloning nerd-fonts" git clone --depth 1 https://github.com/ryanoasis/nerd-fonts "$repo" || exit 1
fi

# Without font names install.sh opens an interactive menu, which installs
# nothing when run unattended. LiberationMono is the "LiterationMono Nerd Font" used by sketchybar.
NERD_FONTS=(LiberationMono)

ui_run "Installing Nerd Fonts" bash -c 'cd "$1" && shift && ./install.sh install "$@"' _ "$repo" "${NERD_FONTS[@]}" || exit 1

success "Nerd Fonts ready"
