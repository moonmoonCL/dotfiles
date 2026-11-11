# AGENTS.md

Guidance for coding agents working in this repository. Standalone by design — no `@imports`; global agent rules live outside this repo and are not duplicated here. `CLAUDE.md` is a symlink to this file so Codex / Claude Code / opencode share one source of truth.

## What this is

Personal macOS/Linux dotfiles managed with GNU Stow. Terminal-first stack: Ghostty (macOS) / kitty (Linux) → tmux → fish (starship, zoxide, fzf, direnv, mise), plus LazyVim, Lazygit, and Yazi. User-facing docs are in Chinese: `README.md` (intro, toolchain overview, install steps), `USAGE.md` (keybinding/command cheat sheet), and `WORKFLOW.md` (end-to-end workflow walkthrough incl. parallel agents) — keep them in sync with config changes.

## Commands

```bash
./install.sh                       # Restow all packages to $HOME (stow --no-folding -R), install TPM if missing
brew bundle                        # Install/update the toolchain from Brewfile
brew bundle --file=Brewfile.macos  # macOS-only taps/casks (Ghostty, im-select, Nerd Font, ...)
stow --no-folding -R <package>     # Restow a single package (run from repo root)
```

There is no build, lint, or test suite — verification is stowing and exercising the affected tool. CI (`.github/workflows/ci.yml`) runs a two-platform smoke gate (fish syntax, install.sh dry-run + real stow, fish boot, tmux config parse) on every push/PR.

## Architecture: the Stow model

Each stow package's internal tree **exactly mirrors its target layout under `$HOME`**; `install.sh` symlinks each package into `$HOME`. The `PACKAGES` array in `install.sh` (per-platform) is the source of truth for which top-level directories are packages — `docs/`, `.github/`, `scripts/`, and this file are repo metadata, not packages.

| Package | Target |
|---|---|
| `fish` | `~/.config/fish/` |
| `tmux` | `~/.tmux.conf` + `~/.config/tmux/`（resurrect-save、session-history.py） |
| `starship` | `~/.config/starship.toml` |
| `nvim` | `~/.config/nvim/` |
| `karabiner` | `~/.config/karabiner/`（仅 macOS） |
| `ghostty` | `~/.config/ghostty/config`（仅 macOS） |
| `kitty` | `~/.config/kitty/kitty.conf`（仅 Linux） |
| `git` | `~/.gitconfig` |
| `lazygit` | `~/Library/Application Support/lazygit/config.yml` |
| `agent-rules` | `~/.config/agent-rules/`（agent 规则单一来源，见不变量 4） |
| `prompts` | `~/.config/prompts/`（提示词模板，`pt` 选择并复制到粘贴板） |
| `mise` | `~/.config/mise/config.toml.example`（仅示例，真实 config.toml 是机器状态，不 stow） |
| `ssh` | `~/.ssh/config`（仅 macOS） |
| `keyd` | 不走 stow——`install.sh` 收尾时打印手动复制到 `/etc/keyd` 的命令（仅 Linux） |

## Invariants (do not break)

1. **Secrets never enter git.** `**/secrets.fish` is gitignored; only `fish/.config/fish/conf.d/secrets.fish.example` is tracked.
2. **A new stow package must be added to the `PACKAGES` array in `install.sh`**, or it is silently never stowed.
3. **Package trees must mirror `$HOME` layout.** XDG configs go under `foo/.config/foo/...`; a wrong internal path puts symlinks in the wrong place, and stow reports no semantic error.
4. **Agent rules have a single source: `agent-rules/.config/agent-rules/`.** Globally-managed agent configs (outside this repo) import `comment-policy.md` from the stowed `~/.config/agent-rules/`. Edit rules only at the source.
5. **Always `stow --no-folding`.** Without it, stow folds a not-yet-existing target directory into a single symlink into this repo, and the program's runtime data (sqlite, logs) lands inside the repo and pollutes git — this actually happened (see `docs/decisions.md`). This applies to `install.sh` and to manual restow alike.

## Docs map

| Doc | Content |
|---|---|
| [README.md](README.md) | 简介、设计目标、平台策略、安装步骤 |
| [USAGE.md](USAGE.md) | 快捷键与命令速查 |
| [WORKFLOW.md](WORKFLOW.md) | 端到端工作流实战（多 agent 并行） |
| [docs/stow-and-install.md](docs/stow-and-install.md) | Stow 模型、install.sh 内部行为、装机与维护的坑 |
| [docs/terminal-integration.md](docs/terminal-integration.md) | Ghostty/tmux/fish/nvim/Karabiner 跨层咬合关系（改键位前必读） |
| [docs/decisions.md](docs/decisions.md) | 带日期的决策记录 |
