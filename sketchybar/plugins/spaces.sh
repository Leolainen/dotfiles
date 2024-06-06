#!/bin/bash

# SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7")

CURRENT_SPACES="$(yabai -m query --displays | jq -r '.[].spaces')"

# echo "current spaces $(yabai -m query --spaces)"

# SPACES="$(yabai -m query --spaces)"

    # echo $(echo "$SPACES" | jq -r ".[].windows")

for space_id in $(echo "$CURRENT_SPACES[@]" | jq -r '.[]');
do


    # TODO: Get all apps of a space and map the apps to icons
    # apps=$(yabai -m query --windows --space $space_id | jq -r ".[].app")

    # # echo $apps
    # # echo $(yabai -m query --windows --space $space_id)

    # app_icons=()

    # for app in $apps; do
    #   # Check if the item already exists in the array
    #   if [[ " ${app_icons[@]} " =~ " $app " ]]; then
    #       # Calculate the count of occurrences
    #       count=$(( $(grep -o "$app" <<< "${app_icons[@]}" | wc -l) + 1 ))

    #       # Append "($count) " to the item
    #       app="$app($count)"
    #   fi

    # app_icons+=("$app")
    # done
    #   
    # echo "app_icons ${app_icons[@]}"
# Use jq to filter the space object based on the index and extract the "windows" array
# windows_array=$(echo "$SPACES" | jq -r --arg index "$space_index" '.[] | select(.index | tonumber == $index) | .windows')

# echo $(echo "$SPACES" | jq -r ".[]" | select(.index | tonumber == $space_id))
# Print the windows array for the selected space
# echo "$windows_array"

  space=(
    associated_space=$space_id
    background.height=16
    width=22
    label=$space_id
    label.font="$LABEL_MD"
    label.color=$TEXT_SECONDARY
    label.padding_left=8
    label.padding_right=8
    label.width=20
    label.align=center
    label.highlight_color=$TEXT_PRIMARY
    icon.drawing=off
    # icon=$app_icons
    # icon="1"
    # icon.width=0 # disable later
    # icon.padding_left=0
    # icon.padding_right=0
    background.color=$TRANSPARENT
    background.border_color=$BORDER
    background.border_width=0
    script="$PLUGIN_DIR/space.sh"
  )
  echo "$space_id id"
  echo $CURRENT_SPACES

  sketchybar --add space space."$space_id"  left          \
             --set space."$space_id"        "${space[@]}" \
             --subscribe space.$space_id    mouse.clicked \
                                            mouse.entered \
                                            mouse.exited
done

spaces_bracket=(
    "${ITEM_MIXIN[@]}"
    background.padding_left=2
    background.padding_right=2
)

# necessary due to padding not working in brackets
spaces_margin=(
    icon.drawing=off
    label.drawing=off
    padding_right=$PADDING
)
# separator=(
#   label=+
#   label.font="$FONT:Heavy:16.0"
#   associated_display=active
#   click_script='yabai -m space --create && sketchybar --trigger space_change'
#   label.color=$TEXT_SECONDARY
# )

sketchybar  --add item spaces_margin left               \
            --set spaces_margin "${spaces_margin[@]}"   \
                                                        \
            --add bracket spaces_bracket '/space\..*/'  \
            --set spaces_bracket "${spaces_bracket[@]}" \
           


           #                                             \
           # --add item separator left                   \
           # --set separator "${separator[@]}"
