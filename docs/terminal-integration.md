# 终端运行时集成

Ghostty（macOS）/ kitty（Linux）、tmux、fish、Neovim、Karabiner（macOS）/ keyd（Linux）如何互相咬合成一套键盘驱动工作流。改任何一层的键位或初始化顺序前先读本文，避免破坏跨层配对；改键位后同步更新 [USAGE.md](../USAGE.md) 速查表。

## Ghostty（macOS）/ kitty（Linux）

- 字体 JetBrainsMono Nerd Font 15，copy-on-select；kitty 半透明（opacity 0.92），ghostty 当前不透明（opacity = 1）——两份配置除 opacity 外逐项平移。
- `macos-option-as-alt = true`：让 Option 发送 Alt/Meta——这是 tmux `M-1..M-7` 免前缀窗口切换能工作的前提。改掉此项会静默废掉 tmux 的免前缀窗口切换。
- shell-integration 指向 fish，与 tmux 一起保证两层都是 fish。tmux 不再写死 `default-shell` 路径，用 chsh 后的登录 shell。

## tmux

- Prefix 改为 `C-a`；vi mode；mouse on；window/pane 从 1 起编号；免前缀 `M-1..M-7` 切窗口；分屏继承 CWD（`-`/`_` 为上下/左右）；`H/J/K/L` 调整窗格大小；`prefix W` 构建 IDE 布局（左主区 75% + 右侧堆叠）；`prefix y` 同步窗格输入；popup 浮窗 `prefix g`（lazygit）、`prefix t`（临时终端）。
- agent 铃声监控：`monitor-bell on` + `bell-action other`——非当前窗口响铃（agent 停下时发 bell）则窗口名黄底高亮，多 agent 并行时判断"谁在等我"。黄底样式由 `window-status-format` 里的 `window_bell_flag` 条件渲染（不用 `window-status-bell-style`，会被 format 内联颜色覆盖）。桌面通知由机器本地的 agent hook 负责，不在本仓库。
- 状态栏手写 Tokyo Night 样式（无主题插件），`bg=default` 透出终端背景（kitty 的半透明随之生效；ghostty 当前不透明）；圆角依赖 Nerd Font 字形。
- copy-mode 中 `y` 走 `if-shell` 选 pbcopy/wl-copy/xclip（双平台剪贴板）。
- TPM 插件：`tmux-resurrect` + `tmux-continuum`（每 10 分钟自动保存，启动**不**自动恢复），与 `session-history.py` 用同一文件锁串行化；`christoomey/vim-tmux-navigator`。持久化权属：自动保存 = continuum；手动兜底 = `prefix C-s`；恢复 = `ts` 历史（按 session）或 `prefix C-r`（整个 server），后者是唯一恢复界面。

## fish

- `config.fish` 交互式初始化顺序（有意为此序）：starship → zoxide → fzf → mise → direnv。
- `conf.d/` 自动加载（字母序）：`aliases.fish`（全部 abbr：git 系、`vim`→nvim、tmux 系、`y`→yy）、`brew.fish`（补 Homebrew PATH——桌面直启的终端不读 shell rc）、`env.fish`（EDITOR=nvim）、`fzf.fish`（fd 数据源 + bat 预览）、`go.env.fish`（`~/go/bin` 入 PATH）、`opencode-background-subagents.fish`（OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true）、`proxy.fish`（`sson`/`ssoff` 指向 Clash 7890；文件末尾 `nc -z` 探测——Clash 在监听才自动开代理）、`tmux-sessionizer.fish`（`ts`——活跃 session 优先直切，已关闭项目从 resurrect 历史按版本恢复，无历史才新建）、`tipsy-workspace.fish`（`tipsy` 聚合 Tipsy 仓库与 worktree）、`uv.env.fish`（`~/.local/bin` 前置）、`worktree-agent.fish`（`wt`/`wtd` 多 agent 并行胶水）、`yazi.fish`（定义 `yy`：退出 yazi 后自动 cd，`y` abbr 依赖它）、`secrets.fish`（本地密钥，仓库只有 `.example`）。
- PATH 由 mise/uv/Homebrew 运行时组装，没有集中的硬编码 PATH 文件。

## Neovim（近乎原生 LazyVim）

- bootstrap、options、keymaps 全是 LazyVim 模板原样——**不要把 LazyVim 默认行为当作本仓库的定制**。真实定制只有五处：
  1. `lua/plugins/tmux.lua`：vim-tmux-navigator（`<C-h/j/k/l>` + `<C-\>`），全配置唯一的自定义 keymap 来源。
  2. `lua/plugins/conform.lua`：formatter 映射（stylua/ruff/prettier/shfmt）。
  3. `lua/plugins/theme.lua`：tokyonight 透明化。
  4. `lua/config/autocmds.lua`：markdown 关 spell。
  5. `lua/plugins/markdown.lua`：摘掉 markdownlint-cli2（中文文档噪音）；markdown-preview 用亮色主题。
- **`lua/plugins/example.lua` 是惰性样板**：第 3 行 `if true then return {} end` 短路，其下内容全部不生效，切勿当作活跃配置。

## Karabiner（macOS）/ keyd（Linux）

- `caps_lock` → `left_control`；`left_control` 双角色：按住为 Ctrl，单击发 `escape` 并执行 im-select 重置输入法为英文（vim 中文用户经典配置）。
- `right_command + h/j/k/l` → 方向键（keyd 同样键位）；`right_shift` → `Ctrl+Space`（输入法切换）。

## 跨层配对总结（改一处需检查另一处）

| 配对 | 两端 |
|---|---|
| C-hjkl 统一导航 | `nvim/lua/plugins/tmux.lua` ↔ `tmux/.tmux.conf` 的 vim-tmux-navigator 插件 |
| M-1..7 窗口切换 | ghostty `macos-option-as-alt` ↔ tmux `M-数字` 绑定 |
| fish 作为 shell | ghostty/kitty 的 shell-integration ↔ chsh 的登录 shell |
| nvim 中心化 | fish `EDITOR=nvim` + `vim`→`nvim` abbr ↔ karabiner 单击 Ctrl 发 Esc 重置输入法 |

部署这些配置的 Stow 模型见 [stow-and-install.md](stow-and-install.md)。
