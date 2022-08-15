#!/usr/bin/env bash

# get dir of current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1
NVIM_DIR=~/.config/nvim


echo "\\n → Creating Nvim config folder in root directory..."
mkdir -p "$NVIM_DIR"
echo "✓ nvim folder created\\n"
echo " "

echo "\\n → Linking nvim config & plugin files..."
ln -sf $SCRIPT_DIR/* $NVIM_DIR
echo "✓ nvim configs & plugins link finished\\n"

