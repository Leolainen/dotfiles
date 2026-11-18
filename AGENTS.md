# Dotfiles engineering instructions

Personal dotfiles (based on AhmedAbdulrahman's) for macOS and Linux (Ubuntu and
Arch). Agents carry changes through to completion while preserving the existing
structure, naming, and style of each tool's config. The default branch is `master`.

## Quick reference

- Layout: `nvim/nvim` (LazyVim, Lua), `zsh/` (antidote plugins, p10k, aliases),
  `sketchybar/sketchybar` (bash plugins and theme files), `config/` (ghostty, git,
  skhd, yabai, taskwarrior, colorls), `scripts/` (brew/node/bootstrap),
  `fonts/`, `installer.sh`.
- Each tool has a `setup.sh` that installs prerequisites and links config
  (`stow --restow` for nvim and sketchybar, `ln -sf` for zsh). Edit files in this repo, never
  the symlink targets in `$HOME`/`~/.config`, and never run setup scripts, package
  managers, or `stow` unless asked: they change the machine.
- Setup scripts use the shared `info/success/warn/error` helpers, `set -e`, and are
  idempotent (check before installing). Follow that when adding to them.
- Commits: `[path/to/file-or-dir]: lower-case description`, e.g.
  `[sketchybar/github_scripts] updates PATH for launchd execution`. One concern per commit.
- Never commit secrets, tokens, or machine-local config. `nvim/nvim/lua/local` and
  `.ghq` are gitignored on purpose.

## Linux support (Ubuntu and Arch)

- Everything that is not inherently macOS must work on macOS, Ubuntu, and Arch.
  Detect the OS (`uname`, `/etc/os-release`) and branch rather than assuming macOS.
- Package installs: `brew` on macOS, `apt` on Ubuntu, `pacman` on Arch (Homebrew
  on Linux only if already the established path). Package names differ per
  distro; map them explicitly and keep installs idempotent.
- Avoid macOS-only assumptions in shared files: `/opt/homebrew` paths, BSD
  `sed -i ''`/`date`/`stat` flags, `pbcopy`/`open`, `launchd`. Use portable
  alternatives or guard with an OS check, and use `$HOME` rather than `/Users/...`.
- macOS-only tools (sketchybar, yabai, skhd, launchd agents) stay macOS-only: do
  not break Linux setup when they are absent, and skip them on Linux.
- Linux-only tools or config must be guarded so they do not run on macOS.

## Understand before changing

- Read the target file and its neighbours first. Match the surrounding style
  (Lua: `nvim/nvim/stylua.toml`; shell: 4-space indent in setup scripts, existing quoting).
- Treat odd details as intentional (launchd `PATH`, absolute paths, commented-out
  blocks, `*BAKUP` files) until `git log`/`git blame` says otherwise. Do not
  clean up, reorder, or reformat unrelated lines.
- Prefer extending existing patterns (a new LazyVim plugin spec under
  `nvim/nvim/lua/plugins`, a new sketchybar plugin in `plugins/`) over new
  abstractions, tools, or layouts.
- Do not hand-edit generated files: `nvim/nvim/lazy-lock.json` changes only via
  `:Lazy` updates, and sketchybar theme files (`themes.sh`, `tokens.sh`,
  `palette.sh`) should stay consistent with `parseTheme.sh`.

## Verification

Run the smallest relevant check; never claim an unrun check passed.

- Lua: `stylua --check nvim/nvim`.
- Shell: `bash -n <file>` (and `shellcheck` if installed); `zsh -n zsh/zshrc` for zsh files.
- Cross-platform changes: reason through each of macOS, Ubuntu, and Arch code
  paths, and state which were actually exercised.
- sketchybar: after edits suggest `sketchybar --reload`; do not restart services
  or launchd agents without being asked.
- Neovim: `nvim --headless "+Lazy! sync" +qa` modifies plugins and the lockfile;
  only run it on request.

## Ownership and autonomy

- Check `git status` first. Existing uncommitted work belongs to the user; do not
  absorb or revert it.
- Resolve routine choices from repo evidence. Ask only for consequential
  decisions (replacing a tool, changing keybindings the user relies on,
  machine-wide effects).
- Update `README.md` when adding or removing a managed tool.
- Keep responses and commit messages short; comment only non-obvious config.
