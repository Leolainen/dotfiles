#!/usr/bin/env sh
source "$HOME/.config/sketchybar/themes.sh" # Loads all defined colors

# theme_rose_pine
# theme_nordic
# theme_darkearth
theme_dynamic

if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/palette.sh" ]; then
    source "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/palette.sh"
    color_base
    export INFO="$BLUE"
fi
