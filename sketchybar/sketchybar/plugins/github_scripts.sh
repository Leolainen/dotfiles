#!/usr/bin/env sh

# Ensure homebrew and common tool paths are available when run via launchd/brew services
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$HOME/.bun/bin:$PATH"

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"
source "$HOME/.config/sketchybar/tokens.sh"
source "$HOME/.config/sketchybar/mixins.sh"

PR_OPTIONS="--repo=atgse/design-system --repo=atgse/atgse --author=@me"

# gh pr list --repo=atgse/design-system --repo=atgse/atgse --author=@me --state open --json number,title,url,mergeable,mergeStateStatus,comments,reviews --jq '.'

update() {
    PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

    PRS_JSON="$($HOME/.bun/bin/bun $PLUGIN_DIR/github_scripts-parser.js)"
    # PRS_JSON="$(bun $PLUGIN_DIR/github_scripts-parser.js)"

    # Get all open PRs with details
    # PRS_JSON="$(gh pr list $PR_OPTIONS --state open --json number,title,url,mergeable,mergeStateStatus,reviews --jq '.')"
    # PRS_JSON="$(gh pr list $PR_OPTIONS --state open --json number,title,url,mergeable,mergeStateStatus,comments,reviews --jq '.')"
    PR_COUNT=$(echo "$PRS_JSON" | jq 'length')
    TOTAL_COMMENTS=0
    TOTAL_REVIEWS=0

    echo "Found $PR_COUNT open PRs."

    PR_ITEMS=$(sketchybar --query | jq -r '.items[] | select(.name | test("^github\\.pr\\.")) | .name')

    args=()
    if [ -n "$PR_ITEMS" ]; then
        for ITEM in $PR_ITEMS; do
            args+=(--remove "$ITEM")
        done
    fi

    # args=(--remove '/github.pr\..*/')
    if [ "$PR_COUNT" -eq 0 ]; then
        echo "No open PRs found."
        sketchybar -m "${args[@]}"
        return
    fi

    for i in $(seq 0 $((PR_COUNT - 1))); do
        PR="$(echo "$PRS_JSON" | jq ".[$i]")"
        NUMBER=$(echo "$PR" | jq -r '.number')
        TITLE=$(echo "$PR" | jq -r '.title')
        URL=$(echo "$PR" | jq -r '.url')
        MERGEABLE=$(echo "$PR" | jq -r '.mergeable')
        MERGESTATESTATUS=$(echo "$PR" | jq -r '.mergeStateStatus')
        COMMENTS=$(echo "$PR" | jq -r '.comments')
        REVIEWS=$(echo "$PR" | jq -r '.reviews')
        APPROVED=$(echo "$PR" | jq -r '.approved')
        # COMMENTS=$(echo "$PR" | jq -r '.comments.totalCount // 0')
        # REVIEWS=$(echo "$PR" | jq -r '.reviews | length')

        TOTAL_COMMENTS=$((TOTAL_COMMENTS + COMMENTS))
        TOTAL_REVIEWS=$((TOTAL_REVIEWS + REVIEWS))

        # - `√` green — approved and clean, ready to merge
        # - `~` accent — blocked, awaiting approval
        # - `≠` red — conflicting/dirty
        # - `!` warning — unstable (CI failing)
        # - `?` muted — unknown state
        if [ "$APPROVED" = "true" ] && [ "$MERGESTATESTATUS" = "CLEAN" ]; then
            MERGEABLE_ICON="√"
            MERGEABLE_COLOR=$SUCCESS
        elif [ "$MERGESTATESTATUS" = "BLOCKED" ]; then
            MERGEABLE_ICON="~"
            MERGEABLE_COLOR=$INFO
        elif [ "$MERGEABLE" = "CONFLICTING" ]; then
        # elif [ "$MERGESTATESTATUS" = "DIRTY" ] || [ "$MERGEABLE" = "CONFLICTING" ]; then
            MERGEABLE_ICON="≠"
            MERGEABLE_COLOR=$ERROR
        elif [ "$MERGESTATESTATUS" = "UNSTABLE" ]; then
            MERGEABLE_ICON="!"
            MERGEABLE_COLOR=$WARNING
        else
            MERGEABLE_ICON="?"
            MERGEABLE_COLOR=$TEXT_HIGHLIGHT
        fi

        github_pr=(
            scroll_texts=on
            width=300
            icon="$MERGEABLE_ICON $TITLE"
            icon.color="$MERGEABLE_COLOR"
            icon.align=left
            icon.max_chars=34
            icon.width=234
            icon.padding_left=8
            label.color=$MERGEABLE_COLOR
            label=" $COMMENTS |  $REVIEWS"
            label.align=left
            label.padding_left=0
            position=popup.github.bell
            click_script="open $URL; sketchybar --set github.bell popup.drawing=off"
            drawing=on
            script="$PLUGIN_DIR/github_scripts.sh"
        )

        args+=(--clone github.pr.$NUMBER github.template \
               --set github.pr.$NUMBER \
               "${github_pr[@]}" \
               --subscribe github.pr.$NUMBER mouse.entered mouse.exited)
    done

    TRANSPARENT_POPUP_BORDER=$GREY_500

    args+=(--set github.bell \
        icon="$BELL" \
        icon.padding_right=4 \
        label="$PR_COUNT" \
        label.background.height=0 \
        label.background.color=$TRANSPARENT \
        label.background.border_color=$TRANSPARENT \

        # icon=" $PR_COUNT" \
        # icon.padding_right=8 \
        # label=" $TOTAL_COMMENTS |  $TOTAL_REVIEWS" \
        # label.padding_left=10 \
        # label.padding_right=8 \
        # label=" $PR_COUNT" \
        # label.background.height=$ITEM_HEIGHT \
        # label.background.color=$GREY_300 \
        # label.background.corner_radius=$BORDER_RADIUS \
        # label.background.border_width=$BORDER_WIDTH \
        # label.background.border_color=$TRANSPARENT \
    )

    sketchybar -m "${args[@]}"

    # Notification logic (optional)
    # You can persist previous counts to a file if you want to notify only on new PRs/comments
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
        sketchybar --set $NAME background.border_color=$BELL_BORDER_COLOR
    else
        sketchybar --set $NAME background.color=$POPUP_BACKGROUND_COLOR
    fi
    # if [ "$NAME" = "github.bell" ]; then
    #     sketchybar --set $NAME background.border_color=$BELL_BORDER_COLOR label.background.border_color=$BELL_BORDER_COLOR
    # else
    #     sketchybar --set $NAME background.color=$POPUP_BACKGROUND_COLOR
    # fi
}

case "$SENDER" in
    "routine"|"forced") update ;;
    "mouse.entered") popup on ;;
    "mouse.exited"|"mouse.exited.global") popup off ;;
    "mouse.clicked") popup toggle ;;
esac
