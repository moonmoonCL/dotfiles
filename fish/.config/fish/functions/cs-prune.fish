function cs-prune --description "删除超过 N 天未活跃的 Claude 会话 (默认 5 天，移到废纸篓)"
    set -l script "$HOME/.config/fish/scripts/claude_sessions.py"
    set -l prune "$HOME/.config/fish/scripts/claude_prune.py"

    set -l days $argv[1]
    test -n "$days"; or set days 5

    set -l rows (python3 $script --older-than $days | cut -f2)
    set -l count (count $rows)

    if test $count -eq 0
        echo "没有超过 $days 天未活跃的会话"
        return
    end

    printf '%s\n' $rows
    echo
    read -l -P "移到废纸篓以上 $count 个会话? [y/N] " reply
    if test "$reply" != y -a "$reply" != Y
        echo "已取消"
        return
    end

    python3 $script --paths --older-than $days | python3 $prune
end
