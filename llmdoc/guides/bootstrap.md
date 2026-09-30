# Guide: 新机器 Bootstrap

从裸机到可用工作站的完整安装流程。面向用户的版本在 README「安装」章节，两处需保持同步；本文补充 agent 维护时需要知道的细节。

## 顺序（不可调换）

1. **Homebrew** — 一切工具的来源。
2. **clone 到 `~/dotfiles`** — 惯例路径；`install.sh` 按自身位置定位仓库，放别处也能跑，但文档均按 `~/dotfiles` 举例。
3. **`brew bundle`** — 手动执行，没有任何脚本调用它。必须先于 `install.sh`，因为后者依赖 `stow` 存在（缺失只会中止提示，不会自动安装）。
4. **`./install.sh`** — stow 全部 `PACKAGES` + clone TPM。
5. **`chsh` 设 fish 为登录 shell** — 未脚本化；需先把 `/opt/homebrew/bin/fish` 加进 `/etc/shells`。
6. **secrets** — `cp secrets.fish.example secrets.fish` 后填 key；`**/secrets.fish` 被根 .gitignore 排除。
7. **收尾** — 重启 Ghostty；tmux 内 `prefix + I` 装插件；nvim 首启等 LazyVim 自动装插件。

## 维护注意

- 改工具链要同时更新 `Brewfile` 和 README 工具总览。
- 新增 stow 包必须进 `install.sh` 的 `PACKAGES` 数组（见 `llmdoc/must/working-agreement.md`）。
- `brew bundle` 与 `install.sh` 是两个独立手动步骤，不要假设互相调用；`install.sh` 只会用 `brew bundle check` 打印提示。
- 在已有配置的旧机器上首次 stow 新包时，目标位置的真实文件（如手写的 `~/.gitconfig`）会导致该包冲突失败；脚本会跳过它继续其余包并在末尾汇总，需备份移走冲突文件后重跑。

## 仓库外依赖（abbr 引用但不归 Brewfile 管）

新机器上以下命令需要单独安装，否则对应 abbr 会 command not found：

| 命令 | 用途 | 来源 |
|--------|--------|--------|
| `ccswitch` | Claude Code 渠道/settings.json 管理 | npm 全局（文档见 must/project-basics.md） |
| `pi` / `just-talk` | 本地模型 agent（abbr pp/piq/ppq/just-talk-s） | 手动安装，暂无固定渠道 |

## 平台差异（2026-09-30 起）

- `install.sh` 按 `uname` 分支选包：Darwin stow `ghostty`+`karabiner`，Linux stow `kitty`；共享包两边一致。未知平台直接报错退出。
- 共享配置内只有三处平台守卫：fish `chromedap`（`switch (uname)`）、tmux `copy-command`（if-shell 选 pbcopy/wl-copy/xclip）、tmux `alert-bell`（notify-send，缺失时静默）。
- keyd 配置在 `keyd/default.conf`，不走 stow（keyd 只读 `/etc/keyd/`），手动复制，命令在 install.sh 结尾打印。
- Linux 收尾三件套：keyd、fcitx5（+ nvim 侧 fcitx5.nvim）、Nerd Font。
- `chsh` 路径：mac `/opt/homebrew/bin/fish`，linux brew `/home/linuxbrew/.linuxbrew/bin/fish`。tmux 不再写死 default-shell，依赖登录 shell。

## Related Docs

- `llmdoc/architecture/stow-install-model.md`：stow 模型与 install.sh 的逐步行为。
