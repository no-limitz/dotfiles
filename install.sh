#!/usr/bin/env bash
# Installs these dotfiles. Safe to re-run; never aborts the whole run on one
# failed step. `coder dotfiles` runs this file automatically.
#
#   ./install.sh [--dry-run] [--skip-deps]
#
#   --dry-run    print what would change, touch nothing
#   --skip-deps  do not download anything (also: DOTFILES_SKIP_DEPS=1)
#
# What it does:
#   - symlinks starship.toml, tmux.conf, vimrc, git/ignore (an existing real
#     file is moved to ~/.dotfiles_backup/<timestamp>/ first);
#   - adds an [include] of git/gitconfig at the TOP of ~/.gitconfig, so your own
#     settings in that file still win, and `git config --global` writes by other
#     tools land in ~/.gitconfig, not in this repo;
#   - appends a managed block to ~/.zshrc and ~/.bashrc that sources shell/zshrc
#     or shell/bashrc. Those files are never replaced, so machine-specific
#     content (and anything other tools append later) is preserved;
#   - installs starship into ~/.local/bin on Linux if missing. No sudo.
set -u

DRY_RUN=0
SKIP_DEPS="${DOTFILES_SKIP_DEPS:-0}"
for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY_RUN=1 ;;
    --skip-deps) SKIP_DEPS=1 ;;
    -h|--help)   sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
FAILED=0
# Result message for a change; silent under --dry-run, where `run` already printed it.
ok_msg() { [ "$DRY_RUN" = 1 ] || info "$*"; }


info() { printf '[dotfiles] %s\n' "$*"; }
warn() { printf '[dotfiles] warning: %s\n' "$*" >&2; FAILED=1; }

# Run a command, or just print it under --dry-run.
run() {
  if [ "$DRY_RUN" = 1 ]; then printf '[dry-run] %s\n' "$*"; else "$@"; fi
}

# link SRC DST: DST becomes a symlink to SRC.
link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    info "ok      $dst"
    return 0
  fi
  run mkdir -p "$(dirname "$dst")" || { warn "cannot create $(dirname "$dst")"; return 1; }
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    run mkdir -p "$BACKUP_DIR" && run mv "$dst" "$BACKUP_DIR/" \
      && ok_msg "backup  $dst -> $BACKUP_DIR/"
  elif [ -L "$dst" ]; then
    run rm "$dst"
  fi
  run ln -s "$src" "$dst" && ok_msg "linked  $dst -> $src" || warn "could not link $dst"
}

# Rewrite FILE with everything between our markers removed (stdout).
strip_block() {
  awk '
    $0 == "# >>> dotfiles >>>" { skip = 1; next }
    $0 == "# <<< dotfiles <<<" { skip = 0; next }
    !skip { print }
  ' "$1"
}

# source_block RC TARGET: make RC source TARGET from a marked block at the end.
source_block() {
  local rc="$1" target="$2" tmp
  local line="[ -f \"$target\" ] && . \"$target\""
  if [ -f "$rc" ] && grep -qxF "$line" "$rc"; then
    info "ok      $rc sources $target"
    return 0
  fi
  if [ "$DRY_RUN" = 1 ]; then
    printf '[dry-run] add dotfiles block to %s -> %s\n' "$rc" "$target"
    return 0
  fi
  touch "$rc" || { warn "cannot write $rc"; return 1; }
  tmp="$(mktemp)" || { warn "mktemp failed"; return 1; }
  {
    strip_block "$rc"
    printf '# >>> dotfiles >>>\n%s\n# <<< dotfiles <<<\n' "$line"
  } > "$tmp" && cat "$tmp" > "$rc" && ok_msg "updated $rc" || warn "could not update $rc"
  rm -f "$tmp"
}

# include_gitconfig: put `[include] path = git/gitconfig` first in ~/.gitconfig.
include_gitconfig() {
  local gc="$HOME/.gitconfig" inc="$DOTFILES_DIR/git/gitconfig" tmp
  if [ -f "$gc" ] && grep -qF "path = $inc" "$gc"; then
    info "ok      $gc includes $inc"
    return 0
  fi
  if [ "$DRY_RUN" = 1 ]; then
    printf '[dry-run] include %s at the top of %s\n' "$inc" "$gc"
    return 0
  fi
  tmp="$(mktemp)" || { warn "mktemp failed"; return 1; }
  {
    printf '# >>> dotfiles >>>\n[include]\n\tpath = %s\n# <<< dotfiles <<<\n' "$inc"
    if [ -f "$gc" ]; then strip_block "$gc"; fi
  } > "$tmp" && cat "$tmp" > "$gc" && ok_msg "updated $gc" || warn "could not update $gc"
  rm -f "$tmp"
}

install_starship() {
  if command -v starship >/dev/null 2>&1 || [ -x "$HOME/.local/bin/starship" ]; then
    info "ok      starship"
    return 0
  fi
  if [ "$SKIP_DEPS" = 1 ]; then info "skip    starship (deps skipped)"; return 0; fi
  if [ "$(uname -s)" = "Darwin" ]; then
    info "starship missing: run 'brew bundle --file=$DOTFILES_DIR/Brewfile'"
    return 0
  fi
  command -v curl >/dev/null 2>&1 || { warn "curl missing; cannot install starship"; return 1; }
  info "installing starship to ~/.local/bin"
  run mkdir -p "$HOME/.local/bin"
  if [ "$DRY_RUN" = 1 ]; then
    printf '[dry-run] curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin\n'
  else
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" >/dev/null \
      || warn "starship install failed; the shell falls back to its default prompt"
  fi
}

info "dotfiles dir: $DOTFILES_DIR"

link "$DOTFILES_DIR/starship.toml" "$XDG_CONFIG_HOME/starship.toml"
link "$DOTFILES_DIR/git/ignore"    "$XDG_CONFIG_HOME/git/ignore"
link "$DOTFILES_DIR/tmux.conf"     "$HOME/.tmux.conf"
link "$DOTFILES_DIR/vimrc"         "$HOME/.vimrc"
run mkdir -p "$HOME/.vim/undo"

include_gitconfig
source_block "$HOME/.zshrc"  "$DOTFILES_DIR/shell/zshrc"
source_block "$HOME/.bashrc" "$DOTFILES_DIR/shell/bashrc"

install_starship

if [ "$FAILED" = 0 ]; then info "done. Open a new shell (or: exec \$SHELL)."; else info "done, with warnings above."; fi
# Never fail the caller: `coder dotfiles` would report the workspace start as broken.
exit 0
