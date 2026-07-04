function ts --description "fzf 选目录并创建/切换同名 tmux session"
    set -l dir (zoxide query -l | fzf)
    test -n "$dir"; or return

    # WHY: tmux session 名不允许含 . 和 :
    set -l name (basename $dir | string replace -a . _ | string replace -a : _)

    if not tmux has-session -t $name 2>/dev/null
        tmux new-session -ds $name -c $dir
    end

    if set -q TMUX
        tmux switch-client -t $name
    else
        tmux attach-session -t $name
    end
end
