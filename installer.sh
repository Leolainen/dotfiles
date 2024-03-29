#!/usr/bin/env bash

set -e
trap on_error SIGKILL SIGTERM

e='\033'
RESET="${e}[0m"
BOLD="${e}[1m"
CYAN="${e}[0;96m"
RED="${e}[0;91m"
YELLOW="${e}[0;93m"
GREEN="${e}[0;92m"

_exists() {
  command -v $1 > /dev/null 2>&1
}

# Success reporter
info() {
  echo -e "${CYAN}${*}${RESET}"
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

export DOTFILES=${1:-"$HOME/dotfiles"}
GITHUB_REPO_URL_BASE="https://github.com/leolainen/dotfiles"
HOMEBREW_INSTALLER_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
brew="/opt/homebrew/bin/brew"


# get the dir of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || exit 1

on_start() {

  info "   _____   ____ _______ ______ _____ _      ______  _____  "
  info "  |  __ \ / __ \__   __|  ____|_   _| |    |  ____|/ ____| "
  info "  | |  | | |  | | | |  | |__    | | | |    | |__  | (___   "
  info "  | |  | | |  | | | |  |  __|   | | | |    |  __|  \___ \  "
  info "  | |__| | |__| | | |  | |     _| |_| |____| |____ ____) | "
  info "  |_____/ \____/  |_|  |_|    |_____|______|______|_____/  "
  info "                                                           "
  info "       by @Leolainen (Stolen from @Ahmedabdulrahman)       "


  info "This script will guide you through installing essentials for your Mac."
  echo "It will not install anything without your direct agreement!"
  echo
  read -p "Do you want to proceed with installation? [y/N] " -n 1 answer
  echo

  if [[ ${answer} != "y" ]]; then
    exit 1
  fi

}

install_cli_tools() {
  # Install Cli Tools.
  # Note:There's not need to install XCode tools on Linux
  echo
  info "Trying to detect installed Command Line Tools..."

  if ! [ $(xcode-select -p) ]; then
    echo "You don't have Command Line Tools installed!"
    read -p "Do you agree to install Command Line Tools? [y/N] " -n 1 answer
    echo
    if [[ ${answer} != "y" ]]; then
      exit 1
    fi

    info "Installing Command Line Tools..."
    echo "Please, wait until Command Line Tools will be installed, before continue."

    xcode-select --install
  else
    success "You already have Command Line Tools installed, nothing to do here skipping ... 💨"
  fi

  finish
}


install_package_manager() {
  echo
  read -p "Do you agree to proceed with Homebrew installation? [y/N] " -n 1 answer
  echo

  if [[ ${answer} != "y" ]]; then
    info "Exiting installation ..."
    exit 1
  fi

  info "Installing Homebrew ..."
  echo "This may take a while"

  /bin/bash -c "$(curl -fsSL ${HOMEBREW_INSTALLER_URL})"

  # Make sure we’re using the latest Homebrew.
  brew update

  # Upgrade any already-installed formulae.
  brew upgrade

  finish
}

ask_install_package_manager() {
  # macOS
  echo
  info "Checking if Homebrew is installed..."

  # special case "if exists" check for brew
  which -s brew
  if [[ $? != 0 ]] ; then
    echo "Homebrew not found!"
    install_package_manager
  else
    info "Homebrew is already installed"
    echo "Skipping to next step.  ... 💨"
    echo

    return
  fi

  finish
}

install_git() {
  echo
  read -p "Would you like to install Git? [y/N] " -n 1 answer
  echo

  if [[ ${answer} != "y" ]]; then
    exit 1
  fi

  info "Installing Git"

  if [ `uname` == 'Darwin' ]; then
    brew install git
  else
    error "Error: Failed to install Git!"
    error "Your computer is probably not a Mac!"
  fi

  finish
}

ask_install_git() {
  # macOS
  echo
  info "Checking if Git is installed..."

  if ! _exists git; then
    echo "Git not found!"
    install_git
  else
    info "Git is already installed"
    echo "Skipping to next step.  ... 💨"
    echo

    return
  fi

  finish
}

install_pip() {
  info "Checking if Pip is installed..."

  if ! _exists $pip; then
    echo
    read -p "Would you like to install pip? [y/N] " -n 1 answer
    echo

    if [[ ${answer} != "y" ]]; then
      echo "Skipping to next step.  ... 💨"
      echo
      return
    fi

    echo "Fetching get-pip.py file ... "
    echo

    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py

    echo
    echo "Running get-pip.py file ... "
    echo

    python get-pip.py --user
  else
    info "Pip is already installed"
    echo "Skipping to next step.  ... 💨"
    echo

    return
  fi

  finish
}

install_composer() {
  info "Checking if Composer is installed..."

  if ! _exists $composer; then
    echo
    read -p "Would you like to install composer? (Requires Pip) [y/N] " -n 1 answer
    echo

    if ! _exists $pip; then
      error "Pip was not found"
      info "Pip is required to install composer."
      install_pip
    fi

    if [[ ${answer} != "y" ]]; then
      echo "Skipping to next step.  ... 💨"
      echo
      return
    fi

    echo "Fetching get-pip.py file ... "
    echo

    curl -sS https://getcomposer.org/installer | php

    echo
    echo "Running get-pip.py file ... "
    echo

    php composer.phar

    echo
    echo "Symlinking composer.phar ... "

    ln -s ~/Desktop/dotfiles/composer.phar ~/../../usr/local/bin/composer.phar

    echo
  else
    info "Composer is already installed"
    echo "Skipping to next step.  ... 💨"
    echo

    return
  fi

  finish
}

install_zsh() {
  # Install ZSH
  echo
  info "Checking if Zsh is installed ..."

  if ! _exists zsh; then
    echo "Zsh not found!"
    read -p "Would you like to install Zsh? [y/N]" -n 1 answer
    echo

    if [[ ${answer} != "y" ]]; then
      exit 1
    fi

    info "Installing Zsh ..."

    if [ `uname` == "Darwin" ]; then
      brew install zsh
    else
      error "Error: Failed to install Zsh!"
      error "Your computer is probably not a Mac!"
      exit 1
    fi
  else
    success "Zsh is already installed! Skipping installation ..."
  fi

  if _exists zsh; then
    info "Setting up Zsh as default shell..."

    echo "The script will ask you the password for sudo when changing your default shell via chsh -s"
    echo

    chsh -s /bin/zsh || chsh -s "$(command -v zsh)" || error "Error: Cannot set Zsh as default shell!"
    echo "You'll need to log out for this to take effect"
  fi

  finish
}

install_dotfiles() {
  echo
  info "Looking for dotfiles in $DOTFILES ..."

  if [ ! -d $DOTFILES ]; then
    echo "No dotfiles directory was found!"
    read -p "Would you like to install Dotfiles? [y/N] " -n 1 answer
    echo

    if [[ ${answer} != "y" ]]; then
      exit 1
    fi

    echo "Cloning dotfiles ..."
    git clone --recursive "$GITHUB_REPO_URL_BASE.git" $DOTFILES

  else
    success "Dotfiles were found! Skipping ..."
  fi

  dotfiles_selection

  finish
}

dotfiles_selection() {
  echo
  echo "Please select what you want to install: "
  dotfiles=("zsh" "fonts" "config" "lvim")

  PS3='Enter your choice: '
  options=("zsh" "fonts" "config" "lvim" "Install all" "Skip this step" "Exit install")

  select opt in "${options[@]}"
  do
      case $opt in
          "zsh")
              install_selected_dotfile $opt
              ;;
          "fonts")
              install_selected_dotfile $opt
              ;;
          "config")
              install_selected_dotfile $opt
              ;;
          "lvim")
              install_selected_dotfile $opt
              ;;
          "Install all")
              for module in "${dotfiles[@]}"
              do
                install_selected_dotfile ${module}
              done
              break
              ;;
          "Skip this step")
              echo "Skipping dotfiles installation ..."
              return
              ;;
          "Exit install")
              echo "Exiting installation ..."
              exit 1
              ;;
          *) echo "invalid option $REPLY";;
      esac
  done
}

