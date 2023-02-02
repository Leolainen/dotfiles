#!/usr/bin/env sh

WIDTH=100
SLIDER_NAME=volume_slider

init() {
    VOLUME=$(osascript -e 'output volume of (get volume settings)')
     sketchybar --set $SLIDER_NAME slider.percentage=$VOLUME
}

open_volume_control() {
    sketchybar --animate tanh 30 --set $SLIDER_NAME slider.width=$WIDTH 
    # INITIAL_WIDTH=$(sketchybar --query volume_slider | jq ".slider.width")


    # if [ $INITIAL_WIDTH -eq "0" ]; then
    #
    # INITIAL_WIDTH=$(sketchybar --query volume_slider | jq ".slider.width")
    #     echo "$INITIAL_WIDTH"


    # if [ "$INITIAL_WIDTH" -eq "0" ]; then
    #     echo "it is 0"
    #     sketchybar --animate tanh 30 --set $SLIDER_NAME slider.width=$WIDTH 
    # fi
}

close_volume_control() {
    sketchybar --animate tanh 30 --set $SLIDER_NAME slider.width=0
    # INITIAL_WIDTH=$(sketchybar --query volume_slider | jq ".slider.width")

    #     echo "$INITIAL_WIDTH"

    # if [ "$INITIAL_WIDTH" -gt "0" ]; then
    #     echo "greater than 0"
    #     sketchybar --animate tanh 30 --set $SLIDER_NAME slider.width=0
    # fi
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
  "mouse.entered"|"mouse.entered.global") open_volume_control
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

# volume_change() {
#   INITIAL_WIDTH=$(sketchybar --query volume | jq ".icon.width")

#   if [ "$INITIAL_WIDTH" -eq "0" ]; then
#     sketchybar --animate tanh 10 --set volume icon.width=$INFO width=100
#     sketchybar --animate tanh 10 --set volume_alias label=$INFO
#     sketchybar --animate tanh 10 --set volume.root background.padding_right=100
#   else
#     sketchybar --set volume icon.width=$INFO width=100
#     sketchybar --set volume_alias label=$INFO
#   fi

#   MUTED=$(osascript -e 'output muted of (get volume settings)')

#   if [ "$MUTED" = "true" ]; then
#     sketchybar --set volume_alias icon=婢
#   else
#     sketchybar --set volume_alias icon=墳
#   fi

#   sleep 3
#   FINAL_WIDTH=$(sketchybar --query volume | jq ".icon.width")

#   if [ "$FINAL_WIDTH" -eq "$INFO" ]; then
#     sketchybar --animate tanh 30 --set volume width=0 icon.width=0
#   fi
# }

# case "$SENDER" in
#   "volume_change") volume_change
#   ;;
# esac

