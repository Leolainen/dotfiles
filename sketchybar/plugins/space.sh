#!/bin/bash

# !/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh"

update() {
    if [ "$SELECTED" = "true" ]; then
      sketchybar -m $NAME label.highlight=on background.color=$HIGHLIGHT_MED
    else
      sketchybar -m $NAME label.highlight=off background.color=$TRANSPARENT
    fi
}

mouse_entered() {
  # sketchybar -m --set $NAME label.highlight=on
  sketchybar -m --set $NAME background.color=$HIGHLIGHT_MED \
                # --set spaces_bracket background.border_color=$BORDER_HIGHLIGHT
}

mouse_exited() {
  # sketchybar -m --set $NAME label.highlight=off                 \
  sketchybar -m --set $NAME background.color=$TRANSPARENT       \
                # --set spaces_bracket background.border_color=$TRANSPARENT
}

mouse_clicked() {
    # yabai -m config mouse_follows_focus off
    yabai -m space --focus $SID 2>/dev/null
    # sleep 1
    # yabai -m config mouse_follows_focus on
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  "mouse.entered") mouse_entered
  ;;
  "mouse.exited"|"mouse.exited.global") mouse_exited
  ;;
  *) update 
  ;;
esac

# WIDTH="0"
# BG_COLOR=$TRANSPARENT

# if [ "$SELECTED" = "true" ]; then
    # WIDTH=4
    # BG_COLOR=$IRIS
    # WIDTH="dynamic"
# fi

sketchybar --animate tanh 10 --set $NAME label.highlight=$SELECTED # label.padding_right=$WIDTH label.padding_left=$WIDTH # background.color=$BG_COLOR # label.padding_left=$WIDTH label.padding_right=$WIDTH # label.border_width=$WIDTH  # label.width=$WIDTH
