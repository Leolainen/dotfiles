#!/usr/bin/env sh

hover() {
    if [ "$NAME" = "apple.logo" ]; then
        sketchybar --set $NAME popup.drawing=$1 background.color=$2
    else
        sketchybar --set $NAME background.color=$2
    fi
}


handle_hover() {
    echo "handle_hover $SENDER $NAME"
    case "$SENDER" in
        "mouse.entered") hover on $BLACK
        ;;
        "mouse.exited"|"mouse.exited.global") hover off $POPUP_BACKGROUND_COLOR
        ;;
    esac
}


POPUP_OFF="sketchybar --set apple.logo popup.drawing=off"
POPUP_CLICK_SCRIPT="sketchybar --set \$NAME popup.drawing=toggle"
HANDLE_HOVER=${handle_hover}

sketchybar --add item           apple.logo left                             \
           --set apple.logo     icon=$APPLE                                 \
                                icon.font="$FONT:Black:16.0"                \
                                icon.color=$WHITE                           \
                                label.drawing=off                           \
                                click_script="$POPUP_CLICK_SCRIPT"          \
                                script=${HANDLE_HOVER}                 \
                                background.border_color=$POPUP_BORDER_COLOR \
                                background.color=$POPUP_BACKGROUND_COLOR    \
                                background.border_width=1                   \
                                background.corner_radius=8                  \
                                background.drawing=on                       \
           --subscribe  apple.logo  mouse.entered                           \
                                    mouse.exited                            \
                                    mouse.exited.global                     \
                                                                            \
           --add item           apple.prefs popup.apple.logo                \
           --set apple.prefs    icon=$PREFERENCES                           \
                                label="Preferences"                         \
                                click_script="open -a 'System Preferences';
                                              $POPUP_OFF"                   \
                                                                            \
           --add item           apple.activity popup.apple.logo             \
           --set apple.activity icon=$ACTIVITY                              \
                                label="Activity"                            \
                                click_script="open -a 'Activity Monitor';
                                              $POPUP_OFF"\
                                                                            \
           --add item           apple.lock popup.apple.logo                 \
           --set apple.lock     icon=$LOCK                                  \
                                label="Lock Screen"                         \
                                click_script="pmset displaysleepnow;
                                              $POPUP_OFF"

