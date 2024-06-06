# Get the bundle identifier of the currently focused application
app_name=$(osascript -e 'tell application "System Events" to get name of (process 1 whose frontmost is true)')

current_app=(
    "${ITEM_MIXIN[@]}"
    padding_right=$PADDING
    icon.width=0
    label=$app_name
    script="$PLUGIN_DIR/current_app_actions.sh"
)

sketchybar  --add       item            current_app left      \
            --add       event           window_focus          \
            --set       current_app     "${current_app[@]}"   \
            --subscribe current_app     window_focus          \
                                        space_change

