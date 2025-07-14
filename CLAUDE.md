# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Git Worktree Manager (`wt`) is a Bash-based CLI tool that simplifies managing Git worktrees. It provides a streamlined workflow for creating, switching between, and managing multiple worktrees for a single repository.

## Common Development Commands

### Testing
```bash
# Run all tests
make test

# Run individual test files (from project root)
./tests/test_add_command.sh
./tests/test_config.sh
./tests/test_pr_checkout.sh
./tests/test_utilities.sh
```

### Installation
```bash
# Install system-wide (production)
make install

# Development installation (symlinks for local testing)
make dev-install

# Clean installation
make clean
```

### Release Management
```bash
# Create release archive
make release

# Install via Homebrew (after formula update)
brew install kniru/tap/wt
```

## Architecture & Code Structure

### Core Components

1. **Main Script (`bin/wt`)**: 
   - Entry point for all commands
   - Command routing logic in `main()` function (line ~420)
   - Core commands: `add`, `list`, `remove`, `switch`, `pr`, `init`, `config`
   - Configuration handling via `load_config()` function

2. **Configuration Module (`bin/wt-config`)**:
   - TOML parser for project configuration files
   - File copying functionality for non-tracked files
   - Configuration merging and hierarchy management
   - Functions: `parse_toml()`, `load_config_file()`, `copy_worktree_files()`

3. **Utilities (`bin/wt-utils`)**:
   - Additional helper functions
   - Sourced by main script when needed
   - Contains advanced worktree operations

4. **Configuration System**:
   - Global config: `~/.wtrc` (bash format, user-level)
   - Project config: `.wtconfig` (TOML format, project-level)
   - Hierarchical loading with project overriding global
   - Key features: file copying, hooks, templates

5. **Command Structure**:
   - Each command is a function: `create_worktree()`, `list_worktrees()`, etc.
   - New commands: `init_config()`, `show_config()`
   - Help system via `usage()` function
   - Main command routing in `main()` function

### Key Design Patterns

1. **Worktree Organization**:
   - Worktrees stored in `{repo-name}-worktrees/` directories
   - Automatic directory creation and management
   - Branch name sanitization for filesystem compatibility

2. **Editor Integration**:
   - Defaults to Cursor editor
   - Falls back to VS Code, then $EDITOR
   - Opens new worktrees automatically after creation

3. **Error Handling**:
   - Consistent error messages to stderr
   - Exit codes: 0 (success), 1 (error)
   - Validation before destructive operations

### Testing Approach

- Shell-based test suite in `tests/` directory
- Each test file is self-contained and executable
- Tests use temporary directories for isolation
- Test utilities defined in individual test files

## Important Implementation Details

- The script requires Bash 4.0+ for associative arrays
- Uses `git worktree` commands under the hood
- Handles special characters in branch names via sanitization
- PR checkout feature requires GitHub CLI (`gh`) to be installed
- Shell completion files need to be sourced in user's shell config