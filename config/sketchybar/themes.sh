
# surface: 100
# overlay: 200
# highlight_med: 300
# muted: 400
# subtle: 500
theme_rose_pine() {
    # base tokens
    export SPACING=8
    export ITEM_HEIGHT=20
    export BAR_HEIGHT=32
    export BORDER_WIDTH=2
    export BORDER_RADIUS=11
    export FONT="LiterationMono Nerd Font" # Needs to have Regular, Bold, Semibold, Heavy and Black variants
    export PADDING=12 # All paddings use this value (icon, label, background)
    export LABEL_SM="$FONT:book:10.0"
    export LABEL_MD="$FONT:book:12.0"
    export LABEL_LG="$FONT:book:14.0"
    export ICON_SM="$FONT:bold:12.0"
    export ICON_MD="$FONT:bold:14.0"
    export ICON_LG="$FONT:bold:16.0"
    export BLUR=0

    # color tokens
    # base: 0xff232136
    export BLACK=0xff181926
    export WHITE=0xffe0def4
    export RED=0xffeb6f92
    export GREEN=0xff9ccfd8
    export BLUE=0xff3e8fb0
    export YELLOW=0xfff6c177
    export ORANGE=0xffea9a97
    export MAGENTA=0xffc4a7e7
    export GREY_50=0xff232136
    export GREY_100=0xff2a273f
    export GREY_200=0xff393552
    export GREY_300=0xff44415a
    export GREY_400=0xff6e6a86
    export GREY_500=0xff908caa
    export TRANSPARENT=0x00000000

    # semantic colors
    export TEXT_PRIMARY=$WHITE
    export TEXT_SECONDARY=$GREY_500
    export TEXT_HIGHLIGHT=$MAGENTA
    export ERROR=$RED
    export SUCCESS=$GREEN
    export INFO=$BLUE
    export WARNING=$ORANGE
    export ACCENT=$YELLOW
    export BACKGROUND=$GREY_100
    export BACKGROUND_HIGHLIGHT=$GREY_200
    export BORDER=$GREY_500
    export BORDER_HIGHLIGHT=$MAGENTA
    export CANVAS=$GREY_50
}

theme_nordic() {
    # base tokens
    export SPACING=8
    export ITEM_HEIGHT=20
    export BAR_HEIGHT=32
    export BORDER_WIDTH=1
    export BORDER_RADIUS=11
    export FONT="LiterationMono Nerd Font" # Needs to have Regular, Bold, Semibold, Heavy and Black variants
    export PADDING=12 # All paddings use this value (icon, label, background)
    export LABEL_SM="$FONT:book:10.0"
    export LABEL_MD="$FONT:book:12.0"
    export LABEL_LG="$FONT:book:14.0"
    export ICON_SM="$FONT:bold:12.0"
    export ICON_MD="$FONT:bold:14.0"
    export ICON_LG="$FONT:bold:16.0"
    export BLUR=15

    # color tokens
    export BLACK=0xff2e3440
    export WHITE=0xffeceff4
    export RED=0xffbf616a
    export GREEN=0xff8fbcbb
    export BLUE_100=0xff81a1c1
    export BLUE_200=0xff5e81ac
    export YELLOW=0xffebcb8b
    export ORANGE=0xffd08770
    export MAGENTA=0xffb48ead
    export GREY_100=0xff3b4252
    export GREY_200=0xff3B414D
    export GREY_300=0xff434c5e
    export GREY_400=0xff4c566a
    export GREY_500=0xffd8dee9
    # export GREY_500=0xff8fbcbb
    export TRANSPARENT=0x00000000

    # semantic colors
    export TEXT_PRIMARY=$WHITE
    export TEXT_SECONDARY=$GREY_400
    export TEXT_HIGHLIGHT=$BLUE_100
    export ERROR=$RED
    export SUCCESS=$GREEN
    export INFO=$BLUE_200
    export WARNING=$ORANGE
    export ACCENT=$YELLOW
    export CANVAS=0xCC232136
    # export BACKGROUND=$GREEN
    export BACKGROUND=0xD93b4252
    # export BACKGROUND_HIGHLIGHT=$BLUE_200
    export BACKGROUND_HIGHLIGHT=0x80434c5e
    export BORDER=0x80908caa
    export BORDER_HIGHLIGHT=$BLUE_200
}
    # # dark_black = '#2e3440', -- bg
    # black = '#3b4252',
    # bright_black = '#434c5e',
    # gray = '#4c566a',

    # -- Custom
    # darkish_black = '#3B414D',
    # grayish = '#667084',
    # dark_black_alt = '#2B303B',

    # -- Snow Storm
    # dark_white = '#d8dee9',
    # # white = '#e5e9f0',
    # # bright_white = '#eceff4',

    # -- Frost
    # cyan = '#8fbcbb', -- classes, types and primitives.
    # bright_cyan = '#88c0d0', -- declarations, calls and execution statements of functions, methods and routines.
    # blue = '#81a1c1', -- keywords, support characters, operators, tags, units, punctuations
    # intense_blue = '#5e81ac', -- pragmas, comment keywords and pre-processor statements.

    # # -- Aurora
    # # red = '#bf616a', -- deletions and errors
    # # orange = '#d08770', -- annotations and decorators
    # # yellow = '#ebcb8b', -- modifications, warning and escape characters
    # # green = '#a3be8c', -- additions and string
    # # purple = '#b48ead', -- integers and floating point numbers

