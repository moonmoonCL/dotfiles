# Architecture: 终端运行时集成

## Purpose

说明 Ghostty、tmux、fish、Neovim、Karabiner 五个组件如何互相咬合成一套键盘驱动工作流。改任何一层的键位或初始化顺序前先读本文，避免破坏跨层配对；改键位后同步更新 `USAGE.md` 速查表。

## Ghostty（`ghostty/.config/ghostty/config`）

- 字体 JetBrainsMono Nerd Font 15，`background-opacity = 0.92`，`copy-on-select = true`。
- `macos-option-as-alt = true`：让 Option 发送 Alt/Meta——这是 tmux `M-1..M-7` 窗口切换能工作的前提。改掉此项会静默废掉 tmux 的免前缀窗口切换。
- `shell-integration = fish`，与 tmux 的 `default-shell /opt/homebrew/bin/fish` 一起保证两层都是 fish。
- 无自定义主题和 keybind，其余为 Ghostty 默认。

## tmux（`tmux/.tmux.conf`）

- Prefix 改为 `C-a`；vi mode（`mode-keys vi`）；mouse on；status bar 置顶；window/pane 从 1 起编号；history 100000。
- 免前缀窗口切换：`M-1`..`M-5`（依赖上述 Ghostty option-as-alt）。
- 分屏继承 CWD（`-c "#{pane_current_path}"`），`-`/`_` 为上下/左右分屏（`"`/`%` 保留同行为）；`prefix r` 重载配置；`H/J/K/L` 可重复调整窗格大小；`prefix W` 构建 IDE 布局（左主窗格 75% + 右侧堆叠）；`prefix y` 同步窗格输入。
- popup 浮窗：`prefix g` 弹出 lazygit、`prefix t` 弹出临时终端，均在当前 pane 目录、`-E` 退出即关。
- agent 铃声监控：`monitor-bell on` + `bell-action other`，非当前窗口响铃（Claude Code 停下时发 bell）则窗口名黄底高亮——多 agent 并行时判断"谁在等我"。黄底样式由 `window-status-format` 里的 `window_bell_flag` 条件渲染（不再用 `window-status-bell-style`，会被 format 内联颜色覆盖）。
- 状态栏手写 Tokyo Night 样式（无主题插件）：`status-style bg=default` 透出 Ghostty 半透明背景；左侧 session 名蓝色圆角胶囊，当前窗口 `#292e42` 底 `#7aa2f7` 字胶囊，非当前窗口灰字，响铃窗口黄底；右侧 prefix 按下时显示黄色 PREFIX 指示 + 日期时间。圆角依赖 Nerd Font 的 powerline 扩展字形（Ghostty 已配 JetBrainsMono Nerd Font）。
- copy-mode-vi 中 `y` 走 `pbcopy`（macOS 剪贴板）。
- TPM 插件：
  - `tmux-resurrect` + `tmux-continuum`：每 10 分钟自动保存（`@continuum-save-interval '10'`），启动时**不**自动恢复（`@continuum-restore 'off'`）——恢复需手动触发。
  - `christoomey/vim-tmux-navigator`：tmux 侧的 C-hjkl 导航，与 nvim 侧配对（见下）。

## fish（`fish/.config/fish/`）

- `config.fish` 交互式初始化顺序（有意为此序）：starship → zoxide → fzf → mise → direnv。
- `conf.d/` 自动加载（字母序）：
  - `env.fish`：`EDITOR`/`VISUAL = nvim`。
  - `aliases.fish`：全部是 `abbr`。git 系（`g/gs/ga/gc/gp/gl/gco/gd/gds/lg`）、`vim`→`nvim`、`c`、`ll`→`eza -la --git --icons`、tmux（`ta`/`tn`）、`y`→`yy`（yazi 包装函数，定义在 `conf.d/yazi.fish`：退出 yazi 后自动 cd 到浏览目录）、pi-agent 系（`pp/piq/ppq`）、`chromedap`（Chrome 远程调试端口 9222）。
  - `fzf.fish`：`FZF_DEFAULT_COMMAND`/`FZF_CTRL_T_COMMAND` 用 fd（含隐藏文件、忽略 .git），`Ctrl+T` 带 bat 预览。
  - `tmux-sessionizer.fish`：`ts` 函数——zoxide 目录列表喂 fzf，选中后创建/切换以目录名命名的 tmux session（session 名中 `.`/`:` 替换为 `_`）。
  - `worktree-agent.fish`：多 agent 并行的胶水。`wt <名>` 在 `~/worktrees/<仓库>/<名>` 建 worktree + 同名分支 + 同名 tmux window 并跳入（tmux 外则 cd）；`wtd <名>` 合并后删 worktree 和分支（`branch -d`，未合并会拒绝）。与 tmux bell 监控、Claude Code 通知 hook（由 ccswitch 管理的 `~/.claude/settings.json` 中的 Notification/Stop 事件 → osascript 系统通知 + bell）构成三层监控。
  - `proxy.fish`：`sson` 设置 `http_proxy`/`https_proxy`/`all_proxy` 指向 `127.0.0.1:7890`（Clash 默认端口），`ssoff` 清除。**文件末尾用 `nc -z 127.0.0.1 7890` 探测：Clash 在监听才自动 `sson`**——直连网络（Clash 未运行）下新 shell 不设代理。排查网络问题仍先确认当前 shell 的代理状态。
  - `uv.env.fish`：直接把 `~/.local/bin` 前置到 PATH（内联了 uv 安装器生成的 `~/.local/bin/env.fish` 的内容，不再 source 该文件）。
  - `secrets.fish`：本地真实密钥文件，conf.d 自动 source；仓库只有 `.example` 模板（OPENROUTER/DEEPSEEK/ZHIPUAI/TAVILY key）。
