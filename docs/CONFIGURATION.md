# Git Worktree Manager Configuration Guide

The Git Worktree Manager (`wt`) now supports comprehensive configuration through `.wtconfig` files, allowing you to customize behavior on both global and project levels.

## Configuration Hierarchy

`wt` follows a hierarchical configuration system, with settings applied in this order (later overrides earlier):

1. **Built-in defaults** - Hardcoded in the tool
2. **Global config** - `~/.wtrc` (bash script format)
3. **Project config** - `.wtconfig` in project root (TOML format)
4. **Command-line options** - Flags passed directly to commands

## Quick Start

Initialize a configuration file in your project:

```bash
wt init
```

This creates a `.wtconfig` file with sensible defaults that you can customize.

## Configuration File Format

Project configuration files use TOML format for clarity and flexibility:

```toml
# .wtconfig example

[global]
default_branch = "main"
default_editor = "cursor"
auto_open = true

[copy]
include = [
    ".env",
    ".env.local",
    "docker-compose.override.yml",
]
exclude = [
    "node_modules/",
    "*.log",
    "dist/",
]
use_gitignore = true
```

## Configuration Options

### Global Settings

```toml
[global]
# The default branch to create worktrees from
default_branch = "main"

# The editor command to open worktrees
default_editor = "cursor"  # Options: cursor, code, vim, etc.

# Whether to automatically open the editor after creating a worktree
auto_open = true
```

### File Copying Configuration

One of the most powerful features is the ability to copy non-tracked files to new worktrees:

```toml
[copy]
# Files and patterns to copy to new worktrees
include = [
    # Environment files
    ".env",
    ".env.local",
    ".env.development",
    
    # Docker overrides
    "docker-compose.override.yml",
    
    # Local configs
    "*.local",
    "config/local.json",
    
    # Build artifacts
    ".astro/",  # Astro build cache
    
    # IDE settings
    ".vscode/settings.json",
]

# Patterns to exclude (follows .gitignore syntax)
exclude = [
    "node_modules/",
    "vendor/",
    "*.log",
    "logs/",
    "dist/",
    "build/",
    ".cache/",
    "coverage/",
    ".DS_Store",
]

# Whether to respect .gitignore when copying
use_gitignore = true
```

### Worktree Templates

Define templates for different types of branches:

```toml
[[templates]]
name = "feature"
branch_prefix = "feature/"
base_branch = "develop"
copy_include = [
    ".env.development",
    "docker-compose.dev.yml",
]

[[templates]]
name = "hotfix"
branch_prefix = "hotfix/"
base_branch = "main"
copy_include = [
    ".env.production",
]
```

### Hook Scripts

Run custom scripts at specific points:

```toml
[hooks]
# Run after creating a worktree
post_create = """
#!/bin/bash
echo "Setting up new worktree..."
if [ -f package.json ]; then
    npm install
fi
if [ -f .env.example ] && [ ! -f .env ]; then
    cp .env.example .env
fi
"""

# Run before removing a worktree
pre_remove = """
#!/bin/bash
echo "Cleaning up worktree..."
# Add cleanup commands here
"""
```

## Usage Examples

### Basic Usage

```bash
# Create worktree with config-based defaults
wt feature-auth

# Override config settings
wt feature-api -b develop -n
```

### View Current Configuration

```bash
# Show active configuration
wt config
```

### Project-Specific Setup

1. Create a `.wtconfig` in your project root:
   ```bash
   wt init
   ```

2. Edit the file to match your project needs:
   ```toml
   [copy]
   include = [
       ".env",
       "docker-compose.override.yml",
       "config/development.json",
   ]
   ```

3. New worktrees will automatically copy these files:
   ```bash
   wt feature-new
   # Creates worktree and copies .env, docker-compose.override.yml, etc.
   ```

## Pattern Syntax

### Include Patterns

- **Exact files**: `".env"`, `"docker-compose.yml"`
- **Wildcards**: `"*.local"`, `"config/*.json"`
- **Directories**: `"docker-data/"`, `".astro/"`
- **Recursive**: `"**/*.config"`

### Exclude Patterns

Exclude patterns follow `.gitignore` syntax:

- `node_modules/` - Exclude directory
- `*.log` - Exclude by extension
- `!important.log` - Exception to exclude rule
- `/root-only.txt` - Only at root
- `**/any-dir/file.txt` - In any directory

## Best Practices

1. **Environment Files**: Include development environment files that aren't tracked:
   ```toml
   include = [".env", ".env.local", ".env.development"]
   ```

2. **Build Caches**: Include build caches for faster development:
   ```toml
   include = [".astro/", ".next/", ".turbo/"]
   ```

3. **IDE Settings**: Share local IDE configurations:
   ```toml
   include = [".vscode/settings.json", ".idea/workspace.xml"]
   ```

4. **Docker Overrides**: Include local Docker configurations:
   ```toml
   include = ["docker-compose.override.yml", "docker-data/"]
   ```

5. **Use Templates**: Define templates for consistent branch naming:
   ```toml
   [[templates]]
   name = "feature"
   branch_prefix = "feat/"
   base_branch = "develop"
   ```

## Troubleshooting

### Files Not Being Copied

1. Check if the pattern matches:
   ```bash
   ls -la .env*  # Check what files exist
   ```

2. Verify configuration is loaded:
   ```bash
   wt config  # Shows active configuration
   ```

3. Check exclude patterns aren't blocking includes

### Configuration Not Loading

1. Ensure `.wtconfig` is in the project root
2. Check TOML syntax is valid
3. Run `wt config` to see what's loaded

### Performance Issues

If copying many files slows down worktree creation:

1. Use specific patterns instead of wildcards
2. Exclude large directories explicitly
3. Consider using hooks for deferred setup

## Migration from Basic Setup

If you're currently using `wt` without configuration:

1. Your existing workflow continues to work
2. Add configuration gradually as needed
3. Start with just the files you manually copy

Example migration:

```toml
# Start simple
[copy]
include = [".env"]

# Add more as needed
include = [
    ".env",
    ".env.local",
    "docker-compose.override.yml",
]
```

## Security Considerations

- Never include sensitive files in shared repositories
- Use `.gitignore` to ensure config files with secrets aren't committed
- Review `include` patterns to avoid copying sensitive data
- Consider using `.env.example` files as templates