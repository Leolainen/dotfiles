#!/usr/bin/env bash

echo "\\n → Creating Nvim folder in root directory..."
mkdir -p ~/.config/nvim
mkdir -p ~/.config/nvim/lua
mkdir -p ~/.config/nvim/lua/user
mkdir -p ~/.config/nvim/lua/plugins
mkdir -p ~/.config/nvim/lua/plugins/lsp
echo "✓ nvim folder created successfully!\\n"

# get dir of current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1
NVIM_DIR=~/.config/nvim/

echo "\\n → Linking nvim config & plugin files..."
ln -sf "$SCRIPT_DIR/init.lua"         "$NVIM_DIR/init.lua"
ln -sf "$SCRIPT_DIR/lua/user/*"            "$NVIM_DIR/lua/user/"
ln -sf "$SCRIPT_DIR/lua/plugins/*"            "$NVIM_DIR/lua/plugins/"
ln -sf "$SCRIPT_DIR/lua/plugins/lsp/*"            "$NVIM_DIR/lua/plugins/lsp/"
echo "✓ nvim configs & plugins linked successfully!\\n"

