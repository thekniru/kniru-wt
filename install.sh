#!/usr/bin/env bash

# Installation script for wt (Git Worktree Manager)
# This script can be used by non-Homebrew users

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default installation prefix
PREFIX="${PREFIX:-$HOME/.local}"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [--prefix DIR]"
            echo "  --prefix DIR    Installation directory (default: ~/.local)"
            echo "  --help, -h      Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}Installing wt (Git Worktree Manager)...${NC}"
echo "Installation directory: $PREFIX"

# Check for required commands
for cmd in git bash; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Error: $cmd is not installed${NC}"
        exit 1
    fi
done

# Create directories
mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/share/wt/completions"
mkdir -p "$PREFIX/share/man/man1"

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install binaries
echo "Installing executables..."
install -m 755 "$SCRIPT_DIR/bin/wt" "$PREFIX/bin/wt"
install -m 755 "$SCRIPT_DIR/bin/wt-utils" "$PREFIX/bin/wt-utils"

# Install completions
echo "Installing shell completions..."
install -m 644 "$SCRIPT_DIR/completions/wt.bash" "$PREFIX/share/wt/completions/wt.bash"
install -m 644 "$SCRIPT_DIR/completions/wt.zsh" "$PREFIX/share/wt/completions/_wt"
install -m 644 "$SCRIPT_DIR/completions/wt.fish" "$PREFIX/share/wt/completions/wt.fish"

# Install man pages
echo "Installing documentation..."
install -m 644 "$SCRIPT_DIR/docs/wt.1" "$PREFIX/share/man/man1/wt.1"
install -m 644 "$SCRIPT_DIR/docs/wt-utils.1" "$PREFIX/share/man/man1/wt-utils.1"

# Install additional files
install -m 644 "$SCRIPT_DIR/README.md" "$PREFIX/share/wt/README.md"
install -m 644 "$SCRIPT_DIR/LICENSE" "$PREFIX/share/wt/LICENSE" 2>/dev/null || true

echo -e "\n${GREEN}✓ Installation complete!${NC}"

# Check if bin directory is in PATH
if [[ ":$PATH:" != *":$PREFIX/bin:"* ]]; then
    echo -e "\n${YELLOW}Warning: $PREFIX/bin is not in your PATH${NC}"
    echo "Add the following to your shell configuration file:"
    echo -e "${BLUE}export PATH=\"$PREFIX/bin:\$PATH\"${NC}"
fi

# Show completion instructions
echo -e "\n${BLUE}To enable shell completions:${NC}"

# Detect shell
if [[ -n "${BASH_VERSION:-}" ]]; then
    echo "For bash, add to ~/.bashrc:"
    echo "  source $PREFIX/share/wt/completions/wt.bash"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
    echo "For zsh, add to ~/.zshrc:"
    echo "  fpath=($PREFIX/share/wt/completions \$fpath)"
    echo "  autoload -U compinit && compinit"
fi

echo -e "\n${BLUE}To use wt-utils functions:${NC}"
echo "  source $PREFIX/bin/wt-utils"

echo -e "\n${BLUE}Configuration:${NC}"
echo "Create ~/.wtrc to customize settings (see .wtrc.example)"

echo -e "\n${GREEN}Run 'wt help' to get started!${NC}"