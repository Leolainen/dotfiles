#!/usr/bin/env sh

WIDTH=100
SLIDER_NAME=volume_slider

init() {
    VOLUME=$(osascript -e 'output volume of (get volume settings)')
     sketchybar --set $SLIDER_NAME slider.percentage=$VOLUME
}

open_volume_control() {
    echo "$NAME $INFO"
    INITIAL_WIDTH=$(sketchybar --query volume_slider | jq -r ".slider.width")

    if [ "$INITIAL_WIDTH" -eq "0" ]; then
        sketchybar --animate tanh 30 --set $SLIDER_NAME slider.width=$WIDTH 
    fi
}

close_volume_control() {
    INITIAL_WIDTH=$(sketchybar --query volume_slider | jq -r ".slider.width")
    
    if [[ $INITIAL_WIDTH -gt "0" ]]; then
        sketchybar --animate tanh 30 --set $SLIDER_NAME slider.width=0
    fi
}

volume_change() {
  open_volume_control
  sketchybar --set $SLIDER_NAME slider.percentage=$INFO \
             --set volume_amount label=$INFO

  MUTED=$(osascript -e 'output muted of (get volume settings)')

  if [ "$MUTED" = "true" ]; then
    sketchybar --set volume_alias icon=婢
  else
    sketchybar --set volume_alias icon=墳
  fi

  sleep 3

  # Check wether the volume was changed another time while sleeping
  FINAL_PERCENTAGE=$(sketchybar --query $SLIDER_NAME | jq -r ".slider.percentage")
  if [ "$FINAL_PERCENTAGE" -eq "$INFO" ]; then
      close_volume_control
  fi
}

mouse_clicked() {
  osascript -e "set volume output volume $PERCENTAGE"
}

case "$SENDER" in
  "mouse.entered") open_volume_control
  ;;
  "mouse.exited"|"mouse.exited.global") close_volume_control
  ;;
  "volume_change") volume_change
  ;;
  "mouse.clicked") mouse_clicked
  ;;
  "forced") init
  ;;
esac


