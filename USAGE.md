# 使用手册

日常操作速查。工作流：Ghostty 进 tmux，每个项目一个 session（`ts` 创建、恢复或切换），编辑用 LazyVim，Git 用 Lazygit（`Prefix + g` 弹出），文件浏览用 Yazi。

tmux Prefix 为 `Ctrl + a`。

| 工具 | 按键 / 命令 | 功能 |
|--------|--------|--------|
| Ghostty | `Cmd + T` / `Cmd + W` | 新建 / 关闭标签页 |
| Ghostty | `Cmd + Shift + [` / `]` | 切换标签页 |
| tmux | `ts` | fzf 选目录；切换活跃 session，或选择历史版本恢复/新建同名 session |
| tmux | `ta <名>` / `tn <名>` | attach / 新建 session |
| tmux | `Prefix + d` | Detach |
| tmux | `Prefix + S` | Session 列表 |
| tmux | `Prefix + c` | 新建窗口 |
| tmux | `Option + 1..7` | 直接切换窗口（无需 Prefix） |
| tmux | `Prefix + n` / `p` / `数字` | 下一个 / 上一个 / 跳转窗口 |
| tmux | `Prefix + ,` | 重命名窗口 |
| tmux | `Prefix + -` / `_` | 上下 / 左右分屏（继承当前目录） |
| tmux | `Ctrl + h/j/k/l` | Pane 切换（无需 Prefix，与 nvim 窗口互通） |
| tmux | `Prefix + H/J/K/L` | 调整 Pane 大小（可连按） |
| tmux | `Prefix + z` | Pane 最大化 / 还原 |
| tmux | `Prefix + x` / `X` | 关闭 Pane / 窗口 |
| tmux | `Prefix + W` | IDE 布局（左主区 75% + 右侧堆叠） |
| tmux | `Prefix + g` | 弹出 Lazygit 浮窗（q 退出） |
| tmux | `Prefix + t` | 弹出临时终端浮窗 |
| tmux | `Prefix + y` | 同步所有 Pane 输入 |
| tmux | `Prefix + r` | 重载配置 |
| tmux | `Prefix + Ctrl + s` | 立即保存所有 session，供关闭后按项目恢复 |
| tmux | `Prefix + Ctrl + r` | 从最新快照恢复整个 tmux server |
| fish | `Ctrl + R` | fzf 搜索历史命令 |
| fish | `Ctrl + T` | fzf 搜索文件（fd 数据源 + bat 预览） |
| fish | `z <名>` / `zi` | zoxide 跳目录 / 交互选目录 |
| fish | `ll` | eza 列表（含 git 状态和图标） |
| fish | `y` | 进入 Yazi，退出后自动 cd |
| fish | `tipsy` | fzf 列出 Tipsy 仓库和 worktree 的服务、分支、脏状态、PR，选中后进入目录 |
| fish | `tipsy --list` | 输出同一清单，便于搜索或脚本使用 |
| fish | `wt <任务名>` | 建 worktree + 分支 + 同名 tmux window（多 agent 并行用） |
| fish | `wtd <任务名>` | 合并后删除该任务的 worktree 和分支 |
| fish | `lg` | 打开 Lazygit |
| fish | `gd` / `gds` | git diff / diff --staged（delta 渲染） |
| fish | `gfd` | 依次输入基准分支与功能分支，比较共同祖先到功能分支的 diff（排除 `llmdoc/`、`docs/`） |
| fish | `gs` / `ga` / `gc` / `gp` / `gl` / `gco` | git status / add / commit -m / push / pull / checkout |
| LazyVim | `Space`（Leader） | 打开快捷键菜单 |
| LazyVim | `Space f f` | 文件搜索 |
| LazyVim | `Space s g` | 全局搜索（ripgrep） |
| LazyVim | `Shift + h` / `l` | Buffer 切换 |
| LazyVim | `:Lazy` / `:Mason` | 插件 / LSP·格式化器管理 |
| Lazygit | `Space` | Stage / Unstage |
| Lazygit | `c` / `P` / `p` | Commit / Push / Pull |
| Lazygit | `s` | Stash |
| Lazygit | `q` | 退出 |
| Yazi | `h/j/k/l` | 导航（返回 / 下 / 上 / 进入） |
| Yazi | `gg` / `G` | 顶部 / 底部 |
| Yazi | `/` | 搜索 |
| Yazi | `z` | zoxide 跳转 |
| Yazi | `.` | 显示/隐藏 隐藏文件 |
| Yazi | `q` | 退出（配合 `y` 自动 cd） |

## 多 Agent 并行工作流

每个任务一个 worktree + 一个 tmux window，互不干扰：

1. 在项目里 `wt fix-auth` —— 自动建分支、worktree（`~/worktrees/<仓库>/fix-auth`）和同名 window 并跳入
2. window 里起 agent（`claude`），`Option + 数字` 回去干别的
3. agent 停下时：非当前 window 名变黄（tmux bell），人不在终端则弹 macOS 通知（Claude Code hook）
4. 跳回去处理；完成后在 worktree 里 `Prefix + g` 用 Lazygit 审查、合并
5. `wtd fix-auth` 清理 worktree 和分支

## 配置生效方式

| 工具 | 改完配置后 |
|--------|--------|
| fish / starship | 开新 shell（或 `exec fish`） |
| tmux | `Prefix + r` |
| nvim | 重开 nvim |
| ghostty | 重启 Ghostty |
| karabiner | 自动生效 |
| git / lazygit / delta | 下次执行即生效 |
