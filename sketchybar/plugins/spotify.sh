#!/usr/bin/env sh

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"

sketchybar  --add       event               spotify_change $SPOTIFY_EVENT                 \
            --add       item                spotify.anchor left                           \
            --set       spotify.anchor      script="$PLUGIN_DIR/spotify_actions.sh"       \
                                            background.padding_left=0                     \
                                            label.padding_left=0                          \
                                            icon.padding_left=0                           \
                                            icon.font="$FONT:bold:14.0"                   \
                                            label="阮"                                    \
                                            label.drawing=on                              \
                                            label.font="$FONT:book:12.0"                  \
                                            label.padding_right=0                         \
            --subscribe spotify.anchor      spotify_change                                \
                                                                                          \
            --add       slider              spotify.progress left                         \
            --set       spotify.progress    slider.width=50                               \
                                            script="$PLUGIN_DIR/spotify_actions.sh"       \
                                            updates=on                                    \
                                            icon.drawing=off                              \
                                            label.drawing=off                             \
                                            padding_left=0                                \
                                            slider.knob.font="$FONT:book:11.0"            \
                                            slider.knob.color="$TRANSPARENT"              \
                                            slider.highlight_color=$WHITE                 \
                                            slider.background.border_color=$WHITE         \
                                            slider.background.border_width=1              \
                                            slider.background.corner_radius=0             \
                                            slider.background.drawing=on                  \
                                            slider.background.height=6                    \
                                            slider.background.padding_left=0              \
                                            slider.background.padding_right=8             \
                                            slider.knob=""                               \
            --subscribe  spotify.progress   mouse.clicked                                 \
                                            mouse.entered                                 \
                                            mouse.exited                                  \
                                                                                          \
            --add       bracket             spotify spotify.anchor                        \
                                                    spotify.progress                      \
            --set       spotify             background.border_color=$POPUP_BORDER_COLOR   \
                                            background.color=$POPUP_BACKGROUND_COLOR      \
                                            background.border_width=1                     \
                                            background.corner_radius=8                    \
                                            background.drawing=on                         \
                                            background.padding_left=0                     \
                                            background.padding_right=26                   \

