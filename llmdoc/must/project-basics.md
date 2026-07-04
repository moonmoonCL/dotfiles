# 项目基础

## 这是什么

个人 macOS dotfiles 仓库，用 GNU Stow 管理。终端优先工作流：Ghostty → tmux → fish → LazyVim。README 为中文长文档。

## Stow 模型

- 每个顶层目录是一个 stow package，其内部目录树精确镜像 `$HOME` 下的目标布局。
- `install.sh` 从 `$HOME/dotfiles` 执行 `stow <package>`，把包内容 symlink 到 `$HOME`。
- `install.sh` 按自身所在目录定位仓库，惯例路径为 `~/dotfiles`。

## Package -> $HOME 映射

| Package | 目标 |
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

## 深入阅读

- Stow/安装模型：`llmdoc/architecture/stow-install-model.md`
- 终端运行时集成：`llmdoc/architecture/terminal-runtime-integration.md`
