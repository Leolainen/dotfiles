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

# Moves real files that would block stow out of the way as <name>.bak.<timestamp>.
backup_conflicts() {
    local pkgdir="$1" target="$2" file dest backup
    [ -d "$pkgdir" ] || return 0
    while IFS= read -r file; do
        dest="$target/${file#"$pkgdir"/}"
        [ "$dest" -ef "$file" ] && continue
        if [ -e "$dest" ] || [ -L "$dest" ]; then
            backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
            if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
                info "Would back up $dest to $backup"
            else
                warn "Backing up existing $dest to $backup"
                mv "$dest" "$backup"
            fi
        fi
    done < <(find "$pkgdir" \( -type f -o -type l \))
}

# usage: stow_pkg <package> <target-dir> ["label"]
stow_pkg() {
    local package="$1" target="$2" label="${3:-$1}"
    [ "${DOTFILES_DRY_RUN:-0}" = 1 ] || mkdir -p "$target"
    backup_conflicts "$SCRIPT_DIR/$package" "$target"
    if ! ui_run "Linking $label" stow --restow --target="$target" --dir="$SCRIPT_DIR" "$package"; then
        stow -v --restow --target="$target" --dir="$SCRIPT_DIR" "$package" >&2 || true
        return 1
    fi
}

# Installs stow when missing (not needed in a dry run).
ensure_stow() {
    pkg_install stow stow stow || return 1
    _exists stow || [ "${DOTFILES_DRY_RUN:-0}" = 1 ] || {
        error "stow is not available."
        return 1
    }
}

install_prereq() {
    # Ubuntu's neovim/lazygit/stylua are missing or too old for LazyVim; warn instead.
    pkg_install neovim neovim neovim nvim || FAILED=1
    pkg_install stylua "" stylua || FAILED=1
    pkg_install lazygit "" lazygit || FAILED=1
    pkg_install ripgrep ripgrep ripgrep rg || FAILED=1
    pkg_install cmake cmake cmake || FAILED=1
    if [ "$OS" = "ubuntu" ]; then
        pkg_install "" build-essential "" || FAILED=1
        pkg_install "" curl "" || FAILED=1
        if ! _exists lazygit || ! _exists stylua; then
            warn "On Ubuntu install a recent neovim (>= 0.9), lazygit and stylua manually (release tarballs, snap or cargo)."
        fi
    fi

    # requires cargo to install tree-sitter-cli
    if _exists tree-sitter; then
        skip "tree-sitter-cli already installed"
        return 0
    fi
    if ! _exists cargo && [ -x "$HOME/.cargo/bin/cargo" ]; then
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
    if _exists cargo; then
        skip "cargo already installed"
    else
        ui_run "Installing Rust (cargo)" bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y" || {
            FAILED=1
            return 0
        }
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
    ui_run "Installing tree-sitter-cli (compiles, takes a while)" cargo install --locked tree-sitter-cli || FAILED=1
}

install_prereq
if ensure_stow; then
    stow_pkg nvim "$HOME/.config/nvim" "nvim config" || FAILED=1
else
    FAILED=1
fi

if [ "$FAILED" -ne 0 ]; then
    error "Neovim finished with errors, see $DOTFILES_LOG"
    exit 1
fi
success "Neovim ready"
