#!/usr/bin/env sh
source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"
source "$HOME/.config/sketchybar/tokens.sh"
source "$HOME/.config/sketchybar/mixins.sh"

PR_OPTIONS="--repo=atgse/atgse --author=@me"

update() {
    PLUGIN_DIR="$HOME/.config/sketchybar/plugins" # Directory where all the plugin scripts are stored
    PR_LIST="$(gh pr list $PR_OPTIONS --json number,title,reviews,url,mergeable,mergeStateStatus --jq '.[] | @base64')"
    TOTAL_REVIEWS=0
    OPEN_PULL_REQUESTS="$(gh pr list $PR_OPTIONS --json 'number' --jq 'length')"

    args+=(--remove '/github.pr\.*/')

    for PR in $PR_LIST; do
        _decoded_pr=$(echo "$PR" | base64 --decode)

        NUMBER=$(echo "$_decoded_pr" | jq -r '.number')
        TITLE=$(echo "$_decoded_pr" | jq -r '.title')
        REVIEWS=$(echo "$_decoded_pr" | jq -r '.reviews | length')
        URL=$(echo "$_decoded_pr" | jq -r '.url')

        TOTAL_REVIEWS=$((TOTAL_REVIEWS+REVIEWS))

        if [ "$MERGEABLE" != "MERGEABLE" ] || [ "$MERGESTATESTATUS" != "CLEAN" ]; then
            MERGE_STATUS=""
            MERGEABLE_ICON="×"
            MERGEABLE_COLOR=$ERROR
        else
            MERGEABLE_ICON=√
            MERGEABLE_COLOR=$SUCCESS
        fi

        github_pr=(
            scroll_texts=on
            width=270
            icon="$MERGEABLE_ICON $TITLE"
            icon.color="$MERGEABLE_COLOR"
            icon.align=left
            icon.max_chars=34
            icon.width=234
            icon.padding_left=8
            label.color=$MERGEABLE_COLOR
            label="${REVIEWS:-" "} "
            label.align=left
            label.padding_left=0
            position=popup.github.bell
            click_script="open $URL; sketchybar --set github.bell popup.drawing=off"
            drawing=on
            script="$PLUGIN_DIR/github_scripts.sh"
        )

        args+=(--clone      github.pr.$NUMBER github.template                \
               --set        github.pr.$NUMBER                                \
                           "${github_pr[@]}"                                 \
                --subscribe github.pr.$NUMBER   mouse.entered                \
                                                mouse.exited                 )

    done
    
    REV_REVIES=$(sketchybar --query github.bell | jq -r .label.value)

    # TRANSPARENT_GREY=0xff # 0x30939ab7
    # TRANSPARENT_POPUP_BORDER=0xff908caa # 0xffc4a7e7 # 0xff908caa # 0xff3e8fb0 # 0xff9ccfd8 # 0xffc4a7e7 # 0x70696468
    TRANSPARENT_POPUP_BORDER=$GREY_500 # 0xffc4a7e7 # 0xff908caa # 0xff3e8fb0 # 0xff9ccfd8 # 0xffc4a7e7 # 0x70696468

    args+=(--set    github.bell                                               \
                    icon=" $OPEN_PULL_REQUESTS"                              \
                    icon.padding_right=8                                      \
                    label=" $TOTAL_REVIEWS"                                  \
                    label.padding_left=10                                     \
                    label.padding_right=8                                     \
                    label.background.height=$ITEM_HEIGHT                      \
                    label.background.color=$GREY_300                      \
                    label.background.corner_radius=$BORDER_RADIUS             \
                    label.background.border_width=$BORDER_WIDTH               \
                    label.background.border_color=$TRANSPARENT                \
                )

    sketchybar -m "${args[@]}"
  
    if [ $TOTAL_REVIEWS -gt $PREV_REVIEWS ] 2>/dev/null || [ "$SENDER" = "forced" ]; then
      sketchybar --animate tanh 15 --set github.bell label.y_offset=5 label.y_offset=0
      
      # For sound to play around with:
      afplay /System/Library/Sounds/Funk.aiff
    fi
}

popup() {
    BELL_BORDER_COLOR=$TRANSPARENT
    POPUP_BACKGROUND_COLOR=$TRANSPARENT
    DRAWING_STATE="$(sketchybar --query github.bell | jq -r .popup.drawing)"

    if [ "$1" = "on" ]; then
        BELL_BORDER_COLOR=$BORDER
        POPUP_BACKGROUND_COLOR=$BACKGROUND_HIGHLIGHT
    else
        POPUP_BACKGROUND_COLOR=$TRANSPARENT
    fi

    if [ "$DRAWING_STATE" = "on" ]; then
        BELL_BORDER_COLOR=$BORDER_HIGHLIGHT
    fi

    if [ "$NAME" = "github.bell" ]; then
        sketchybar --set $NAME background.border_color=$BELL_BORDER_COLOR label.background.border_color=$BELL_BORDER_COLOR
    else
        sketchybar --set $NAME background.color=$POPUP_BACKGROUND_COLOR
    fi
}

case "$SENDER" in
    "routine"|"forced") update
    ;;
    "mouse.entered") popup on # $BORDER_HIGHLIGHT
    ;;
    "mouse.exited"|"mouse.exited.global") popup off # $TRANSPARENT
    ;;
    "mouse.clicked") popup toggle
    ;;
esac

