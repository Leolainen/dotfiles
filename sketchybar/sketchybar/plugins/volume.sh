#!/usr/bin/env sh

WIDTH=100

volume_amount=(
    icon.drawing=off
    label="$(osascript -e 'output volume of (get volume settings)')"
    label.width=32
    label.align=center
    label.padding_left=$SPACING
)

volume_slider=(
    script="$PLUGIN_DIR/volume_change.sh"
    updates=on
    icon.drawing=off
    label.drawing=off
    padding_left=0
    padding_right=0
    slider.highlight_color=$TEXT_PRIMARY
    slider.background.padding_left=0
    slider.background.height=5
    slider.background.color=$TRANSPARENT
    slider.background.border_color=$BORDER
    slider.background.border_width=1
    slider.knob=
)

volume_alias=(
    label.drawing=off
    icon=墳
    icon.padding_right=$SPACING
    alias.color=$TEXT_PRIMARY
    background.padding_right=0
    background.padding_left=0
    click_script="$PLUGIN_DIR/volume_click.sh"
)

volume=(
    "${ITEM_MIXIN[@]}"
    script="$PLUGIN_DIR/volume_change.sh"
)

sketchybar  --add item  volume_amount   right                                         \
            --set volume_amount         "${volume_amount[@]}"                         \
                                                                                      \
            --add   slider volume_slider right                                        \
            --set   volume_slider       "${volume_slider[@]}"                         \
                                                                                      \
           --subscribe  volume_slider   volume_change                                 \
                                        mouse.clicked                                 \
                                                                                      \
           --add alias "Control Center,Sound" right                                   \
           --rename "Control Center,Sound" volume_alias                               \
           --set volume_alias           "${volume_alias[@]}"                          \
                                                                                      \
            --add   bracket     volume  volume_slider                                 \
                                        volume_amount                                 \
                                        volume_alias                                  \
            --set   volume              "${volume[@]}"
