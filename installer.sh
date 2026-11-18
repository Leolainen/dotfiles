#!/usr/bin/env bash
#
# One command to set up a whole machine (macOS, Ubuntu or Arch).
#
#   Fresh machine:  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Leolainen/dotfiles/master/installer.sh)" -- --all
#   From a clone:   ./installer.sh            pick what to install from a checklist
#                   ./installer.sh --all      install everything, no questions
#                   ./installer.sh --only zsh,nvim
#                   ./installer.sh --help

REPO_URL="https://github.com/Leolainen/dotfiles.git"
HOMEBREW_INSTALLER_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

# key|label|script|shell|default
MODULES=(
    "packages|Packages and apps (Brewfile / apt / pacman)|scripts/brew.zsh|zsh|1"
    "node|Node.js and npm setup|scripts/nodejs.zsh|zsh|1"
    "zsh|zsh, antidote and aliases|zsh/setup.sh|bash|1"
    "nvim|Neovim (LazyVim)|nvim/setup.sh|bash|1"
    "config|git, taskwarrior, ghostty, herdr, obsidian, yabai and skhd|config/setup.sh|bash|1"
    "fonts|Nerd Fonts|fonts/setup.sh|bash|1"
    "sketchybar|SketchyBar (macOS only)|sketchybar/setup.sh|bash|1"
)

usage() {
    cat <<EOF
Usage: installer.sh [options] [module...]

Options:
  -a, --all, -y, --yes   install everything without asking questions
      --only a,b         install only the listed modules (implies --yes)
      --dir PATH         where the dotfiles live / are cloned (default: this repo, or ~/dotfiles)
      --dry-run          show what would happen without changing anything
      --list             list the available modules
      --no-color         plain output
  -h, --help             show this help

Modules: packages node zsh nvim config fonts sketchybar
Command output is logged to ~/.dotfiles-install.log
EOF
}

# --- argument parsing -------------------------------------------------------
ONLY=""
while [ $# -gt 0 ]; do
    case "$1" in
    -a | --all | -y | --yes) export DOTFILES_YES=1 ;;
    --only)
        ONLY="$2"
        export DOTFILES_YES=1
        shift
        ;;
    --dir)
        DOTFILES_DIR_ARG="$2"
        shift
        ;;
    --dry-run) export DOTFILES_DRY_RUN=1 ;;
    --no-color) export NO_COLOR=1 ;;
    --list)
        for m in "${MODULES[@]}"; do
            IFS='|' read -r key label _ <<<"$m"
            printf '%-12s %s\n' "$key" "$label"
        done
        exit 0
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    -*)
        echo "Unknown option: $1" >&2
        usage >&2
        exit 2
        ;;
    *)
        ONLY="${ONLY:+$ONLY,}$1"
        export DOTFILES_YES=1
        ;;
    esac
    shift
done

# --- running via curl: clone the repo and hand over --------------------------
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/lib/ui.sh" ]; then
    target="${DOTFILES_DIR_ARG:-${DOTFILES:-$HOME/dotfiles}}"
    echo "→ Fetching dotfiles into $target"
    if ! command -v git >/dev/null 2>&1; then
        case "$(uname -s)" in
        Darwin)
            echo "→ git is missing, installing the Command Line Tools (follow the dialog)..."
            xcode-select --install 2>/dev/null
            until command -v git >/dev/null 2>&1; do sleep 5; done
            ;;
        *)
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update && sudo apt-get install -y git
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S --needed --noconfirm git
            else
                echo "Please install git and run this again." >&2
                exit 1
            fi
            ;;
        esac
    fi
    if [ -d "$target/.git" ]; then
        git -C "$target" pull --ff-only --no-recurse-submodules || true
    else
        git clone --depth 1 "$REPO_URL" "$target" || exit 1
    fi
    args=()
    [ "${DOTFILES_YES:-0}" = 1 ] && [ -z "$ONLY" ] && args+=(--all)
    [ -n "$ONLY" ] && args+=(--only "$ONLY")
    [ "${DOTFILES_DRY_RUN:-0}" = 1 ] && args+=(--dry-run)
    exec bash "$target/installer.sh" "${args[@]}"
fi

cd "$SCRIPT_DIR" || exit 1
export DOTFILES="${DOTFILES_DIR_ARG:-$SCRIPT_DIR}"
# shellcheck source=lib/ui.sh
. "$SCRIPT_DIR/lib/ui.sh"
export DOTFILES_LOG

trap 'echo; error "Interrupted, partial progress is kept. Re-run the installer to continue."; exit 130' INT TERM

