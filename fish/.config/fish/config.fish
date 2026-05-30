if status is-interactive
    starship init fish | source
    zoxide init fish | source
    fzf --fish | source
    mise activate fish | source
    direnv hook fish | source
end
