#!/usr/bin/env bash

set -e

info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*"; }

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1

install_prereq() {
    info "Checking and installing Neovim dependencies..."

    PREREQ=(
        "neovim"
        "stylua"
        "lazygit"
        "ripgrep"
        "cmake"
    )

    for tool in "${PREREQ[@]}"; do
        if ! brew list --formula | grep -q "^${tool}\$"; then
            info "Installing $tool..."
            brew install "$tool"
        else
            success "$tool already installed."
        fi
    done

    # I DONT THINK LAZYVIM REQURIES PIP Ensure pip is available
    # if ! command -v pip3 >/dev/null 2>&1; then
    #   info "Installing pip3..."
    #   python3 -m ensurepip
    # else
    #   success "pip3 already installed."
    # fi

    # requires cargo to install tree-sitter-cli
    if ! command -v cargo >/dev/null 2>&1; then
        info "Installing Rust (cargo)..."
        curl https://sh.rustup.rs -sSf | sh -s -- -y
        export PATH="$HOME/.cargo/bin:$PATH"
    else
        success "cargo already installed."
    fi

    # Checks for tree-sitter-cli and installs it
    if ! command -v tree-sitter >/dev/null 2>&1; then
        info "Installing tree-sitter-cli..."
        cargo install --locked tree-sitter-cli
    else
        success "tree-sitter-cli already installed."
    fi

    success "All prerequisites are installed."
}

# Can probably be handled by lazyvim
# npm_nvim_dependencies() {
#     info "Checking and installing global npm/yarn dependencies..."
#
#     DEPENDENCIES=(
#         "eslint"
#         "typescript"
#         "typescript-language-server"
#         "prettier"
#     )
#
#     for dep in "${DEPENDENCIES[@]}"; do
#         if ! yarn global list --pattern "$dep" | grep -q "$dep"; then
#             info "Installing $dep globally with yarn..."
#             yarn global add "$dep"
#         else
#             success "$dep already installed globally."
#         fi
#     done
#
#     success "All npm/yarn dependencies are installed."
# }

symlink_nvim() {
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    info "Symlinking nvim config with stow..."
    mkdir -p "$HOME/.config/nvim"
    stow --restow -vv --target="$HOME/.config/nvim" --dir=$SCRIPT_DIR nvim

    success "nvim config has been symlinked."
}

main() {
    read -p "Would you like to set up Neovim (LazyVim)? [y/N] " -n 1 answer
    echo
    if [[ $answer =~ ^[Yy]$ ]]; then
        symlink_nvim
        install_prereq
        # npm_nvim_dependencies
        success "Neovim setup complete!"
    else
        warn "Neovim setup skipped."
    fi
}

main "$@"
