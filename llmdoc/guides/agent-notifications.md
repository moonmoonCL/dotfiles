# Guide: Agent 通知回路（桌面通知）

多 agent 并行时「谁在等我」的反馈链路：终端内靠 tmux 黄名（`monitor-bell`），人不在终端时靠桌面通知。

## 层级

| 场景 | 机制 | 配置位置 |
|--------|--------|--------|
| 人在终端 | agent 响铃 → 非当前 window 名变黄 | `.tmux.conf` 的 `monitor-bell` + `bell-action other` |
| 人不在终端（Linux） | tmux `alert-bell` hook → `notify-send` 桌面通知 | `.tmux.conf` 的 `set-hook -g alert-bell`（2026-09-30 起，notify-send 缺失时静默跳过） |
| 人不在终端（macOS） | Claude Code hook → `agent-notify` → `osascript` | ccswitch 管理的 `~/.claude/settings.json`（本仓库之外） |

## agent-notify 脚本

`agent-notify/.local/bin/agent-notify`（stow 包，两平台同一个入口）：
macOS 走 `osascript`，Linux 走 `notify-send`，都没有则静默退出。

用法：`agent-notify "任务完成" "fix-auth 分支 agent 已停止"`

## Claude Code hooks 接线（settings.json）

settings.json 由 ccswitch 独占、不入 stow；以下是要粘贴的 hooks 结构（事件名以 Claude Code 官方文档为准）：

```json
{
  "hooks": {
    "Stop": [
      { "hooks": [ { "type": "command", "command": "~/.local/bin/agent-notify \"任务完成\" \"agent 已停止，等待处理\"" } ] }
    ],
    "Notification": [
      { "hooks": [ { "type": "command", "command": "~/.local/bin/agent-notify \"需要确认\" \"agent 在等你拍板\"" } ] }
    ]
  }
}
```

macOS 上若沿用旧的 hook 命令（内联 osascript），建议切换到 `agent-notify` 统一两平台入口。

## Related Docs

- `llmdoc/memory/decisions/2026-09-30-linux-branch.md`：通知回路入库的决策背景。
