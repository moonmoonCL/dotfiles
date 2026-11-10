# Stow 模型与安装流程

Stow 配置管理模型、`install.sh` 的内部行为，以及装机和维护时的坑。面向用户的新机器安装步骤见 [README.md](../README.md)「安装」章节；本文是面向维护者的补充。

## 模型

- 每个顶层包目录是一个 stow package；包内目录树 = `$HOME` 下的目标布局。`stow <pkg>`（在仓库根执行）为包里每个文件在 `$HOME` 对应位置创建 symlink。
- 两种目标风格并存：
  - XDG 风格，嵌套 `.config/`：fish、starship、nvim、karabiner、ghostty、kitty、agent-rules、prompts、mise。
  - 直挂 `$HOME`：git（`~/.gitconfig`）、ssh（`~/.ssh/config`，macOS 专属）、lazygit（`~/Library/Application Support/lazygit/`，macOS 专有路径）。tmux 两者兼有：`~/.tmux.conf` 直挂，另有两个脚本落在 `~/.config/tmux/`（resurrect-save、session-history.py）。
- `DOTFILES_DIR` 由脚本自身位置推导（`$(dirname "$0")`），仓库放哪都能跑；约定俗成仍放 `~/dotfiles`（README 与文档均按此路径举例）。

## 安装流程（install.sh）

1. 检查 `stow` 是否在 PATH，缺失则中止并提示 `brew install stow`（不自动安装）。
2. `brew bundle check` 不满足时打印提示（工具缺失或待更新），不中止、不自动安装——`install.sh` 不调用 `brew bundle`，两者是独立的手动步骤，改工具链时要同时更新 `Brewfile` 和 README。
3. 按 `uname` 分支选定的 `PACKAGES` 数组顺序 `stow --no-folding -R`：共享包 `fish, tmux, starship, nvim, git, lazygit, agent-rules, prompts, mise`；Darwin 额外 `ghostty`+`karabiner`+`ssh`；Linux 额外 `kitty`（keyd 不走 stow，收尾时打印手动安装命令）。未知平台 fail-loud。
4. 单个包冲突不会中断脚本：失败的包被收集，其余包继续 stow；末尾汇总失败包并提示常见原因（目标位置已存在真实文件，需先备份移走），退出码 1。全部成功才打印手动后续步骤（TPM、LazyVim 首次启动）。
5. `~/.tmux/plugins/tpm` 不存在时用空 git 配置克隆 TPM（绕开本仓库 gitconfig 的 insteadOf 改写，匿名公共仓库无需凭证）。
6. 冲突处理（`prepare_target`）：stow 前逐包扫描目标路径——与仓库一致的直接删除；有差异的备份为 `*.pre-stow.<时间戳>` 后让位，保证脚本幂等可重跑。悬空的或绝对路径指向本仓库的旧软链（stow 不认、会报 "not owned by stow"）会被移除重建。

## 不变量与失败点

- 新包必须进 `PACKAGES` 数组，否则静默不生效。
- 包内路径写错 = symlink 落错位置，stow 不会报语义错误。
- `.gitignore` 排除运行时产物：`**/secrets.fish`、`*.local`、`.tmux/resurrect`、nvim lazy 状态、`.DS_Store`。不要提交生成状态。
- **目录折叠（folding）事故**：不加 `--no-folding` 时，若目标目录尚不存在，stow 会把整个目录软链进仓库（如 `~/.codex -> dotfiles/codex/.codex`），程序随后把运行时数据写进仓库、污染 git。2026-07-05 codex 曾中招（sqlite、日志落进仓库），修复方式就是给 `install.sh` 与手动 restow 都加上 `--no-folding`，详见 [decisions.md](decisions.md)。
- `mise` 只 stow `config.toml.example`：真实 `config.toml` 是机器状态（各机工具版本不同），不入仓库。
- 机器本地的密钥（`secrets.fish`）与 ccswitch 独占管理的 `~/.claude/settings.json`、全局 agent 配置（`~/.claude/CLAUDE.md`、`~/.codex/AGENTS.md`、`~/.config/opencode/AGENTS.md`）都不属于本仓库；本仓库只提供它们引用的 `~/.config/agent-rules/`。
