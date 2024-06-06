#!/bin/sh

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/tokens.sh"

app_name="Spotify"
spotify_exists="off"

player_state() {
    echo "$(osascript -e 'tell application "Spotify" to player state as string')" 
}

update() {
    if pgrep -x "Spotify" > /dev/null; then
        args=()
        
        # ARTIST="$(echo "$INFO" | jq -r .Artist | sed 's/\(.\{14\}\).*/\1.../')"
        # TRACK="$(echo "$INFO" | jq -r .Name | sed 's/\(.\{14\}\).*/\1.../')"
        # ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' | sed 's/\(.\{18\}\).*/\1.../')
        # TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string' | sed 's/\(.\{16\}\).*/\1.../')
        ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string')
        TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string')
        DURATION=$(osascript -e 'tell application "Spotify" to duration of current track as string')
        PLAYING=$(osascript -e 'tell application "Spotify" to player state as string') 
        POSITION=$(osascript -e 'tell application "Spotify" to player position') 

        # label_icon=""
        updates="off"
        border_color=$TRANSPARENT
        text_color=$TEXT_SECONDARY
        scroll_texts=off

        if [ $PLAYING = "playing" ]; then
          # label_icon=""
          updates="on"
          border_color=$BORDER_HIGHLIGHT
          text_color=$TEXT_PRIMARY
          scroll_texts=on
        fi

        TRACK_LENGTH=$(($DURATION / 1000))

        percentage=$(echo "scale=2; $POSITION / $TRACK_LENGTH * 100" | bc | awk '{print int($0)}')

        args+=(--animate tahn 8
               --set spotify.anchor     icon="阮"                                     \
                                        icon.padding_left=8                           \
                                        icon.padding_right=4                          \
                                        icon.color=$text_color                        \
                                        label="$ARTIST – $TRACK"                      \
                                        label.color="$text_color"                     \
                                        label.max_chars=20                            \
                                        scroll_texts=$scroll_texts                    \
                                        label.scroll_duration=200                     \
               --set spotify            background.border_color="$border_color"       \
               --set spotify.progress   drawing=on                                    \
                                        updates="$updates"                            \
                                        update_freq=2                                 \
                                        slider.highlight_color="$text_color"          \
                                        slider.background.border_color="$text_color"  \
                                        slider.knob.color="$text_color"               \
                                        slider.percentage="$percentage"               )

        sketchybar -m "${args[@]}"
    else
        sketchybar --set spotify.progress drawing=off updates=off
    fi
}

handle_click() {
    if [ "$NAME" = "spotify.progress" ]; then
        progress_updated
    else
        echo "$NAME"
    fi
}

progress_updated()
{
        DURATION=$(osascript -e 'tell application "Spotify" to duration of current track')

        percent=$(echo "scale=2; $PERCENTAGE / 100" | bc)
        duration_in_seconds=$((DURATION / 1000))
        position_in_seconds=$(echo "$percent * $duration_in_seconds" | bc)
        position_as_int=$(printf "%.0f" $position_in_seconds)

        osascript -e "tell application \"Spotify\" to set player position to $position_as_int"

        sketchybar --set spotify.progress slider.percentage="${PERCENTAGE}" 
}

# Doesn't feel very nice
# mouse_entered() {
#     args=()

#     # args+=(--animate tanh 8)

#     if [ "$NAME" = "spotify.progress" ]; then
#         args+=(--set spotify.progress   slider.highlight_color=$BORDER_HIGHLIGHT          \
#                                         slider.background.border_color=$BORDER_HIGHLIGHT  \
#                                         slider.knob.color=$BORDER_HIGHLIGHT               )
#     fi

#     sketchybar -m "${args[@]}"
# }

# mouse_exited() {
#     args=()

#     # args+=(--animate tanh 3)

#     if [ "$NAME" = "spotify.progress" ]; then
#         args+=(--set spotify.progress   slider.highlight_color=$BORDER          \
#                                         slider.background.border_color=$BORDER  \
#                                         slider.knob.color=$BORDER               )
#     fi

#     sketchybar -m "${args[@]}"
# }

update

case "$SENDER" in
  "mouse.entered") mouse_entered 
  ;;
  "mouse.exited") mouse_exited
  ;;
  "mouse.clicked") handle_click
  ;;
  *) update
  ;;
esac
