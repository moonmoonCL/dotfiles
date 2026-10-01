# Terminal First Workflow

一套**同时服务 macOS 与 Linux（Pop!_OS / Ubuntu 系）**的终端优先开发工作站配置，单仓库、stow 管理、CI 守门。

日常操作速查见 [USAGE.md](USAGE.md)，完整工作流实战见 [WORKFLOW.md](WORKFLOW.md)，架构与决策细节见 [llmdoc/](llmdoc/index.md)。

## 设计目标

- **终端即 IDE，键盘即鼠标，会话不丢，手不离主键区**——所有高频操作都不离开键盘与主键区
- **单仓库双平台**：平台差异在安装时消化（`install.sh` 按平台选包），共享配置字节级一致，改动一次两台机器同时生效
- **可复现**：Brewfile 管工具、lazy-lock/mise 锁版本、install.sh 幂等可重跑
- **可恢复**：tmux 会话自动保存 + 按项目版本化恢复（`ts`）

## 架构

```text
Ghostty (macOS) / kitty (Linux)
└── tmux                       ← session = 项目，window = 任务
    ├── fish                   ← starship / zoxide / fzf / direnv / mise
    ├── LazyVim
    ├── Lazygit（Prefix+g 浮窗）
    └── Yazi（y 退出即 cd）
```

## 平台策略

macOS 与 Linux 的差异集中在三处，其余全部共享：

| 层 | macOS | Linux |
|--------|--------|--------|
| 终端 | Ghostty | kitty（配置逐项平移，见 `kitty/` 包） |
| 改键 | Karabiner（Caps 双角色、右 Cmd 方向键） | keyd（同样的键位，配置在 `keyd/`，不走 stow） |
| 输入法 | im-select（Ctrl 单击切英文） | 系统输入法（GNOME ibus / fcitx5 均可），中英切换 Ctrl+Space；nvim 内自动切换为可选插件 |

共享的跨平台件：fish + 全部 conf.d 函数（`ts`/`wt`/`tipsy`/`yy`）、tmux（免前缀 M-1..7、IDE 布局、resurrect/continuum 持久化、bell 监控）、LazyVim、lazygit、yazi、`agent-notify` 桌面通知（osascript/notify-send 双实现）。

## 安装（新机器）

前置：macOS 装 Homebrew；Linux 装 [Homebrew](https://brew.sh)（工具链来源）+ 构建工具（keyd 源码编译用）。

```bash
# 1. 克隆到 ~/dotfiles（install.sh 按自身位置定位，放别处也能跑）
git clone git@github.com:moonmoonCL/dotfiles.git ~/dotfiles && cd ~/dotfiles

# 2. 装工具链（两平台共用）；macOS 额外装 cask
brew bundle
brew bundle --file=Brewfile.macos   # 仅 macOS

# 3. 预览将产生的链接（不落盘），确认后实装
./install.sh --dry-run
./install.sh
```

`install.sh` 按 `uname` 自动选包（mac：ghostty+karabiner；Linux：kitty），并安装 TPM。

后续手动步骤：

1. **fish 设为登录 shell**——tmux 依赖它决定 pane 的 shell，必做：
   ```bash
   # macOS
   echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells && chsh -s /opt/homebrew/bin/fish
   # Linux（Homebrew；apt 装的 fish 则为 /usr/bin/fish）
   echo /home/linuxbrew/.linuxbrew/bin/fish | sudo tee -a /etc/shells && chsh -s /home/linuxbrew/.linuxbrew/bin/fish
   ```
2. **密钥**：`cp fish/.config/fish/conf.d/secrets.fish.example secrets.fish` 后填入 API key（gitignore 保护，不入库）。Claude Code 的渠道与 `~/.claude/settings.json` 由 ccswitch 管理，不走 stow。
3. **收尾**：重启终端 → tmux 内 `Ctrl+a` `Shift+i` 装 tmux 插件 → 打开 nvim 等 LazyVim 装插件。
   仅 Linux：keyd 改键与字体的具体命令在 `./install.sh` 结束时打印；输入法用系统自带（GNOME 设置里配 libpinyin 或装 fcitx5）。

## 多机协同

- **单仓库单历史**：`main` 为稳定线（mac 在用），`linux` 分支承载 Linux 侧改造，试运行稳定后经 PR 合入 `main`。
- **同步仪式只有一条**：改完 `git push`；另一台机器 `git pull --ff-only && ./install.sh`（幂等，冲突自动备份）。
- **CI 冒烟闸门**（[.github/workflows/ci.yml](.github/workflows/ci.yml)）：每次 push/PR 在真实 macOS + Ubuntu runner 上跑——fish 语法检查、install.sh dry-run + 实装、fish 启动、tmux 配置解析。合入 `main` 时启用分支保护（要求 smoke 全绿），此后任何进 `main` 的改动都先经过双平台验证。
- 平台专属内容只允许两种形态：独立 stow 包（另一平台不链接），或共享文件内**运行时守卫**且守卫的另一半必须保持原行为。

## 文档地图

| 文档 | 内容 |
|--------|--------|
| [USAGE.md](USAGE.md) | 快捷键与命令速查（含多 agent 并行工作流） |
| [WORKFLOW.md](WORKFLOW.md) | 从开工到收尾的完整实战演练 |
| [llmdoc/index.md](llmdoc/index.md) | 架构文档与决策记录的总入口 |
| [llmdoc/guides/](llmdoc/guides/) | bootstrap / agent 通知回路等操作指南 |
| [agent-rules/](agent-rules/) | agent 规则单一来源（claude/codex/opencode 共享引用） |