# Package names are identical on macOS (brew), Ubuntu (apt) and Arch (pacman) for git, zsh and curl.
pkg_install() {
    case "$OS" in
    macos) brew install "$@" ;;
    ubuntu) sudo apt-get install -y "$@" ;;
    arch) sudo pacman -S --needed --noconfirm "$@" ;;
    esac
}

load_brew() {
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

install_homebrew() {
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL "$HOMEBREW_INSTALLER_URL")"
}

# --- prerequisites ----------------------------------------------------------
install_prerequisites() {
    ui_step "System prerequisites"

    case "$OS" in
    macos)
        if xcode-select -p >/dev/null 2>&1; then
            skip "Command Line Tools already installed"
        else
            ui_live "Installing Command Line Tools, follow the dialog that opens" xcode-select --install
            if [ "${DOTFILES_DRY_RUN:-0}" != 1 ]; then
                until xcode-select -p >/dev/null 2>&1; do sleep 5; done
                success "Command Line Tools installed"
            fi
        fi

        load_brew
        if _exists brew; then
            skip "Homebrew already installed"
        else
            ui_live "Installing Homebrew (this takes a while)" install_homebrew || return 1
            load_brew
        fi
        ;;
    ubuntu)
        ui_run "Updating the apt package index" sudo apt-get update || return 1
        ;;
    arch)
        if ask_yn "Upgrade all installed packages first (pacman -Syu)?" n; then
            ui_run "Upgrading the system" sudo pacman -Syu --noconfirm || return 1
        else
            ui_run "Refreshing the package database" sudo pacman -Sy || return 1
        fi
        ;;
    esac

    local tool
    for tool in git zsh curl; do
        if _exists "$tool"; then
            skip "$tool already installed"
        else
            ui_run "Installing $tool" pkg_install "$tool" || return 1
        fi
    done
}

run_module() {
    local key="$1" label="$2" script="$3" shell="$4"
    ui_step "$label"
    if [ ! -f "$DOTFILES/$script" ]; then
        error "$script not found"
        ui_record fail "$label" "missing $script"
        return
    fi
    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
        info "dry run: would run $shell $script"
        ui_record skip "$label" "dry run"
        return
    fi
    if "$shell" "$DOTFILES/$script"; then
        ui_record ok "$label"
    else
        ui_record fail "$label" "see $DOTFILES_LOG"
    fi
}

# --- main -------------------------------------------------------------------
main() {
    local start=$SECONDS m key label script shell default selected="" choices=()

    ui_banner
    detect_os || exit 1
    info "Detected ${BOLD}$OS${RESET}, dotfiles in ${BOLD}$DOTFILES${RESET}"

    for m in "${MODULES[@]}"; do
        IFS='|' read -r key label script shell default <<<"$m"
        [ "$key" = sketchybar ] && [ "$OS" != macos ] && continue
        choices+=("$key|$label|$default")
    done

    if [ -n "$ONLY" ]; then
        selected="${ONLY//,/ }"
        local k
        for k in $selected; do
            case " ${choices[*]} " in
            *"$k|"*) ;;
            *)
                error "Unknown or unavailable module: $k (see --list)"
                exit 2
                ;;
            esac
        done
    else
        ui_pick "What should be installed?" "${choices[@]}"
        selected="$PICKED"
        if [ -z "$selected" ]; then
            warn "Nothing selected, bye."
            exit 0
        fi
        if [ "${DOTFILES_YES:-0}" != 1 ] && ! ask_yn "Install $(wc -w <<<"$selected" | tr -d ' ') item(s) now?" y; then
            exit 0
        fi
    fi

    local count
    count=$(wc -w <<<"$selected" | tr -d ' ')
    export DOTFILES_TOTAL_STEPS=$((count + 1))

    if [ "$OS" != macos ] && [ "${DOTFILES_DRY_RUN:-0}" != 1 ]; then
        ui_sudo_keepalive || exit 1
    fi

    if install_prerequisites; then
        ui_record ok "System prerequisites"
    else
        ui_record fail "System prerequisites" "see $DOTFILES_LOG"
        ui_summary
        error "Cannot continue without the prerequisites."
        exit 1
    fi

    for m in "${MODULES[@]}"; do
        IFS='|' read -r key label script shell default <<<"$m"
        case " $selected " in
        *" $key "*) run_module "$key" "$label" "$script" "$shell" ;;
        esac
    done

    ui_summary
    printf '  %sFinished in %ss. Log: %s%s\n' "$DIM" "$((SECONDS - start))" "$DOTFILES_LOG" "$RESET"
    case "$DOTFILES_RESULTS" in
    *"fail|"*) warn "Some steps failed. Fix the cause and re-run, finished steps are skipped." ;;
    *) success "All done. Open a new terminal (or run: exec zsh) to start using it." ;;
    esac
    echo
}

main
