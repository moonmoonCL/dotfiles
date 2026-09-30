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
Ghostty (macOS) / kitty (Linux)
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

同一个仓库服务两台机器：macOS 与 Linux（Pop!_OS / Ubuntu 系）。平台差异全部在安装时消化——`install.sh` 按平台 stow 不同包（mac: ghostty+karabiner，linux: kitty+keyd），共享配置内只有少量 `uname` 守卫；Linux 改键用 [keyd](https://github.com/rvaiya/keyd) 平替 Karabiner，中文输入法用 fcitx5 + fcitx5.nvim 平替 im-select。

---

# 工具总览

| 工具 | 作用 |
|--------|--------|
| Ghostty（macOS）/ kitty（Linux） | 终端模拟器 |
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

Brewfile 是两平台共用的 CLI 工具链（fish、tmux、neovim、stow、mise、direnv 等）。
macOS 额外装 cask（Ghostty、Nerd Font 等）：

```bash
brew bundle --file=Brewfile.macos
```

## 4. Stow 配置

```bash
./install.sh
```

脚本会把所有包 symlink 到 `$HOME`，并安装 TPM（tmux 插件管理器）。

## 5. 设置 fish 为默认 Shell

```bash
# macOS（Homebrew）
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish

# Linux（Homebrew；apt 安装的 fish 则为 /usr/bin/fish）
echo /home/linuxbrew/.linuxbrew/bin/fish | sudo tee -a /etc/shells
chsh -s /home/linuxbrew/.linuxbrew/bin/fish
```

tmux 不再写死 shell 路径，直接使用登录 shell——这一步同时是 tmux 用上 fish 的前提。

## 6. 填入密钥

```bash
cd ~/dotfiles/fish/.config/fish/conf.d
cp secrets.fish.example secrets.fish
```

编辑 `secrets.fish` 填入真实 API key。该文件被 gitignore 保护，不会提交。

Claude Code 的渠道与 `~/.claude/settings.json` 由 ccswitch 管理，不受本仓库的 Stow 安装流程影响。需要配置 `ANTHROPIC_*` 环境变量时，可在 `secrets.fish` 中填写；填完后开新 shell 再启动 `claude` 才会生效。

## 7. 收尾

1. 重启终端（macOS: Ghostty / Linux: kitty）
2. 进入 tmux，按 `Ctrl+a` 然后 `Shift+i` 安装 tmux 插件
3. 打开 nvim，等待 LazyVim 自动安装插件
4. 仅 Linux：keyd 改键、fcitx5 输入法、Nerd Font 字体——`./install.sh` 结束时会打印具体命令

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
