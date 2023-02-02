#!/usr/bin/env sh

WIDTH=100

sketchybar  --add item  volume_amount   right                                         \
            --set volume_amount         icon.drawing=off                              \
                                        padding_left=0                                \
                                        padding_right=0                               \
                                        label="$(osascript -e 'output volume of (get volume settings)')"\
                                        label.padding_left=6                          \
                                                                                      \
            --add   slider volume_slider right                                        \
            --set   volume_slider       script="$PLUGIN_DIR/volume_change.sh"         \
                                        updates=on                                    \
                                        icon.drawing=off                              \
                                        label.drawing=off                             \
                                        padding_left=0                                \
                                        padding_right=0                               \
                                        slider.highlight_color=$WHITE                 \
                                        slider.background.padding_left=0              \
                                        slider.background.height=5                    \
                                        slider.background.color=$TRANSPARENT          \
                                        slider.background.border_color=$WHITE         \
                                        slider.background.border_width=1              \
                                        slider.knob=                                 \
           --subscribe  volume_slider   volume_change                                 \
                                        mouse.clicked                                 \
                                                                                      \
           --add alias "Control Center,Sound" right                                   \
           --rename "Control Center,Sound" volume_alias                               \
           --set volume_alias           label.drawing=on                              \
                                        icon=墳                                       \
                                        icon.padding_right=0                          \
                                        alias.color=$WHITE                            \
                                        padding_left=0                                \
                                        padding_right=0                               \
                                        background.padding_right=0                    \
                                        background.padding_left=0                     \
                                        click_script="$PLUGIN_DIR/volume_click.sh"    \
                                                                                      \
            --add   bracket     volume  volume_slider                                 \
                                        volume_amount                                 \
                                        volume_alias                                  \
            --set   volume              background.border_color=$POPUP_BORDER_COLOR   \
                                        background.color=$POPUP_BACKGROUND_COLOR      \
                                        background.border_width=1                     \
                                        background.corner_radius=8                    \
                                        background.drawing=on                         \
                                        script="$PLUGIN_DIR/volume_change.sh"         \
           --subscribe  volume          mouse.entered.global                                 \
                                        mouse.exited.global                                  \
