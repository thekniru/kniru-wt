# Bash completion for wt (Git Worktree Manager)
# Install: source this file in your .bashrc or .bash_profile

_wt_completions() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Main commands
    local commands="list ls remove rm switch sw clean status st help"
    
    # Options
    local options="-b --base -e --editor -n --no-open -f --force -h --help"
    
    # Complete options
    if [[ ${cur} == -* ]]; then
        COMPREPLY=( $(compgen -W "${options}" -- ${cur}) )
        return 0
    fi
    
    # Complete based on previous word
    case "${prev}" in
        -b|--base)
            # Complete with git branches
            local branches=$(git branch --format='%(refname:short)' 2>/dev/null)
            COMPREPLY=( $(compgen -W "${branches}" -- ${cur}) )
            return 0
            ;;
        -e|--editor)
            # Common editors
            COMPREPLY=( $(compgen -W "code cursor vim nvim emacs subl atom" -- ${cur}) )
            return 0
            ;;
        remove|rm|switch|sw)
            # Complete with existing worktree names
            if command -v wt &> /dev/null; then
                local worktrees=$(wt list 2>/dev/null | awk 'NR>2 {print $1}' | grep -v "^*")
                COMPREPLY=( $(compgen -W "${worktrees}" -- ${cur}) )
            fi
            return 0
            ;;
    esac
    
    # First argument - complete with commands or branch name
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        # Combine commands and branch suggestions
        local branches=$(git branch --format='%(refname:short)' 2>/dev/null | grep -v "^${cur}")
        COMPREPLY=( $(compgen -W "${commands} ${branches}" -- ${cur}) )
        return 0
    fi
    
    # Default - show options
    COMPREPLY=( $(compgen -W "${options}" -- ${cur}) )
}

# Register the completion function
complete -F _wt_completions wt

# Completion for wt-utils functions
_wt_utils_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    case "${COMP_WORDS[0]}" in
        wt_diff)
            # Complete with worktree names
            if command -v wt &> /dev/null; then
                local worktrees=$(wt list 2>/dev/null | awk 'NR>2 {print $1}' | grep -v "^*")
                COMPREPLY=( $(compgen -W "${worktrees}" -- ${cur}) )
            fi
            ;;
        wt_backup)
            # Complete with worktree names
            if command -v wt &> /dev/null; then
                local worktrees=$(wt list 2>/dev/null | awk 'NR>2 {print $1}' | grep -v "^*")
                COMPREPLY=( $(compgen -W "${worktrees}" -- ${cur}) )
            fi
            ;;
        wt_merge)
            if [[ ${COMP_CWORD} -eq 1 ]]; then
                # First argument - source worktree
                if command -v wt &> /dev/null; then
                    local worktrees=$(wt list 2>/dev/null | awk 'NR>2 {print $1}' | grep -v "^*")
                    COMPREPLY=( $(compgen -W "${worktrees}" -- ${cur}) )
                fi
            elif [[ ${COMP_CWORD} -eq 2 ]]; then
                # Second argument - target branch
                local branches=$(git branch --format='%(refname:short)' 2>/dev/null)
                COMPREPLY=( $(compgen -W "${branches}" -- ${cur}) )
            fi
            ;;
    esac
}

# Register completions for wt-utils functions
complete -F _wt_utils_completions wt_diff
complete -F _wt_utils_completions wt_backup
complete -F _wt_utils_completions wt_merge
complete -W "" wt_sync_all