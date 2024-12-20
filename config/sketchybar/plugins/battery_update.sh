source "$HOME/.config/sketchybar/colors.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ $PERCENTAGE = "" ]; then
  exit 0
fi

COLOR=$TEXT_PRIMARY

case ${PERCENTAGE} in
  9[0-9]|100) ICON=󰁹; 
  ;;
  8[0-9]|100) ICON=󰂂;
  ;;
  7[0-9]|100) ICON=󰂁; 
  ;;
  6[0-9]|100) ICON=󰂀; 
  ;;
  5[0-9]|100) ICON=󰁿; 
  ;;
  4[0-9]|100) ICON=󰁽; 
  ;;
  3[0-9]|100) ICON=󰁼; COLOR=$WARNING
  ;;
  2[0-9]|100) ICON=󰁻; COLOR=$WARNING
  ;;
  1[0-9]|100) ICON=󰁺; COLOR=$ERROR
  ;;
  *) ICON=󰁺; COLOR=$ERROR
esac

if [[ $CHARGING != "" ]]; then
    charging_icons=(      )
    number_of_icons=${#charging_icons[@]}
    counter=0

    while [[ $PERCENTAGE -lt 99 && $NAME = "AC" ]]; do
        ICON="${charging_icons[counter % number_of_icons]}"

        counter=$(( counter + 1 ))

        sketchybar --set $NAME icon="$ICON" icon.color=$COLOR icon.padding_left=4 label="$PERCENTAGE%" drawing=on
        sleep 0.5
    done

    ICON=
fi

sketchybar --set $NAME icon="$ICON" icon.color=$COLOR icon.padding_left=4 label="$PERCENTAGE%" drawing=on
