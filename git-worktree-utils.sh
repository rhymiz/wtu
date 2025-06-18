#!/bin/bash

# Git Worktree Utilities
# A collection of bash functions to simplify working with git worktrees

# Configuration
WORKTREE_BASE_DIR="${WORKTREE_BASE_DIR:-$(pwd)/../}"
WORKTREE_PREFIX="${WORKTREE_PREFIX:-wt-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create a new worktree
# Usage: wt-add <branch-name> [worktree-name]
wt-add() {
    local branch="$1"
    local worktree_name="${2:-$WORKTREE_PREFIX$branch}"
    local worktree_path="$WORKTREE_BASE_DIR/$worktree_name"
    
    if [ -z "$branch" ]; then
        echo -e "${RED}Error: Branch name required${NC}"
        echo "Usage: wt-add <branch-name> [worktree-name]"
        return 1
    fi
    
    # Check if branch exists
    if git show-ref --verify --quiet "refs/heads/$branch"; then
        echo -e "${BLUE}Creating worktree for existing branch '$branch'...${NC}"
        git worktree add "$worktree_path" "$branch"
    else
        echo -e "${YELLOW}Branch '$branch' doesn't exist. Creating new branch...${NC}"
        git worktree add -b "$branch" "$worktree_path"
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Worktree created at: $worktree_path${NC}"
        echo -e "${BLUE}To enter the worktree, run: cd $worktree_path${NC}"
    else
        echo -e "${RED}✗ Failed to create worktree${NC}"
        return 1
    fi
}

# Create worktree from remote branch
# Usage: wt-add-remote <remote-branch> [local-branch-name]
wt-add-remote() {
    local remote_branch="$1"
    local local_branch="${2:-${remote_branch#*/}}"
    local worktree_name="$WORKTREE_PREFIX$local_branch"
    local worktree_path="$WORKTREE_BASE_DIR/$worktree_name"
    
    if [ -z "$remote_branch" ]; then
        echo -e "${RED}Error: Remote branch name required${NC}"
        echo "Usage: wt-add-remote <remote-branch> [local-branch-name]"
        return 1
    fi
    
    echo -e "${BLUE}Creating worktree for remote branch '$remote_branch'...${NC}"
    git worktree add -b "$local_branch" "$worktree_path" "$remote_branch"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Worktree created at: $worktree_path${NC}"
        echo -e "${GREEN}✓ Tracking remote branch: $remote_branch${NC}"
    else
        echo -e "${RED}✗ Failed to create worktree${NC}"
        return 1
    fi
}

# List all worktrees with enhanced formatting
# Usage: wt-list
wt-list() {
    echo -e "${BLUE}Git Worktrees:${NC}"
    echo "────────────────────────────────────────────────────────"
    
    git worktree list --porcelain | awk '
    BEGIN {
        count = 0
    }
    /^worktree/ {
        if (count > 0) print ""
        count++
        path = substr($0, 10)
        printf "'"${GREEN}"'[%d]'"${NC}"' %s\n", count, path
    }
    /^HEAD/ {
        commit = substr($0, 6, 7)
        printf "    Commit: %s\n", commit
    }
    /^branch/ {
        branch = substr($0, 8)
        printf "    Branch: '"${YELLOW}"'%s'"${NC}"'\n", branch
    }
    /^detached/ {
        printf "    Branch: '"${RED}"'(detached HEAD)'"${NC}"'\n"
    }
    '
    echo "────────────────────────────────────────────────────────"
}

