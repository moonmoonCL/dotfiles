function pt -d "选择提示词模板并复制到粘贴板"
    set -l dir ~/.config/prompts

    if not test -d $dir
        echo "提示词目录不存在: $dir" >&2
        return 1
    end

    # pt <名字>：直接按文件名复制，跳过 fzf
    if set -q argv[1]
        if test "$argv[1]" = README
            echo "README 不是模板" >&2
            return 1
        end
        set -l file $dir/$argv[1].md
        if not test -f $file
            set -l names (ls $dir/*.md | path basename | string replace -r '\.md$' '' | string match -rv README | string join ' ')
            echo "没有这个模板: $argv[1]（可用: $names）" >&2
            return 1
        end
        pbcopy <$file
        echo "已复制: $argv[1]"
        return 0
    end

    set -l files $dir/*.md
    if test (count $files) -eq 0 -o ! -e $files[1]
        echo "$dir 下没有模板" >&2
        return 1
    end

    # README.md 只是说明，不算模板
    set -l picked (ls $dir/*.md | string match -rv '/README\.md$' | fzf --preview 'bat -n --color=always {}' --preview-window=right:60%)
    or return 1
    test -n "$picked"; or return 1

    pbcopy <$picked
    echo "已复制: "(basename $picked .md)
end
