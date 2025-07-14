#!/usr/bin/env bash

# Git integration tests for wt

# Create a temporary git repository for testing
setup_test_repo() {
    local test_repo=$(mktemp -d)
    cd "$test_repo"
    
    # Initialize git repo
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create initial commit
    echo "test" > README.md
    git add README.md
    git commit -m "Initial commit" --quiet
    
    echo "$test_repo"
}

# Clean up test repository
cleanup_test_repo() {
    local test_repo="$1"
    if [[ -d "$test_repo" ]]; then
        rm -rf "$test_repo"
        rm -rf "${test_repo}-worktrees" 2>/dev/null || true
    fi
}

# Test worktree creation
test_create_worktree() {
    local test_repo=$(setup_test_repo)
    cd "$test_repo"
    
    # Create worktree
    local output=$("$PROJECT_DIR/bin/wt" feature-test -n 2>&1)
    assert_contains "$output" "Created worktree at:" "Should show success message"
    
    # Check worktree exists
    assert_true "[[ -d \"${test_repo}-worktrees/feature-test\" ]]" "Worktree directory should exist"
    
    # Check git recognizes the worktree
    local worktrees=$(git worktree list | grep -c "feature-test")
    assert_equals "1" "$worktrees" "Git should recognize the worktree"
    
    cleanup_test_repo "$test_repo"
}

# Test worktree listing
test_list_worktrees() {
    local test_repo=$(setup_test_repo)
    cd "$test_repo"
    
    # Create a worktree first
    "$PROJECT_DIR/bin/wt" feature-list -n >/dev/null 2>&1
    
    # List worktrees
    local output=$("$PROJECT_DIR/bin/wt" list 2>&1)
    assert_contains "$output" "WORKTREE" "Should show header"
    assert_contains "$output" "feature-list" "Should show created worktree"
    
    cleanup_test_repo "$test_repo"
}

# Test worktree removal
test_remove_worktree() {
    local test_repo=$(setup_test_repo)
    cd "$test_repo"
    
    # Create and remove worktree
    "$PROJECT_DIR/bin/wt" feature-remove -n >/dev/null 2>&1
    
    # Remove without branch deletion (simulate 'n' response)
    echo "n" | "$PROJECT_DIR/bin/wt" remove feature-remove >/dev/null 2>&1
    
    # Check worktree is removed
    assert_false "[[ -d \"${test_repo}-worktrees/feature-remove\" ]]" "Worktree directory should not exist"
    
    # Check branch still exists
    local branch_exists=$(git branch | grep -c "feature-remove")
    assert_equals "1" "$branch_exists" "Branch should still exist"
    
    cleanup_test_repo "$test_repo"
}

# Test worktree status
test_worktree_status() {
    local test_repo=$(setup_test_repo)
    cd "$test_repo"
    
    # Create worktree
    "$PROJECT_DIR/bin/wt" feature-status -n >/dev/null 2>&1
    
    # Check status
    local output=$("$PROJECT_DIR/bin/wt" status 2>&1)
    assert_contains "$output" "STATUS" "Should show status header"
    assert_contains "$output" "clean" "Should show clean status"
    
    cleanup_test_repo "$test_repo"
}

# Test error handling - not in git repo
test_not_git_repo() {
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    local output=$("$PROJECT_DIR/bin/wt" test-branch 2>&1)
    assert_contains "$output" "Not in a git repository" "Should show error when not in git repo"
    
    rmdir "$temp_dir"
}

# Run tests
test_create_worktree
test_list_worktrees
test_remove_worktree
test_worktree_status
test_not_git_repo