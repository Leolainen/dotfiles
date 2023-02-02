#!/usr/bin/env bash

symlink_files() {
  echo "\\n → Linking sketchbar config & plugin files..."
  # get dir of current script
  SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1

  CONFIG_DIR=${XDG_CONFIG_HOME:=$HOME/.config}
  SKETCHYBAR_CONFIG=${SCRIPT_DIR:=/sketchybar}

  ln -sf "$SKETCHYBAR_CONFIG/sketchybarrc"  "$CONFIG_DIR/sketchybar/sketchybarrc"
  ln -sf "$SKETCHYBAR_CONFIG/icons.sh"      "$CONFIG_DIR/sketchybar/icons.sh"
  ln -sf "$SKETCHYBAR_CONFIG/colors.sh"     "$CONFIG_DIR/sketchybar/colors.sh"

  for file in $SKETCHYBAR_CONFIG/plugins/*; do
    ln -sf "$file" "$CONFIG_DIR/sketchybar/plugins/"
  done

  echo "✓ Sketchybar config & plugins have been linked\\n"
}

install_sketchybar() {
  echo "Installing SketchBar"
  echo "If problems; read how to setup here –> https://felixkratz.github.io/SketchyBar/setup"

  info "Installing SketchyBar ..."

  brew tap FelixKratz/formulae
  brew install sketchybar

  echo "✓ SketchyBar has finished installing \\n"

  read -p "Symlink existing configs?? [y/N]" -n 1 answer
  echo

  if [ ${answer} == "y" ]; then
    symlink_files
  fi

  # run bar automatically on startup
  echo "Starting sketchybar"
  brew services start sketchybar
}

read -p "Would you like to install SketchyBar? [y/N]" -n 1 answer
echo

if [ ${answer} == "y" ]; then
  install_sketchybar
fi

