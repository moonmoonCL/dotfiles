function cs --description "fzf 搜索 Claude 会话，回车 cd 并恢复 (支持 --newer-than/--older-than N)"
    set -l script "$HOME/.config/fish/scripts/claude_sessions.py"

    set -l selected (python3 $script $argv \
        | fzf --delimiter \t --with-nth 2 \
              --preview "python3 $script --preview {1}" \
              --preview-window 'down,45%,wrap' \
              --prompt 'claude session > ' \
              --header '回车: cd 到工作目录并恢复会话')
    test -n "$selected"; or return

    set -l path (string split -f1 \t -- $selected)
    set -l dir (python3 $script --cwd $path)
    set -l id (basename $path .jsonl)

    if test -n "$dir" -a -d "$dir"
        cd $dir
    end
    claude --resume $id
end
