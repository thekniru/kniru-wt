#compdef wt
# Zsh completion for wt (Git Worktree Manager)
# Install: Place in your $fpath (e.g., /usr/local/share/zsh/site-functions/)

_wt() {
    local -a commands options worktrees branches

    commands=(
        'list:List all worktrees'
        'ls:List all worktrees (alias)'
        'remove:Remove a worktree'
        'rm:Remove a worktree (alias)'
        'switch:Switch to an existing worktree'
        'sw:Switch to an existing worktree (alias)'
        'clean:Remove worktrees with deleted branches'
        'status:Show status of all worktrees'
        'st:Show status of all worktrees (alias)'
        'help:Show help message'
    )

    options=(
        '-b[Base branch to create from]:branch:_wt_branches'
        '--base[Base branch to create from]:branch:_wt_branches'
        '-e[Editor command]:editor:(code cursor vim nvim emacs subl atom)'
        '--editor[Editor command]:editor:(code cursor vim nvim emacs subl atom)'
        '-n[Do not open in editor]'
        '--no-open[Do not open in editor]'
        '-f[Force remove]'
        '--force[Force remove]'
        '-h[Show help]'
        '--help[Show help]'
    )

    # Get worktrees for completion
    _wt_worktrees() {
        local -a worktrees
        if command -v wt &> /dev/null; then
            worktrees=("${(@f)$(wt list 2>/dev/null | awk 'NR>2 {print $1}' | grep -v '^\*')}")
        fi
        _describe -t worktrees 'worktree' worktrees
    }

    # Get branches for completion
    _wt_branches() {
        local -a branches
        branches=("${(@f)$(git branch --format='%(refname:short)' 2>/dev/null)}")
        _describe -t branches 'branch' branches
    }

    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        '1: :->command' \
        '*::arg:->args'

    case $state in
        command)
            # First argument can be a command or a branch name for creation
            _alternative \
                "commands:command:compadd -a commands" \
                'branches:branch name:_wt_branches'
            ;;
        args)
            case $line[1] in
                remove|rm|switch|sw)
                    _wt_worktrees
                    ;;
                list|ls|clean|status|st|help)
                    # No arguments needed
                    ;;
                *)
                    # Branch creation - show options
                    _arguments "${options[@]}"
                    ;;
            esac
            ;;
    esac
}

# Completion for wt-utils functions
_wt_diff() {
    _arguments \
        '1:first worktree:_wt_worktrees' \
        '2:second worktree:_wt_worktrees'
}

_wt_backup() {
    _arguments '1:worktree:_wt_worktrees'
}

_wt_merge() {
    _arguments \
        '1:source worktree:_wt_worktrees' \
        '2:target branch:_wt_branches'
}

_wt_sync_all() {
    # No arguments
    _message "no arguments"
}

# Helper function for worktrees (reused by utils)
_wt_worktrees() {
    local -a worktrees
    if command -v wt &> /dev/null; then
        worktrees=("${(@f)$(wt list 2>/dev/null | awk 'NR>2 {print $1}' | grep -v '^\*')}")
    fi
    _describe -t worktrees 'worktree' worktrees
}

# Helper function for branches (reused by utils)
_wt_branches() {
    local -a branches
    branches=("${(@f)$(git branch --format='%(refname:short)' 2>/dev/null)}")
    _describe -t branches 'branch' branches
}

# Register completions
compdef _wt wt
compdef _wt_diff wt_diff
compdef _wt_backup wt_backup
compdef _wt_merge wt_merge
compdef _wt_sync_all wt_sync_all