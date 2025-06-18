#!/bin/bash

# Git Worktree Utilities - Installation Script
# This script installs the git-worktree-utils.sh file and configures your shell

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Default installation directory
DEFAULT_INSTALL_DIR="$HOME"
DEFAULT_INSTALL_FILE=".git-worktree-utils.sh"

# Function to detect shell configuration file
detect_shell_config() {
    if [ -n "$BASH_VERSION" ]; then
        if [ -f "$HOME/.bashrc" ]; then
            echo "$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            echo "$HOME/.bash_profile"
        else
            echo "$HOME/.profile"
        fi
    elif [ -n "$ZSH_VERSION" ]; then
        if [ -f "$HOME/.zshrc" ]; then
            echo "$HOME/.zshrc"
        else
            echo "$HOME/.zprofile"
        fi
    else
        echo "$HOME/.profile"
    fi
}

# Print header
echo -e "${MAGENTA}"
echo "╔═══════════════════════════════════════╗"
echo "║   Git Worktree Utilities Installer    ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: Git is not installed!${NC}"
    echo "Please install Git first: https://git-scm.com/downloads"
    exit 1
fi

# Check git version (need 2.5+ for worktree support)
GIT_VERSION=$(git --version | awk '{print $3}')
GIT_MAJOR=$(echo "$GIT_VERSION" | cut -d. -f1)
GIT_MINOR=$(echo "$GIT_VERSION" | cut -d. -f2)

if [ "$GIT_MAJOR" -lt 2 ] || ([ "$GIT_MAJOR" -eq 2 ] && [ "$GIT_MINOR" -lt 5 ]); then
    echo -e "${RED}Error: Git version 2.5+ is required for worktree support${NC}"
    echo "Current version: $GIT_VERSION"
    echo "Please upgrade Git: https://git-scm.com/downloads"
    exit 1
fi

echo -e "${GREEN}✓ Git version $GIT_VERSION detected${NC}"

# Determine installation method
if [ -f "git-worktree-utils.sh" ]; then
    echo -e "${GREEN}✓ Found local git-worktree-utils.sh${NC}"
    SOURCE_FILE="git-worktree-utils.sh"
    SOURCE_TYPE="local"
else
    echo -e "${BLUE}Local file not found. Will download from GitHub...${NC}"
    SOURCE_TYPE="remote"
fi

# Ask for installation directory
echo
echo -e "${YELLOW}Where would you like to install the utilities?${NC}"
echo -e "Default: ${BLUE}$DEFAULT_INSTALL_DIR/$DEFAULT_INSTALL_FILE${NC}"
read -p "Press Enter for default or specify path: " CUSTOM_PATH

if [ -z "$CUSTOM_PATH" ]; then
    INSTALL_PATH="$DEFAULT_INSTALL_DIR/$DEFAULT_INSTALL_FILE"
else
    INSTALL_PATH="$CUSTOM_PATH"
fi

# Create directory if needed
INSTALL_DIR=$(dirname "$INSTALL_PATH")
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${BLUE}Creating directory: $INSTALL_DIR${NC}"
    mkdir -p "$INSTALL_DIR"
fi

# Install the file
echo
if [ "$SOURCE_TYPE" = "local" ]; then
    echo -e "${BLUE}Installing from local file...${NC}"
    cp "$SOURCE_FILE" "$INSTALL_PATH"
else
    echo -e "${BLUE}Downloading from GitHub...${NC}"
    if command -v curl &> /dev/null; then
        curl -fsSL "https://raw.githubusercontent.com/rhymiz/wtu/main/git-worktree-utils.sh" -o "$INSTALL_PATH"
    elif command -v wget &> /dev/null; then
        wget -q "https://raw.githubusercontent.com/rhymiz/wtu/main/git-worktree-utils.sh" -O "$INSTALL_PATH"
    else
        echo -e "${RED}Error: Neither curl nor wget is installed${NC}"
        echo "Please install curl or wget to download the file"
        exit 1
    fi
fi

# Make it readable
chmod +r "$INSTALL_PATH"

echo -e "${GREEN}✓ Utilities installed to: $INSTALL_PATH${NC}"

# Install completions
echo
echo -e "${BLUE}Installing shell completions...${NC}"

if [ "$SOURCE_TYPE" = "local" ] && [ -d "completions" ]; then
    # Install from local completions
    if [ -n "$BASH_VERSION" ]; then
        if [ -f "completions/bash/wtu-completions.bash" ]; then
            cp "completions/bash/wtu-completions.bash" "$HOME/.wtu-completions.bash"
            echo -e "${GREEN}✓ Bash completions installed${NC}"
        fi
    elif [ -n "$ZSH_VERSION" ]; then
        if [ -f "completions/zsh/_wtu" ]; then
            mkdir -p "$HOME/.wtu/completions/zsh"
            cp "completions/zsh/_wtu" "$HOME/.wtu/completions/zsh/"
            echo -e "${GREEN}✓ Zsh completions installed${NC}"
        fi
    fi
