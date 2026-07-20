function git_feature_diff --description 'Compare a feature branch with its merge base'
    set -l base_branch
    read --prompt-str 'Base branch: ' base_branch; or return
    test -n "$base_branch"; or return

    set -l feature_branch
    read --prompt-str 'Feature branch: ' feature_branch; or return
    test -n "$feature_branch"; or return

    set -l merge_base (command git merge-base "$base_branch" "$feature_branch"); or return
    command git diff "$merge_base" "$feature_branch" -- ':!llmdoc' ':!docs'
end
