# Dotfiles

我的个人开发环境配置仓库。

目标：

* 配置版本化管理
* 新 Mac 快速恢复
* Terminal First 工作流
* 尽量减少 GUI 依赖
* 一套配置长期维护

---

# 工作站架构

```text
Ghostty
└── tmux
    ├── fish
    │   ├── starship
    │   ├── zoxide
    │   ├── fzf
    │   ├── direnv（可选）
    │   └── mise（可选）
    │
    ├── nvim（LazyVim）
    ├── lazygit
    └── yazi
```

---

# 工具说明

| 工具       | 作用                   |
| -------- | -------------------- |
| Ghostty  | 终端模拟器                |
| tmux     | Session 管理、窗口管理、断线恢复 |
| fish     | Shell                |
| starship | Prompt 美化            |
| zoxide   | 智能目录跳转               |
| fzf      | 模糊搜索                 |
| nvim     | 编辑器                  |
| LazyVim  | Neovim 发行版           |
| lazygit  | Git TUI              |
| yazi     | 文件管理器                |
| stow     | Dotfiles 管理          |
| direnv   | 项目环境变量管理             |
| mise     | 语言版本管理               |

---

# 仓库结构

```text
dotfiles/
├── Brewfile
├── README.md
├── install.sh
│
├── fish/
├── tmux/
├── starship/
├── nvim/
├── karabiner/
├── ghostty/
│
└── docs/
    ├── fish.md
    ├── tmux.md
    ├── nvim.md
    └── migration.md
```

---

# 配置管理方案

本仓库使用 GNU Stow 管理配置。

例如：

```text
dotfiles/fish/.config/fish
        │
        ▼
~/.config/fish
```

通过符号链接（symlink）接管配置文件，而不是直接复制。

优点：

* 配置集中管理
* Git 可追踪
* 新机器恢复简单
* 不影响原有软件运行

---

# 首次安装

## 1. 安装 Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## 2. 克隆仓库

```bash
git clone <YOUR_REPOSITORY_URL> ~/dotfiles

cd ~/dotfiles
```

---

## 3. 安装软件

```bash
brew bundle
```

根据 Brewfile 安装所有依赖。

---

## 4. 应用配置

```bash
chmod +x install.sh

./install.sh
```

---

## 5. 安装 tmux 插件

TPM（Tmux Plugin Manager）：

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

进入 tmux 后执行：

```text
Ctrl+a
Shift+i
```

安装插件。

---

# 新 Mac 恢复流程

```bash
git clone <YOUR_REPOSITORY_URL> ~/dotfiles

cd ~/dotfiles

brew bundle

./install.sh
```

然后：

```text
打开 tmux
Ctrl+a
Shift+i
```

即可恢复完整环境。

---

# 常用命令

## 更新 Brewfile

安装或删除软件后：

```bash
brew bundle dump --force
```

---

## 提交配置

```bash
git add .

git commit -m "update dotfiles"

git push
```

---

## 查看 Stow 是否接管成功

```bash
ls -ld ~/.config/fish

ls -ld ~/.config/nvim

ls -ld ~/.config/ghostty
```

正确结果：

```text
~/.config/fish -> ~/dotfiles/fish/.config/fish

~/.config/nvim -> ~/dotfiles/nvim/.config/nvim
```

---

# tmux

前缀键：

```text
Ctrl+a
```

常用快捷键：

| 快捷键              | 功能         |
| ---------------- | ---------- |
| Prefix + c       | 新建窗口       |
| Prefix + 数字      | 切换窗口       |
| Prefix + h/j/k/l | 切换 Pane    |
| Prefix + -       | 垂直分屏       |
| Prefix + _       | 水平分屏       |
| Prefix + z       | Pane 最大化   |
| Prefix + d       | 分离 Session |
| Prefix + r       | 重新加载配置     |

---

# fish

重新加载配置：

```fish
source ~/.config/fish/config.fish
```

查看当前 Shell：

```fish
echo $SHELL
```

---

# Neovim

发行版：

LazyVim

配置目录：

```text
~/.config/nvim
```

插件配置：

```text
lua/plugins
```

核心配置：

```text
lua/config
```

插件锁定文件：

```text
lazy-lock.json
```

建议提交到 Git，以保证不同机器的插件版本一致。

---

# 维护原则

1. 配置进入 Git
2. 软件交给 Brew 管理
3. 配置交给 Stow 管理
4. 优先精简工具，而不是增加工具
5. 保持环境可迁移、可恢复

---

最后更新：

2026
macOS + Ghostty + tmux + fish + LazyVim

