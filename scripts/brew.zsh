#!/usr/bin/env zsh

# Installs CLI tools and apps: Brewfile on macOS, apt/pacman equivalents on Linux.
# Runs standalone or through installer.sh. Honours DOTFILES_YES and DOTFILES_DRY_RUN.

DOTFILES="${DOTFILES:-${0:A:h:h}}"
if [[ -r "${0:A:h}/../lib/ui.sh" ]]; then
  source "${0:A:h}/../lib/ui.sh"
else
  source "${DOTFILES}/lib/ui.sh"
fi

FAILED=()
INSTALLED_COUNT=0
SKIPPED_COUNT=0

# Maps a generic name to the package(s) for the current OS.
# Prints nothing when the package is not available through the package manager.
pkg_name() {
  case "${OS}:${1}" in
    ubuntu:fd) echo "fd-find" ;;
    arch:gh) echo "github-cli" ;;
    ubuntu:ruby) echo "ruby-full build-essential" ;;
    arch:ruby) echo "ruby base-devel" ;;
    arch:awscli) echo "aws-cli" ;;
    ubuntu:timewarrior) echo "timewarrior" ;;
    arch:timewarrior) echo "timew" ;;
    ubuntu:docker) echo "docker.io" ;;
    # yarn from apt is not the JS package manager, antidote is cloned instead
    ubuntu:yarn|ubuntu:antidote|arch:antidote) ;;
    # not packaged for the distro (or only in the AUR)
    ubuntu:lazygit|ubuntu:stylua|ubuntu:watchman|ubuntu:tasksh|ubuntu:aws-vault) ;;
    ubuntu:helm|ubuntu:kubectl|ubuntu:terraform|ubuntu:terragrunt|ubuntu:granted) ;;
    arch:watchman|arch:tasksh|arch:terraform|arch:terragrunt|arch:granted) ;;
    ubuntu:ghostty|ubuntu:firefox|ubuntu:obsidian) ;;
    ubuntu:slack|ubuntu:spotify|ubuntu:visual-studio-code) ;;
    ubuntu:google-chrome|ubuntu:brave-browser) ;;
    arch:obsidian|arch:slack|arch:spotify|arch:visual-studio-code) ;;
    arch:google-chrome|arch:brave-browser) ;;
    *) echo "${1}" ;;
  esac
}

is_installed() {
  local pkg
  for pkg in ${=1}; do
    case "${OS}" in
      ubuntu) dpkg -s "${pkg}" >/dev/null 2>&1 || return 1 ;;
      arch) pacman -Qi "${pkg}" >/dev/null 2>&1 || return 1 ;;
    esac
  done
  return 0
}

# Installs one generic package on Linux, failures are recorded and never abort
pkg_install() {
  local pkgs
  pkgs="$(pkg_name "$1")"

  if [[ -z "${pkgs}" ]]; then
    skip "$1 has no ${OS} package"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    return 0
  fi

  if is_installed "${pkgs}"; then
    skip "$1 is already installed"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    return 0
  fi

  local rc=0
  case "${OS}" in
    ubuntu) ui_run "Installing $1" sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y ${=pkgs} || rc=$? ;;
    arch) ui_run "Installing $1" sudo pacman -S --needed --noconfirm ${=pkgs} || rc=$? ;;
  esac

  if (( rc == 0 )); then
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
  else
    warn "Could not install $1, continuing"
    FAILED+=("$1")
  fi
  return 0
}

install_antidote() {
  [[ "${OS}" == "macos" ]] && return

  if [[ -d "${ZDOTDIR:-$HOME}/.antidote" ]]; then
    skip "antidote is already installed"
    return
  fi

  ui_run "Installing antidote" git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}/.antidote" ||
    FAILED+=("antidote")
}

# Herdr is not packaged, it ships its own installer script
install_herdr() {
  if command -v herdr-app >/dev/null 2>&1 || [[ -x "${HOME}/.local/bin/herdr-app" ]]; then
    skip "herdr is already installed"
    return
  fi

  ask_yn "Install herdr?" y || { skip "herdr"; return; }

  ui_live "Installing herdr" sh -c 'curl -fsSL https://releases.herdr.dev/app/install.sh | sh' ||
    FAILED+=("herdr")
}

