#!/usr/bin/env bash

install_prereq() {
  info "Brew installing dependencies for LVIM ..."

  LVIM_PREREQ=(
    "neovim"
    "stylua"
    "code-minimap"
    "lazygit"
    "ripgrep"
    "cmake"
  )

  for tool in "${LVIM_PREREQ[@]}"
  do
    brew install "${tool}"
  done

  # lunarvim requires pip - ensure that it is installed
  python3 -m ensurepip

  # install rust package manager – cargo
  curl https://sh.rustup.rs -sSf | sh

  success "Brew installation done!"

  unset -v LVIM_PREREQ
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
  ln -sf "$LVIM_CONFIG/config.lua" "$CONFIG_DIR/lvim/config.lua"

  echo "✓ lvim config & plugins have been linked\\n"
}

install_lvim() {
  echo "Installing LunarVim"
  echo "If you see an EACCES – read https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally"

  install_prereq
  npm_lvim_dependencies

  echo "✓ necessary dependencies have finished installing \\n"
  echo "\\n → Running LunarVim installer "

  # https://www.lunarvim.org/docs/installation  
  LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

  if confirm "Symlink existing configs?"; then
    symlink_files
  fi
}

if confirm "Would you like to install LunarVim?"; then
  install_lvim
fi
