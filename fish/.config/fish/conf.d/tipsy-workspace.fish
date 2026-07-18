function tipsy --description "选择 Tipsy 仓库或 worktree 并进入"
    set -l roots "$HOME/tipsy" "$HOME/tipsy-admin" "$HOME/tipsy-app-ui-backend" "$HOME/tipsy-app-ui"
    set -l entries
    set -l pr_records

    if type -q gh
        set pr_records (gh api graphql -f query='query { search(query: "is:pr is:open author:@me", type: ISSUE, first: 100) { nodes { ... on PullRequest { number headRefName repository { nameWithOwner } } } } }' --jq '.data.search.nodes[] | [.repository.nameWithOwner, .headRefName, (.number | tostring)] | @tsv' 2>/dev/null)
    end

    for root in $roots
        test -d "$root"; or continue

        for repository in "$root"/tipsy-*
            test -d "$repository"; or continue
            git -C "$repository" rev-parse --is-inside-work-tree >/dev/null 2>&1; or continue

            for worktree in (git -C "$repository" worktree list --porcelain | string match -r '^worktree .*' | string replace -r '^worktree ' '')
                set -l branch (git -C "$worktree" branch --show-current 2>/dev/null)
                test -n "$branch"; or set branch "(detached)"

                set -l changes (git -C "$worktree" status --porcelain 2>/dev/null)
                set -l state clean
                test -n "$changes"; and set state dirty

                set -l pr "-"
                if test "$branch" != "(detached)"
                    set -l remote (git -C "$worktree" remote get-url origin 2>/dev/null)
                    set -l github_repository (string replace -r '^(?:git@github\.com:|https://github\.com/)(.+?)(?:\.git)?$' '$1' -- "$remote")
                    for pr_record in $pr_records
                        set -l pr_columns (string split \t -- "$pr_record")
                        if test "$pr_columns[1]" = "$github_repository"; and test "$pr_columns[2]" = "$branch"
                            set pr "PR#$pr_columns[3]"
                            break
                        end
                    end
                end

                set -a entries (string join \t (basename "$repository") "$branch" "$state" "$pr" "$worktree")
            end
        end
    end

    if not set -q entries[1]
        echo "没有找到 Tipsy 仓库或 worktree"
        return 1
    end

    set -l listing (printf '%s\n' $entries | sort)
    if contains -- --list $argv
        printf '%s\n' $listing
        return
    end

    set -l selected (printf '%s\n' $listing | fzf --delimiter='\t' --with-nth=1,2,3,4,5 --prompt='Tipsy > ' --height=60% --reverse)
    test -n "$selected"; or return

    set -l columns (string split \t -- "$selected")
    cd "$columns[-1]"
end
