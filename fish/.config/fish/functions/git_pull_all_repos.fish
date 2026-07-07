function git_pull_all_repos --description "Recursively pull all git repositories under current directory"
    set -l cwd (pwd)

    echo
    echo "Searching git repositories under: $cwd"
    echo

    set -l repos
    for gitmeta in (find . \( -type d -name .git -o -type f -name .git \) -print)
        set -l repo (dirname "$gitmeta")

        # Avoid pulling the same repository more than once if find returns duplicates.
        if contains -- "$repo" $repos
            continue
        end
        set -a repos "$repo"

        echo "==> $repo"

        if not git -C "$repo" remote | grep -q .
            echo "No remote, skipped."
        else
            git -C "$repo" pull --ff-only
        end

        echo
    end

    if test (count $repos) -eq 0
        echo "No git repositories found."
    else
        echo "Done. Pulled "(count $repos)" repositories."
    end

    commandline -f repaint
end
