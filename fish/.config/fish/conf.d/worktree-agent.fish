function wt --description "为任务建 worktree + 同名 tmux window 并进入"
    set -l name $argv[1]
    if test -z "$name"
        echo "用法: wt <任务名>"
        return 1
    end

    set -l root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$root"
        echo "不在 git 仓库内"
        return 1
    end

    set -l repo (basename $root)
    set -l dir ~/worktrees/$repo/$name

    if not test -d $dir
        git -C $root worktree add $dir -b $name
        or git -C $root worktree add $dir $name
        or return 1
    end

    if set -q TMUX
        tmux new-window -n $name -c $dir
    else
        cd $dir
    end
end

function wtd --description "删除任务 worktree 与分支（合并后收尾用）"
    set -l name $argv[1]
    if test -z "$name"
        echo "用法: wtd <任务名>"
        return 1
    end

    set -l root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$root"
        echo "不在 git 仓库内"
        return 1
    end

    set -l repo (basename $root)
    set -l dir ~/worktrees/$repo/$name

    git -C $root worktree remove $dir
    and git -C $root branch -d $name
end
