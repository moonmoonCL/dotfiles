# Architecture: Stow 配置管理与安装流程

## Purpose

解释本仓库的配置管理模型（GNU Stow symlink farm）和从裸机到可用环境的完整 bootstrap 路径，以及维护时容易踩的坑。

## 模型

- 每个顶层目录是一个 stow package；包内目录树 = `$HOME` 下的目标布局。`stow <pkg>`（在 `~/dotfiles` 执行）为包里每个文件在 `$HOME` 对应位置创建 symlink。
- 两种目标风格并存：
  - XDG 风格，嵌套 `.config/`：fish、starship、nvim、karabiner、ghostty、agent-rules、opencode。
  - 直挂 `$HOME`：tmux（`~/.tmux.conf`）、git（`~/.gitconfig`）、claude（`~/.claude/`）、codex（`~/.codex/`）、lazygit（`~/Library/Application Support/lazygit/`，macOS 专有路径）。
- `DOTFILES_DIR` 由脚本自身位置推导（`$(dirname "$0")`），仓库放哪都能跑；约定俗成仍放 `~/dotfiles`（README 与文档均按此路径举例）。

## 安装流程（install.sh）

1. 检查 `stow` 是否在 PATH，缺失则中止并提示 `brew install stow`（不自动安装）。
2. `brew bundle check` 不满足时打印提示（工具缺失或待更新），不中止、不自动安装。
3. 按固定顺序 `stow -R` `PACKAGES` 数组：`fish, tmux, starship, nvim, karabiner, ghostty, git, lazygit, agent-rules, claude, codex, opencode`。`-R`（restow）保证包内新增文件也会补上软链。
4. 单个包冲突不会中断脚本：失败的包被收集，其余包继续 stow。
5. 若 `~/.tmux/plugins/tpm` 不存在则 git clone TPM（tmux 插件管理器）。
6. 若有失败的包，末尾汇总包名并提示常见原因（目标位置已存在真实文件，需先备份移走），以退出码 1 结束；全部成功才打印手动后续步骤：重启 Ghostty → 进 tmux → `prefix + I` 装 tmux 插件 → 打开 nvim 等 LazyVim 自动装插件。

## 完整 bootstrap 顺序

正式版见 README「安装」章节与 `llmdoc/guides/bootstrap.md`。摘要：

1. 安装 Homebrew。
2. `brew bundle`（手动执行；没有任何脚本调用它）。`Brewfile` 提供工具链：fish、tmux、neovim、starship、stow、fzf、zoxide、mise、direnv、lazygit、yazi、gh、fd、ripgrep、bat、eza 等，taps 里有 opencode/crush/im-select，casks 有 ghostty 和 JetBrainsMono Nerd Font。
3. clone 仓库到 `~/dotfiles`，运行 `./install.sh`。
4. 手动后续步骤（TPM、LazyVim 首次启动）。
5. 复制 `fish/.config/fish/conf.d/secrets.fish.example` 为 `secrets.fish` 并填入密钥（gitignore 保护）。
6. 未脚本化：设 fish 为登录 shell（`chsh`）。

## 不变量与失败点

- 新包必须进 `PACKAGES` 数组，否则静默不生效（见 `llmdoc/must/working-agreement.md`）。
- 包内路径写错 = symlink 落错位置，stow 不会报语义错误。
- `.gitignore` 排除运行时产物：`**/secrets.fish`、`*.local`、`.tmux/resurrect`、nvim lazy 状态、`.DS_Store`、`.llmdoc-tmp/`。不要提交生成状态。
- `install.sh` 不调用 `brew bundle`，两者是独立的手动步骤——改工具链时要同时更新 `Brewfile` 和 README。

## 历史清理记录

2026-07-04 清理（详见 `llmdoc/memory/decisions/2026-07-04-remove-orphans.md`）：

- 删除空孤儿包 `zoxide/`（zoxide 由 `fish/.config/fish/config.fish` 里的 `zoxide init fish | source` 接入，与 stow 无关）。
- 删除 `karabiner/.config/karabiner/switch_to_abc.sh`（逻辑已被 `karabiner.json` 内联 `shell_command` im-select 取代）。
- 将机器本地文件 `yazi.fish`（定义 `yy` 函数）与 `opencode-background-subagents.fish` 收进 fish 包，消除新机器上 `abbr y yy` 失效的漂移风险。

## Related Docs

- `llmdoc/must/project-basics.md`：包 -> `$HOME` 映射表。
- `llmdoc/architecture/terminal-runtime-integration.md`：装好之后各组件如何协作。
