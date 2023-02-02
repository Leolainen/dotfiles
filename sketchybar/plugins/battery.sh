#!/usr/bin/env sh
#
sketchybar --add item battery right                             \
           --set battery script="$PLUGIN_DIR/battery_update.sh" \
                         icon.font="$FONT:book:13.0"            \
                         icon.padding_right=0 \
                         label.padding_left=4 \
                         drawing=on                             \
                         update_freq=120                        \
                         updates=on                             \
                         background.border_color=$POPUP_BORDER_COLOR \
                         background.color=$POPUP_BACKGROUND_COLOR    \
                         background.border_width=1                   \
                         background.corner_radius=8                  \
                         background.drawing=on                       \
            --subscribe battery power_source_change system_woke
