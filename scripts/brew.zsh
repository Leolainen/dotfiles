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
  printf "${YELLOW}%s [y/N]: ${RESET}" "${*}"
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

# Maps a generic name to the package(s) for the current OS.
# Prints nothing when the package is not available through the package manager.
pkg_name() {
  case "${OS}:${1}" in
    ubuntu:fd) echo "fd-find" ;;
    arch:gh) echo "github-cli" ;;
    ubuntu:gh) echo "gh" ;;
    ubuntu:ruby) echo "ruby-full build-essential" ;;
    arch:ruby) echo "ruby base-devel" ;;
    # yarn from apt is not the JS package manager, antidote is cloned instead
    ubuntu:yarn|ubuntu:antidote|arch:antidote) ;;
    # GUI apps: casks on macOS, packages on Linux where they exist
    ubuntu:docker) echo "docker.io" ;;
    arch:docker) echo "docker" ;;
    ubuntu:ghostty) ;;
    arch:ghostty) echo "ghostty" ;;
    ubuntu:vlc|arch:vlc) echo "vlc" ;;
    arch:firefox) echo "firefox" ;;
    ubuntu:firefox) ;;
    ubuntu:obsidian) ;;
    ubuntu:slack|ubuntu:spotify|ubuntu:visual-studio-code) ;;
    ubuntu:google-chrome|ubuntu:opera|ubuntu:microsoft-edge) ;;
    arch:slack|arch:spotify|arch:visual-studio-code) ;;
    arch:google-chrome|arch:opera|arch:microsoft-edge) ;;
    *) echo "${1}" ;;
  esac
}

is_installed() {
  local pkg
  for pkg in ${=1}; do
    case "${OS}" in
      macos) brew list "${pkg}" >/dev/null 2>&1 || return 1 ;;
      ubuntu) dpkg -s "${pkg}" >/dev/null 2>&1 || return 1 ;;
      arch) pacman -Qi "${pkg}" >/dev/null 2>&1 || return 1 ;;
    esac
  done
  return 0
}

# Installs the mapped packages, $2 = "cask" installs a macOS cask
pkg_install() {
  local pkgs
  pkgs="$(pkg_name "$1")"

  if [[ -z "${pkgs}" ]]; then
    info "No ${OS} package for $1, skipping ..."
    return
  fi

  if is_installed "${pkgs}"; then
    info "$1 is already installed, skipping ..."
    return
  fi

  case "${OS}" in
    macos)
      if [[ "$2" == "cask" ]]; then
        brew install --cask "${pkgs}"
      else
        brew install "${pkgs}"
      fi
      ;;
    ubuntu) sudo apt-get install -y ${=pkgs} ;;
    arch) sudo pacman -S --needed --noconfirm ${=pkgs} ;;
  esac
}

on_start() {
  info "                         ____   _____  "
  info "                        / __ \ / ____| "
  info "   _ __ ___   __ _  ___| |  | | (___   "
  info "  | '_ \` _ \ / _\` |/ __| |  | |\___ \  "
  info "  | | | | | | (_| | (__| |__| |____) | "
  info "  |_| |_| |_|\__,_|\___|\____/|_____/  "
  info "                                       "
  info "This script will guide you through installing applications and cli tools (macOS, Ubuntu, Arch)."
  echo "It will not install anything without your direct agreement!"

  echo
  ask "Do you want to proceed with installation?" && read -r answer
  echo

  if [[ "${answer}" != "y" ]]; then
    exit 1
  fi
}

check_updates() {
  case "${OS}" in
    macos)
      info "Updating brew ..."
      brew update

      info "Upgrading apps ..."
      brew upgrade
      ;;
    ubuntu)
      info "Updating apt ..."
      sudo apt-get update
      ;;
    arch)
      info "Updating pacman ..."
      sudo pacman -Syu --noconfirm
      ;;
  esac
}

