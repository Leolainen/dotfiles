#!/usr/bin/env bash

set -e

e='\033'
RESET="${e}[0m"
BOLD="${e}[1m"
CYAN="${e}[0;96m"
RED="${e}[0;91m"
YELLOW="${e}[0;93m"
GREEN="${e}[0;92m"

_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Sets OS to macos, ubuntu or arch
detect_os() {
    case "$(uname -s)" in
    Darwin)
        OS="macos"
        ;;
    Linux)
        local ids=""
        [ -r /etc/os-release ] && ids=$(. /etc/os-release && echo "${ID:-} ${ID_LIKE:-}")
        case " ${ids} " in
        *" arch "*)
            OS="arch"
            ;;
        *" ubuntu "* | *" debian "*)
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

# Package names are identical on macOS (brew), Ubuntu (apt) and Arch (pacman)
# for everything installed here (git, zsh).
pkg_install() {
    case "$OS" in
    macos) brew install "$@" ;;
    ubuntu) sudo apt-get install -y "$@" ;;
    arch) sudo pacman -S --needed --noconfirm "$@" ;;
    esac
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

GITHUB_REPO_URL_BASE="https://github.com/leolainen/dotfiles"
HOMEBREW_INSTALLER_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

# get the dir of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || exit 1

if [ -n "$1" ]; then
    export DOTFILES="$1"
elif [ -f "$SCRIPT_DIR/zsh/setup.sh" ]; then
    export DOTFILES="$SCRIPT_DIR"
else
    export DOTFILES="$HOME/dotfiles"
fi

on_start() {

    info "   _____   ____ _______ ______ _____ _      ______  _____  "
    info "  |  __ \ / __ \__   __|  ____|_   _| |    |  ____|/ ____| "
    info "  | |  | | |  | | | |  | |__    | | | |    | |__  | (___   "
    info "  | |  | | |  | | | |  |  __|   | | | |    |  __|  \___ \  "
    info "  | |__| | |__| | | |  | |     _| |_| |____| |____ ____) | "
    info "  |_____/ \____/  |_|  |_|    |_____|______|______|_____/  "
    info "                                                           "
    info "       by @Leolainen (Stolen from @Ahmedabdulrahman)       "

    info "This script will guide you through installing essentials for macOS, Ubuntu or Arch Linux."
    echo "It will not install anything without your direct agreement!"
    echo
    read -r -p "Do you want to proceed with installation? [y/N] " -n 1 answer
    echo

    if [[ "${answer}" != "y" ]]; then
        exit 1
    fi

}

install_cli_tools() {
    # Install Cli Tools.
    echo

    if [[ "$OS" != "macos" ]]; then
        info "No Command Line Tools needed on $OS, skipping ... 💨"
        return
    fi

    info "Trying to detect installed Command Line Tools..."

    if ! xcode-select -p >/dev/null 2>&1; then
        echo "You don't have Command Line Tools installed!"
        read -r -p "Do you agree to install Command Line Tools? [y/N] " -n 1 answer
        echo
        if [[ "${answer}" != "y" ]]; then
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
    read -r -p "Do you agree to proceed with Homebrew installation? [y/N] " -n 1 answer
    echo

    if [[ "${answer}" != "y" ]]; then
        info "Exiting installation ..."
        exit 1
    fi

    info "Installing Homebrew ..."
    echo "This may take a while"

    /bin/bash -c "$(curl -fsSL "${HOMEBREW_INSTALLER_URL}")"

    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    # Make sure we’re using the latest Homebrew.
    brew update

    # Upgrade any already-installed formulae.
    brew upgrade

    finish
}

