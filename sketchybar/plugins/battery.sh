#!/usr/bin/env sh

battery=(
    "${ITEM_MIXIN[@]}"
    padding_left=$PADDING
    script="$PLUGIN_DIR/battery_update.sh"
    icon.width=24
    icon.align=left
    label.width=32
    label.padding_left=4
    label.align=center
    update_freq=120
    updates=on
)

sketchybar --add item battery right                             \
           --set battery "${battery[@]}"                        \
            --subscribe battery power_source_change system_woke
