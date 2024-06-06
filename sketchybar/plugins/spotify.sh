#!/usr/bin/env sh

spotify_anchor=(
    padding_right=$PADDING
    padding_left=$PADDING
    script="$PLUGIN_DIR/spotify_actions.sh"
    background.padding_left=0
    label.padding_left=0
    icon.padding_left=0
    icon.font="$ICON_MD"
    label="阮"
    label.drawing=on
    label.font="$LABEL_MD"
    label.padding_right=0
    # y_offset=1
)

spotify_progress=(
    slider.width=50
    script="$PLUGIN_DIR/spotify_actions.sh"
    updates=on
    icon.drawing=off
    label.drawing=off
    padding_left=0
    slider.knob.font="$ICON_MD"
    slider.knob.color="$TRANSPARENT"
    slider.knob.padding_left=-3
    slider.highlight_color=$BORDER
    padding_right=$SPACING
    slider.background.border_color=$BORDER
    slider.background.border_width=1
    slider.background.corner_radius=$BORDER_RADIUS
    # slider.background.corner_radius=0
    slider.background.drawing=on
    slider.background.height=8
    slider.knob="|"
    # slider.knob=""
)

spotify=(
    ${ITEM_MIXIN[@]}
)

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"

sketchybar  --add       event               spotify_change $SPOTIFY_EVENT                 \
            --add       item                spotify.anchor left                           \
            --set       spotify.anchor      "${spotify_anchor[@]}"                        \
                                                                                          \
            --subscribe spotify.anchor      spotify_change                                \
                                            mouse.clicked                                 \
                                            mouse.entered                                 \
                                            mouse.exited                                  \
                                                                                          \
            --add       slider              spotify.progress left                         \
            --set       spotify.progress    "${spotify_progress[@]}"                      \
                                                                                          \
            --subscribe  spotify.progress   mouse.clicked                                 \
                                            mouse.entered                                 \
                                            mouse.exited                                  \
                                                                                          \
            --add       bracket             spotify spotify.anchor                        \
                                                    spotify.progress                      \
            --set       spotify             "${spotify[@]}"