install_selected_dotfile() {
  echo
  info "Installing $1 config ..."

  [[ ! -f "$1/setup.sh" ]] && error "$1 config not found!" && dotfiles_selection
  "$1/setup.sh"            && success "$1 config installed successfully!"
}

bootstrap() {
  read -p "Would you like to bootstrap your environment by installing Homebrew formulae? [y/N] " -n 1 answer
  echo

  if [ ${answer} != "y" ]; then
    return
  fi

  $DOTFILES/scripts/bootstrap.zsh

  finish
}

on_finish() {
  echo
  success "Setup was successfully done!"
  echo
  echo -ne $RED'-_-_-_-_-_-_-_-_-_-_-_-_-_-_'
  echo -e  $RESET$BOLD',------,'$RESET
  echo -ne $YELLOW'-_-_-_-_-_-_-_-_-_-_-_-_-_-_'
  echo -e  $RESET$BOLD'|   /\_/\\'$RESET
  echo -ne $GREEN'-_-_-_-_-_-_-_-_-_-_-_-_-_-'
  echo -e  $RESET$BOLD'~|__( ^ .^)'$RESET
  echo -ne $CYAN'-_-_-_-_-_-_-_-_-_-_-_-_-_-_'
  echo -e  $RESET$BOLD'""  ""'$RESET
  echo
  info "P.S: Don't forget to restart a terminal!"
  echo "Cheers"
  echo
}

on_error() {
  echo
  error "Something went wrong!"
  error "I have no idea what!!"
  echo
  exit 1
}

main() {
  on_start "$*"
  install_cli_tools "$*"
  ask_install_package_manager "$*"
  ask_install_git "$*"
  install_pip "$*"
  install_composer "$*"
  install_zsh "$*"
  install_dotfiles "$*"
  bootstrap "$*"
  on_finish "$*"
}

main "$*"