# Background Color: #24211E
# Foreground Color: #D7C484
# Selection Color: #5F865F
# Ansi 4 (Blue): #B36B42 (main orange)
# Ansi 5 (Magenta): #BB7844 (light orange)
# Ansi 6 (Cyan): #C9A654 (yellow)
# Ansi 7 (White): #D7C484 (foreground)
# Ansi 8 (Bright Black): #675642 (darker brown)
theme_darkearth() {
    # base tokens
    export SPACING=8
    export ITEM_HEIGHT=20
    export BAR_HEIGHT=32
    # export BORDER_WIDTH=1
    # export BORDER_RADIUS=11
    export BORDER_WIDTH=4
    export BORDER_RADIUS=0
    export FONT="ProggyCleanSZ Nerd Font Mono"
    export ICON_FONT="LiterationMono Nerd Font" # Separate font for icons
    export LABEL_SM="$FONT:regular:18.0"
    export LABEL_MD="$FONT:regular:20.0"
    export LABEL_LG="$FONT:regular:22.0"
    export ICON_SM="$ICON_FONT:book:12.0"
    export ICON_MD="$ICON_FONT:book:14.0"
    export ICON_LG="$ICON_FONT:book:16.0"
    # export FONT="BigBlueTermPlus Nerd Font Mono" 
    # export LABEL_SM="$FONT:regular:12.0"
    # export LABEL_MD="$FONT:regular:14.0"
    # export LABEL_LG="$FONT:regular:16.0"
    # export ICON_SM="$FONT:regular:12.0"
    # export ICON_MD="$FONT:regular:14.0"
    # export ICON_LG="$FONT:regular:16.0"
    # export FONT="FixedsysModernV05 NFM"
    export PADDING=12 # All paddings use this value (icon, label, background)
    export BLUR=0

    # color tokens
    export BLACK=0xff24211E
    export WHITE=0xffD7C484
    export RED=0xffAC987D
    export GREEN=0xff5F865F
    export YELLOW=0xffC9A654
    export ORANGE=0xffB36B42
    export MAGENTA=0xffBB7844
    # export GREY_500=0xff8fbcbb
    export TRANSPARENT=0x00000000


    # semantic colors
    export TEXT_PRIMARY=0xffD7C484 # 0xffB36B42 # 0xffD7C484 # 0xffB36B42
    export TEXT_SECONDARY=0xffB36B42 # 0xff5F865F
    export TEXT_HIGHLIGHT=0xff5F865F
    export ERROR=$RED
    export SUCCESS=$GREEN
    export INFO=$MAGENTA
    export WARNING=$ORANGE
    export ACCENT=$YELLOW
    export CANVAS=0xff24211E
    # export BACKGROUND=$GREEN
    export BACKGROUND=0xff675642 #0xff24211E
    export BACKGROUND_HIGHLIGHT=0xff24211E # 0xffD7C484
    export BORDER=0xff675642
    export BORDER_HIGHLIGHT=0xff675642
}

# Export the functions
export -f theme_rose_pine
export -f theme_nordic
export -f theme_darkearth