else
    # Download completions from GitHub
    if [ -n "$BASH_VERSION" ]; then
        echo -e "${BLUE}Downloading bash completions...${NC}"
        if command -v curl &> /dev/null; then
            curl -fsSL "https://raw.githubusercontent.com/rhymiz/wtu/main/completions/bash/wtu-completions.bash" -o "$HOME/.wtu-completions.bash" 2>/dev/null && \
                echo -e "${GREEN}✓ Bash completions installed${NC}" || \
                echo -e "${YELLOW}⚠ Could not download bash completions${NC}"
        elif command -v wget &> /dev/null; then
            wget -q "https://raw.githubusercontent.com/rhymiz/wtu/main/completions/bash/wtu-completions.bash" -O "$HOME/.wtu-completions.bash" 2>/dev/null && \
                echo -e "${GREEN}✓ Bash completions installed${NC}" || \
                echo -e "${YELLOW}⚠ Could not download bash completions${NC}"
        fi
    elif [ -n "$ZSH_VERSION" ]; then
        echo -e "${BLUE}Downloading zsh completions...${NC}"
        mkdir -p "$HOME/.wtu/completions/zsh"
        if command -v curl &> /dev/null; then
            curl -fsSL "https://raw.githubusercontent.com/rhymiz/wtu/main/completions/zsh/_wtu" -o "$HOME/.wtu/completions/zsh/_wtu" 2>/dev/null && \
                echo -e "${GREEN}✓ Zsh completions installed${NC}" || \
                echo -e "${YELLOW}⚠ Could not download zsh completions${NC}"
        elif command -v wget &> /dev/null; then
            wget -q "https://raw.githubusercontent.com/rhymiz/wtu/main/completions/zsh/_wtu" -O "$HOME/.wtu/completions/zsh/_wtu" 2>/dev/null && \
                echo -e "${GREEN}✓ Zsh completions installed${NC}" || \
                echo -e "${YELLOW}⚠ Could not download zsh completions${NC}"
        fi
    fi
fi

# Detect shell config file
SHELL_CONFIG=$(detect_shell_config)
echo
echo -e "${YELLOW}Detected shell configuration file: $SHELL_CONFIG${NC}"

# Check if already sourced
if grep -q "source.*$INSTALL_PATH" "$SHELL_CONFIG" 2>/dev/null || grep -q "\\..*$INSTALL_PATH" "$SHELL_CONFIG" 2>/dev/null; then
    echo -e "${GREEN}✓ Utilities already sourced in $SHELL_CONFIG${NC}"
else
    echo -e "${BLUE}Adding source command to $SHELL_CONFIG...${NC}"
    echo "" >> "$SHELL_CONFIG"
    echo "# Git Worktree Utilities" >> "$SHELL_CONFIG"
    echo "source $INSTALL_PATH" >> "$SHELL_CONFIG"
    echo -e "${GREEN}✓ Added to shell configuration${NC}"
fi

# Optional: Check for fzf
echo
if command -v fzf &> /dev/null; then
    echo -e "${GREEN}✓ fzf detected - interactive switching (wt-switch) will be available${NC}"
else
    echo -e "${YELLOW}Note: fzf not found${NC}"
    echo "Install fzf for interactive worktree switching: https://github.com/junegunn/fzf"
fi

# Optional configuration
echo
echo -e "${MAGENTA}═══ Optional Configuration ═══${NC}"
echo
echo -e "${YELLOW}Would you like to configure the utilities now? (y/N)${NC}"
read -p "> " CONFIGURE

if [[ "$CONFIGURE" =~ ^[Yy]$ ]]; then
    echo
    echo -e "${BLUE}1. Worktree base directory${NC}"
    echo "   Where worktrees will be created (default: ../)"
    echo "   Current: ${WORKTREE_BASE_DIR:-../}"
    read -p "   New value (press Enter to skip): " NEW_BASE_DIR
    
    echo
    echo -e "${BLUE}2. Worktree prefix${NC}"
    echo "   Prefix for worktree directory names (default: wt-)"
    echo "   Current: ${WORKTREE_PREFIX:-wt-}"
    read -p "   New value (press Enter to skip): " NEW_PREFIX
    
    # Add configuration if provided
    if [ -n "$NEW_BASE_DIR" ] || [ -n "$NEW_PREFIX" ]; then
        echo >> "$SHELL_CONFIG"
        echo "# Git Worktree Utilities Configuration" >> "$SHELL_CONFIG"
        
        if [ -n "$NEW_BASE_DIR" ]; then
            echo "export WORKTREE_BASE_DIR=\"$NEW_BASE_DIR\"" >> "$SHELL_CONFIG"
            echo -e "${GREEN}✓ Set WORKTREE_BASE_DIR=$NEW_BASE_DIR${NC}"
        fi
        
        if [ -n "$NEW_PREFIX" ]; then
            echo "export WORKTREE_PREFIX=\"$NEW_PREFIX\"" >> "$SHELL_CONFIG"
            echo -e "${GREEN}✓ Set WORKTREE_PREFIX=$NEW_PREFIX${NC}"
        fi
    fi
fi

# Success message
echo
echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Installation Complete! 🎉         ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
echo
echo -e "${YELLOW}To start using the utilities:${NC}"
echo -e "  1. Reload your shell: ${BLUE}source $SHELL_CONFIG${NC}"
echo -e "  2. Or open a new terminal"
echo -e "  3. Run ${BLUE}wt-help${NC} to see available commands"
echo
echo -e "${MAGENTA}Quick start:${NC}"
echo -e "  ${BLUE}wt-add feature/new-feature${NC}  - Create a new worktree"
echo -e "  ${BLUE}wt-list${NC}                     - List all worktrees"
echo -e "  ${BLUE}wt-cd feature/new-feature${NC}   - Switch to a worktree"
echo
echo -e "${GREEN}Happy branching! 🌳${NC}"

# Offer to source immediately
echo
echo -e "${YELLOW}Would you like to load the utilities now? (y/N)${NC}"
read -p "> " LOAD_NOW

if [[ "$LOAD_NOW" =~ ^[Yy]$ ]]; then
    source "$INSTALL_PATH"
    echo -e "${GREEN}✓ Utilities loaded! Run 'wt-help' to get started.${NC}"
fi