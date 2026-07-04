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
| Claude（全局） | `claude/.claude/CLAUDE.md` | `@import` | yes | no |
| Claude（本仓库） | 仓库根 `CLAUDE.md` | `@import`（repo 相对路径） | 继承全局 | yes |
| Codex | `codex/.codex/AGENTS.md` | symlink → comment-policy.md | yes | no |
| opencode | `opencode/.config/opencode/AGENTS.md` | symlink → comment-policy.md | yes | no |

- 作用域设计（2026-07-04 调整）：comment-policy 是通用代码规范，走全局；llmdoc-policy 只对遵循 llmdoc 架构的仓库有意义，**必须项目级导入、禁止进全局 CLAUDE.md**——否则非 llmdoc 工作目录也会被要求读不存在的 llmdoc 文档。新仓库接入 llmdoc 时在其 CLAUDE.md 里加一行 `@~/.config/agent-rules/llmdoc-policy.md`（或本仓库这种 repo 相对路径）。
- Codex/opencode 的 symlink 只能指向单一目标文件，故只覆盖 comment-policy；若要扩展需合并策略文件或写 wrapper。

## llmdoc plugin

- `llmdoc@llmdoc-cc-plugin` 以 user scope 安装（Claude Code 插件，不在本仓库内跟踪）；提供 llmdoc skill、subagents 与 `/llmdoc:*` 命令。

## Sources of Truth

- `agent-rules/.config/agent-rules/comment-policy.md`、`llmdoc-policy.md`：规则正文，改规则只改这里。
- `claude/.claude/CLAUDE.md`：Claude 全局入口（@import comment-policy）；仓库根 `CLAUDE.md` 追加 @import llmdoc-policy。
- `codex/.codex/AGENTS.md`、`opencode/.config/opencode/AGENTS.md`：symlink，勿替换为文本副本。
