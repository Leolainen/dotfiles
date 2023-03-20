#!/usr/bin/env sh
source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

update() {
    PLUGIN_DIR="$HOME/.config/sketchybar/plugins" # Directory where all the plugin scripts are stored


    PR_LIST="$(gh pr list --repo=atgse/atgse --author=@me --json number,title,reviews,url,mergeable,mergeStateStatus)"
    TOTAL_REVIEWS=0
    OPEN_PULL_REQUESTS=$(echo "$PR_LIST" | jq -r "length")

    args+=(--remove '/github.pr\.*/')

    for PR in $(echo "$PR_LIST" | jq -r '.[] | @base64'); do
        _jq() {
          echo ${PR} | base64 --decode | jq -r ${1}
        }

        NUMBER=$(_jq '.number')
        TITLE=$(_jq '.title')
        REVIEWS=$(_jq '.reviews' | jq 'length')
        URL=$(_jq '.url')
        MERGEABLE=$(_jq '.mergeable')
        MERGESTATESTATUS=$(_jq '.mergeStateStatus')

        TOTAL_REVIEWS=$((TOTAL_REVIEWS+REVIEWS))

        if [ "$MERGEABLE" != "MERGEABLE" ] || [ "$MERGESTATESTATUS" != "CLEAN" ]; then
            MERGE_STATUS=""

            if [ "$MERGEABLE" != "MERGEABLE" ]; then
                MERGE_STATUS+=" $MERGEABLE"
            fi

            if [ "$MERGESTATESTATUS" != "CLEAN" ]; then
                MERGE_STATUS+=" $MERGESTATESTATUS"
            fi

              MERGEABLE_ICON="×$MERGE_STATUS |"
              MERGEABLE_COLOR=$RED
        else
          MERGEABLE_ICON=√
          MERGEABLE_COLOR=$GREEN
        fi

        args+=(--clone      github.pr.$NUMBER github.template                \
               --set        github.pr.$NUMBER                                \
                            icon="$MERGEABLE_ICON $TITLE"                    \
                            icon.color="$MERGEABLE_COLOR"                    \
                            label.color=$MERGEABLE_COLOR                     \
                            label=" $REVIEWS"                               \
                            position=popup.github.bell                       \
                            click_script="open $URL;
                                            sketchybar --set github.bell popup.drawing=off" \
                            drawing=on                                       \
                            script="$PLUGIN_DIR/github_scripts.sh"           \
                --subscribe github.pr.$NUMBER   mouse.entered                \
                                                mouse.exited                 )

    done
    
    PREV_REVIEWS=$(sketchybar --query github.bell | jq -r .label.value)

    TRANSPARENT_GREY=0x30939ab7
    TRANSPARENT_POPUP_BORDER=0x70696468

    args+=(--set    github.bell                                               \
                    icon=" $OPEN_PULL_REQUESTS"                              \
                    icon.padding_right=8                                      \
                    label=" $TOTAL_REVIEWS"                                  \
                    label.padding_left=6                                      \
                    label.background.border_width=1                           \
                    label.background.border_color=$TRANSPARENT_POPUP_BORDER   \
                    label.background.height=24                                \
                    label.background.color=$TRANSPARENT_GREY                  \
                    label.background.corner_radius=8                          )

    sketchybar -m "${args[@]}"
  
    if [ $TOTAL_REVIEWS -gt $PREV_REVIEWS ] 2>/dev/null || [ "$SENDER" = "forced" ]; then
      sketchybar --animate tanh 15 --set github.bell label.y_offset=5 label.y_offset=0
      
      # For sound to play around with:
      afplay /System/Library/Sounds/Funk.aiff
    fi
}

popup() {
    if [ "$NAME" = "github.bell" ]; then
        sketchybar --set $NAME popup.drawing=$1 background.color=$2
    else
        sketchybar --set $NAME  background.color=$2
    fi
}

case "$SENDER" in
    "routine"|"forced") update
    ;;
    "mouse.entered") popup on $POPUP_BACKGROUND_COLOR_HIGHLIGHT
    ;;
    "mouse.exited"|"mouse.exited.global") popup off $POPUP_BACKGROUND_COLOR
    ;;
    "mouse.clicked") popup toggle
    ;;
esac

