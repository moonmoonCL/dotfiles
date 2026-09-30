# Decision: 双平台单仓库改造（linux 分支）

日期：2026-09-30
状态：试运行中（`linux` 分支，稳定后合入 main）

## 动机

在 Pop!_OS（Ubuntu 系）上复刻 macOS 的终端操作体验（终端即 IDE、键盘即鼠标、会话不丢、手不离主键区），同时保持单仓库单历史：平台差异在仓库内部消化（安装时选包 + 少量运行时守卫），而不是拆两个仓库靠人肉 changelog 同步。

## 变更清单

1. **Brewfile 剪枝与拆分**：删除全仓库零引用/被覆盖的 9 项（ansiweather、boxes、cowsay、fortune、lolcat、tree、wget、iterm2、crush 及其 tap）；cask 与 mac-only tap 移入 `Brewfile.macos`；主 Brewfile 变为两平台共用 CLI。
2. **路径归一**：gitconfig credential helper 去掉 `/opt/homebrew` 绝对路径；tmux 删除 `default-shell` 写死路径（改用 chsh 后的登录 shell）；copy-mode 剪贴板由 pbcopy 写死改为 `if-shell` 选 pbcopy/wl-copy/xclip。
3. **新包**：`kitty`（Ghostty 平替，逐项对应 font/opacity/copy-on-select/shell）；`keyd/default.conf`（Karabiner 平替，不走 stow，手动复制到 /etc/keyd）；`mise/.config/mise/config.toml.example`（工具版本锚，仅示例，避免覆盖机器上的真实 mise 配置）；`agent-notify`（跨平台桌面通知入口）。
4. **通知回路入库**：tmux `alert-bell` hook → notify-send（Linux）；`agent-notify` 脚本供 Claude Code hooks 两平台统一调用；接线文档 `guides/agent-notifications.md`。此前 macOS 通知配置只存在于 ccswitch 独占的 settings.json，是仓库盲区。
5. **install.sh**：uname 平台分支（未知平台 fail-loud）、`--dry-run`（stow -n 模拟）、Linux 收尾步骤打印。
6. **CI 冒烟闸门**（`.github/workflows/ci.yml`）：macos+ubuntu 矩阵跑 fish 语法检查、install.sh dry-run + 实装、fish 启动、tmux 解析；nvim headless 先非阻塞观察。

## 持久化权属矩阵（降低心智负担的归一）

| 职责 | Owner |
|--------|--------|
| 自动保存（每 10 分钟） | tmux-continuum（唯一自动写入者） |
| 手动兜底保存 | `Prefix+C-s`（resurrect-save wrapper，仅"最后一刻保鲜"语义） |
| 版本化恢复 / 全局恢复 | `ts` 历史列表 / `Prefix+C-r`（session-history.py，唯一恢复界面） |

机制未删减，只明确 owner，避免"三个工具"的心智印象。

## 刻意不做的事

- **不改 nvim 配置**：fcitx5.nvim 等输入法插件作为 Linux 收尾可选项文档化，不绑定，避免影响 mac 侧 LazyVim。
- **不 stow mise 的 config.toml**：那是机器状态（真实工具版本各机不同），只入库 `.example`。
- **不动 karabiner/im-select**：mac 侧行为原样保留，守卫的 mac 分支与旧行为逐字节等价。

## 试运行期追记（同日晚）：输入法与 keyd 的最终现状

- **输入法留在 ibus + GNOME**（Pop 原生，libpinyin），中文输入正常。fcitx5 处于休眠状态（已装、有 profile、但 Pop 的 GNOME 会话不走 im-config 启动器，进程从未拉起）。mac 的 im-select 平替如需补齐，走 ibus 系插件（vim-im-select 类）而非 fcitx5.nvim。
- **中英切换快捷键**：mac 的「右 Shift → Ctrl+Space」在 keyd 侧由 `rightshift = C-space` 实现（该绑定对正常键盘有效）；GNOME 侧把 Ctrl+Space 加进了输入源切换：`gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Super>space', '<Control>space']"`——此命令是机器本地状态，不入仓库。
- **特殊布局键盘的已知问题（用户暂缓处理）**：该键盘「右 Shift 位」的键固件发出的是 leftshift（keycode 42），`rightshift` 绑定永远不触发。修复路径：keyd 按设备绑定（`[ids]` 指定 vendor:product 的独立配置文件，仅该键盘上把 leftshift 映射为 C-space）。诊断技巧：用户在 input 组，可直接读取 `/dev/input` 的 keyd 虚拟设备事件流（无需 sudo）观察 keyd 实际输出。

## 回滚

整分支可整体 revert；单仓库下所有变更在同一个历史里，不存在双仓库的渐进漂移。
