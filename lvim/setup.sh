#!/usr/bin/env bash

# get dir of current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1

CONFIG_DIR=${XDG_CONFIG_HOME:=$HOME/.config}
LVIM_CONFIG=${SCRIPT_DIR:=/lvim}

echo $LVIM_CONFIG
echo $CONFIG_DIR

# echo "✓ lvim folder created\\n"
# echo " "

echo "\\n → Linking lvim config & plugin files..."

ln -sf $LVIM_CONFIG $XDG_CONFIG_HOME

echo "✓ lvim configs & plugins link finished\\n"

