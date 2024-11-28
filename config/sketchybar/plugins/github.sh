#!/usr/bin/env sh

POPUP_CLICK_SCRIPT="sketchybar --set \$NAME popup.drawing=toggle"

github_bell=(
    ${ITEM_MIXIN[@]}
    update_freq=180
    # padding_right=$PADDING
    icon.font="$ICON_SM"
    icon=$LOADING
    # icon=""
    icon.color=$TEXT_PRIMARY
    icon.padding_right=0
    label.padding_right=0
    label.padding_left=0
    # label=$LOADING
    # label.highlight_color=$INFO
    popup.align=center
    script="$PLUGIN_DIR/github_scripts.sh"
    click_script="$POPUP_CLICK_SCRIPT"
)

github_template=(
    drawing=off
    background.drawing=off
    width=325
    background.corner_radius=0
    background.padding_left=4
    background.padding_right=4
    icon.font="$LABEL_SM"
    # label.font="$ICON_SM"
    label.align=right
)

sketchybar --add    item                github.bell right                             \
           --set    github.bell         "${github_bell[@]}"                           \
                                                                                      \
           --subscribe github.bell      mouse.entered                                 \
                                        mouse.exited                                  \
                                        mouse.exited.global                           \
                                                                                      \
           --add       item             github.template popup.github.bell             \
           --set       github.template  "${github_template[@]}"
