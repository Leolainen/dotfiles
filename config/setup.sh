#!/usr/bin/env bash
################################################################################
#  Author: Ahmed Abdulrahman
#  Email: a.kasapbashi@gmail.com
#  Created: 2019-10-12 22:20
################################################################################

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

if ! ensure_stow; then
    error "stow is required to link the configs."
    exit 1
fi

[ "${DOTFILES_DRY_RUN:-0}" = 1 ] || mkdir -p "$HOME/.config"

stow_pkg git "$HOME" "git config (.gitconfig, .gitignore)" || FAILED=1

# Taskwarrior; package names differ per distro
pkg_install task taskwarrior task || FAILED=1
pkg_install tasksh "" "" || FAILED=1
pkg_install timewarrior timewarrior timew timew || FAILED=1
stow_pkg taskwarrior "$HOME" "taskwarrior (.taskrc)" || FAILED=1
[ "${DOTFILES_DRY_RUN:-0}" = 1 ] || mkdir -p "$HOME/.timewarrior"

# Currently don't use custom configs
# stow_pkg timewarrior "$HOME/.timewarrior" "timewarrior.cfg"

# yabai and skhd are macOS only
if [ "$OS" = "macos" ]; then
    if ! _exists yabai; then
        if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
            ui_run "Adding the Asmvik/formulae tap" brew tap asmvik/formulae
            ui_run "Trusting the Yabai formula" brew trust --formula asmvik/formulae/yabai
            ui_run "Installing yabai" brew install asmvik/formulae/yabai
        elif ! _exists brew; then
            error "Homebrew is required to install yabai"
            FAILED=1
        else
            ui_run "Adding the Asmvik/formulae tap" brew tap asmvik/formulae || FAILED=1
            ui_run "Trusting the Yabai formula" brew trust --formula asmvik/formulae/yabai || FAILED=1
            ui_run "Installing yabai" brew install asmvik/formulae/yabai || FAILED=1
        fi
    else
        skip "yabai already installed"
    fi

    stow_pkg yabai "$HOME/.config/yabai" || FAILED=1
    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
        info "Would restart or start yabai service"
    elif _exists yabai; then
        if yabai --restart-service >/dev/null 2>&1; then
            success "yabai service restarted"
        else
            ui_run "Starting yabai at login" yabai --start-service || FAILED=1
        fi
    fi

    if ! _exists skhd; then
        if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
            ui_run "Adding the Asmvik/formulae tap" brew tap asmvik/formulae
            ui_run "Trusting the skhd formula" brew trust --formula asmvik/formulae/skhd
            ui_run "Installing skhd" brew install asmvik/formulae/skhd
        elif ! _exists brew; then
            error "Homebrew is required to install skhd"
            FAILED=1
        else
            ui_run "Adding the Asmvik/formulae tap" brew tap asmvik/formulae || FAILED=1
            ui_run "Trusting the skhd formula" brew trust --formula asmvik/formulae/skhd || FAILED=1
            ui_run "Installing skhd" brew install asmvik/formulae/skhd || FAILED=1
        fi
    else
        skip "skhd already installed"
    fi

    stow_pkg skhd "$HOME/.config/skhd" || FAILED=1
    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
        info "Would reload or start skhd service"
    elif _exists skhd; then
        if skhd --reload >/dev/null 2>&1; then
            success "skhd config reloaded"
        else
            ui_run "Starting skhd at login" skhd --start-service || FAILED=1
        fi
    fi

    SHORTCUT_SHEET_SOURCE="$SCRIPT_DIR/skhd/shortcut_sheet.swift"
    SHORTCUT_SHEET_BIN="$HOME/.local/bin/dotfiles-shortcut-sheet"
    if [ -x "$SHORTCUT_SHEET_BIN" ] && [ "$SHORTCUT_SHEET_BIN" -nt "$SHORTCUT_SHEET_SOURCE" ]; then
        skip "Shortcut sheet is up to date"
    elif [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
        info "Would build the floating shortcut sheet"
    elif ! command -v swiftc >/dev/null 2>&1; then
        error "Swift compiler is required to build the shortcut sheet"
        FAILED=1
    else
        mkdir -p "${SHORTCUT_SHEET_BIN%/*}"
        ui_run "Building the floating shortcut sheet" swiftc -O "$SHORTCUT_SHEET_SOURCE" -o "$SHORTCUT_SHEET_BIN" || FAILED=1
    fi
else
    skip "yabai and skhd (macOS only)"
fi

stow_pkg ghostty "$HOME/.config/ghostty" || FAILED=1

# usage: adopt_into_repo <package> <target-dir> <name>...
# Moves existing real files/dirs from the target into the repo (first run on a
# machine that already has the config) so stow can replace them with symlinks.
adopt_into_repo() {
    local package="$1" target="$2" name
    shift 2
    [ "${DOTFILES_DRY_RUN:-0}" = 1 ] || mkdir -p "$SCRIPT_DIR/$package"
    for name in "$@"; do
        if [ -e "$target/$name" ] && [ ! -L "$target/$name" ] && [ ! -e "$SCRIPT_DIR/$package/$name" ]; then
            if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
                info "Would adopt $target/$name into config/$package"
            else
                info "Adopting $target/$name into config/$package"
                mv "$target/$name" "$SCRIPT_DIR/$package/$name"
            fi
        fi
    done
}

# herdr: only user config is tracked, runtime state (socket, data, icons, mods, ...) is not
HERDR_DIR="$HOME/.config/herdr-app"
HERDR_TRACKED=(settings.json keys.json layouts themes)
adopt_into_repo herdr "$HERDR_DIR" "${HERDR_TRACKED[@]}"
stow_pkg herdr "$HERDR_DIR" || FAILED=1

# obsidian: config lives in each vault's .obsidian dir; workspace*.json is per-device state and not tracked
OBSIDIAN_TRACKED=(app.json appearance.json hotkeys.json core-plugins.json community-plugins.json snippets themes)
OBSIDIAN_VAULT="${OBSIDIAN_VAULT:-}"
if [ -z "$OBSIDIAN_VAULT" ] && [ "${DOTFILES_YES:-0}" != 1 ] && [ -t 0 ]; then
    printf '  %s?%s Path to your Obsidian vault %s[Enter to skip]%s ' "$YELLOW" "$RESET" "$DIM" "$RESET"
    read -r OBSIDIAN_VAULT
fi
OBSIDIAN_VAULT="${OBSIDIAN_VAULT/#\~/$HOME}"
if [ -z "$OBSIDIAN_VAULT" ]; then
    warn "Skipping Obsidian config (set OBSIDIAN_VAULT=/path/to/vault to link it)."
elif [ ! -d "$OBSIDIAN_VAULT" ]; then
    warn "Skipping Obsidian config ($OBSIDIAN_VAULT is not a directory)."
else
    adopt_into_repo obsidian "$OBSIDIAN_VAULT/.obsidian" "${OBSIDIAN_TRACKED[@]}"
    stow_pkg obsidian "$OBSIDIAN_VAULT/.obsidian" "obsidian config" || FAILED=1
fi

if [ "$FAILED" -ne 0 ]; then
    error "Config finished with errors, see $DOTFILES_LOG"
    exit 1
fi
success "config ready"
