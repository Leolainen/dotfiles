#!/usr/bin/env sh
POPUP_OFF="sketchybar --set apple.logo popup.drawing=off"
# POPUP_CLICK_SCRIPT="sketchybar --set apple.logo popup.drawing=toggle"
POPUP_CLICK_SCRIPT="sketchybar --set \$NAME popup.drawing=toggle"

apple_logo=(
    padding_right=$PADDING
    icon="$APPLE"
    icon.font="$ICON_LG"
    label.drawing=off
    popup.align=left
    script="$PLUGIN_DIR/apple_actions.sh"
    click_script="$POPUP_CLICK_SCRIPT"
)

menu_template=(
    width=175
    drawing=off
    background.drawing=off
    background.corner_radius=0
    background.padding_left=3
    background.padding_right=2
    label.padding_left=0
    script="$PLUGIN_DIR/apple_actions.sh"       
)

menu_item=(
    drawing=on
    background.drawing=on
    position=popup.apple.logo
)

interactions=(
    mouse.entered
    mouse.exited
)

sketchybar --add        item            apple.logo left                             \
           --set        apple.logo      "${apple_logo[@]}"                          \
           --subscribe  apple.logo      "${interactions[@]}"                        \
                                                                                    \
           --add        item            apple.template popup.apple.logo             \
           --set        apple.template  "${menu_template[@]}"                       \
                                                                                    \
           --clone      apple.prefs     apple.template                              \
           --set        apple.prefs     "${menu_item[@]}"                           \
                                        icon="$PREFERENCES"                         \
                                        label="Preferences"                         \
                                        click_script="open -a 'System Preferences';
                                                      $POPUP_OFF"                   \
           --subscribe  apple.prefs     "${interactions[@]}"                        \
                                                                                    \
           --clone      apple.activity  apple.template                              \
           --set        apple.activity  "${menu_item[@]}"                           \
                                        icon="$ACTIVITY"                            \
                                        label="Activity"                            \
                                        click_script="open -a 'Activity Monitor';
                                                      $POPUP_OFF"                   \
           --subscribe  apple.activity  "${interactions[@]}"                        \
                                                                                    \
           --clone      apple.lock  apple.template                                  \
           --set        apple.lock  "${menu_item[@]}"                               \
                                        icon="$LOCK"                                \
                                        label="Lock Screen"                         \
                                        click_script="pmset displaysleepnow;
                                                      $POPUP_OFF"                   \
           --subscribe  apple.lock  "${interactions[@]}"
