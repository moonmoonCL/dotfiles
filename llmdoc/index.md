# llmdoc Index

## Purpose

- 本文件是 llmdoc 系统的全局地图。启动阅读顺序见 `llmdoc/startup.md`。

## Categories

- `must/`：每次任务都要读的极小启动包（稳定、跨任务的规则）。
- `overview/`：项目身份与边界。
- `architecture/`：流程、不变量、组件咬合关系。
- `guides/`：单一工作流的操作指南（当前为空）。
- `reference/`：稳定的查询事实与契约。
- `memory/`：过程记忆——reflections（reflector 维护）、decisions、doc-gaps.md（recorder 维护）。

## Documents

### must/
- `must/project-basics.md`：仓库是什么、stow 模型、包 -> `$HOME` 映射表。
- `must/working-agreement.md`：五条不可破坏的不变量（secrets、PACKAGES 数组、目录镜像、.llmdoc-tmp、agent 规则单一来源）。

### overview/
- `overview/project-overview.md`：终端优先工作站的身份、目标（可迁移/可恢复/长期维护）、macOS-only 边界。

### architecture/
- `architecture/stow-install-model.md`：Stow 配置管理模型、install.sh 与完整 bootstrap 顺序、失败点、孤儿包与本地漂移风险。
- `architecture/terminal-runtime-integration.md`：ghostty→tmux→fish↔nvim+karabiner 的深度集成图：初始化顺序、键位配对、代理默认开启、example.lua 惰性警告。

### reference/
- `reference/agent-rules-wiring.md`：agent 规则单一来源与 Claude/Codex/opencode 覆盖矩阵（@import vs symlink）。

### memory/
- `memory/doc-gaps.md`：待作者决策的文档缺口（bootstrap 文档化、未提交的 CLAUDE.md 改造）。
- `memory/decisions/2026-07-04-remove-orphans.md`：删除 zoxide 孤儿包与 switch_to_abc.sh、收编 yazi.fish 的决定。

## Routing Rules

- 装机、加包、改 install.sh/Brewfile → `architecture/stow-install-model.md`。
- 改任何终端组件的键位/初始化/插件 → `architecture/terminal-runtime-integration.md`（注意跨层配对表）。
- 改 agent 规则或入口文件 → `reference/agent-rules-wiring.md`。
- 重复工作流或修问题子系统前 → 先看 `memory/reflections/` 与 `memory/doc-gaps.md`。
- `.llmdoc-tmp/` 不属于本索引，仅为临时缓存。
