#!/usr/bin/env sh

toggle_mute() {
  # INITIAL_WIDTH=$(sketchybar --query volume | jq ".icon.width")

  # if [ "$INITIAL_WIDTH" -eq "0" ]; then
  #   sketchybar --animate tanh 10 --set volume icon.width=$INFO width=100
  #   sketchybar --animate tanh 10 --set volume_alias label=$INFO
  # else
  #   sketchybar --animate tanh 30 --set volume width=0 icon.width=0
  # fi
  echo "toggle_mute"
  sketchybar --set "$NAME" popup.drawing=off

  MUTED=$(osascript -e 'output muted of (get volume settings)')

  if [ "$MUTED" = "false" ]; then
    osascript -e 'set volume output muted true'
    sketchybar --set "$NAME" icon=婢
  else
    osascript -e 'set volume output muted false'
    sketchybar --set "$NAME" icon=墳
  fi
  exit 0
}

toggle_devices() {
    echo "toggle_devices"
  which SwitchAudioSource >/dev/null || exit 0
  source "$HOME/.config/sketchybar/colors.sh"

  args=(--remove '/volume.device\.*/' --set "$NAME" popup.drawing=toggle)
  COUNTER=0
  CURRENT="$(SwitchAudioSource -t output -c)"

  while IFS= read -r device; do
    COLOR=$GREY_400
    if [ "${device}" = "$CURRENT" ]; then
      COLOR=$TEXT_PRIMARY
    fi
    args+=(--add item volume.device.$COUNTER popup."$NAME" \
           --set volume.device.$COUNTER label="${device}" \
                                        label.color="$COLOR" \
                 click_script="SwitchAudioSource -s \"${device}\" && sketchybar --set /volume.device\.*/ label.color=$GREY_400 --set \$NAME label.color=$TEXT_PRIMARY")
    COUNTER=$((COUNTER+1))
  done <<< "$(SwitchAudioSource -a -t output)"

  sketchybar -m "${args[@]}"
}

if [ "$BUTTON" = "right" ] || [ "$MODIFIER" = "shift" ]; then
  toggle_devices
else
  toggle_mute
fi
