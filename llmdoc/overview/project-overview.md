# 项目概览

## 身份

个人 macOS 工作站的 dotfiles 仓库：一套终端优先、键盘驱动的开发环境。

- 终端栈：Ghostty（终端）→ tmux（会话/窗格）→ fish（shell）。
- 编辑与文件：LazyVim（近乎原生的 Neovim 发行版）、Lazygit、Yazi。
- 运行时与环境：mise（语言运行时版本管理）、direnv（目录级环境变量）。
- 输入层：Karabiner-Elements 做键位改造（Caps→Ctrl、tap-Esc 重置输入法等），配合 vim/tmux 模态工作流。
- AI agent 配置：agent 行为规则单一来源化（`agent-rules/`），分发给 Claude / Codex / opencode。

## 目标

- **可迁移**：换机器时 clone 到 `~/dotfiles`，`brew bundle` + `./install.sh` 即可重建环境。
- **可恢复**：配置全部纳入版本控制；tmux-resurrect/continuum 保存会话状态。
- **长期维护**：单人拥有，配置演进有 git 历史，llmdoc 记录结构性知识。

## 边界

- 只面向 macOS（Homebrew 路径、pbcopy、Karabiner 均为 macOS 专属）。
- 个人仓库，不追求通用性或跨平台兼容。
- 不管理机器上的全部软件——`Brewfile` 覆盖 CLI 工具链和少量 cask，系统级设置不在此仓库内。

## 主要区域

- Stow 包与安装流程：`llmdoc/architecture/stow-install-model.md`
- 终端各组件如何咬合：`llmdoc/architecture/terminal-runtime-integration.md`
- Agent 规则分发契约：`llmdoc/reference/agent-rules-wiring.md`
