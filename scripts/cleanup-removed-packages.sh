#!/usr/bin/env bash
# 一次性历史清理（幂等可重跑）：移除已删除 stow 包留在 $HOME 的悬空软链。
#
# 背景：2026-11 仓库移除了 claude/codex/opencode/agent-notify 四个 stow 包
# （全局 agent 配置改由外部管理，通知接线在机器本地 hook）。旧机器上这四个包
# stow 出的软链会因包目录删除而悬空，本脚本负责清掉它们。
#
# 安全边界：只删除「是软链 + 已悬空 + 目标路径含已删除包目录名」的链接；
# 真实文件和仍然有效的软链（可能已被外部管理接管）一律不动。
# 由 install.sh 在非 dry-run 时自动调用，也可手动执行；两台机器都迁移完成后可删。

set -e

REMOVED_LINKS=(
  "$HOME/.claude/CLAUDE.md"            # claude 包
  "$HOME/.codex/AGENTS.md"             # codex 包
  "$HOME/.config/opencode/AGENTS.md"   # opencode 包
  "$HOME/.local/bin/agent-notify"      # agent-notify 包
)

removed=0

for link in "${REMOVED_LINKS[@]}"; do
  [ -L "$link" ] || continue          # 不存在，或已是真实文件（外部管理接管）→ 不动
  if [ -e "$link" ]; then
    echo "  ⏭️  跳过仍有效的软链（外部管理已接管？）：$link"
    continue
  fi
  dest="$(readlink "$link")"
  case "$dest" in
    *"/claude/"*|*"/codex/"*|*"/opencode/"*|*"/agent-notify/"*)
      rm "$link"
      echo "  ♻️  已移除悬空软链：$link"
      echo "      → $dest"
      removed=$((removed + 1))
      ;;
    *)
      echo "  ⏭️  跳过目标不明的悬空软链（非本仓库旧包路径，请自行确认）：$link → $dest"
      ;;
  esac
done

if [ "$removed" -gt 0 ]; then
  echo "🧹 历史清理完成：移除 $removed 条悬空软链"
fi
