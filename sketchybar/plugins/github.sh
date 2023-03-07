#!/usr/bin/env sh

POPUP_CLICK_SCRIPT="sketchybar --set \$NAME popup.drawing=toggle"

echo "asdasd $PLUGIN_DIR"

sketchybar --add    item                github.bell right                             \
           --set    github.bell         update_freq=180                               \
                                        icon.font="$FONT:bold:12"                     \
                                        icon=""                                      \
                                        icon.color=$WHITE                             \
                                        icon.padding_right=0                          \
                                        label=$LOADING                                \
                                        label.highlight_color=$BLUE                   \
                                        popup.align=center                            \
                                        script="$PLUGIN_DIR/github_scripts.sh"        \
                                        click_script="$POPUP_CLICK_SCRIPT"            \
                                        background.border_color=$POPUP_BORDER_COLOR   \
                                        background.color=$POPUP_BACKGROUND_COLOR      \
                                        background.border_width=1                     \
                                        background.drawing=on                         \
           --subscribe github.bell      mouse.entered                                 \
                                        mouse.exited                                  \
                                        mouse.exited.global                           \
                                                                                      \
           --add       item             github.template popup.github.bell             \
           --set       github.template  drawing=off                                   \
                                        padding_left=0                                \
                                        padding_right=0                               \
                                        background.corner_radius=4                    \
                                        background.drawing=off                        \
                                        icon.font="$FONT:book:11"                     \
                                        label.font="$FONT:book:11"                    \


