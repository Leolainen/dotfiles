#!/bin/bash

# local signals_exists=$(yabai -m signal --list | jq "any(.[]; .label == 'adjust-window-on-create' or .label == 'adjust-window-on-destroy'"))

# has_horizontal_split=$(yabai -m query --windows --space | jq 'any(.[]; ."split-type" == "horizontal")')
signals_exists=$(yabai -m signal --list | jq 'any(.[]; ."label" == "adjust-window-on-create" or ."label" == "adjust-window-on-destroy")')

if [ $signals_exists == true ]; then
    yabai -m signal --remove adjust-window-on-create
    yabai -m signal --remove adjust-window-on-destroy
    yabai -m space --padding abs:18:12:12:12
else 
    yabai -m signal                                                               \
          --add event=window_created                                              \
          label=adjust-window-on-create                                         \
          action="$HOME/.config/yabai/adjust_window_layout adjust_window_layout"

    yabai -m signal                                                               \
          --add event=window_destroyed                                            \
          label=adjust-window-on-destroy                                        \
          action="$HOME/.config/yabai/adjust_window_layout adjust_window_layout"

    $HOME/.config/yabai/adjust_window_layout adjust_window_layout
fi

# shift + alt - c : yabai -m signal                                                               \
#                         --add event=window_created                                              \
#                         --label adjust-window-on-create                                         \
#                         action="$HOME/.config/yabai/adjust_window_layout adjust_window_layout"  \
#                   yabai -m signal                                                               \
#                         --add event=window_destroyed                                            \
#                         --label adjust-window-on-destroy                                        \
#                         action="$HOME/.config/yabai/adjust_window_layout adjust_window_layout"  \
#                         $HOME/.config/yabai/adjust_window_layout adjust_window_layout           \

