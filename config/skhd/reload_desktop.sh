#!/bin/bash
# Called by skhd on macOS. Its launch environment may omit Homebrew.
export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"
config_dir=$(cd "$(dirname "$0")/.." && pwd) || exit 1
failed=0

run() {
    "$@" || { echo "Failed: $*" >&2; failed=1; }
}

refresh_panel() {
    local name="$1" source="$2" bin="$HOME/.local/bin/$1" tmp
    if [ ! -x "$bin" ] || [ "$source" -nt "$bin" ]; then
        mkdir -p "${bin%/*}" || return 1
        tmp=$(mktemp "${bin}.XXXXXX") || return 1
        if ! swiftc -O "$source" -o "$tmp" || ! mv -f "$tmp" "$bin"; then
            rm -f "$tmp"
            return 1
        fi
    fi
    if pgrep -u "$UID" -f "/${name}$" >/dev/null; then
        pkill -TERM -u "$UID" -f "/${name}$" || return 1
        "$bin" </dev/null >/dev/null 2>&1 &
    fi
}

run yabai --restart-service
run sketchybar --reload
if pgrep -u "$UID" -ix ghostty >/dev/null; then
    run osascript -e 'tell application "Ghostty" to perform action "reload_config" on terminal 1' \
        -e 'if result is not true then error "Ghostty declined the reload"'
fi
run refresh_panel dotfiles-shortcut-sheet "$config_dir/skhd/shortcut_sheet.swift"
run refresh_panel dotfiles-theme-picker "$config_dir/theme-picker/theme_picker.swift"
run skhd --reload
exit "$failed"
