# Guide: 新机器 Bootstrap

从裸机到可用工作站的完整安装流程。面向用户的版本在 README「安装」章节，两处需保持同步；本文补充 agent 维护时需要知道的细节。

## 顺序（不可调换）

1. **Homebrew** — 一切工具的来源。
2. **clone 到 `~/dotfiles`** — 位置是契约，`install.sh` 硬编码 `DOTFILES_DIR="$HOME/dotfiles"`。
3. **`brew bundle`** — 手动执行，没有任何脚本调用它。必须先于 `install.sh`，因为后者依赖 `stow` 存在（缺失只会中止提示，不会自动安装）。
4. **`./install.sh`** — stow 全部 `PACKAGES` + clone TPM。
5. **`chsh` 设 fish 为登录 shell** — 未脚本化；需先把 `/opt/homebrew/bin/fish` 加进 `/etc/shells`。
6. **secrets** — `cp secrets.fish.example secrets.fish` 后填 key；`**/secrets.fish` 被根 .gitignore 排除。
7. **收尾** — 重启 Ghostty；tmux 内 `prefix + I` 装插件；nvim 首启等 LazyVim 自动装插件。

## 维护注意

- 改工具链要同时更新 `Brewfile` 和 README 工具总览。
- 新增 stow 包必须进 `install.sh` 的 `PACKAGES` 数组（见 `llmdoc/must/working-agreement.md`）。
- `brew bundle` 与 `install.sh` 是两个独立手动步骤，不要假设互相调用。

## Related Docs

- `llmdoc/architecture/stow-install-model.md`：stow 模型与 install.sh 的逐步行为。
