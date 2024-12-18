#!/usr/bin/env bash
################################################################################
#  Author: Ahmed Abdulrahman
#  Email: a.kasapbashi@gmail.com
#  Created: 2019-10-12 22:20
################################################################################

# get the dir of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1

echo "Create some required folders...\\n"
mkdir -p $HOME/.config

echo "⏳Symlink .gitconfig, .gitconfig.local, .gitignore files"
stow --restow -vv --target="$HOME" --dir=$SCRIPT_DIR git

# Install Taskwarrior, assumes brew is installed.
echo "⏳Installing Taskwarrior"
brew="/usr/local/bin/brew"

packages=(
    "task"
    "tasksh"
    "timewarrior"
    "stow"
)

for package in "${packages[@]}"
do
    echo "⏳Installing {$package}"
    brew install $package
    echo "---------------------------------------------------------"
done

echo "⏳Symlink .taskrc file"
stow --restow -vv --target="$HOME" --dir=$SCRIPT_DIR taskwarrior

echo "Create timewarrior folder...\\n"
mkdir -p $HOME/.timewarrior

# Currently don't use custom configs
# echo "⏳Symlink timewarrior.cfg file"
# stow --restow -vv --target="$HOME/.timewarrior" --dir=$SCRIPT_DIR timewarrior

# yabai
mkdir -p "$HOME/.config/yabai"
stow --restow -vv --target="$HOME/.config/yabai" --dir=$SCRIPT_DIR yabai

# skhd
mkdir -p "$HOME/.config/skhd"
stow --restow -vv --target="$HOME/.config/skhd" --dir=$SCRIPT_DIR skhd

# sketchybar
mkdir -p "$HOME/.config/sketchybar"
stow --restow -vv --target="$HOME/.config/sketchybar" --dir=$SCRIPT_DIR sketchybar
