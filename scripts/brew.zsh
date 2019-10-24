#!usr/bin/env zsh

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
  printf "${YELLOW}${*} [y/N]: ${RESET}"
}

error() {
  echo -e "${RED}${*}${RESET}"
}

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
  if [ $(uname) != 'Darwin' ]; then
    exit 1
  fi

  info "                         ____   _____  "
  info "                        / __ \ / ____| "
  info "   _ __ ___   __ _  ___| |  | | (___   "
  info "  | '_ ` _ \ / _` |/ __| |  | |\___ \  "
  info "  | | | | | | (_| | (__| |__| |____) | "
  info "  |_| |_| |_|\__,_|\___|\____/|_____/  "
  info "                                       "
  info "This script will guide you through installing macOS applications and cli tools."
  echo "It will not install anything without your direct agreement!"

  echo
  ask "Do you want to proceed with installation?" && read answer
  echo

  if [[ "${answer}" != "y" ]]; then
    exit 1
  fi
}

check_updates() {
  info "Updating brew ..."
  brew update

  info "Upgrading apps ..."
  brew upgrade
}

brew_install() {
  ask "Do you want to install $(info $1)?" && read answer

  if [ ${answer} != 'y' ]; then
    success "Skipping ..."
    return
  else
    info "Installing $1 ..."
    brew install $1
  fi

  finish
}

brew_cask_install() {
  ask "Do you want to install $(info $1)?" && read answer

  if [ ${answer} != 'y' ]; then
    success "Skipping ..."
    return
  else
    info "Installing $1 with cask ..."
    brew cask install $1
  fi

  finish
}

install_cli_tools() {
  info "Installing CLI tools ..."

  CLI_TOOLS=(
    "tree"
    "wget"
    "yarn"
    "fd"  
  )

  brew_install "${CLI_TOOLS[@]}"

  success "CLI Tools installed successfully!"

  unset -v CLI_TOOLS
}

install_binaries() {
  info "Intalling useful binaries ..."

  BINARIES=(
    "zsh"
    "zplug"
    "git"
    "ruby"
    "htop"    # monitor CPU, RAM and processes
    "thefuck" # Corrects misspelled console commands
    "ncdu"    # find where diskspace went
  )

  brew_install "${BINARIES[@]}"

  success "Binaries installed successfully!"

  unset -v BINARIES

  # Special install for colorls as it's Ruby based
  info "Installing colorls ..."

  gem install colorls
}

intall_apps() {
  info "Installing useful apps ..."

  APPS=(
    "java"
    "slack"
    "discord"
    "iterm2"
    "visual-studio-code"
    "sequel-pro"
    "docker"
    "figma"
    "zeplin"
    "virtualbox"
    "vagrant"
    "vlc"
    "dashlane"
    "spotify"
    "postman"
  )

  brew_cask_install "${APPS[@]}"

  success "Apps installed successfully!"

  unset -v APPS
}

install_browsers() {
  info "Installing browsers ..."

  BROWSERS=(
    "google-chrome"
    "firefox"
    "firefox-developer-edition"
    "opera"
    "microsoft-edge-canary"
  )

  brew_install cask "${BROWSERS[@]}"

  success "Browsers installed sucessfully!"

  unset -v BROWSERS
}

on_finish() {
  echo
  success "macOS applications were successfully installed"
  echo
}

on_error() {
  echo
  error "Something went wrong!"
  error "Exiting installation ..."
  echo

  exit 1
}

main() {
  on_start "$*"
  check_updates "$*"
  install_cli_tools "$*"
  install_binaries "$*"
  intall_apps "$*"
  install_browsers "$*"
  brew cleanup "$*"
  on_finish "$*"
}

main "$*"