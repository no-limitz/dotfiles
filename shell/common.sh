# Shared by bash and zsh (sourced from shell/bashrc and shell/zshrc).
# Interactive shells only. Keep this POSIX-ish: no zsh- or bash-only syntax.

# --- PATH ---------------------------------------------------------------------
# Only adds directories that exist and are not already on PATH, so sourcing this
# after a machine's own PATH setup never reorders it.
path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) [ -d "$1" ] && PATH="$1:$PATH" ;;
  esac
}
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.bun/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/go/bin"
export PATH

# --- environment --------------------------------------------------------------
if [ -z "${EDITOR:-}" ]; then
  for _e in nvim vim vi; do
    if command -v "$_e" >/dev/null 2>&1; then export EDITOR="$_e"; break; fi
  done
  unset _e
fi
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--FRX}"   # quit if one screen, keep colors, don't clear screen
export CLICOLOR=1             # BSD/macOS ls color

# --- aliases ------------------------------------------------------------------
# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ls: GNU (Linux) and BSD (macOS) take different color flags
if ls --color=auto >/dev/null 2>&1; then alias ls='ls --color=auto'; else alias ls='ls -G'; fi
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

# git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# network
alias myip='curl -s ifconfig.me && echo'
if [ "$(uname -s)" = "Darwin" ]; then
  alias ports='lsof -iTCP -sTCP:LISTEN -n -P'
else
  alias ports='ss -tulnp'
fi

# --- functions ----------------------------------------------------------------
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# --- machine-specific / private ----------------------------------------------
# Not tracked: work paths, tokens, per-host tweaks.
[ -f "$HOME/.shell.local" ] && . "$HOME/.shell.local"
