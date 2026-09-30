# Homebrew into PATH（mac：/opt/homebrew；Linux：/home/linuxbrew）
# WHY：桌面直接启动的终端不读 shell rc，PATH 里没有 Homebrew，fish 内的
# starship/mise/fzf/eza 等会全部 command not found；由 fish 侧统一补齐。
# 用 fish_add_path 而非 brew shellenv：幂等、不会产生重复 PATH 项。
if test -x /opt/homebrew/bin/brew
    fish_add_path /opt/homebrew/bin /opt/homebrew/sbin
else if test -x /home/linuxbrew/.linuxbrew/bin/brew
    fish_add_path /home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/sbin
end
