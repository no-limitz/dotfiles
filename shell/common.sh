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

# --- commands banner -----------------------------------------------------------
# One line per terminal, always, so the helpers are never out of sight once the
# hints below go quiet. Exported so nested shells stay quiet.
if [ -z "${DOTFILES_BANNER_SHOWN:-}" ] && command -v dothelp >/dev/null 2>&1; then
  export DOTFILES_BANNER_SHOWN=1
  printf 'Workspace commands: ghrepo · multica-register · omp. Run `dothelp` for the full list.\n'
fi

# --- GitHub sign-in hint -------------------------------------------------------
# One line, only while there is no GitHub credential. File checks only: `gh auth
# status` calls the API and would slow every new shell. Exported so nested shells
# stay quiet.
if [ -z "${DOTFILES_GH_HINTED:-}" ] && command -v ghrepo >/dev/null 2>&1 \
   && [ -z "${GH_TOKEN:-}${GITHUB_TOKEN:-}" ] && [ ! -s "$HOME/.git-credentials" ] \
   && ! grep -qs 'github.com' "${XDG_CONFIG_HOME:-$HOME/.config}/gh/hosts.yml"; then
  export DOTFILES_GH_HINTED=1
  printf 'Not signed in to GitHub. Run `ghrepo` to sign in and clone a repo.\n'
fi

# --- Multica runtime hint ------------------------------------------------------
# One line, only until `multica-register` has run here (it writes ~/.multica-enabled;
# `multica-register --disable` removes it). File check only, so new shells stay fast.
if [ -z "${DOTFILES_MULTICA_HINTED:-}" ] && command -v multica-register >/dev/null 2>&1 \
   && [ ! -e "$HOME/.multica-enabled" ]; then
  export DOTFILES_MULTICA_HINTED=1
  printf 'Not registered with Multica. Run `multica-register` to let Multica run agents here.\n'
fi

# --- machine-specific / private ----------------------------------------------
# Not tracked: work paths, tokens, per-host tweaks.
[ -f "$HOME/.shell.local" ] && . "$HOME/.shell.local"
