#!/usr/bin/env zsh

# Installs Node.js and npm, configures npm init and global packages.
# Runs standalone or through installer.sh. Honours DOTFILES_YES and DOTFILES_DRY_RUN.

DOTFILES="${DOTFILES:-${0:A:h:h}}"
if [[ -r "${0:A:h}/../lib/ui.sh" ]]; then
  source "${0:A:h}/../lib/ui.sh"
else
  source "${DOTFILES}/lib/ui.sh"
fi

install_node() {
  if _exists node && _exists npm; then
    skip "Node.js is already installed"
    return 0
  fi

  case "${OS}" in
    macos) ui_run "Installing Node.js" brew install node ;;
    ubuntu) ui_run "Installing Node.js" sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs npm ;;
    arch) ui_run "Installing Node.js" sudo pacman -S --needed --noconfirm nodejs npm ;;
  esac
}

# Handled and lazyloaded by a zsh plugin for faster startup
# install_nvm() {
#   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash
# }

configure_npm_init() {
  # Defaults from git config, if set
  local name="$(git config --get user.name)"
  local email="$(git config --get user.email)"
  local website=""

  if [[ -n "${name}" && -n "${email}" ]] && ask_yn "Use ${name} <${email}> for npm init?" y; then
    :
  elif [[ "${DOTFILES_YES:-0}" != 1 && -t 0 ]]; then
    local input
    printf '  %s?%s Name %s[%s]%s: ' "${YELLOW}" "${RESET}" "${DIM}" "${name}" "${RESET}"
    read -r input; name="${input:-${name}}"
    printf '  %s?%s E-mail %s[%s]%s: ' "${YELLOW}" "${RESET}" "${DIM}" "${email}" "${RESET}"
    read -r input; email="${input:-${email}}"
    printf '  %s?%s Website %s[%s]%s: ' "${YELLOW}" "${RESET}" "${DIM}" "${website}" "${RESET}"
    read -r input; website="${input:-${website}}"
  fi

  if [[ -z "${name}${email}${website}" ]]; then
    skip "npm init defaults (no author details)"
    return 0
  fi

  ui_run "Setting npm init author to ${name:-?} <${email:-?}>" sh -c '
    npm set init.author.name "$1" &&
    npm set init.author.email "$2" &&
    npm set init.author.url "$3"' sh "${name}" "${email}" "${website}"
}

# Global installs need a user writable npm prefix (e.g. apt/pacman put it in /usr)
fix_npm_permissions() {
  local npm_prefix="$(npm config get prefix)"

  if [[ -w "${npm_prefix}" ]]; then
    skip "npm prefix ${npm_prefix} is writable"
    return 0
  fi

  mkdir -p "$HOME/.npm-global" &&
    ui_run "Setting npm prefix to ~/.npm-global" npm config set prefix "$HOME/.npm-global" &&
    info "Make sure ~/.npm-global/bin is in your PATH"
}

install_global_packages() {
  local -a packages=(nodemon)
  local pkg

  for pkg in "${packages[@]}"; do
    if npm ls -g --depth=0 "${pkg}" >/dev/null 2>&1; then
      skip "${pkg} is already installed"
    else
      ui_run "Installing ${pkg} globally" npm install -g "${pkg}"
    fi
  done
}

main() {
  detect_os || exit 1

  ui_step "Node.js"

  # Only needed when sudo has no cached credentials and a human can type
  if [[ "${OS}" != macos && "${DOTFILES_DRY_RUN:-0}" != 1 && -t 0 ]] && ! _exists node && ! sudo -n true 2>/dev/null; then
    ui_sudo_keepalive || { error "sudo is required"; exit 1; }
  fi

  install_node || { error "Node.js installation failed, see ${DOTFILES_LOG}"; exit 1; }

  if ! _exists npm; then
    if [[ "${DOTFILES_DRY_RUN:-0}" == 1 ]]; then
      info "npm is not installed yet, skipping npm configuration (dry run)"
      return 0
    fi
    error "npm not found"
    exit 1
  fi

  configure_npm_init || warn "Could not configure npm init"
  fix_npm_permissions || warn "Could not fix npm permissions"
  install_global_packages || warn "Some global npm packages failed"

  success "Node.js is set up"
}

main
