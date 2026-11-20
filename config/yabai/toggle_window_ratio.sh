#!/bin/bash

window=$(yabai -m query --windows --window) || exit 1
floating=$(printf '%s' "$window" | jq -r '."is-floating"')

if [ "$floating" = true ]; then
    yabai -m window --toggle float
    exit
fi

display=$(yabai -m query --displays --display) || exit 1
read -r x y width height < <(printf '%s' "$display" | jq -r '[.frame.x, .frame.y, .frame.w, .frame.h] | @tsv')

# Fit a centered 4:3 window within 80% of the display's usable frame.
width=$(awk -v w="$width" -v h="$height" 'BEGIN {
    w *= 0.8
    h *= 0.8
    if (w / h > 4 / 3) w = h * 4 / 3
    else h = w * 3 / 4
    printf "%d", w
}')
height=$((width * 3 / 4))
x=$(awk -v x="$x" -v w="$width" -v dw="$(printf '%s' "$display" | jq -r '.frame.w')" 'BEGIN { printf "%d", x + (dw - w) / 2 }')
y=$(awk -v y="$y" -v h="$height" -v dh="$(printf '%s' "$display" | jq -r '.frame.h')" 'BEGIN { printf "%d", y + (dh - h) / 2 }')

yabai -m window --toggle float
yabai -m window --move abs:"$x":"$y"
yabai -m window --resize abs:"$width":"$height"
