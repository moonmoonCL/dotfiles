# 工作约定（不可破坏的不变量）

1. **Secrets 绝不提交。** 根 `.gitignore` 用 `**/secrets.fish` 排除真实密钥文件，仓库只跟踪 `fish/.config/fish/conf.d/secrets.fish.example`。任何真实 API key 不得进入 git。`~/.claude/settings.json` 由 ccswitch 管理，禁止纳入本仓库。
2. **新增 stow package 必须加入 `install.sh` 的 `PACKAGES` 数组。** 否则该包会被静默跳过、永不 stow。
3. **Package 内部目录树必须镜像 `$HOME` 布局。** 例如 XDG 配置要写成 `foo/.config/foo/...`，否则 stow 会把 symlink 放错位置。
4. **`.llmdoc-tmp/` 只是临时上下文缓存，不是项目事实来源。** 已被 gitignore，不索引、不当作 stable 知识引用。
5. **Agent 规则单一来源在 `agent-rules/.config/agent-rules/`**（comment-policy.md + llmdoc-policy.md）。修改 agent 规则只改这里，各 agent 入口文件（CLAUDE.md / AGENTS.md）通过 @import 或 symlink 引用，不复制文本。
