# Terminal First Workflow

我的个人开发工作站。

目标：

- Terminal First
- Keyboard Driven
- Git Managed
- 可迁移
- 可恢复
- 长期维护

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
| mise | 运行时版本管理 |
| direnv | 项目环境变量管理 |
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

位置必须是 `~/dotfiles`（`install.sh` 硬编码）：

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

## 7. 收尾

1. 重启 Ghostty
2. 进入 tmux，按 `Ctrl+a` 然后 `Shift+i` 安装 tmux 插件
3. 打开 nvim，等待 LazyVim 自动安装插件

---

# Ghostty

现代终端模拟器。

特点：

- 极快
- 原生支持 GPU 渲染
- 配置简单
- 与 tmux 配合优秀

作用：

```text
Ghostty
↓
tmux
↓
所有开发工作
```

常用操作：

```text
Cmd + T
新标签页

Cmd + W
关闭标签页

Cmd + Shift + ]
切换标签页

Cmd + Shift + [
切换标签页
```

---

# tmux

Terminal Multiplexer。

解决：

- 多窗口
- 多 Pane
- Session 持久化
- SSH 断线恢复

---

## 核心概念

```text
Session
└── Window
    └── Pane
```

---

## Prefix

```text
Ctrl + a
```

---

## 常用快捷键

### Window

| 快捷键 | 功能 |
|----------|----------|
| Prefix + c | 新建窗口 |
| Prefix + n | 下一个窗口 |
| Prefix + p | 上一个窗口 |
| Prefix + 数字 | 跳转窗口 |
| Prefix + , | 重命名窗口 |

---

### Pane

| 快捷键 | 功能 |
|----------|----------|
| Prefix + - | 垂直分屏 |
| Prefix + _ | 水平分屏 |
| Prefix + h/j/k/l | Pane切换 |
| Prefix + z | Pane最大化 |
| Prefix + x | 关闭Pane |

---

### Session

| 快捷键 | 功能 |
|----------|----------|
| Prefix + d | Detach |
| tmux ls | 查看Session |
| tmux attach | 恢复Session |

---

### 配置

重新加载：

```bash
Prefix + r
```

---

# fish

现代 Shell。

特点：

- 默认可用
- 自动补全优秀
- 语法高亮
- 配置简单

---

## 重新加载配置

```fish
source ~/.config/fish/config.fish
```

---

## 查看当前Shell

```fish
echo $SHELL
```

---

## Alias

推荐使用：

```fish
abbr
```

例如：

```fish
abbr -a lg lazygit
abbr -a y yy
```

---

## 查看环境变量

```fish
echo $PATH

echo $OPENAI_API_KEY
```

---

# starship

Prompt 美化工具。

作用：

显示：

```text
Git状态
Node版本
Python版本
目录
命令耗时
```

例如：

```text
frontend on main via Node v24
❯
```

---

## 刷新

```fish
exec fish
```

---

# zoxide

智能 cd。

替代：

```bash
cd
```

---

## 使用

传统：

```bash
cd ~/Workspace/thus-spoke/frontend
```

zoxide：

```bash
z frontend
```

---

## 添加权重

访问越多：

```text
目录排名越高
```

---

## 查询

```bash
zi
```

交互式选择目录。

---

# fzf

模糊搜索工具。

作用：

```text
文件搜索
命令搜索
目录搜索
历史搜索
```

---

## 历史命令

```text
Ctrl + r
```

搜索历史命令。

---

## 文件搜索

```bash
fzf
```

---

# mise

运行时版本管理器。

替代：

```text
nvm
pyenv
asdf
```

---

## 支持

```text
Node
Python
Go
Rust
Java
...
```

---

## 查看版本

```bash
mise ls
```

---

## 安装 Node

```bash
mise use -g node@24
```

---

## 当前版本

```bash
node -v
```

---

## 项目版本管理

项目目录：

```text
.mise.toml
```

例如：

```toml
[tools]
node = "24"
```

进入项目自动切换。

---

# direnv

项目环境变量管理。

作用：

```text
进入项目
↓
自动加载变量

离开项目
↓
自动卸载变量
```

---

## 创建

```bash
touch .envrc
```

---

## 允许

```bash
direnv allow
```

---

## 示例

```bash
export OPENAI_API_KEY=xxx
```

---

## 查看状态

```bash
direnv status
```

---

# LazyVim

Neovim 发行版。

特点：

- 开箱即用
- 插件生态完善
- LSP默认集成

---

## Leader键

```text
Space
```

---

## 文件搜索

```text
Space + f + f
```

---

## 全局搜索

```text
Space + s + g
```

---

## Buffer切换

```text
Shift + h
Shift + l
```

---

## Lazy面板

```text
:Lazy
```

---

## Mason

```text
:Mason
```

安装：

```text
LSP
Formatter
Linter
```

---

## 插件配置目录

```text
lua/plugins
```

---

## 核心配置目录

```text
lua/config
```

---

# Lazygit

Git TUI。

作用：

```text
add
commit
push
pull
stash
rebase
```

全部图形化。

---

## 启动

```bash
lg
```

---

## 常用操作

| 按键 | 功能 |
|--------|--------|
| Space | Stage |
| c | Commit |
| P | Push |
| p | Pull |
| s | Stash |
| q | 退出 |

---

## 工作流

```text
修改代码
↓
lg
↓
Space
↓
c
↓
P
```

---

# Yazi

现代终端文件管理器。

特点：

- 快
- 支持预览
- 支持图片
- 支持插件

---

## 启动

```bash
y
```

---

## 导航

| 按键 | 功能 |
|--------|--------|
| j | 下 |
| k | 上 |
| h | 返回 |
| l | 进入 |
| gg | 顶部 |
| G | 底部 |

---

## 搜索

```text
/
```

---

## 跳转目录

```text
z
```

利用 zoxide 跳转。

---

## 隐藏文件

```text
.
```

显示/隐藏。

---

## 退出

```text
q
```

---

## yy

推荐使用：

```bash
yy
```

作用：

```text
进入Yazi
↓
浏览目录
↓
退出
↓
自动cd到当前目录
```

例如：

```bash
yy
```

进入：

```text
Workspace
└── thus-spoke
    └── frontend
```

退出：

```text
q
```

当前目录自动切换到：

```text
~/Workspace/thus-spoke/frontend
```

---

# 推荐工作流

```text
Ghostty
↓
tmux

Pane1
  LazyVim

Pane2
  Yazi

Pane3
  Lazygit

Pane4
  Agent
```

---

# 常用命令

```bash
y
```

打开文件管理器

```bash
lg
```

打开 Lazygit

```bash
z project
```

跳转项目

```bash
zi
```

搜索目录

```bash
direnv status
```

查看环境变量状态

```bash
mise ls
```

查看工具版本

```bash
tmux ls
```

查看 Session

```fish
source ~/.config/fish/config.fish
```

刷新 Fish

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
