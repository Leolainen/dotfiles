#!/usr/bin/env zsh

set -e
trap on_error SIGKILL SIGTERM

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
  printf "${YELLOW}${*}${RESET}"
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
  ask "Do you want to proceed with installation? [y/N] " && read answer
  echo

  if [[ "${answer}" != "y" ]]; then
    exit 1
  fi
}

install_node() {
  info "Installing Node.js ..."

  if [[ "$(uname)" == 'Darwin' ]]; then
    brew install node
  else
    error "You’re not using a Mac! Exiting ..."
    exit 1
  fi

  finish
}

install_nvm() {
  info "Installing Node Version Manager ..."

  if [[ "$(uname)" == 'Darwin' ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash
  else
    error "You’re not using a Mac! Exiting ..."
    exit 1
  fi

  finish
}

configure_npm_init() {
  # Ask required parameters
  info "Configuring npm init ..."

  # Defaults
  local name="Leolainen"
  local email="Leolainen2@gmail.com"
  local website=""

  ask "Enter your name: ($name)" && read NAME
  ask "Enter your e-mail: ($email)" && read EMAIL
  ask "Enter your website: ($website)" && read WEBSITE

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

fix_npm_permissions() {
  # Fixing npm permissions
  info "Fixing npm persmissions ..."

  NPM_PREFIX="$(npm config get prefix)"

  if [ "${NPM_PREFIX}" = '/usr/local' ]; then
    sudo chown -R $(whoami) $(npm config get prefix)/{lib/node_modules,bin,share}
  elif [ ! $NPM_PREFIX = '/usr' ]; then
    [ ! -d ~/.npm-global ] && mkdir ~/.npm-global
    npm config set prefix '~/.npm-global'
  fi

  finish
}

install_global_packages() {
  info "Installing NPM global packges"

  NPM_PACKAGES=(
    "npx"
    "nodemon"
  )

	yarn global add "${NPM_PACKAGES[@]}"

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

main() {
  on_start "$*"
  install_node "$*"
  install_nvm "$*"
  configure_npm_init "$*"
  install_global_packages "$*"
}

main "$*"