- PATH 基本由 mise/uv/Homebrew 运行时组装，没有集中的硬编码 PATH 文件。

## Neovim（`nvim/.config/nvim/`，近乎原生 LazyVim）

- bootstrap（`init.lua`、`lua/config/lazy.lua`）、`options.lua`、`keymaps.lua` 全是 LazyVim 模板原样——**不要把 LazyVim 默认行为当作本仓库的定制来记录**。
- 真实定制只有五处：
  1. `lua/plugins/tmux.lua`：vim-tmux-navigator，映射 `<C-h/j/k/l>` 和 `<C-\>` 到 TmuxNavigate*——这是全配置里唯一的自定义 keymap 来源，与 `.tmux.conf` 中的同名 TPM 插件配对，实现 nvim split 与 tmux pane 的统一 C-hjkl 移动。
  2. `lua/plugins/conform.lua`：formatter 映射（lua=stylua、python=ruff_format、js/ts/json/yaml/markdown=prettier、sh=shfmt）。
  3. `lua/plugins/theme.lua`：tokyonight 透明化（transparent + sidebars/floats transparent），不换色。
  4. `lua/config/autocmds.lua`：markdown 关闭 spell。
  5. `lua/plugins/markdown.lua`：从 nvim-lint 摘掉 markdown 的 markdownlint-cli2（风格规则对中文文档全是噪音）；markdown-preview.nvim（`<leader>cp`）使用 `mkdp_theme=light`；`lang.markdown` extra 其余部分（marksman、render-markdown、prettier）保留。
- LazyVim extras（`lazyvim.json`）：neo-tree、lang.{go,json,markdown,python,tailwind,toml,typescript(+vtsls)}、util.mini-hipatterns。
- **`lua/plugins/example.lua` 是惰性样板**：第 3 行 `if true then return {} end` 直接短路，其下的 gruvbox/telescope/pyright 等全部不生效。切勿当作活跃配置记录。

## Karabiner（`karabiner/.config/karabiner/karabiner.json`）

- `caps_lock` → `left_control`。
- `left_control` 双角色：按住配合其他键为 Ctrl；单击 tap 发送 `escape` 并执行 `im-select com.apple.keylayout.ABC`（退出插入模式同时把输入法重置为英文——vim 中文用户的经典配置）。
- `right_command + h/j/k/l` → 方向键；`right_command + ,/.` → Home/End；`right_shift` → `Ctrl+Space`（输入法切换）。

## 跨层配对总结（改一处需检查另一处）

| 配对 | 两端 |
|---|---|
| C-hjkl 统一导航 | `nvim/lua/plugins/tmux.lua` ↔ `tmux/.tmux.conf` 的 vim-tmux-navigator 插件 |
| M-1..7 窗口切换 | ghostty `macos-option-as-alt` ↔ tmux `M-数字` 绑定 |
| fish 作为 shell | ghostty `shell-integration = fish` ↔ tmux `default-shell` |
| nvim 中心化 | fish `EDITOR=nvim` + `vim`→`nvim` abbr ↔ karabiner tap-Esc 重置输入法 |

## Related Docs

- `llmdoc/architecture/stow-install-model.md`：这些配置如何被部署到 `$HOME`。
- `llmdoc/must/working-agreement.md`：secrets 与包结构不变量。
