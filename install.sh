#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

echo ""
echo "🚀 开始安装 Dotfiles"
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
fi

cd "$DOTFILES_DIR"

PACKAGES=(
  fish
  tmux
  starship
  nvim
  karabiner
  ghostty
  git
  lazygit
  agent-rules
  claude
  codex
  opencode
)

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

# WHY: 有些程序（如 Claude Code）保存配置时会"写临时文件再改名"，把 stow
# 软链替换成真实文件，导致下次 stow 冲突。与仓库一致的直接删除，有差异的
# 备份后让位，保证 install.sh 可重复执行。
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
  prepare_package_targets "$package"
  if ! output="$(stow --no-folding -R "$package" 2>&1)"; then
    FAILED+=("$package")
    echo "$output"
    echo ""
  fi
done

echo ""
echo "🔌 检查 TPM（Tmux Plugin Manager）"

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "📥 安装 TPM..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
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
echo "1. 重启 Ghostty（或重新打开终端）"
echo "2. 进入 tmux"
echo "3. 按 Ctrl+a 然后 Shift+i 安装 tmux 插件"
echo "4. 打开 nvim 等待 LazyVim 自动安装插件"
echo ""
echo "完成。"
echo ""
