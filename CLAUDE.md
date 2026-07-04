# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal macOS dotfiles managed with GNU Stow. Terminal-first stack: Ghostty → tmux → fish (starship, zoxide, fzf, direnv, mise), plus LazyVim, Lazygit, and Yazi. User-facing docs are in Chinese: `README.md` (intro, toolchain overview, install steps) and `USAGE.md` (keybinding/command cheat sheet) — keep both in sync with config changes.

Project knowledge lives in `llmdoc/` — read `llmdoc/startup.md` first; it routes to the must-read docs (`llmdoc/must/`) and deeper architecture/reference docs per task. `.llmdoc-tmp/` is a gitignored temporary context cache, not a source of truth.

## Commands

```bash
./install.sh            # Restow all packages to $HOME (stow -R), install TPM if missing
brew bundle             # Install/update the toolchain from Brewfile
stow -R <package>       # Restow a single package (run from repo root)
```

There is no build, lint, or test suite — verification is stowing and exercising the affected tool.

## Architecture: the Stow model

Every top-level directory (except `llmdoc/`) is a stow package whose internal tree **exactly mirrors the target layout under `$HOME`**. `install.sh` symlinks each package into `$HOME`.

| Package | Target |
|---|---|
| `fish` | `~/.config/fish/` |
| `tmux` | `~/.tmux.conf` |
| `starship` | `~/.config/starship.toml` |
| `nvim` | `~/.config/nvim/` |
| `karabiner` | `~/.config/karabiner/` |
| `ghostty` | `~/.config/ghostty/config` |
| `git` | `~/.gitconfig` |
| `lazygit` | `~/Library/Application Support/lazygit/config.yml` |
| `agent-rules` | `~/.config/agent-rules/` |
| `claude` | `~/.claude/CLAUDE.md` |
| `codex` | `~/.codex/AGENTS.md` |
| `opencode` | `~/.config/opencode/AGENTS.md` |

## Invariants (do not break)

1. **Secrets never enter git.** `**/secrets.fish` is gitignored; only `fish/.config/fish/conf.d/secrets.fish.example` is tracked.
2. **A new stow package must be added to the `PACKAGES` array in `install.sh`**, or it is silently never stowed.
3. **Package trees must mirror `$HOME` layout.** XDG configs go under `foo/.config/foo/...`; a wrong internal path puts symlinks in the wrong place.
4. **Agent rules have a single source: `agent-rules/.config/agent-rules/`** (`comment-policy.md`, `llmdoc-policy.md`). Entry files reference them — `claude/.claude/CLAUDE.md` via `@import`, while `codex/.codex/AGENTS.md` and `opencode/.config/opencode/AGENTS.md` are symlinks to `comment-policy.md`. Edit rules only at the source; never replace the symlinks with text copies. See `llmdoc/reference/agent-rules-wiring.md`.