# Switch to a worktree directory
# Usage: wt-cd <branch-name-or-number>
wt-cd() {
    local target="$1"
    
    if [ -z "$target" ]; then
        echo -e "${RED}Error: Branch name or number required${NC}"
        echo "Usage: wt-cd <branch-name-or-number>"
        return 1
    fi
    
    local worktree_path=""
    
    # Check if target is a number
    if [[ "$target" =~ ^[0-9]+$ ]]; then
        worktree_path=$(git worktree list --porcelain | grep "^worktree" | sed -n "${target}p" | cut -d' ' -f2-)
    else
        # Search by branch name
        worktree_path=$(git worktree list --porcelain | awk -v branch="$target" '
            /^worktree/ { path = substr($0, 10) }
            /^branch/ && substr($0, 8) == branch { print path; exit }
        ')
    fi
    
    if [ -z "$worktree_path" ]; then
        echo -e "${RED}Error: Worktree not found for '$target'${NC}"
        return 1
    fi
    
    cd "$worktree_path" || return 1
    echo -e "${GREEN}✓ Switched to worktree: $worktree_path${NC}"
}

# Remove a worktree
# Usage: wt-remove <branch-name-or-path>
wt-remove() {
    local target="$1"
    
    if [ -z "$target" ]; then
        echo -e "${RED}Error: Branch name or path required${NC}"
        echo "Usage: wt-remove <branch-name-or-path>"
        return 1
    fi
    
    local worktree_path=""
    
    # Check if it's a path
    if [[ -d "$target" ]]; then
        worktree_path="$target"
    else
        # Search by branch name
        worktree_path=$(git worktree list --porcelain | awk -v branch="$target" '
            /^worktree/ { path = substr($0, 10) }
            /^branch/ && substr($0, 8) == branch { print path; exit }
        ')
    fi
    
    if [ -z "$worktree_path" ]; then
        echo -e "${RED}Error: Worktree not found for '$target'${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Removing worktree: $worktree_path${NC}"
    git worktree remove "$worktree_path"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Worktree removed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to remove worktree${NC}"
        echo -e "${YELLOW}Try: git worktree remove --force $worktree_path${NC}"
        return 1
    fi
}

# Clean up all worktrees that no longer exist
# Usage: wt-clean
wt-clean() {
    echo -e "${BLUE}Cleaning up stale worktree entries...${NC}"
    git worktree prune -v
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

# Create worktrees for all remote branches
# Usage: wt-add-all-remote [remote-name]
wt-add-all-remote() {
    local remote="${1:-origin}"
    
    echo -e "${BLUE}Creating worktrees for all branches from remote '$remote'...${NC}"
    
    # Get all remote branches
    git for-each-ref --format='%(refname:short)' "refs/remotes/$remote" | while read -r branch; do
        # Skip HEAD
        if [[ "$branch" == "$remote/HEAD" ]]; then
            continue
        fi
        
        local branch_name="${branch#$remote/}"
        
        # Skip if local branch already exists
        if git show-ref --verify --quiet "refs/heads/$branch_name"; then
            echo -e "${YELLOW}⚠ Branch '$branch_name' already exists locally, skipping...${NC}"
            continue
        fi
        
        # Skip if worktree already exists
        if git worktree list --porcelain | grep -q "branch.*$branch_name$"; then
            echo -e "${YELLOW}⚠ Worktree for '$branch_name' already exists, skipping...${NC}"
            continue
        fi
        
        wt-add-remote "$branch" "$branch_name"
    done
    
    echo -e "${GREEN}✓ All remote branches processed${NC}"
}

# Show status of all worktrees
# Usage: wt-status
wt-status() {
    echo -e "${BLUE}Status of all worktrees:${NC}"
    echo "────────────────────────────────────────────────────────"
    
    git worktree list --porcelain | awk '
    /^worktree/ {
        path = substr($0, 10)
        getline
        getline
        if ($0 ~ /^branch/) {
            branch = substr($0, 8)
        } else {
            branch = "(detached)"
        }
        
        # Get git status for this worktree
        cmd = "cd \"" path "\" && git status --porcelain 2>/dev/null | wc -l"
        cmd | getline changes
        close(cmd)
        
        # Check if directory exists
        cmd = "test -d \"" path "\" && echo exists"
        cmd | getline exists
        close(cmd)
        
        if (exists == "exists") {
            if (changes > 0) {
                printf "'"${YELLOW}"'●'"${NC}"' %s ('"${YELLOW}"'%d changes'"${NC}"')\n", branch, changes
            } else {
                printf "'"${GREEN}"'●'"${NC}"' %s (clean)\n", branch
            }
            printf "  %s\n", path
        } else {
            printf "'"${RED}"'●'"${NC}"' %s ('"${RED}"'missing'"${NC}"')\n", branch
            printf "  %s\n", path
        }
    }'
    echo "────────────────────────────────────────────────────────"
}

# Open a new terminal in worktree
# Usage: wt-open <branch-name>
wt-open() {
    local branch="$1"
    
    if [ -z "$branch" ]; then
        echo -e "${RED}Error: Branch name required${NC}"
        echo "Usage: wt-open <branch-name>"
        return 1
    fi
    
    local worktree_path=$(git worktree list --porcelain | awk -v branch="$branch" '
        /^worktree/ { path = substr($0, 10) }
        /^branch/ && substr($0, 8) == branch { print path; exit }
    ')
    
    if [ -z "$worktree_path" ]; then
        echo -e "${RED}Error: Worktree not found for branch '$branch'${NC}"
        return 1
    fi
    
    # Detect terminal and open new window/tab
    if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
        # Ghostty terminal support
        osascript -e "tell application \"Ghostty\" to activate" -e "tell application \"System Events\" to keystroke \"t\" using command down" -e "delay 0.5" -e "tell application \"System Events\" to keystroke \"cd $worktree_path\" & return"
    elif [[ "$TERM_PROGRAM" == "WarpTerminal" ]]; then
        # Warp terminal support
        osascript -e "tell application \"Warp\" to activate" -e "tell application \"System Events\" to keystroke \"t\" using command down" -e "delay 0.5" -e "tell application \"System Events\" to keystroke \"cd $worktree_path\" & return"
    elif [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        osascript -e "tell application \"iTerm\" to create window with default profile command \"cd $worktree_path && $SHELL\""
    elif [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
        osascript -e "tell application \"Terminal\" to do script \"cd $worktree_path\""
    elif command -v gnome-terminal &> /dev/null; then
        gnome-terminal --working-directory="$worktree_path"
    elif command -v konsole &> /dev/null; then
        konsole --workdir "$worktree_path"
    elif command -v xterm &> /dev/null; then
        xterm -e "cd $worktree_path && $SHELL" &
    else
        echo -e "${YELLOW}Could not detect terminal. Please manually open: $worktree_path${NC}"
    fi
}

# Interactive worktree switcher using fzf (if available)
# Usage: wt-switch
wt-switch() {
    if ! command -v fzf &> /dev/null; then
        echo -e "${RED}Error: fzf is not installed${NC}"
        echo "Install fzf for interactive switching: https://github.com/junegunn/fzf"
        return 1
    fi
    
    local selected=$(git worktree list | fzf --ansi --preview 'echo "Branch: $(git -C {1} branch --show-current 2>/dev/null || echo "detached")" && echo && git -C {1} status -s' | awk '{print $1}')
    
    if [ -n "$selected" ]; then
        cd "$selected" || return 1
        echo -e "${GREEN}✓ Switched to: $selected${NC}"
    fi
}

# Create a worktree for a pull request (GitHub)
# Usage: wt-pr <pr-number>
wt-pr() {
    local pr_number="$1"
    
    if [ -z "$pr_number" ]; then
        echo -e "${RED}Error: PR number required${NC}"
        echo "Usage: wt-pr <pr-number>"
        return 1
    fi
    
    # Fetch PR info
    echo -e "${BLUE}Fetching PR #$pr_number...${NC}"
    git fetch origin "pull/$pr_number/head:pr-$pr_number"
    
    if [ $? -eq 0 ]; then
        wt-add "pr-$pr_number"
    else
        echo -e "${RED}✗ Failed to fetch PR #$pr_number${NC}"
        return 1
    fi
}

# Show help
# Usage: wt-help
wt-help() {
    echo -e "${BLUE}Git Worktree Utilities${NC}"
    echo "────────────────────────────────────────────────────────"
    echo -e "${GREEN}wt-add${NC} <branch> [name]      - Create a new worktree"
    echo -e "${GREEN}wt-add-remote${NC} <remote-branch> - Create worktree from remote branch"
    echo -e "${GREEN}wt-add-all-remote${NC} [remote]  - Create worktrees for all remote branches"
    echo -e "${GREEN}wt-list${NC}                     - List all worktrees"
    echo -e "${GREEN}wt-cd${NC} <branch-or-number>    - Change to worktree directory"
    echo -e "${GREEN}wt-remove${NC} <branch-or-path>  - Remove a worktree"
    echo -e "${GREEN}wt-clean${NC}                    - Clean up stale worktree entries"
    echo -e "${GREEN}wt-status${NC}                   - Show status of all worktrees"
    echo -e "${GREEN}wt-open${NC} <branch>            - Open worktree in new terminal"
    echo -e "${GREEN}wt-switch${NC}                   - Interactive switcher (requires fzf)"
    echo -e "${GREEN}wt-pr${NC} <pr-number>           - Create worktree for GitHub PR"
    echo -e "${GREEN}wt-help${NC}                     - Show this help message"
    echo "────────────────────────────────────────────────────────"
    echo -e "${YELLOW}Configuration:${NC}"
    echo "  WORKTREE_BASE_DIR - Base directory for worktrees (default: ../)"
    echo "  WORKTREE_PREFIX   - Prefix for worktree names (default: wt-)"
}

# Alias for quick access
alias wtl='wt-list'
alias wta='wt-add'
alias wtr='wt-remove'
alias wtc='wt-cd'
alias wts='wt-status'

# Load completions if available
if [ -n "$BASH_VERSION" ]; then
    # Bash completion
    # Check common locations
    for completion_file in \
        "$HOME/.wtu-completions.bash" \
        "${BASH_SOURCE%/*}/completions/bash/wtu-completions.bash" \
        "/usr/local/share/wtu/completions/bash/wtu-completions.bash" \
        "/usr/share/wtu/completions/bash/wtu-completions.bash"; do
        if [ -f "$completion_file" ]; then
            source "$completion_file"
            break
        fi
    done
elif [ -n "$ZSH_VERSION" ]; then
    # Zsh completion
    # Add completion paths
    for completion_dir in \
        "$HOME/.wtu/completions/zsh" \
        "${0:A:h}/completions/zsh" \
        "/usr/local/share/wtu/completions/zsh" \
        "/usr/share/wtu/completions/zsh"; do
        if [ -d "$completion_dir" ]; then
            fpath=("$completion_dir" $fpath)
            break
        fi
    done
    
    # Ensure compinit is loaded
    autoload -Uz compinit && compinit
fi