ask_install_package_manager() {
    echo

    if [[ "$OS" == "ubuntu" ]]; then
        info "Using apt as package manager"
        read -r -p "Would you like to update the apt package index? [y/N] " -n 1 answer
        echo
        if [[ "${answer}" == "y" ]]; then
            sudo apt-get update
        fi
        return
    elif [[ "$OS" == "arch" ]]; then
        info "Using pacman as package manager"
        read -r -p "Would you like to update the system (pacman -Syu)? [y/N] " -n 1 answer
        echo
        if [[ "${answer}" == "y" ]]; then
            sudo pacman -Syu --noconfirm
        fi
        return
    fi

    info "Checking if Homebrew is installed..."

    if ! _exists brew; then
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
    read -r -p "Would you like to install Git? [y/N] " -n 1 answer
    echo

    if [[ "${answer}" != "y" ]]; then
        exit 1
    fi

    info "Installing Git"

    pkg_install git

    finish
}

ask_install_git() {
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

install_zsh() {
    # Install ZSH
    echo
    info "Checking if Zsh is installed ..."

    if ! _exists zsh; then
        echo "Zsh not found!"
        read -r -p "Would you like to install Zsh? [y/N] " -n 1 answer
        echo

        if [[ "${answer}" != "y" ]]; then
            exit 1
        fi

        info "Installing Zsh ..."

        pkg_install zsh
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

    if [ ! -d "$DOTFILES" ]; then
        echo "No dotfiles directory was found!"
        read -r -p "Would you like to install Dotfiles? [y/N] " -n 1 answer
        echo

        if [[ "${answer}" != "y" ]]; then
            exit 1
        fi

        echo "Cloning dotfiles ..."
        git clone --recursive "$GITHUB_REPO_URL_BASE.git" "$DOTFILES"

    else
        success "Dotfiles were found! Skipping ..."
    fi

    dotfiles_selection

    finish
}

dotfiles_selection() {
    echo
    echo "Please select what you want to install: "
    dotfiles=("zsh" "fonts" "config" "nvim")
    [[ "$OS" == "macos" ]] && dotfiles+=("sketchybar")

    PS3='Enter your choice: '
    options=("${dotfiles[@]}" "Install all" "Skip this step" "Exit install")

    select opt in "${options[@]}"; do
        case $opt in
        "zsh" | "fonts" | "config" | "nvim" | "sketchybar")
            install_selected_dotfile "$opt"
            ;;
        "Install all")
            for module in "${dotfiles[@]}"; do
                install_selected_dotfile "${module}"
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
        *) echo "invalid option $REPLY" ;;
        esac
    done
}

install_selected_dotfile() {
    echo
    info "Installing $1 config ..."

    if [[ ! -f "$DOTFILES/$1/setup.sh" ]]; then
        error "$1 config not found!"
        return 0
    fi

    bash "$DOTFILES/$1/setup.sh" && success "$1 config installed successfully!"
}

bootstrap() {
    read -r -p "Would you like to bootstrap your environment by installing packages and tools? [y/N] " -n 1 answer
    echo

    if [[ "${answer}" != "y" ]]; then
        return
    fi

    zsh "$DOTFILES/scripts/bootstrap.zsh"

    finish
}

on_finish() {
    echo
    success "Setup was successfully done!"
    echo
    echo -ne $RED'-_-_-_-_-_-_-_-_-_-_-_-_-_-_'
    echo -e $RESET$BOLD',------,'$RESET
    echo -ne $YELLOW'-_-_-_-_-_-_-_-_-_-_-_-_-_-_'
    echo -e $RESET$BOLD'|   /\_/\\'$RESET
    echo -ne $GREEN'-_-_-_-_-_-_-_-_-_-_-_-_-_-'
    echo -e $RESET$BOLD'~|__( ^ .^)'$RESET
    echo -ne $CYAN'-_-_-_-_-_-_-_-_-_-_-_-_-_-_'
    echo -e $RESET$BOLD'""  ""'$RESET
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

trap on_error ERR SIGINT SIGTERM

main() {
    detect_os
    on_start "$*"
    install_cli_tools "$*"
    ask_install_package_manager "$*"
    ask_install_git "$*"
    install_zsh "$*"
    install_dotfiles "$*"
    bootstrap "$*"
    on_finish "$*"
}

main "$*"
