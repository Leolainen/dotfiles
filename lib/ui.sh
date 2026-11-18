# shellcheck shell=bash
# Shared terminal UI helpers for the installer and every setup script.
# Source it from bash or zsh:  . "$DOTFILES/lib/ui.sh"
#
# Environment:
#   DOTFILES_YES=1       answer every prompt with its default/yes (unattended)
#   DOTFILES_DRY_RUN=1   ui_run only prints what it would run
#   DOTFILES_LOG=<file>  command output log (default ~/.dotfiles-install.log)
#   NO_COLOR=1           disable colors

[ -n "${DOTFILES_UI_LOADED:-}" ] && return 0
DOTFILES_UI_LOADED=1

DOTFILES_LOG="${DOTFILES_LOG:-$HOME/.dotfiles-install.log}"
DOTFILES_RESULTS=""
DOTFILES_STEP=0
DOTFILES_TOTAL_STEPS="${DOTFILES_TOTAL_STEPS:-0}"

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    e=$(printf '\033')
    RESET="${e}[0m"
    BOLD="${e}[1m"
    DIM="${e}[2m"
    RED="${e}[0;91m"
    GREEN="${e}[0;92m"
    YELLOW="${e}[0;93m"
    BLUE="${e}[0;94m"
    MAGENTA="${e}[0;95m"
    CYAN="${e}[0;96m"
    unset e
else
    RESET="" BOLD="" DIM="" RED="" GREEN="" YELLOW="" BLUE="" MAGENTA="" CYAN=""
fi

_exists() { command -v "$1" >/dev/null 2>&1; }

info() { printf '  %s•%s %s\n' "$CYAN" "$RESET" "$*"; }
success() { printf '  %s✔%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '  %s!%s %s\n' "$YELLOW" "$RESET" "$*"; }
error() { printf '  %s✖%s %s\n' "$RED" "$RESET" "$*" >&2; }
skip() { printf '  %s↷ %s%s\n' "$DIM" "$*" "$RESET"; }

# Sets OS to macos, ubuntu or arch. Returns 1 on unsupported systems.
detect_os() {
    case "$(uname -s)" in
    Darwin) OS="macos" ;;
    Linux)
        local ids=""
        [ -r /etc/os-release ] && ids=$(. /etc/os-release && echo "${ID:-} ${ID_LIKE:-}")
        case " ${ids} " in
        *" arch "*) OS="arch" ;;
        *" ubuntu "* | *" debian "*) OS="ubuntu" ;;
        *)
            error "Unsupported Linux distribution (only Ubuntu and Arch are supported)"
            return 1
            ;;
        esac
        ;;
    *)
        error "Unsupported OS: $(uname -s)"
        return 1
        ;;
    esac
    export OS
}

# usage: ui_banner  (prints the dotfiles logo)
ui_banner() {
    printf '%s' "$CYAN"
    cat <<'EOF'

   ┌┬┐┌─┐┌┬┐┌─┐┬┬  ┌─┐┌─┐
    │││ │ │ ├┤ ││  ├┤ └─┐
   ─┴┘└─┘ ┴ └  ┴┴─┘└─┘└─┘
EOF
    printf '%s' "$RESET"
    printf '   %sby @Leolainen · based on @AhmedAbdulrahman%s\n\n' "$DIM" "$RESET"
}

# usage: ui_step "Installing packages"  (prints "━━ [2/5] Installing packages ━━")
ui_step() {
    DOTFILES_STEP=$((DOTFILES_STEP + 1))
    local counter=""
    [ "$DOTFILES_TOTAL_STEPS" -gt 0 ] && counter="[${DOTFILES_STEP}/${DOTFILES_TOTAL_STEPS}] "
    printf '\n%s%s━━ %s%s ━━%s\n\n' "$BOLD" "$MAGENTA" "$counter" "$*" "$RESET"
}

# usage: ask_yn "Question?" [y|n]   default is y; returns 0 for yes
ask_yn() {
    local question="$1" default="${2:-y}" hint answer
    if [ "${DOTFILES_YES:-0}" = 1 ] || [ ! -t 0 ]; then
        [ "$default" = y ] && return 0 || return 1
    fi
    [ "$default" = y ] && hint="Y/n" || hint="y/N"
    printf '  %s?%s %s %s[%s]%s ' "$YELLOW" "$RESET" "$question" "$DIM" "$hint" "$RESET"
    read -r answer
    answer="${answer:-$default}"
    case "$answer" in
    [Yy]*) return 0 ;;
    *) return 1 ;;
    esac
}

