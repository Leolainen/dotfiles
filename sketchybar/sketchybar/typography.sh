typography_smooth() {
    export FONT="LiterationMono Nerd Font"      # Needs to have Regular, Bold, Semibold, Heavy and Black variants
    export ICON_FONT="LiterationMono Nerd Font" # Separate font for icons

    export LABEL_SM="$FONT:book:10.0"
    export LABEL_MD="$FONT:book:12.0"
    export LABEL_LG="$FONT:book:14.0"
    export ICON_SM="$ICON_FONT:book:12.0"
    export ICON_MD="$ICON_FONT:book:14.0"
    export ICON_LG="$ICON_FONT:book:16.0"
}

typography_pixel() {
    # Separate font for icons
    export ICON_FONT="LiterationMono Nerd Font"
    export FONT="Departure Mono"

    export LABEL_SM="$FONT:regular:10.0"
    export LABEL_MD="$FONT:regular:12.0"
    export LABEL_LG="$FONT:regular:14.0"
    export ICON_SM="$ICON_FONT:book:12.0"
    export ICON_MD="$ICON_FONT:book:14.0"
    export ICON_LG="$ICON_FONT:book:16.0"
}

export -f typography_smooth
export -f typography_pixel
