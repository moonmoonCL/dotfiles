#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
OS="$(uname -s)"

DRY_RUN=0
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=1
  echo "🧪 dry-run 模式：只模拟 stow，不落盘、不 clone TPM"
fi

echo ""
echo "🚀 开始安装 Dotfiles（平台：$OS）"
echo ""

if ! command -v stow >/dev/null 2>&1; then
  echo "❌ 未检测到 stow"
  echo "请先执行："
  echo "brew install stow"
  exit 1
fi

if command -v brew >/dev/null 2>&1; then
  if ! brew bundle check --file="$DOTFILES_DIR/Brewfile" >/dev/null 2>&1; then
    echo "⚠️  Brewfile 中有工具缺失或待更新，可执行：brew bundle"
    echo ""
  fi
  if [ "$OS" = "Darwin" ] && ! brew bundle check --file="$DOTFILES_DIR/Brewfile.macos" >/dev/null 2>&1; then
    echo "⚠️  Brewfile.macos 中有 cask 缺失或待更新，可执行：brew bundle --file=Brewfile.macos"
    echo ""
  fi
fi

cd "$DOTFILES_DIR"

case "$OS" in
  Darwin)
    PACKAGES=(
      fish
      tmux
      starship
      nvim
      ghostty
      karabiner
      git
      lazygit
      agent-rules
      claude
      codex
      opencode
      agent-notify
      mise
    )
    ;;
  Linux)
    PACKAGES=(
      fish
      tmux
      starship
      nvim
      kitty
      git
      lazygit
      agent-rules
      claude
      codex
      opencode
      agent-notify
      mise
    )
    ;;
  *)
    echo "❌ 不支持的平台：$OS（脚本只认 Darwin / Linux）"
    exit 1
    ;;
esac

BACKUPS=()
FAILED=()

