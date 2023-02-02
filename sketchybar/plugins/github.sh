#!/usr/bin/env sh

POPUP_CLICK_SCRIPT="sketchybar --set \$NAME popup.drawing=toggle"

sketchybar --add       item            github.bell right                  \
           --set       github.bell     update_freq=180                    \
                                       icon.font="$FONT:Bold:15.0"        \
                                       icon=$BELL                         \
                                       icon.color=$BLUE                   \
                                       label=$LOADING                     \
                                       label.highlight_color=$BLUE        \
                                       popup.align=right                  \
                                       script="$PLUGIN_DIR/github.sh"     \
                                       click_script="$POPUP_CLICK_SCRIPT" \
           --subscribe github.bell     mouse.entered                      \
                                       mouse.exited                       \
                                       mouse.exited.global                \
                                                                          \
           --add       item            github.template popup.github.bell  \
           --set       github.template drawing=off                        \
                                       background.corner_radius=12        \
                                       background.padding_left=7          \
                                       background.padding_right=7         \
                                       background.color=$BLACK            \
                                       background.drawing=off             \
                                       icon.background.height=2           \
                                       icon.background.y_offset=-12

update() {
  source "$HOME/.config/sketchybar/colors.sh"
  source "$HOME/.config/sketchybar/icons.sh"

  NOTIFICATIONS="$(gh api notifications)"
  COUNT="$(echo "$NOTIFICATIONS" | jq 'length')"
  args=()
  if [ "$NOTIFICATIONS" = "[]" ]; then
    args+=(--set $NAME icon=$BELL label="0")
  else
    args+=(--set $NAME icon=$BELL_DOT label="$COUNT")
  fi

  PREV_COUNT=$(sketchybar --query github.bell | jq -r .label.value)
  # For sound to play around with:
  # afplay /System/Library/Sounds/Morse.aiff

  args+=(--remove '/github.notification\.*/')

  COUNTER=0
  COLOR=$BLUE
  args+=(--set github.bell icon.color=$COLOR)

  while read -r repo url type title 
  do
    COUNTER=$((COUNTER + 1))
    IMPORTANT="$(echo "$title" | egrep -i "(deprecat|break|broke)")"
    COLOR=$BLUE
    PADDING=0

    if [ "${repo}" = "" ] && [ "${title}" = "" ]; then
      repo="Note"
      title="No new notifications"
    fi 
    case "${type}" in
      "'Issue'") COLOR=$GREEN; ICON=$GIT_ISSUE; URL="$(gh api "$(echo "${url}" | sed -e "s/^'//" -e "s/'$//")" | jq .html_url)"
      ;;
      "'Discussion'") COLOR=$WHITE; ICON=$GIT_DISCUSSION; URL="https://www.github.com/notifications"
      ;;
      "'PullRequest'") COLOR=$MAGENTA; ICON=$GIT_PULL_REQUEST; URL="$(gh api "$(echo "${url}" | sed -e "s/^'//" -e "s/'$//")" | jq .html_url)"
      ;;
      "'Commit'") COLOR=$WHITE; ICON=$GIT_COMMIT; URL="$(gh api "$(echo "${url}" | sed -e "s/^'//" -e "s/'$//")" | jq .html_url)"
      ;;
    esac
    
    if [ "$IMPORTANT" != "" ]; then
      COLOR=$RED
      ICON=􀁞
      args+=(--set github.bell icon.color=$COLOR)
    fi
    
    args+=(--clone github.notification.$COUNTER github.template \
           --set github.notification.$COUNTER label="$(echo "$title" | sed -e "s/^'//" -e "s/'$//")" \
                                            icon="$ICON $(echo "$repo" | sed -e "s/^'//" -e "s/'$//"):" \
                                            icon.padding_left="$PADDING" \
                                            label.padding_right="$PADDING" \
                                            icon.color=$COLOR \
                                            position=popup.github.bell \
                                            icon.background.color=$COLOR \
                                            drawing=on \
                                            click_script="open $URL;
                                                          sketchybar --set github.bell popup.drawing=off")
  done <<< "$(echo "$NOTIFICATIONS" | jq -r '.[] | [.repository.name, .subject.latest_comment_url, .subject.type, .subject.title] | @sh')"

  sketchybar -m "${args[@]}"

  if [ $COUNT -gt $PREV_COUNT ] 2>/dev/null || [ "$SENDER" = "forced" ]; then
    sketchybar --animate tanh 15 --set github.bell label.y_offset=5 label.y_offset=0
  fi
}

popup() {
  sketchybar --set $NAME popup.drawing=$1
}

case "$SENDER" in
  "routine"|"forced") update
  ;;
  "mouse.entered") popup on
  ;;
  "mouse.exited"|"mouse.exited.global") popup off
  ;;
  "mouse.clicked") popup toggle
  ;;
esac
