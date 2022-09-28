#!/usr/bin/env bash

brew_lvim_dependencies() {
  info "Brew installing dependencies for LVIM ..."

  LVIM_TOOLS=(
    "neovim"
    "stylua"
    "code-minimap"
    "lazygit"
    "ripgrep"
  )

  for tool in "${LVIM_TOOLS[@]}"
  do
    brew install "${tool}"
  done


  success "Brew installation done!"

  unset -v LVIM_TOOLS
}

npm_lvim_dependencies() {
  info "NPM installing dependencies for LVIM ..."

  NVM_DEPENDENCIES=(
    "eslint"
    "typescript"
    "typescript-language-server"
    "prettier"
  )

	yarn global add "${NVM_DEPENDENCIES[@]}"

  success "NPM installation done!"

  # Removes NVM_DEPENDENCIES variable
  unset -v NVM_DEPENDENCIES
}

symlink_files() {
  # get dir of current script
  SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1

  CONFIG_DIR=${XDG_CONFIG_HOME:=$HOME/.config}
  LVIM_CONFIG=${SCRIPT_DIR:=/lvim}

  echo "\\n → Linking lvim config & plugin files..."

  # ln -sf $LVIM_CONFIG $XDG_CONFIG_HOME
  ln -sf "$LVIM_CONFIG/config.lua"                            "$CONFIG_DIR/lvim/config.lua"
  ln -sf "$LVIM_CONFIG/lua/plugins/toggleterm.lua"            "$CONFIG_DIR/lua/plugins/toggleterm.lua"
  ln -sf "$LVIM_CONFIG/lua/plugins/vim-visual-multi.lua"      "$CONFIG_DIR/lua/plugins/vim-visual-multi.lua"

  echo "✓ lvim config & plugins have been linked\\n"
}

install_lvim() {
  brew_lvim_dependencies
  npm_lvim_dependencies

  echo "✓ necessary dependencies have finished installing \\n"
  echo "\\n → Running LunarVim installer "

  # https://github.com/LunarVim/LunarVim
  bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) 

  if confirm "Symlink existing configs?"; then
    symlink_files
  fi
}

if confirm "Would you like to install LunarVim's and all dependencies?"; then
  install_lvim
fi