# usage: ui_run "Installing ripgrep" cmd args...
# Runs the command with a spinner, logs its output and reports ✔/✖.
# Needs no interactive input (cache sudo first); use ui_live for commands that prompt.
ui_run() {
    local msg="$1"
    shift
    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
        printf '  %s…%s %s %s(dry run: %s)%s\n' "$DIM" "$RESET" "$msg" "$DIM" "$*" "$RESET"
        return 0
    fi
    printf '\n=== %s: %s\n' "$msg" "$*" >>"$DOTFILES_LOG"
    local start
    start=$(wc -l <"$DOTFILES_LOG")
    "$@" >>"$DOTFILES_LOG" 2>&1 &
    local pid=$! i=0 rc=0 frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    if [ -t 1 ]; then
        while kill -0 "$pid" 2>/dev/null; do
            printf '\r  %s%s%s %s' "$CYAN" "${frames:$((i % 10)):1}" "$RESET" "$msg"
            i=$((i + 1))
            sleep 0.1
        done
        printf '\r\033[K'
    fi
    wait "$pid" || rc=$?
    if [ "$rc" -eq 0 ]; then
        success "$msg"
    else
        error "$msg (exit $rc), see $DOTFILES_LOG"
        tail -n +$((start + 1)) "$DOTFILES_LOG" | tail -n 5 | sed 's/^/      /' >&2
    fi
    return "$rc"
}

# usage: ui_live "Installing Homebrew" cmd args...  (output streams to the terminal)
ui_live() {
    local msg="$1"
    shift
    if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
        printf '  %s…%s %s %s(dry run: %s)%s\n' "$DIM" "$RESET" "$msg" "$DIM" "$*" "$RESET"
        return 0
    fi
    info "$msg"
    "$@"
}

# usage: ui_record ok|skip|fail "name" ["detail"]; collected for ui_summary
ui_record() {
    DOTFILES_RESULTS="${DOTFILES_RESULTS}${1}|${2}|${3:-}
"
}

ui_summary() {
    local rstatus name detail icon
    printf '\n%s%s━━ Summary ━━%s\n\n' "$BOLD" "$MAGENTA" "$RESET"
    while IFS='|' read -r rstatus name detail; do
        [ -z "$rstatus" ] && continue
        case "$rstatus" in
        ok) icon="${GREEN}✔${RESET}" ;;
        skip) icon="${DIM}↷${RESET}" ;;
        *) icon="${RED}✖${RESET}" ;;
        esac
        printf '  %s %s' "$icon" "$name"
        [ -n "$detail" ] && printf ' %s%s%s' "$DIM" "$detail" "$RESET"
        printf '\n'
    done <<EOF
$DOTFILES_RESULTS
EOF
    printf '\n'
}

# Keeps sudo credentials fresh until the calling script exits.
ui_sudo_keepalive() {
    [ "$(id -u)" -eq 0 ] && return 0
    _exists sudo || return 0
    info "Administrator access is needed once, you may be asked for your password."
    sudo -v || return 1
    (while kill -0 "$$" 2>/dev/null; do
        sudo -n true
        sleep 50
    done) >/dev/null 2>&1 &
}

# bash only. usage: ui_pick "Title" "key|Label|1" "key|Label|0" ...
# Shows a checklist (1 = preselected), result in PICKED (space separated keys).
ui_pick() {
    local title="$1"
    shift
    local -a keys labels sel
    local item i n=0 input tok
    for item in "$@"; do
        keys[n]="${item%%|*}"
        item="${item#*|}"
        labels[n]="${item%%|*}"
        sel[n]="${item##*|}"
        n=$((n + 1))
    done
    if [ "${DOTFILES_YES:-0}" = 1 ] || [ ! -t 0 ]; then
        PICKED=""
        for ((i = 0; i < n; i++)); do [ "${sel[i]}" = 1 ] && PICKED="$PICKED ${keys[i]}"; done
        PICKED="${PICKED# }"
        return 0
    fi
    while true; do
        printf '\n  %s%s%s\n\n' "$BOLD" "$title" "$RESET"
        for ((i = 0; i < n; i++)); do
            if [ "${sel[i]}" = 1 ]; then
                printf '   %s[x]%s %2d) %s\n' "$GREEN" "$RESET" $((i + 1)) "${labels[i]}"
            else
                printf '   %s[ ]%s %2d) %s\n' "$DIM" "$RESET" $((i + 1)) "${labels[i]}"
            fi
        done
        printf '\n  %sType numbers to toggle, a = all, n = none, enter = continue:%s ' "$DIM" "$RESET"
        read -r input
        [ -z "$input" ] && break
        for tok in $input; do
            case "$tok" in
            a) for ((i = 0; i < n; i++)); do sel[i]=1; done ;;
            n) for ((i = 0; i < n; i++)); do sel[i]=0; done ;;
            *[!0-9]* | "") ;;
            *)
                if [ "$tok" -ge 1 ] && [ "$tok" -le "$n" ]; then
                    [ "${sel[tok - 1]}" = 1 ] && sel[tok - 1]=0 || sel[tok - 1]=1
                fi
                ;;
            esac
        done
    done
    PICKED=""
    for ((i = 0; i < n; i++)); do [ "${sel[i]}" = 1 ] && PICKED="$PICKED ${keys[i]}"; done
    PICKED="${PICKED# }"
}
