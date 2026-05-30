#!/usr/bin/env bash

set -e

DOTFILES_DIR="$HOME/dotfiles"

echo ""
echo "🚀 开始安装 Dotfiles"
echo ""

# 检查 stow

if ! command -v stow >/dev/null 2>&1; then
  echo "❌ 未检测到 stow"
  echo "请先执行："
  echo "brew install stow"
  exit 1
fi

cd "$DOTFILES_DIR"

PACKAGES=(
  fish
  tmux
  starship
  nvim
  karabiner
  ghostty
)

for package in "${PACKAGES[@]}"; do
  echo "📦 Stowing $package ..."
  stow "$package"
done

echo ""
echo "🔌 检查 TPM（Tmux Plugin Manager）"

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "📥 安装 TPM..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
  echo "✅ TPM 已安装"
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
