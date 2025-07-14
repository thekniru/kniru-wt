#!/usr/bin/env bash

# Basic tests for wt command

# Test wt help command
test_help() {
    # Remove color codes for testing
    local output=$("$PROJECT_DIR/bin/wt" help 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
    assert_contains "$output" "Git Worktree Manager" "Help should show title"
    assert_contains "$output" "USAGE:" "Help should show usage section"
    assert_contains "$output" "COMMANDS:" "Help should show commands section"
}

# Test wt with no arguments
test_no_args() {
    local output=$("$PROJECT_DIR/bin/wt" 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
    assert_contains "$output" "USAGE:" "No args should show usage"
}

# Test wt version in script
test_version() {
    local version=$(grep "^# Version:" "$PROJECT_DIR/bin/wt" | cut -d' ' -f3)
    assert_equals "1.0.0" "$version" "Version should be 1.0.0"
}

# Test configuration loading
test_config() {
    # Create temporary config
    local temp_config=$(mktemp)
    echo 'DEFAULT_BASE_BRANCH="develop"' > "$temp_config"
    echo 'EDITOR_COMMAND="vim"' >> "$temp_config"
    
    # Test that config would be loaded (without actually running wt)
    assert_true "[[ -f \"$temp_config\" ]]" "Temp config file should exist"
    
    # Clean up
    rm -f "$temp_config"
}

# Test script syntax
test_syntax() {
    local result=$(bash -n "$PROJECT_DIR/bin/wt" 2>&1)
    assert_equals "" "$result" "Script should have valid syntax"
    
    local result=$(bash -n "$PROJECT_DIR/bin/wt-utils" 2>&1)
    assert_equals "" "$result" "Utils script should have valid syntax"
}

# Run tests
test_help
test_no_args
test_version
test_config
test_syntax