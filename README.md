# Workbench Dev Setup

A reproducible workstation provisioning guide. One clone, one script, a ready machine.

## Architecture

```
macOS
├── Homebrew          # package manager
├── Brewfile          # declarative package list
├── bootstrap.sh      # one-command provisioning
├── lib.sh            # shared helpers
├── doctor.sh         # health checks
├── Dotfiles
│   ├── Ghostty       # terminal
│   ├── Zsh           # shell
│   ├── Starship      # prompt
│   └── Git           # version control
├── asdf              # runtime version manager
│   ├── Node.js
│   ├── Bun
│   ├── Python
│   ├── Go
│   └── Rust
├── CLI Tools
│   ├── fzf           # fuzzy finder
│   ├── zoxide        # smart cd
│   ├── lazygit       # git TUI
│   ├── ripgrep       # fast grep
│   ├── fd            # fast find
│   ├── eza           # modern ls
│   ├── bat           # syntax-highlighted cat
│   ├── jq / yq       # JSON / YAML processing
│   ├── delta         # better git diff
│   └── atuin         # synced shell history
└── Extensions        # opt-in tool bundles
    └── ai            # AI engineering tools
        ├── herdr     # multi-terminal agent sessions
        └── pi        # AI coding agent
```

## Terminal

**Ghostty** — GPU-accelerated, native macOS feel, TOML config, fast startup.

Alternative: WezTerm if you need built-in Lua scripting and multiplexing.

## Shell

**Zsh** with a minimal hand-rolled config. Avoid frameworks like Oh My Zsh or Prezto — they add complexity you don't need.

```
~/.config/zsh/
├── zshrc
├── aliases.zsh
├── exports.zsh
├── functions.zsh
└── completions.zsh
```

Small, separate files are easier to maintain and reason about.

## Prompt

**Starship** — fast (Rust), cross-shell, single config file.

```
~/.config/starship.toml
```

## Navigation

**zoxide** — a smarter `cd` that learns your habits.

```sh
z project    # jumps to ~/code/project
```

## Fuzzy Finding

**fzf** — the backbone of interactive terminal use.

| Shortcut | Action           |
| -------- | ---------------- |
| Ctrl-R   | History search   |
| Ctrl-T   | File search      |
| Alt-C    | Directory search |

Integrates with git, zoxide, ripgrep, and bat.

## File Listing

**eza** — modern `ls` replacement with git integration.

```sh
eza -lah --git
```

## Git

**lazygit** for daily work — staging, committing, rebasing, conflict resolution.

Still learn the Git CLI; interviews and automation require it.

**delta** for readable diffs:

```sh
git config --global core.pager delta
```

## Search

**ripgrep** (`rg`) — fast recursive search. Probably the most-used command after git.

```sh
rg UserService
```

**fd** — fast, user-friendly `find` replacement.

```sh
fd package.json
```

## File Viewing

**bat** — `cat` with syntax highlighting and line numbers.

```sh
bat file.ts
```

## Data Processing

**jq** — essential for JSON. **yq** — same for YAML (Kubernetes, GitHub Actions, Docker Compose).

## Shell History

**atuin** — synced shell history across machines with powerful search.

## Runtime Version Management

**asdf** as the single version manager for all languages. No need for nvm, pyenv, or separate installers.

| Language | asdf Plugin |
| -------- | ----------- |
| Node.js  | asdf-nodejs |
| Bun      | asdf-bun    |
| Python   | asdf-python |
| Go       | asdf-golang |
| Rust     | asdf-rust   |

```sh
asdf plugin add nodejs
asdf install nodejs latest
asdf set --home nodejs latest
```

Per-project versions are pinned in `.tool-versions`.

## Editor

**Zed** — fast, native editor built in Rust. Launch from terminal with `zed .`.

## Package Manager

**Homebrew** with a declarative Brewfile.

```sh
brew bundle dump    # export current packages
brew bundle         # install from Brewfile
```

## Dotfiles Structure

```
dotfiles/
├── Brewfile
├── bootstrap.sh
├── doctor.sh
├── lib.sh
├── README.md
├── ghostty/
│   └── config
├── starship.toml
├── git/
│   ├── gitconfig
│   └── gitignore_global
├── zsh/
│   ├── zshrc
│   ├── aliases.zsh
│   ├── exports.zsh
│   └── functions.zsh
└── extensions/
    └── ai/
        ├── Brewfile
        ├── bootstrap.sh
        ├── doctor.sh
        └── herdr/
            └── config.toml
```

Root contains core files. Tool-specific configs live under their own directory, symlinked to `~/.config/`. Extensions live under `extensions/` with a self-contained structure.

## Bootstrap

One script provisions a fresh Mac:

```sh
git clone <repo> ~/dotfiles && ~/dotfiles/bootstrap.sh
```

The script:

1. Installs Homebrew
2. Installs packages from Brewfile
3. Creates config symlinks
4. Installs asdf and language runtimes
5. Installs Zed extensions
6. Installs fonts

## Extensions

Extensions are opt-in tool bundles that add capabilities without changing the base setup. Enable them with the `--ext` flag:

```sh
./bootstrap.sh --ext ai        # base setup + AI tools
./bootstrap.sh --ext all       # base setup + all extensions
./doctor.sh --ext ai           # health checks including AI tools
```

Each extension is a self-contained directory under `extensions/` with its own `Brewfile`, `bootstrap.sh`, `doctor.sh`, and config files. Without `--ext`, the base setup runs identically to before.

### AI Extension

Installs tools for AI-assisted development:

- **herdr** — multi-terminal agent multiplexer ("tmux for coding agents"). Manages multiple AI agents in split panes with persistent sessions.
- **pi** — open-source, BYOK terminal-based AI coding agent. Reads codebases, plans changes, edits files, and runs shell commands. Supports 20+ LLM providers.

Config files managed by this repo:
- `extensions/ai/herdr/config.toml` → `~/.config/herdr/config.toml`

### Creating New Extensions

Add a directory under `extensions/` with:

```
extensions/<name>/
├── Brewfile        # packages to install
├── bootstrap.sh    # setup script (sourced, not executed)
├── doctor.sh       # health checks (sourced, not executed)
└── <tool>/
    └── config      # managed config files
```

Extension scripts are sourced by the main scripts and have access to all shared helpers from `lib.sh` (`info`, `success`, `skip`, `link_config`, `check_command`, `check_symlink`, etc.).
