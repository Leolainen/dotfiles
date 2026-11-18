#!/usr/bin/env zsh

e='\033'
RESET="${e}[0m"
BOLD="${e}[1m"
CYAN="${e}[0;96m"
RED="${e}[0;91m"
YELLOW="${e}[0;93m"
GREEN="${e}[0;92m"

info() {
  echo -e "${CYAN}${*}${RESET}"
}

ask() {
  printf "${YELLOW}%s${RESET}" "${*}"
}

# Error reporter
error() {
  echo -e "${RED}${*}${RESET}"
}

# Success reporter
success() {
  echo -e "${GREEN}${*}${RESET}"
}

# End section
finish() {
  success "Done!"
  echo
  sleep 1
}

# Sets OS to macos, ubuntu or arch
detect_os() {
  case "$(uname -s)" in
    Darwin)
      OS="macos"
      ;;
    Linux)
      local ids=""
      [[ -r /etc/os-release ]] && ids=$(. /etc/os-release && echo "${ID:-} ${ID_LIKE:-}")
      case " ${ids} " in
        *" arch "*)
          OS="arch"
          ;;
        *" ubuntu "*|*" debian "*)
          OS="ubuntu"
          ;;
        *)
          error "Unsupported Linux distribution (only Ubuntu and Arch are supported)"
          exit 1
          ;;
      esac
      ;;
    *)
      error "Unsupported OS: $(uname -s)"
      exit 1
      ;;
  esac
}

on_start() {
  info "   _   _           _           _  _____  "
  info "  | \ | |         | |         | |/ ____| "
  info "  |  \| | ___   __| | ___     | | (___   "
  info "  | .   |/ _ \ / _  |/ _ \_   | |\___ \  "
  info "  | |\  | (_) | (_| |  __/ |__| |____) | "
  info "  |_| \_|\___/ \__,_|\___|\____/|_____/  "
  info "                                         "
  info "This script will guide you through installing Node.js, nvm, etc."

  echo
  ask "Do you want to proceed with installation? [y/N] " && read -r answer
  echo

  if [[ "${answer}" != "y" ]]; then
    exit 1
  fi
}

install_node() {
  info "Installing Node.js ..."

  if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    success "Node.js is already installed, skipping ..."
    return
  fi

  case "${OS}" in
    macos) brew install node ;;
    ubuntu) sudo apt-get install -y nodejs npm ;;
    arch) sudo pacman -S --needed --noconfirm nodejs npm ;;
  esac

  finish
}

# Handled and lazyloaded by a zsh plugin for faster startup
# install_nvm() {
#   info "Installing Node Version Manager ..."

#   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash

#   finish
# }

configure_npm_init() {
  # Ask required parameters
  info "Configuring npm init ..."

  # Defaults from git config, if set
  local name="$(git config --get user.name)"
  local email="$(git config --get user.email)"
  local website=""
  local NAME EMAIL WEBSITE

  ask "Enter your name: ($name)" && read -r NAME
  ask "Enter your e-mail: ($email)" && read -r EMAIL
  ask "Enter your website: ($website)" && read -r WEBSITE

  # If required parameters are not enterd, set default values
  : ${NAME:="$name"}
  : ${EMAIL:="$email"}
  : ${WEBSITE:="$website"}

  echo "Author name set to: $NAME"
  npm set init.author.name "$NAME"
  echo "Author email set to: $EMAIL"
  npm set init.author.email "$EMAIL"
  echo "Author website set to: $WEBSITE"
  npm set init.author.url "$WEBSITE"
  echo

  finish
}

# Global installs need a user writable npm prefix (e.g. apt/pacman put it in /usr)
fix_npm_permissions() {
  info "Checking npm permissions ..."

  local npm_prefix="$(npm config get prefix)"

  if [[ ! -w "${npm_prefix}" ]]; then
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global"
    info "npm prefix set to ~/.npm-global, make sure ~/.npm-global/bin is in your PATH"
  fi

  finish
}

install_global_packages() {
  info "Installing NPM global packges"

  NPM_PACKAGES=(
    "nodemon"
  )

  npm install -g "${NPM_PACKAGES[@]}"

  # Removes NPM_PACKAGES variable
  unset -v NPM_PACKAGES
}

on_finish() {
  success "Done!"
  success "Node.js was successfully installed!"
  echo
}

on_error() {
  error "Something went wrong!"
  error "Exiting installation ..."
  exit 1
}

trap on_error ERR INT TERM

main() {
  detect_os
  on_start "$*"
  install_node "$*"
  # install_nvm "$*"
  configure_npm_init "$*"
  fix_npm_permissions "$*"
  install_global_packages "$*"
  on_finish "$*"
}

main "$*"
