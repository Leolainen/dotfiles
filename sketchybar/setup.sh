#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || exit 1
# shellcheck source=../lib/ui.sh
. "$SCRIPT_DIR/../lib/ui.sh"

# SketchyBar is macOS only
if [ "$(uname -s)" != "Darwin" ]; then
    skip "SketchyBar is macOS only"
    exit 0
fi
OS=macos
FAILED=0


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

if [ "${DOTFILES_DRY_RUN:-0}" != 1 ] && ! _exists brew; then
    error "Homebrew is required to install SketchyBar"
    exit 1
fi

if brew list --formula sketchybar >/dev/null 2>&1; then
    skip "SketchyBar already installed"
else
    ui_run "Adding the FelixKratz/formulae tap" brew tap FelixKratz/formulae || exit 1
    ui_run "Installing SketchyBar" brew install sketchybar || exit 1
fi

# stow comes from the Brewfile; install it here only when running standalone
if ! _exists stow; then
    ui_run "Installing stow" brew install stow || exit 1
else
    skip "stow already installed"
fi

stow_pkg sketchybar "$HOME/.config/sketchybar" "SketchyBar config" || FAILED=1

# run bar automatically on startup
ui_run "Starting SketchyBar at login" brew services start sketchybar || FAILED=1
info "If the bar misbehaves, see https://felixkratz.github.io/SketchyBar/setup"

if [ "$FAILED" -ne 0 ]; then
    error "SketchyBar finished with errors, see $DOTFILES_LOG"
    exit 1
fi
success "SketchyBar ready"