# $1 = generic package name, $2 = "cask" for macOS casks (mapped packages on Linux)
brew_install() {
  ask "Do you want to install $1?" && read -r answer

  if [[ "${answer}" != 'y' ]]; then
    success "Skipping ..."
    return
  else
    info "Installing $1 ..."
    pkg_install "$1" "$2"
  fi

  finish
}

brew_cask_install() {
  brew_install "$1" cask
}

install_antidote() {
  [[ "${OS}" == "macos" ]] && return

  if [[ -d "${ZDOTDIR:-$HOME}/.antidote" ]]; then
    info "antidote is already installed, skipping ..."
    return
  fi

  ask "Do you want to install antidote (git clone to ~/.antidote)?" && read -r answer

  if [[ "${answer}" != 'y' ]]; then
    success "Skipping ..."
    return
  fi

  git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}/.antidote"

  finish
}

install_cli_tools() {
  info "Installing CLI tools ..."

  CLI_TOOLS=(
    "tree"
    "wget"
    "yarn"
    "fd"
    "gh"
  )

  for tool in "${CLI_TOOLS[@]}"
  do
    brew_install "${tool}"
  done


  success "CLI Tools installed successfully!"

  unset -v CLI_TOOLS
}

install_binaries() {
  info "Installing useful binaries ..."

  BINARIES=(
    "zsh"
    # "zplug"
    "antidote" # fast replacement for zplug
    "git"
    "ruby"    # required for colorls
    "htop"    # monitor CPU, RAM and processes
    # "thefuck" # Corrects misspelled console commands
    # "ncdu"    # find where diskspace went
    "fzf"
    # "git-flow"
    # "ansible" # possibly useful but not used today
  )

  for binary in "${BINARIES[@]}"
  do
    if [[ "${binary}" == "antidote" && "${OS}" != "macos" ]]; then
      install_antidote
    else
      brew_install "${binary}"
    fi
  done

  success "Binaries installed successfully!"

  unset -v BINARIES

  # Special install for colorls as it's Ruby based
  info "Installing colorls ..."

  if [[ "${OS}" == "macos" ]]; then
    gem install colorls
  else
    gem install --user-install colorls
  fi
}

install_apps() {
  info "Installing useful apps ..."

  APPS=(
    # "bankid"
    # "java"
    # "discord"
    # "iterm2"
    # "figma"
    # "postman"
    "docker"
    "ghostty"
    "obsidian"
    "slack"
    "spotify"
    "visual-studio-code"
    "vlc"
  )

  for app in "${APPS[@]}"
  do
    brew_cask_install "${app}"
  done


  success "Apps installed successfully!"

  unset -v APPS

  install_herdr
}

# Herdr is not packaged, it ships its own installer script
install_herdr() {
  if command -v herdr-app >/dev/null 2>&1 || [[ -x "${HOME}/.local/bin/herdr-app" ]]; then
    info "herdr is already installed, skipping ..."
    return
  fi

  ask "Do you want to install herdr?" && read -r answer

  if [[ "${answer}" != 'y' ]]; then
    success "Skipping ..."
    return
  fi

  info "Installing herdr ..."
  curl -fsSL https://releases.herdr.dev/app/install.sh | sh

  finish
}

install_browsers() {
  info "Installing browsers ..."

  BROWSERS=(
    "google-chrome"
    "firefox"
    "opera"
    "microsoft-edge"
  )

  for browser in "${BROWSERS[@]}"
  do
    brew_cask_install "${browser}"
  done


  success "Browsers installed sucessfully!"

  unset -v BROWSERS
}

on_finish() {
  echo
  success "Applications were successfully installed"
  echo
}

on_error() {
  echo
  error "Something went wrong!"
  error "Exiting installation ..."
  echo

  exit 1
}

trap on_error ERR INT TERM

main() {
  detect_os
  on_start "$*"
  check_updates "$*"
  install_cli_tools "$*"
  install_binaries "$*"
  install_apps "$*"
  install_browsers "$*"
  if [[ "${OS}" == "macos" ]]; then
    brew cleanup
  fi
  on_finish "$*"
}

main "$*"
