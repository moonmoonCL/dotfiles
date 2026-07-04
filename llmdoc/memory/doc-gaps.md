# Doc Gaps

由 recorder 维护。每条 gap 需有关闭条件；解决后标记关闭。

## Open

（当前无开放缺口）

## Closed

- [x] **bootstrap 顺序曾未在仓库正式文档化。** 2026-07-04 已解决：README 新增「安装」章节（7 步：Homebrew → clone → brew bundle → install.sh → chsh → secrets → 收尾），并写入 `llmdoc/guides/bootstrap.md`；`stow-install-model.md` 同步更新。

- [x] **Claude 入口文件改造曾未提交。** 2026-07-04 已提交（`f3965a8`）：`claude/.claude/CLAUDE.md` 改为 @import 组合文件、新增 `llmdoc-policy.md`；`reference/agent-rules-wiring.md` 复核后仍准确。

- [x] **`yy`（yazi.fish）与 `opencode-background-subagents.fish` 曾是机器本地未跟踪文件。** 2026-07-04 已收进 fish 包（`fish/.config/fish/conf.d/`）并重新 stow，相关文档已同步。
- [x] **`zoxide/` 空孤儿包与 `switch_to_abc.sh` 孤儿脚本。** 2026-07-04 经作者确认后删除（zoxide 由 fish config 初始化；输入法切换由 karabiner.json 内联 im-select 承担），见 `memory/decisions/2026-07-04-remove-orphans.md`。
