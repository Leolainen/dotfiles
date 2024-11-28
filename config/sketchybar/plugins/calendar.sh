#!/usr/bin/env sh

clock=(
    icon.padding_right=4
    label.padding_left=4
    padding_left=$PADDING
    script="$PLUGIN_DIR/calendar_update.sh"
    updates=on
    update_freq=10 
)

calendar=(
    icon.padding_right=4
    label.padding_left=4
    padding_left=$PADDING
    script="$PLUGIN_DIR/calendar_update.sh"
    updates=on
    update_freq=10
)

sketchybar --add item     clock right                          \
           --set clock    "${clock[@]}"

sketchybar --add item     calendar right                          \
           --set calendar "${calendar[@]}"
