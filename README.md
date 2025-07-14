# Git Worktree Manager (wt)

A world-class CLI tool for managing Git worktrees with an emphasis on agentic coding experiences. `wt` makes working with multiple branches simultaneously effortless and efficient.

## Features

- **Simple Worktree Creation**: Create worktrees with a single command
- **Smart Directory Organization**: Automatically organizes worktrees in a `{project}-worktrees` folder
- **Editor Integration**: Opens worktrees directly in your preferred editor (defaults to Cursor)
- **Comprehensive Management**: List, switch, remove, and clean up worktrees easily
- **Status Overview**: View all worktrees with their branches and uncommitted changes
- **Utility Functions**: Sync, diff, backup, and merge worktrees with helper commands
- **Shell Completions**: Full support for bash, zsh, and fish shells
- **Configurable**: Customize default branches, editor commands, and more

## Installation

### Via Homebrew (Recommended)

```bash
brew tap thekniru/kniru-wt https://github.com/thekniru/kniru-wt
brew install wt
```

Or install directly:

```bash
brew install https://raw.githubusercontent.com/thekniru/kniru-wt/main/Formula/wt.rb
```

This will install:
- `wt` command for worktree management
- `wt-utils` helper functions
- Shell completions for your shell
- Man pages for documentation

### Manual Installation

```bash
git clone https://github.com/thekniru/kniru-wt.git
cd kniru-wt
make install
```

## Quick Start

```bash
# Create a new worktree for a feature
wt feature-auth

# List all worktrees
wt list

# Switch to an existing worktree
wt switch feature-api

# Remove a worktree
wt remove feature-auth

# Show status of all worktrees
wt status
```

## Commands

### Core Commands

- `wt <branch-name>` - Create a new worktree with the given branch name
- `wt list` - List all worktrees for the current project
- `wt remove <branch-name>` - Remove a worktree
- `wt switch <branch-name>` - Switch to an existing worktree
- `wt clean` - Remove all worktrees with deleted branches
- `wt status` - Show status of all worktrees
- `wt help` - Show help message

### Options

- `-b, --base <branch>` - Base branch to create worktree from (default: main)
- `-e, --editor <command>` - Editor command to open worktree (default: cursor)
- `-n, --no-open` - Don't open the worktree in editor after creation
- `-f, --force` - Force remove worktree even if it has uncommitted changes

### Utility Functions

Source `wt-utils` to access additional helper functions:

```bash
source $(brew --prefix)/bin/wt-utils
```

- `wt_sync_all` - Sync all worktrees with remote
- `wt_diff <wt1> <wt2>` - Show diff between two worktrees
- `wt_backup <worktree>` - Create a backup branch of a worktree
- `wt_merge <worktree> [target]` - Merge worktree into target branch

## Configuration

Create a `~/.wtrc` file to customize defaults:

```bash
# Default base branch for new worktrees
DEFAULT_BASE_BRANCH="develop"

# Default editor command
EDITOR_COMMAND="code"

# Worktrees directory suffix
WORKTREES_SUFFIX="-worktrees"
```

## Shell Completions

Completions are automatically installed with Homebrew. For manual installation:

### Bash
```bash
source /usr/local/share/wt/completions/wt.bash
```

### Zsh
```bash
fpath=(/usr/local/share/wt/completions $fpath)
autoload -U compinit && compinit
```

### Fish
```bash
source /usr/local/share/wt/completions/wt.fish
```

## Use Cases

### Feature Development
```bash
# Create a feature branch worktree
wt feature-payment-integration

# Work on the feature...
# Switch back to main project
wt switch main

# Merge when ready
wt_merge feature-payment-integration
```

### Bug Fixes
```bash
# Create hotfix from production branch
wt hotfix-security -b production

# Fix the bug...
# Create PR and clean up
wt remove hotfix-security
```

### Code Reviews
```bash
# Checkout a PR branch in a separate worktree
wt pr-123 -b origin/pr-123

# Review code without disrupting current work
# Remove when done
wt remove pr-123
```

### Parallel Development
```bash
# Work on multiple features simultaneously
wt feature-auth
wt feature-api
wt feature-ui

# See status of all work
wt status

# Sync all with remote
wt_sync_all
```

## Best Practices

1. **Naming Convention**: Use descriptive branch names (e.g., `feature-auth`, `bugfix-login`, `hotfix-security`)
2. **Regular Cleanup**: Run `wt clean` periodically to remove orphaned worktrees
3. **Commit Before Switching**: Always commit or stash changes before switching worktrees
4. **Use Base Branches**: Specify the correct base branch with `-b` for features from develop
5. **Backup Important Work**: Use `wt_backup` before risky operations

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details.

## License

Apache License 2.0 - see [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/thekniru/kniru-wt/issues)
- **Discussions**: [GitHub Discussions](https://github.com/thekniru/kniru-wt/discussions)
- **Documentation**: `man wt` or `wt help`