# colorls is a Ruby gem, prefer the ruby installed by Homebrew on macOS
install_colorls() {
  local gem_cmd="gem" brew_ruby
  local -a gem_args=()

  if [[ "${OS}" == "macos" ]] && brew_ruby="$(brew --prefix ruby 2>/dev/null)" && [[ -x "${brew_ruby}/bin/gem" ]]; then
    gem_cmd="${brew_ruby}/bin/gem"
  else
    gem_args=(--user-install)
  fi

  if ! command -v "${gem_cmd}" >/dev/null 2>&1; then
    if [[ "${DOTFILES_DRY_RUN:-0}" == 1 ]]; then
      ui_run "Installing colorls" gem install colorls
    else
      warn "ruby is not available, skipping colorls"
      FAILED+=("colorls")
    fi
    return
  fi

  if "${gem_cmd}" list -i '^colorls$' >/dev/null 2>&1; then
    skip "colorls is already installed"
    return
  fi

  ui_run "Installing colorls" "${gem_cmd}" install "${gem_args[@]}" colorls || FAILED+=("colorls")
}

install_macos() {
  if ! _exists brew; then
    error "Homebrew is not installed, run installer.sh first"
    exit 1
  fi

  local -a bundle_env=()

  if ask_yn "Install browsers (Firefox, Chrome, Brave)?" y; then
    :
  else
    bundle_env=(HOMEBREW_BUNDLE_CASK_SKIP="firefox google-chrome brave-browser")
    skip "Browsers"
  fi

  ui_run "Updating Homebrew" brew update || warn "brew update failed, continuing"

  # live output: cask installs may ask for your password
  ui_live "Installing Brewfile packages and apps" \
    env "${bundle_env[@]}" brew bundle --file="${DOTFILES}/Brewfile" ||
    FAILED+=("brew bundle")

  install_colorls
  install_herdr

  ui_run "Cleaning up" brew cleanup || true
}

install_linux() {
  local -a tools=(
    zsh git curl wget tree jq fd ripgrep fzf htop btop ncdu stow gh
    neovim lazygit stylua luarocks watchman pre-commit mkcert
    httpie imagemagick diff-so-fancy yarn antidote ruby
    tasksh timewarrior
    awscli aws-vault helm kubectl terraform terragrunt granted
    docker ghostty obsidian slack spotify visual-studio-code vlc
    firefox google-chrome brave-browser
  )

  info "Skipping yabai, skhd, borders and sketchybar (macOS only)"

  # Only needed when sudo has no cached credentials and a human can type
  if [[ "${DOTFILES_DRY_RUN:-0}" != 1 && -t 0 ]] && ! sudo -n true 2>/dev/null; then
    ui_sudo_keepalive || { error "sudo is required"; exit 1; }
  fi

  case "${OS}" in
    ubuntu) ui_run "Updating apt" sudo apt-get update || warn "apt update failed, continuing" ;;
    arch) ui_run "Updating pacman" sudo pacman -Syu --noconfirm || warn "pacman update failed, continuing" ;;
  esac

  local tool
  for tool in "${tools[@]}"; do
    if [[ "${tool}" == "antidote" ]]; then
      install_antidote
    else
      pkg_install "${tool}"
    fi
  done

  install_colorls
  install_herdr

  info "${INSTALLED_COUNT} installed, ${SKIPPED_COUNT} skipped, ${#FAILED[@]} failed"
}

main() {
  detect_os || exit 1

  ui_step "Packages and apps"

  case "${OS}" in
    macos) install_macos ;;
    *) install_linux ;;
  esac

  if (( ${#FAILED[@]} > 0 )); then
    warn "Failed: ${FAILED[*]} (see ${DOTFILES_LOG})"
  else
    success "Packages and apps are set up"
  fi
}

main
