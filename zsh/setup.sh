#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || exit 1
# shellcheck source=../lib/ui.sh
. "$SCRIPT_DIR/../lib/ui.sh"

detect_os || exit 1
FAILED=0

# usage: pkg_install <brew-name> <apt-name> <pacman-name> [command]
# Skips when the command or package exists; empty name = unavailable on that OS.
pkg_install() {
    local brew_pkg="$1" apt_pkg="$2" pacman_pkg="$3" cmd="${4:-$1}" pkg
    local label="${brew_pkg:-${apt_pkg:-$pacman_pkg}}"
    case "$OS" in
    macos) pkg="$brew_pkg" ;;
    ubuntu) pkg="$apt_pkg" ;;
    arch) pkg="$pacman_pkg" ;;
    esac
    if [ -z "$pkg" ]; then
        warn "No $OS package for $label, install it manually."
        return 0
    fi
    if [ -n "$cmd" ] && _exists "$cmd"; then
        skip "$label already installed"
        return 0
    fi
    case "$OS" in
    macos)
        if [ "${DOTFILES_DRY_RUN:-0}" != 1 ] && ! _exists brew; then
            error "Homebrew is required to install $pkg"
            return 1
        fi
        if brew list --formula "$pkg" >/dev/null 2>&1; then
            skip "$label already installed"
            return 0
        fi
        ui_run "Installing $pkg" brew install "$pkg"
        ;;
    ubuntu)
        if dpkg -s "$pkg" >/dev/null 2>&1; then
            skip "$label already installed"
            return 0
        fi
        ensure_sudo || return 1
        ui_run "Installing $pkg" sudo apt-get install -y "$pkg"
        ;;
    arch)
        if pacman -Qi "$pkg" >/dev/null 2>&1; then
            skip "$label already installed"
            return 0
        fi
        ensure_sudo || return 1
        ui_run "Installing $pkg" sudo pacman -S --needed --noconfirm "$pkg"
        ;;
    esac
}

# ui_run cannot prompt, so make sure sudo credentials are cached first.
ensure_sudo() {
    [ "${DOTFILES_DRY_RUN:-0}" = 1 ] && return 0
    [ "$(id -u)" -eq 0 ] && return 0
    sudo -n true 2>/dev/null || ui_sudo_keepalive
}

# Link a file into $HOME, backing up an existing regular file first.
link_file() {
    local src="$1" dest="$2" backup
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        skip "$dest already linked"
        return 0
    fi
    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
        info "Would link $dest -> $src"
        return 0
    fi
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
        warn "Backing up existing $dest to $backup"
        mv "$dest" "$backup"
    fi
    ln -s "$src" "$dest"
    success "Linked $dest"
}

pkg_install zsh zsh zsh || FAILED=1

# antidote: brew formula on macOS, git clone fallback elsewhere (not in apt)
if [ "$OS" = "macos" ]; then
    pkg_install antidote "" "" || FAILED=1
elif [ -d "$HOME/.antidote" ]; then
    skip "antidote already cloned"
elif _exists git; then
    ui_run "Cloning antidote to ~/.antidote" git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote" || FAILED=1
else
    warn "git not found, install antidote manually: https://antidote.sh"
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

if [[ "$SHELL" == *zsh* ]]; then
    skip "zsh is already the default shell"
elif ! _exists zsh && [ "${DOTFILES_DRY_RUN:-0}" != 1 ]; then
    warn "zsh not found, default shell not changed."
elif [ "${DOTFILES_DRY_RUN:-0}" != 1 ] && [ ! -t 0 ]; then
    warn "Not interactive, run 'chsh -s $(command -v zsh)' to make zsh your default shell."
else
    ui_live "Changing default shell to zsh" chsh -s "$(command -v zsh || echo zsh)" ||
        warn "chsh failed, run 'chsh -s $(command -v zsh)' manually."
fi

if [ "$FAILED" -ne 0 ]; then
    error "zsh finished with errors, see $DOTFILES_LOG"
    exit 1
fi
success "zsh ready"
