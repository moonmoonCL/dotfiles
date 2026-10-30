if status is-interactive
    starship init fish | source
    zoxide init fish | source
    fzf --fish | source
    mise activate fish | source
    direnv hook fish | source
end

# QODER_DISPATCHER_PATH v1
fish_add_path -p -m $HOME/.qoder/entry
# END QODER_DISPATCHER_PATH v1
