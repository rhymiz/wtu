#!/bin/bash

# Bash completion for Git Worktree Utilities

# Helper function to get all branch names
_wtu_branches() {
    git for-each-ref --format='%(refname:short)' refs/heads/ 2>/dev/null
}

# Helper function to get worktree branches
_wtu_worktree_branches() {
    git worktree list --porcelain 2>/dev/null | awk '/^branch/ {print substr($0, 8)}'
}

# Helper function to get worktree paths
_wtu_worktree_paths() {
    git worktree list --porcelain 2>/dev/null | awk '/^worktree/ {print substr($0, 10)}'
}

# Helper function to get remote branches
_wtu_remote_branches() {
    git for-each-ref --format='%(refname:short)' refs/remotes/ 2>/dev/null
}

# Helper function to get remotes
_wtu_remotes() {
    git remote 2>/dev/null
}

# Completion for wt-add
_wt_add() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    
    case $COMP_CWORD in
        1)
            # First argument: branch names
            COMPREPLY=( $(compgen -W "$(_wtu_branches)" -- "$cur") )
            ;;
        2)
            # Second argument: custom worktree name (no completion, user input)
            COMPREPLY=()
            ;;
    esac
}

# Completion for wt-add-remote
_wt_add_remote() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    
    case $COMP_CWORD in
        1)
            # First argument: remote branches
            COMPREPLY=( $(compgen -W "$(_wtu_remote_branches)" -- "$cur") )
            ;;
        2)
            # Second argument: local branch name (no completion, user input)
            COMPREPLY=()
            ;;
    esac
}

# Completion for wt-cd
_wt_cd() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    
    # Can be either a branch name or a number
    local branches="$(_wtu_worktree_branches)"
    local numbers=$(git worktree list 2>/dev/null | wc -l | xargs seq 1)
    
    COMPREPLY=( $(compgen -W "$branches $numbers" -- "$cur") )
}

# Completion for wt-remove
_wt_remove() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    
    # Can be either a branch name or a path
    local branches="$(_wtu_worktree_branches)"
    local paths="$(_wtu_worktree_paths)"
    
    COMPREPLY=( $(compgen -W "$branches" -- "$cur") )
    
    # Also complete file paths if the input looks like a path
    if [[ "$cur" == /* || "$cur" == ./* ]]; then
        COMPREPLY+=( $(compgen -d -- "$cur") )
    fi
}

# Completion for wt-open
_wt_open() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "$(_wtu_worktree_branches)" -- "$cur") )
}

# Completion for wt-pr
_wt_pr() {
    # PR numbers - no completion, just numeric input
    COMPREPLY=()
}

# Completion for wt-add-all-remote
_wt_add_all_remote() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    
    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$(_wtu_remotes)" -- "$cur") )
    fi
}

# Completion for commands with no arguments
_wt_no_args() {
    COMPREPLY=()
}

# Register completions
complete -F _wt_add wt-add
complete -F _wt_add wta
complete -F _wt_add_remote wt-add-remote
complete -F _wt_cd wt-cd
complete -F _wt_cd wtc
complete -F _wt_remove wt-remove
complete -F _wt_remove wtr
complete -F _wt_open wt-open
complete -F _wt_pr wt-pr
complete -F _wt_add_all_remote wt-add-all-remote
complete -F _wt_no_args wt-list
complete -F _wt_no_args wtl
complete -F _wt_no_args wt-status
complete -F _wt_no_args wts
complete -F _wt_no_args wt-clean
complete -F _wt_no_args wt-switch
complete -F _wt_no_args wt-help