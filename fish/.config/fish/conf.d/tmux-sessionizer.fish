function ts --description "fzf 选目录并创建、恢复或切换同名 tmux session"
    set -l dir (zoxide query -l | fzf)
    test -n "$dir"; or return

    set -l name (basename $dir | string replace -a . _ | string replace -a : _)
    set -l target "=$name"

    if not tmux has-session -t "$target" 2>/dev/null
        set -l helper "$HOME/.config/tmux/session-history.py"
        set -l versions (python3 "$helper" list "$name" "$dir"); or return 1

        if test (count $versions) -gt 0
            set -l selected (printf '%s\n' $versions | fzf --delimiter='\t' --with-nth=2,3,4,5 --prompt='tmux history > ')
            test -n "$selected"; or return
            set -l columns (string split \t -- "$selected")
            python3 "$helper" restore "$name" "$dir" "$columns[1]"; or return 1
        else
            tmux new-session -ds "$name" -c "$dir"; or return 1
        end
    end

    if set -q TMUX
        tmux switch-client -t "$target"
    else
        tmux attach-session -t "$target"
    end
end
