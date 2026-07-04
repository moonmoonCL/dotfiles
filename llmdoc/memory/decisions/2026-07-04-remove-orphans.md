# Decision: 清理孤儿并收编本地漂移文件

日期：2026-07-04

## 决定

1. 删除 `zoxide/` 空 stow 包。zoxide 实际由 `fish/.config/fish/config.fish` 中 `zoxide init fish | source` 接入，包目录从未进入 `install.sh` 的 `PACKAGES` 数组，也没有任何文件。
2. 删除 `karabiner/.config/karabiner/switch_to_abc.sh`（含 `~/.config/karabiner/` 下的 stow 链接）。其输入法切换逻辑已被 `karabiner.json` 内联 `shell_command`（im-select）取代，仓库与本地配置均无调用方。
3. 将机器本地未跟踪文件收进 fish 包并重新 stow：
   - `fish/.config/fish/conf.d/yazi.fish`：定义 `yy` 函数（退出 yazi 后自动 cd），tracked 的 `abbr y yy` 依赖它。
   - `fish/.config/fish/conf.d/opencode-background-subagents.fish`：设置 `OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true`。

## 理由

新机器 clone + stow 后 `y` 必须能用；孤儿文件会误导未来的维护判断。
