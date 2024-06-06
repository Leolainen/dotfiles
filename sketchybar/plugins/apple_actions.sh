#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"

hover() {
    MENU_STATE="$(sketchybar --query apple.logo | jq -r .popup.drawing)"
    BORDER_COLOR=$TRANSPARENT

    if [ "$1" = "on" ]; then
        BORDER_COLOR=$BORDER
    fi

    if [ "$MENU_STATE" = "on" ]; then
        BORDER_COLOR=$BORDER_HIGHLIGHT
    fi

    if [ "$NAME" = "apple.logo" ]; then
        sketchybar -m --set apple.logo background.border_color=$BORDER_COLOR # popup.drawing=$1 background.color=$2
    else
        if [ "$SENDER" = "mouse.entered" ]; then
            sketchybar -m --set $NAME background.color=$BACKGROUND_HIGHLIGHT
        else
            sketchybar -m --set $NAME background.color=$TRANSPARENT
        fi
    fi
}

case "$SENDER" in
    "mouse.entered") hover on
    ;;
    "mouse.exited") hover off
    ;;
esac

