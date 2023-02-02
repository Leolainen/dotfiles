#!/usr/bin/env sh

sketchybar --add item     clock right                          \
           --set clock    icon.font="$FONT:bold:12"              \
                          icon.padding_right=0   \
                          icon.padding_right=0   \
                          background.border_color=$POPUP_BORDER_COLOR   \
                          background.color=$POPUP_BACKGROUND_COLOR      \
                          background.border_width=1                     \
                          background.drawing=on \
                          script="$PLUGIN_DIR/calendar_update.sh" \
                          updates=on                              \
                          update_freq=10

sketchybar --add item     calendar right                          \
           --set calendar icon.font="$FONT:book:12"               \
                          icon.padding_right=0   \
                          icon.padding_right=0   \
                          background.border_color=$POPUP_BORDER_COLOR   \
                          background.color=$POPUP_BACKGROUND_COLOR      \
                          background.border_width=1                     \
                          background.drawing=on \
                          script="$PLUGIN_DIR/calendar_update.sh" \
                          updates=on                              \
                          update_freq=10

