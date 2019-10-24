#!/usr/bin/env bash

# get dir of current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1

# ln -sf "$SCRIPT_DIR/zsh_env"          ~/.zsh_env
# ln -sf "$SCRIPT_DIR/zsh_keybinds"     ~/.zsh_keybinds
# ln -sf "$SCRIPT_DIR/zsh_functions"    ~/.zsh_functions
# ln -sf "$SCRIPT_DIR/zsh_misc"         ~/.zsh_misc
# ln -sf "$SCRIPT_DIR/zsh_fzf_extra"    ~/.zsh_fzf_extra
ln -sf "$SCRIPT_DIR/zshrc"            ~/.zshrc
ln -sf "$SCRIPT_DIR/zsh_aliases"      ~/.zsh_aliases
ln -sf "$SCRIPT_DIR/zsh_plug"         ~/.zsh_plug
ln -sf "$SCRIPT_DIR/zsh_theme"        ~/.zsh_theme

mkdir -p ~/.zsh_completions
ln -sf "$SCRIPT_DIR/completions/_jq"  ~/.zsh_completions/_jq

[ "$SHELL" =~ "zsh" ] || chsh -s "$(command -v zsh)"