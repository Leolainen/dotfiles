#!/usr/bin/env sh

clock=(
    "${ITEM_MIXIN[@]}"
    icon.font="$LABEL_MD"
    padding_left=$PADDING
    label.drawing=off
    script="$PLUGIN_DIR/calendar_update.sh"
    updates=on
    update_freq=10 
)

calendar=(
    "${ITEM_MIXIN[@]}"
    icon.font="$LABEL_MD"
    label.drawing=off
    padding_left=$PADDING
    script="$PLUGIN_DIR/calendar_update.sh"
    updates=on
    update_freq=10
)

sketchybar --add item     clock right                          \
           --set clock    "${clock[@]}"

sketchybar --add item     calendar right                          \
           --set calendar "${calendar[@]}"
