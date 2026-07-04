# Agent Rules Wiring Reference

## Scope

AI coding agent（Claude / Codex / opencode）的规则分发契约：单一来源、各 agent 入口文件的引用机制、覆盖矩阵。

## 单一来源：`agent-rules/.config/agent-rules/`

stow 到 `~/.config/agent-rules/`。两份策略文件：

- `comment-policy.md`：写自解释代码；禁止复述型注释；注释仅允许非显而易见的原因/约束，且必须用固定前缀 `WHY:` / `SECURITY:` / `PERF:` / `COMPAT:` / `BUSINESS:`；收尾前 review diff 清除复述注释。
- `llmdoc-policy.md`：非平凡任务前加载 `llmdoc` skill；主助手在非平凡计划/编辑前与用户对齐；subagent 路由（investigator/recorder/worker/reflector）；任务结束评估是否建议 `/llmdoc:update`；`.llmdoc-tmp/` 只是临时缓存。

## 覆盖矩阵

| Agent | 入口文件 | 机制 | comment-policy | llmdoc-policy |
|---|---|---|---|---|
| Claude | `claude/.claude/CLAUDE.md` | `@import` 两行 | yes | yes |
| Codex | `codex/.codex/AGENTS.md` | symlink → comment-policy.md | yes | no |
| opencode | `opencode/.config/opencode/AGENTS.md` | symlink → comment-policy.md | yes | no |

- 不对称的根因：只有 Claude 支持多文件 `@import`（`@~/.config/agent-rules/...`）；symlink 只能指向单一目标文件，因此 llmdoc-policy 目前仅 Claude 生效。
- 若要扩展到 Codex/opencode：需要合并策略文件作为 symlink 目标，或为各 agent 写 wrapper 文件。

## llmdoc plugin

- `llmdoc@llmdoc-cc-plugin` 以 user scope 安装（Claude Code 插件，不在本仓库内跟踪）；提供 llmdoc skill、subagents 与 `/llmdoc:*` 命令。

## Sources of Truth

- `agent-rules/.config/agent-rules/comment-policy.md`、`llmdoc-policy.md`：规则正文，改规则只改这里。
- `claude/.claude/CLAUDE.md`：Claude 的组合入口（@import 两份策略）。
- `codex/.codex/AGENTS.md`、`opencode/.config/opencode/AGENTS.md`：symlink，勿替换为文本副本。
