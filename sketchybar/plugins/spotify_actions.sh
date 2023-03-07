#!/bin/sh

app_name="Spotify"
spotify_exists="off"

update() {
    if pgrep -x "Spotify" > /dev/null; then
        args=()
        
        # ARTIST="$(echo "$INFO" | jq -r .Artist | sed 's/\(.\{14\}\).*/\1.../')"
        # TRACK="$(echo "$INFO" | jq -r .Name | sed 's/\(.\{14\}\).*/\1.../')"
        ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' | sed 's/\(.\{18\}\).*/\1.../')
        TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string' | sed 's/\(.\{16\}\).*/\1.../')
        DURATION=$(osascript -e 'tell application "Spotify" to duration of current track as string')
        PLAYING=$(osascript -e 'tell application "Spotify" to player state as string') 
        POSITION=$(osascript -e 'tell application "Spotify" to player position') 

        label_icon=""
        updates="off"

        if [ $PLAYING = "playing" ]; then
          label_icon=""
          updates="on"
        fi

        TRACK_LENGTH=$(($DURATION / 1000))

        percentage=$(echo "scale=2; $POSITION / $TRACK_LENGTH * 100" | bc | awk '{print int($0)}')

        args+=(--set spotify.anchor     label="阮 $ARTIST – $TRACK $label_icon"   \
               --set spotify.progress   drawing=on                                \
                                        updates="$updates"                        \
                                        update_freq=2                             \
                                        slider.percentage="$percentage"           )

        sketchybar -m "${args[@]}"
    else
        sketchybar --set spotify.progress drawing=off updates=off
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

mouse_entered() {
    sketchybar --animate tanh 8 --set spotify.progress slider.knob.color=0xffcad3f5 
}

mouse_exited() {
    sketchybar --animate tanh 8 --set spotify.progress slider.knob.color=0x00000000 
}

update

case "$SENDER" in
  "mouse.entered"|"mouse.entered.global") mouse_entered 
  ;;
  "mouse.exited"|"mouse.exited.global") mouse_exited
  ;;
  "mouse.clicked") progress_updated
  ;;
  *) update
  ;;
esac

