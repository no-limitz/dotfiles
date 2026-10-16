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
| `bin/*` (`ghrepo`, `multica-register`, `dothelp`) | symlinks in `~/.local/bin` | Helper commands, see below. |
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

## ghrepo: sign in to GitHub and pick a repo

```bash
ghrepo               # sign in (first run), choose an owner/org, choose a repo, clone it
ghrepo OWNER/REPO    # sign in (first run) and clone that repo directly
```

Sign-in is `gh auth login --web` (device code), so it works headless: open the printed URL on any machine and
enter the code. It then runs `gh auth setup-git`, so `git` over https uses gh's credentials and no token is
written to disk. Repos clone into `~/projects` (`GHREPO_DIR` to change), and it offers to start `omp` there.
Uses `fzf` for picking if installed, otherwise a numbered menu with text filtering.

While no GitHub credential exists (no `~/.config/gh/hosts.yml` entry, `~/.git-credentials` or token env var), new
interactive shells print a one-line hint to run `ghrepo`. It is a file check only, so it adds no startup delay.

## multica-register: make this machine a Multica runtime

```bash
multica-register                    # connect to multica.nolimitz.io and start the daemon
multica-register --status           # login, daemon and runtime state
multica-register --disable          # stop the daemon and its autostart
multica-register --agent [NAME]     # also create an agent on this runtime (--model ID)
multica-register --repo [TARGET]    # also register a repo (URL, path, the repo you are in, or ~/projects clones)
```

Installs the CLI with the official `install.sh` if missing. On a desktop it runs
`multica setup self-host --server-url ... --app-url ...` (browser sign-in, starts the daemon). In a Coder
workspace or over SSH it signs in with `MULTICA_NODE_TOKEN` if set, otherwise a pasted personal access token.
The daemon registers one runtime per agent CLI on `PATH` (omp needs multica 0.4.22 or newer; the script
updates the CLI if needed). `--agent` defaults to `litellm/nolimitz/coder` (thinking off); set `--model` or
`MULTICA_AGENT_MODEL` for another, e.g. `litellm/nolimitz/agent` for thinking on. `--repo` with no target
registers the repo you are in, or else every repo `ghrepo` cloned under `~/projects`; repos already in the
registry, in ssh or https form, are skipped. Until it has run, new shells print a one-line hint.

The daemon registers a runtime for every agent CLI it finds, so `copilot` (in the Coder image) is hidden by
default: only the LiteLLM gateway models are offered. `MULTICA_DISABLE_AGENTS="copilot codex"` hides a different
set, and `MULTICA_DISABLE_AGENTS=""` hides nothing. It works by pointing `MULTICA_<NAME>_PATH` at a path that
does not exist, and the `omp-nolimitz` Coder template sets `MULTICA_COPILOT_PATH` for the daemon autostart.

## dothelp: cheat sheet

```bash
dothelp            # everything
dothelp multica    # one topic: start repos multica omp coder git shell
```

Plain text in `bin/dothelp`, so it works offline on any new workspace once the dotfiles are applied.
Update it when a helper gains or loses an option.
