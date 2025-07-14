# Fish completion for wt (Git Worktree Manager)
# Install: Place in ~/.config/fish/completions/

# Disable file completion by default
complete -c wt -f

# Helper function to get worktrees
function __fish_wt_worktrees
    if command -v wt >/dev/null 2>&1
        wt list 2>/dev/null | awk 'NR>2 {print $1}' | grep -v '^*'
    end
end

# Helper function to get git branches
function __fish_wt_branches
    git branch --format='%(refname:short)' 2>/dev/null
end

# Helper function to check if no command is given yet
function __fish_wt_needs_command
    set -l cmd (commandline -opc)
    test (count $cmd) -eq 1
end

# Helper function to check current command
function __fish_wt_using_command
    set -l cmd (commandline -opc)
    test (count $cmd) -gt 1; and contains -- $cmd[2] $argv
end

# Main commands
complete -c wt -n __fish_wt_needs_command -a list -d "List all worktrees"
complete -c wt -n __fish_wt_needs_command -a ls -d "List all worktrees (alias)"
complete -c wt -n __fish_wt_needs_command -a remove -d "Remove a worktree"
complete -c wt -n __fish_wt_needs_command -a rm -d "Remove a worktree (alias)"
complete -c wt -n __fish_wt_needs_command -a switch -d "Switch to an existing worktree"
complete -c wt -n __fish_wt_needs_command -a sw -d "Switch to an existing worktree (alias)"
complete -c wt -n __fish_wt_needs_command -a clean -d "Remove worktrees with deleted branches"
complete -c wt -n __fish_wt_needs_command -a status -d "Show status of all worktrees"
complete -c wt -n __fish_wt_needs_command -a st -d "Show status of all worktrees (alias)"
complete -c wt -n __fish_wt_needs_command -a help -d "Show help message"

# Branch names for creating new worktrees
complete -c wt -n __fish_wt_needs_command -a "(__fish_wt_branches)" -d "Create worktree with branch"

# Options
complete -c wt -s b -l base -d "Base branch to create from" -xa "(__fish_wt_branches)"
complete -c wt -s e -l editor -d "Editor command" -xa "code cursor vim nvim emacs subl atom"
complete -c wt -s n -l no-open -d "Don't open in editor"
complete -c wt -s f -l force -d "Force remove"
complete -c wt -s h -l help -d "Show help"

# Command-specific completions
complete -c wt -n "__fish_wt_using_command remove rm" -a "(__fish_wt_worktrees)" -d "Worktree"
complete -c wt -n "__fish_wt_using_command switch sw" -a "(__fish_wt_worktrees)" -d "Worktree"

# Completions for wt-utils functions
complete -c wt_sync_all -f -d "Sync all worktrees with remote"

complete -c wt_diff -f
complete -c wt_diff -n "test (count (commandline -opc)) -eq 1" -a "(__fish_wt_worktrees)" -d "First worktree"
complete -c wt_diff -n "test (count (commandline -opc)) -eq 2" -a "(__fish_wt_worktrees)" -d "Second worktree"

complete -c wt_backup -f
complete -c wt_backup -n "test (count (commandline -opc)) -eq 1" -a "(__fish_wt_worktrees)" -d "Worktree to backup"

complete -c wt_merge -f
complete -c wt_merge -n "test (count (commandline -opc)) -eq 1" -a "(__fish_wt_worktrees)" -d "Source worktree"
complete -c wt_merge -n "test (count (commandline -opc)) -eq 2" -a "(__fish_wt_branches)" -d "Target branch"