# WTU (Worktree Utilities )

A comprehensive set of bash utilities to simplify and enhance your Git worktree workflow. Work on multiple branches simultaneously without the hassle of constant switching.

## 🚀 Features

- **Easy worktree management** - Create, list, remove, and navigate worktrees with simple commands
- **Remote branch support** - Quickly create worktrees from remote branches
- **Pull request integration** - Check out GitHub pull requests in isolated worktrees
- **Interactive switching** - Use fzf for fuzzy finding and switching between worktrees
- **Status overview** - See the status of all worktrees at a glance
- **Terminal integration** - Open worktrees in new terminal windows
- **Batch operations** - Create worktrees for all remote branches at once
- **Smart defaults** - Sensible naming conventions and directory organization
- **Colorized output** - Clear, color-coded feedback for all operations
- **Shell completion** - Tab completion support for bash and zsh

## 📋 Prerequisites

- Git 2.5+ (for worktree support)
- Bash 4.0+
- Optional: [fzf](https://github.com/junegunn/fzf) for interactive switching

## 🛠️ Installation

### Automated Install (Recommended)

Use the install script for a guided installation:

```bash
# Download and run the installer
curl -fsSL https://raw.githubusercontent.com/rhymiz/wtu/main/install.sh | bash

# Or if you've cloned the repo
./install.sh
```

The installer will:
- Check Git version compatibility (2.5+ required)
- Detect your shell (bash/zsh) and configure it automatically
- Install shell completions for tab completion support
- Optionally configure worktree settings
- Install from local file or download from GitHub
- Work on both macOS and Linux

### Quick Install

```bash
# Download the utilities
curl -o ~/.git-worktree-utils.sh https://raw.githubusercontent.com/rhymiz/wtu/main/git-worktree-utils.sh

# Add to your shell configuration
echo 'source ~/.git-worktree-utils.sh' >> ~/.bashrc
# OR for zsh users
echo 'source ~/.git-worktree-utils.sh' >> ~/.zshrc

# Reload your shell
source ~/.bashrc  # or source ~/.zshrc
```

### Manual Install

1. Copy the script to your preferred location:
   ```bash
   cp git-worktree-utils.sh ~/.git-worktree-utils.sh
   ```

2. Source it in your shell configuration file (`~/.bashrc`, `~/.zshrc`, etc.):
   ```bash
   source ~/.git-worktree-utils.sh
   ```

3. Reload your shell or open a new terminal

## ⚙️ Configuration

Configure the utilities by setting environment variables in your shell configuration:

```bash
# Base directory where worktrees will be created (default: ../)
export WORKTREE_BASE_DIR="$HOME/projects/worktrees"

# Prefix for worktree directory names (default: wt-)
export WORKTREE_PREFIX="branch-"
```

## 📖 Commands Reference

### Core Commands

#### `wt-add <branch> [name]`
Create a new worktree for a branch. If the branch doesn't exist, it will be created.

```bash
# Create worktree for existing branch
wt-add feature/authentication

# Create worktree with custom directory name
wt-add feature/authentication auth-feature

# Create new branch and worktree
wt-add feature/new-feature
```

#### `wt-list` (alias: `wtl`)
List all worktrees with their current branch and commit information.

```bash
wt-list
# Output:
# [1] /home/user/project/../wt-feature-auth
#     Commit: abc1234
#     Branch: feature/authentication
# [2] /home/user/project/../wt-bugfix
#     Commit: def5678
#     Branch: bugfix/issue-123
```

#### `wt-cd <branch-or-number>` (alias: `wtc`)
Change directory to a worktree by branch name or number from the list.

```bash
# Navigate by branch name
wt-cd feature/authentication

# Navigate by number from wt-list
wt-cd 2
```

#### `wt-remove <branch-or-path>` (alias: `wtr`)
Remove a worktree and clean up its reference.

```bash
# Remove by branch name
wt-remove feature/authentication

# Remove by path
wt-remove /path/to/worktree
```

#### `wt-status` (alias: `wts`)
Show the status of all worktrees, including uncommitted changes.

```bash
wt-status
# Output:
# ● main (clean)
#   /home/user/project
# ● feature/authentication (3 changes)
#   /home/user/project/../wt-feature-auth
# ● bugfix/issue-123 (missing)
#   /home/user/project/../wt-bugfix
```

### Remote Operations

#### `wt-add-remote <remote-branch> [local-branch]`
Create a worktree tracking a remote branch.

```bash
# Create worktree from remote branch
wt-add-remote origin/feature/remote-feature

# Specify local branch name
wt-add-remote origin/feature/remote-feature my-local-feature
```

#### `wt-add-all-remote [remote]`
Create worktrees for all remote branches that don't already have local counterparts.

```bash
# Create worktrees for all origin branches
wt-add-all-remote

# Create worktrees for specific remote
wt-add-all-remote upstream
```

### Advanced Commands

#### `wt-pr <pr-number>`
Create a worktree for a GitHub pull request.

```bash
# Checkout PR #123
wt-pr 123
```

#### `wt-switch`
Interactive worktree switcher using fzf (requires fzf to be installed).

```bash
wt-switch
# Opens interactive fuzzy finder with preview
```

#### `wt-open <branch>`
Open a worktree in a new terminal window (supports Ghostty, Warp, iTerm, Terminal.app, gnome-terminal, konsole, xterm).

```bash
wt-open feature/authentication
```

#### `wt-clean`
Clean up stale worktree entries that no longer exist on disk.

```bash
wt-clean
```

#### `wt-help`
Display help information for all commands.

```bash
wt-help
```

## 🎯 Common Workflows

### Feature Development

```bash
# Start working on a new feature
wt-add feature/user-authentication

# Navigate to the worktree
wt-cd feature/user-authentication

# Work on your feature...
# Meanwhile, if you need to fix something in main:
wt-cd main

# Check status across all worktrees
wt-status

# When done, remove the feature worktree
wt-remove feature/user-authentication
```

### Code Review Workflow

```bash
# Review a pull request
wt-pr 456

# Or checkout a colleague's remote branch
wt-add-remote origin/colleague/feature

# Open in new terminal for side-by-side comparison
wt-open colleague/feature

# Clean up after review
wt-remove pr-456
```

### Multiple Feature Development

```bash
# Set up worktrees for all remote features
wt-add-all-remote

# See what you have
wt-list

# Use interactive switcher to jump between them
wt-switch

# Check which ones have uncommitted work
wt-status
```

### Emergency Hotfix

```bash
# Quickly create a hotfix worktree
wt-add hotfix/critical-bug

# Your current work remains untouched in other worktrees
wt-cd hotfix/critical-bug

# Fix the bug, push, and remove
git add . && git commit -m "Fix critical bug"
git push origin hotfix/critical-bug
wt-remove hotfix/critical-bug
```

## 🔌 Shell Completion

Tab completion is automatically installed and configured by the install script. If you need to manually set it up:

### Bash Completion

```bash
# Download completion file
curl -o ~/.wtu-completions.bash https://raw.githubusercontent.com/rhymiz/wtu/main/completions/bash/wtu-completions.bash

# The main script will automatically source it
```

### Zsh Completion

```bash
# Create completion directory
mkdir -p ~/.wtu/completions/zsh

# Download completion file
curl -o ~/.wtu/completions/zsh/_wtu https://raw.githubusercontent.com/rhymiz/wtu/main/completions/zsh/_wtu

# The main script will automatically add to fpath
```

### What Can Be Completed

- **Branch names** - When creating or switching to worktrees
- **Remote branches** - When adding remote worktrees
- **Worktree numbers** - When using `wt-cd` with list numbers
- **Remote names** - When specifying which remote to use
- **File paths** - When removing worktrees by path

Example usage:
```bash
wt-add fea<TAB>              # Completes to feature branches
wt-cd <TAB>                  # Shows all worktree branches and numbers
wt-add-remote origin/<TAB>   # Shows all origin branches
wt-remove <TAB>              # Shows current worktrees
```

## 💡 Tips and Tricks

### 1. Organize Your Worktrees
```bash
# Set a dedicated directory for all worktrees
export WORKTREE_BASE_DIR="$HOME/dev/worktrees/$(basename $(pwd))"
```

### 2. Use Descriptive Prefixes
```bash
# Different prefixes for different types
export WORKTREE_PREFIX="feat-"  # for features
export WORKTREE_PREFIX="fix-"   # for bugfixes
export WORKTREE_PREFIX="pr-"    # for pull requests
```

### 3. Combine with Git Aliases
```bash
# Add to your .gitconfig
[alias]
    wt = worktree
    wtl = !bash -c 'source ~/.git-worktree-utils.sh && wt-list'
```

### 4. Quick Status Check
```bash
# Add to your prompt to show current worktree
PS1='[\W$(git worktree list --porcelain | grep -c "^worktree" | sed "s/1//")WT] $ '
```

### 5. Cleanup Script
```bash
# Remove all worktrees except main
for wt in $(git worktree list --porcelain | grep "^worktree" | cut -d' ' -f2- | grep -v "$(pwd)"); do
    wt-remove "$wt"
done
```

## 🔧 Troubleshooting

### Worktree Already Exists
```bash
# Error: fatal: 'feature/x' is already checked out at '/path/to/worktree'
# Solution: Remove the existing worktree first
wt-remove feature/x
wt-add feature/x
```

### Cannot Remove Worktree
```bash
# Error: fatal: 'worktree' contains modified or untracked files
# Solution: Force remove (loses uncommitted changes!)
git worktree remove --force /path/to/worktree
```

### Missing Worktree Directory
```bash
# If you deleted a worktree directory manually
wt-clean  # This will clean up the git references
```

### Permission Issues
```bash
# Ensure the base directory exists and is writable
mkdir -p "$WORKTREE_BASE_DIR"
chmod 755 "$WORKTREE_BASE_DIR"
```

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. Fork the repository
2. Create a feature branch (`wt-add feature/amazing-feature`)
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

### Ideas for Contribution

- Support for more terminal emulators
- Integration with tmux/screen
- Worktree templates
- Integration with other Git hosting services (GitLab, Bitbucket)
- Worktree-specific git hooks
- Performance optimizations for large repositories

## 📄 License

This project is licensed under the MIT License - see below for details:

```
MIT License

Copyright (c) 2024 Git Worktree Utilities

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🙏 Acknowledgments

- Inspired by the Git worktree feature and the need for better tooling
- Thanks to the Git community for continuous improvements to worktree functionality
- Special thanks to contributors and users who provide feedback and improvements

---

**Happy branching!** 🌳

If you find these utilities helpful, consider starring the repository and sharing with your team!