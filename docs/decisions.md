# 决策记录

带日期的决策日志，新条目追加在末尾。只记"决定了什么、为什么"，实现细节以代码和对应文档为准。

## 2026-07-04 清理孤儿并收编本地漂移文件

- 删除 `zoxide/` 空 stow 包：zoxide 实际由 `fish/.config/fish/config.fish` 的 `zoxide init fish | source` 接入，包从未进 `PACKAGES` 数组且无文件。
- 删除 `karabiner/.config/karabiner/switch_to_abc.sh`：输入法切换逻辑已被 `karabiner.json` 内联 `shell_command`（im-select）取代，无调用方。
- 将机器本地未跟踪文件收进 fish 包（`conf.d/yazi.fish` 定义 `yy`、`conf.d/opencode-background-subagents.fish`），消除新机器上 `abbr y yy` 失效的漂移风险。

原则：孤儿文件会误导未来的维护判断；`abbr` 依赖的东西必须随包入库。

## 2026-07-05 stow 目录折叠事故 → 全线 `--no-folding`

不加 `--no-folding` 时，目标目录尚不存在则 stow 把整个目录折叠成一条指向仓库的软链，程序随后把运行时数据写进仓库（codex 的 sqlite/日志曾因此污染 git）。修复：`install.sh` 与手动 restow 一律 `stow --no-folding -R`，只对文件建链接、目录一律真实目录。见 [stow-and-install.md](stow-and-install.md)。

## 2026-09-30 双平台单仓库改造（linux 分支）

在 Pop!_OS 上复刻 macOS 终端体验，单仓库单历史：平台差异在安装时消化（`install.sh` 按平台选包）+ 少量运行时守卫，而不是拆两个仓库人肉同步。

- Brewfile 剪枝拆分：两平台共用 CLI 在 `Brewfile`，mac-only tap/cask 移入 `Brewfile.macos`。
- 路径归一：gitconfig credential helper 去 `/opt/homebrew` 绝对路径；tmux 删写死的 `default-shell`；剪贴板 `if-shell` 选 pbcopy/wl-copy/xclip。
- 新包：`kitty`（Ghostty 平替）、`keyd/default.conf`（Karabiner 平替，不走 stow）、`mise/.config/mise/config.toml.example`（工具版本锚，仅示例）。
- CI 冒烟闸门：macos+ubuntu 矩阵跑 fish 语法、install.sh dry-run + 实装、fish 启动、tmux 解析；nvim headless 先非阻塞。
- 平台专属内容只允许两种形态：独立 stow 包（另一平台不链接），或共享文件内运行时守卫且守卫另一半保持原行为。

## 2026-11-10 `~/.ssh/config` 纳入 stow（ssh 包，Darwin 专属）

`gitconfig` 的 `insteadOf` 把 https 地址重写为 SSH，github:22 直连被限速导致 SwiftPM 拉依赖卡死。保留 insteadOf（https 凭证链依赖 gh），在 `~/.ssh/config` 加 `ProxyCommand nc -X 5 -x 127.0.0.1:7890` 走 Clash，配置收入 `ssh/` 包消除重装漂移。验证：`ssh -T git@github.com` 经代理 5.4s 认证成功。

## 2026-11-11 精简仓库：llmdoc → docs，移除 agent 配置与通知包

- llmdoc 体系（must/overview/architecture/guides/reference/memory 六层目录）对这个规模的仓库太重，降级为一个独立 `AGENTS.md`（不 @import）+ `docs/` 三份文档（stow-and-install / terminal-integration / decisions）。`CLAUDE.md` 变为指向 `AGENTS.md` 的软链，单一来源。
- 移除 `claude/`、`codex/`、`opencode/` stow 包：全局 agent 配置（`~/.claude/CLAUDE.md` 等）在别处统一管理，本仓库不再负责分发入口文件；但 `agent-rules/` 包保留——外部全局配置 `@import` 了它 stow 出的 `~/.config/agent-rules/comment-policy.md`，是唯一仍被外部引用的仓库内容。
- 移除 `agent-notify/` 包（`~/.local/bin/agent-notify`）：桌面通知的接线在机器本地的 agent hook（ccswitch 管理），脚本在本仓库无调用方；终端内的 tmux 黄名兜底不受影响。
- 拉取后的一次性迁移自动化为 `scripts/cleanup-removed-packages.sh`（install.sh 非 dry-run 时自动调用）：清理四个包遗留的悬空软链。只删「软链 + 已悬空 + 指向已删包路径」的链接，外部管理写入的真实文件与有效软链不受影响；幂等可重跑，两台机器都迁移完成后可删。
