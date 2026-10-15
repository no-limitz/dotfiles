# dotfiles

Shell, git, tmux, vim and prompt defaults for macOS and Linux (including Coder
workspaces). Plain zsh/bash, no framework; one optional download (starship).

## Install

```bash
git clone <this repo> ~/dotfiles && ~/dotfiles/install.sh
```

Preview first with `./install.sh --dry-run`. Re-running is safe.

**Coder:** pass this repo's URL as the workspace's `dotfiles_uri`, or run
`coder dotfiles <url>`. Coder clones it and runs `install.sh` on every start.

**macOS:** `brew bundle --file=Brewfile` installs the tools the config uses.

## What install.sh does

| Target | How | Why |
|---|---|---|
| `~/.zshrc`, `~/.bashrc` | appends a marked block that sources `shell/zshrc` / `shell/bashrc` | Never replaces your file, so machine-specific lines and other tools' appends survive. |
| `~/.gitconfig` | adds `[include]` of `git/gitconfig` at the **top** | Settings in `~/.gitconfig` still win; tools that run `git config --global` do not write into this repo. |
| `~/.config/starship.toml`, `~/.config/git/ignore`, `~/.tmux.conf`, `~/.vimrc` | symlinks | An existing real file is moved to `~/.dotfiles_backup/<timestamp>/`. |
| starship | installed to `~/.local/bin` on Linux only | No sudo. On macOS use the Brewfile. |

Starship is the only download: `--skip-deps` or `DOTFILES_SKIP_DEPS=1` skips it. The script always exits 0 so
a failed step cannot break a workspace start; warnings are printed.

## Defaults

- **Shell (zsh and bash):** 100k-line shared history without duplicates, Up/Down search by typed prefix,
  case-insensitive completion, starship prompt, `EDITOR` = nvim > vim > vi, `~/.local/bin` `~/.bun/bin`
  `~/.cargo/bin` `~/go/bin` on `PATH` when they exist, `ls` colors that work on both GNU and BSD.
  zsh also loads `zsh-autosuggestions` / `zsh-syntax-highlighting` if installed.
- **git:** `main` default branch, `pull.rebase`, `push.autoSetupRemote`, `fetch.prune`, `rerere`,
  histogram diffs, newest-first `git branch`, short aliases (`co`, `sw`, `st`, `amend`, `undo`, `tree`).
  No identity or credentials: Coder provides them.
- **Global gitignore:** OS/editor noise, `.env`, `.claude/settings.local.json`. Nothing that hides source.
- **tmux:** mouse, vi keys, truecolor, 1-based windows, new panes open in the current directory.
- **vim:** self-contained, no plugins. Neovim reads `~/.config/nvim` and is not managed here.

## Local overrides

Put machine-specific or private settings (work paths, tokens, per-host PATH) in `~/.shell.local`.
It is sourced last and is not tracked.
