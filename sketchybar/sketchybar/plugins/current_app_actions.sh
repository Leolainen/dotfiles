
update_app_name() {
    app_name=$(osascript -e 'tell application "System Events" to get name of (process 1 whose frontmost is true)')
    # tab_title=""

    # Can get google chrome tabs, but they're super long!
    # Also must set up some sort of "onTabChange" event
    # if [[ "$app_name" == "Google Chrome" ]]; then
    #     # Get the title of the currently active tab in Chrome
    #     tab_title=$(osascript -e 'tell application "Google Chrome" to get title of active tab of front window')

    #     echo "Currently open tab in Google Chrome: $tab_title"
    # fi

    sketchybar --set current_app label="$app_name" # icon="$tab_title"
}

case "$SENDER" in
    "window_focus" | "space_change") update_app_name
    ;;
esac