# WHY: stow 只认自己创建的相对路径软链；绝对路径或悬空的旧软链会让它报
# "not owned by stow" 并中止，指回本仓库的旧软链删掉重建即可。
is_stale_symlink() {
  local link="$1" dest
  dest="$(readlink "$link")"
  case "$dest" in
    /*) ;;
    *) return 1 ;;
  esac
  [ -e "$link" ] || return 0
  case "$dest" in
    "$DOTFILES_DIR"/*) return 0 ;;
  esac
  return 1
}

# WHY: 有些程序保存配置时会“写临时文件再改名”，把 stow 软链替换成真实
# 文件，导致下次 stow 冲突。与仓库一致的直接删除，有差异的备份后让位，
# 保证 install.sh 可重复执行。Claude 的 settings.json 由 ccswitch 独占，不纳入
# stow 管理。
prepare_target() {
  local package="$1" rel="$2"
  local path="$HOME" part
  local -a parts
  IFS='/' read -r -a parts <<<"$rel"

  for part in "${parts[@]}"; do
    path="$path/$part"
    if [ -L "$path" ]; then
      if is_stale_symlink "$path"; then
        rm "$path"
        echo "  ♻️  已移除旧软链：$path"
      fi
      return 0
    fi
    [ -e "$path" ] || return 0
  done

  if [ -f "$path" ]; then
    if cmp -s "$package/$rel" "$path"; then
      rm "$path"
    else
      local backup="$path.pre-stow.$TIMESTAMP"
      mv "$path" "$backup"
      BACKUPS+=("$backup")
      echo "  💾 已备份本地文件：$path"
      echo "      → $backup"
    fi
  fi
  return 0
}

prepare_package_targets() {
  local package="$1" file
  while IFS= read -r -d '' file; do
    prepare_target "$package" "${file#"$package"/}"
  done < <(find "$package" \( -type f -o -type l \) -print0)
}

# WHY: 不加 --no-folding 时，目标目录若不存在，stow 会把整个目录软链进仓库
# （目录折叠）。程序随后写入的运行时数据会全部落在仓库里污染 git——codex 的
# sqlite/日志曾因此变成一堆未追踪文件。--no-folding 让 stow 只对文件建链接。
for package in "${PACKAGES[@]}"; do
  echo "📦 Stowing $package ..."
  if [ "$DRY_RUN" = "1" ]; then
    # dry-run 不执行 prepare_target 的删除/备份动作，冲突会由 stow -n 原样报出，
    # 其中包含真实运行会自动清理的部分，仅作预览参考。
    if ! output="$(stow -n --no-folding -t "$HOME" -R "$package" 2>&1)"; then
      FAILED+=("$package")
      echo "$output"
      echo ""
    fi
  else
    prepare_package_targets "$package"
    if ! output="$(stow --no-folding -t "$HOME" -R "$package" 2>&1)"; then
      FAILED+=("$package")
      echo "$output"
      echo ""
    fi
  fi
done

if [ "$DRY_RUN" = "1" ]; then
  echo ""
  if [ ${#FAILED[@]} -gt 0 ]; then
    echo "🧪 dry-run 结束：以下包存在冲突：${FAILED[*]}"
  else
    echo "🧪 dry-run 结束：无冲突"
  fi
  exit 0
fi

echo ""
echo "🔌 检查 TPM（Tmux Plugin Manager）"

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "📥 安装 TPM..."
  # WHY: 本仓库 gitconfig 的 insteadOf 会把 https 克隆改写成 ssh（runner 无密钥、
  # 部分 网络 22 端口不通时直接失败）。TPM 是匿名公共仓库，用空 git 配置克隆。
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  echo "✅ TPM 已安装"
fi

if [ ${#BACKUPS[@]} -gt 0 ]; then
  echo ""
  echo "💾 以下本地文件与仓库版本不同，已备份后由 stow 软链接管："
  for backup in "${BACKUPS[@]}"; do
    echo "  $backup"
  done
  echo "如有本机专属配置（如密钥），请迁移到对应位置（例如 ~/.config/fish/conf.d/secrets.fish）后删除备份。"
fi

if [ ${#FAILED[@]} -gt 0 ]; then
  echo ""
  echo "❌ 以下包 stow 失败：${FAILED[*]}"
  echo ""
  echo "请查看上方 stow 输出，处理冲突后重跑 ./install.sh"
  exit 1
fi

echo ""
echo "🎉 Dotfiles 安装完成"
echo ""

echo "后续操作："
echo ""
echo "1. 重启终端（macOS: Ghostty / Linux: kitty）"
echo "2. 进入 tmux"
echo "3. 按 Ctrl+a 然后 Shift+i 安装 tmux 插件"
echo "4. 打开 nvim 等待 LazyVim 自动安装插件"

if [ "$OS" = "Linux" ] && [ -z "$CI" ]; then
  if ! fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
    echo ""
    echo "🔤 安装 JetBrainsMono Nerd Font（用户级，无需 sudo）..."
    if ! command -v unzip >/dev/null 2>&1; then
      echo "⚠️ 缺 unzip，请先 sudo apt install unzip 后重跑本脚本"
    elif curl -fL --max-time 300 -o /tmp/JetBrainsMono.zip \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"; then
      mkdir -p "$HOME/.local/share/fonts/JetBrainsMono"
      unzip -oq /tmp/JetBrainsMono.zip -d "$HOME/.local/share/fonts/JetBrainsMono"
      rm -f /tmp/JetBrainsMono.zip
      fc-cache -f >/dev/null 2>&1
      echo "✅ 字体已安装"
    else
      echo "⚠️ 字体自动安装失败，按下方第 7 步手动装"
    fi
  fi
fi

if [ "$OS" = "Linux" ]; then
  echo ""
  echo "Linux 专属收尾（手动执行一次）："
  echo "5. 键盘改键（keyd，平替 Karabiner）。22.04 源里没有 keyd 包，源码安装："
  echo "   sudo apt install -y build-essential git"
  echo "   git clone https://github.com/rvaiya/keyd /tmp/keyd && cd /tmp/keyd && make"
  echo "   sudo make install"
  echo "   sudo mkdir -p /etc/keyd && sudo cp $DOTFILES_DIR/keyd/default.conf /etc/keyd/default.conf"
  echo "   sudo systemctl enable --now keyd"
  echo "   （Ubuntu 23.10+/Debian 13+ 可直接 sudo apt install keyd，跳过编译）"
  echo "6. 中文输入法（fcitx5，平替 im-select）：sudo apt install fcitx5 fcitx5-chinese-addons，系统设置里切换输入法框架；nvim 侧配 fcitx5.nvim 实现离开插入模式自动切英文"
  echo "7. 字体：正常由本脚本自动安装（用户级）；若上方报失败，手动下载 https://github.com/ryanoasis/nerd-fonts/releases 的 JetBrainsMono.zip 解压到 ~/.local/share/fonts 后 fc-cache -f"
fi

echo ""
echo "完成。"
echo ""
