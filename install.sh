#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

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

FAILED=()

for package in "${PACKAGES[@]}"; do
  echo "📦 Stowing $package ..."
  if ! output="$(stow -R "$package" 2>&1)"; then
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

if [ ${#FAILED[@]} -gt 0 ]; then
  echo ""
  echo "❌ 以下包 stow 失败：${FAILED[*]}"
  echo ""
  echo "常见原因：目标位置已存在同名真实文件（非 stow 软链）。"
  echo "请备份后重跑，例如："
  echo "  mv ~/.gitconfig ~/.gitconfig.bak && ./install.sh"
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
