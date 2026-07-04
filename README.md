# Terminal First Workflow

我的个人开发工作站。

目标：

- Terminal First
- Keyboard Driven
- Git Managed
- 可迁移
- 可恢复
- 长期维护

日常操作与快捷键速查见 [USAGE.md](USAGE.md)；完整工作流实战演练见 [WORKFLOW.md](WORKFLOW.md)。

---

# 工作站架构

```text
Ghostty
└── tmux
    ├── fish
    │   ├── starship
    │   ├── zoxide
    │   ├── fzf
    │   ├── direnv
    │   └── mise
    │
    ├── LazyVim
    ├── Lazygit
    └── Yazi
```

---

# 工具总览

| 工具 | 作用 |
|--------|--------|
| Ghostty | 现代终端模拟器 |
| tmux | Terminal Multiplexer，多窗口管理 |
| fish | Shell |
| starship | 跨平台 Prompt |
| zoxide | 智能目录跳转 |
| fzf | 模糊搜索 |
| ripgrep | 全文搜索（LazyVim 全局搜索依赖） |
| fd | 文件查找（fzf 数据源） |
| bat | 带高亮的 cat（fzf/yazi 预览） |
| eza | 现代 ls |
| mise | 运行时版本管理 |
| direnv | 项目环境变量管理 |
| git-delta | Git diff 高亮（git/lazygit 共用） |
| LazyVim | Neovim 发行版 |
| Lazygit | Git TUI |
| Yazi | 文件管理器 |

---

# 安装

新机器从零到可用，按以下顺序执行。

## 1. 安装 Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 2. Clone 仓库

推荐放在 `~/dotfiles`（`install.sh` 会按自身位置定位仓库，放别处也能跑）：

```bash
git clone git@github.com:moonmoonCL/dotfiles.git ~/dotfiles
```

## 3. 安装工具链

```bash
cd ~/dotfiles
brew bundle
```

Brewfile 包含全部 CLI 工具（fish、tmux、neovim、stow、mise、direnv 等）和 cask（Ghostty、Nerd Font）。

## 4. Stow 配置

```bash
./install.sh
```

脚本会把所有包 symlink 到 `$HOME`，并安装 TPM（tmux 插件管理器）。

## 5. 设置 fish 为默认 Shell

```bash
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

## 6. 填入密钥

```bash
cd ~/dotfiles/fish/.config/fish/conf.d
cp secrets.fish.example secrets.fish
```

编辑 `secrets.fish` 填入真实 API key。该文件被 gitignore 保护，不会提交。

Claude Code 的 `ANTHROPIC_*` 中转站配置（token、base URL、模型映射）也在这里填——仓库跟踪的 `claude/.claude/settings.json` 只含 hooks、statusLine、插件列表，不含任何凭据。填完后开新 shell 再启动 `claude` 才会生效。

## 7. 收尾

1. 重启 Ghostty
2. 进入 tmux，按 `Ctrl+a` 然后 `Shift+i` 安装 tmux 插件
3. 打开 nvim，等待 LazyVim 自动安装插件

---

# 核心理念

- 用键盘而不是鼠标
- 用终端而不是 GUI
- 用 Git 管理配置
- 用 Stow 管理配置文件
- 用 mise 管理运行时
- 用 direnv 管理环境变量
- 用 tmux 管理工作空间
- 保持配置简单、可迁移、可恢复
