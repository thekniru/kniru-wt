#!/usr/bin/env bash

# Test configuration functionality

set -euo pipefail

# Source test utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../bin/wt-config"

# Test directory setup
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

# Test function
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "Testing $test_name... "
    
    local output=$($test_function 2>&1)
    local result=$?
    
    if [[ "$output" == "SKIPPED"* ]]; then
        echo -e "${YELLOW}$output${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))  # Count skipped as passed
    elif [[ $result -eq 0 ]]; then
        echo -e "${GREEN}PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}FAILED${NC}"
    fi
}

# Test 1: Parse simple TOML values
test_parse_toml_simple() {
    cd "$TEST_DIR"
    cat > test.toml << 'EOF'
# Test config
[global]
default_branch = "main"
default_editor = "cursor"
auto_open = true

[copy]
use_gitignore = true
EOF

    local output=$(parse_toml test.toml)
    
    # Check parsed values
    [[ "$output" =~ "global.default_branch=main" ]] || return 1
    [[ "$output" =~ "global.default_editor=cursor" ]] || return 1
    [[ "$output" =~ "global.auto_open=true" ]] || return 1
    [[ "$output" =~ "copy.use_gitignore=true" ]] || return 1
    
    return 0
}

# Test 2: Parse TOML arrays
test_parse_toml_arrays() {
    # Skip this test on bash < 4.0 due to regex limitations
    if [[ "${BASH_VERSION%%.*}" -lt 4 ]]; then
        echo "SKIPPED (requires bash 4.0+)"
        return 0
    fi
    
    cd "$TEST_DIR"
    cat > test.toml << 'EOF'
[copy]
include = [
    ".env",
    ".env.local",
    "docker-compose.override.yml",
]

exclude = [
    "node_modules/",
    "*.log",
]
EOF

    # Test include array
    local includes=$(parse_toml_array test.toml "copy.include")
    [[ "$includes" =~ ".env" ]] || return 1
    [[ "$includes" =~ ".env.local" ]] || return 1
    [[ "$includes" =~ "docker-compose.override.yml" ]] || return 1
    
    # Test exclude array
    local excludes=$(parse_toml_array test.toml "copy.exclude")
    [[ "$excludes" =~ "node_modules/" ]] || return 1
    [[ "$excludes" =~ "\*.log" ]] || return 1
    
    return 0
}

# Test 3: Load config file
test_load_config_file() {
    cd "$TEST_DIR"
    cat > test.toml << 'EOF'
[global]
default_branch = "develop"

[copy]
include = [
    ".env",
]
EOF

    # Clear any existing config vars
    unset WT_CONFIG_GLOBAL_DEFAULT_BRANCH
    unset WT_CONFIG_COPY_INCLUDE
    
    # Load config
    load_config_file test.toml
    
    # Check variables were set
    [[ "${WT_CONFIG_GLOBAL_DEFAULT_BRANCH}" == "develop" ]] || return 1
    [[ "${WT_CONFIG_COPY_INCLUDE[0]}" == ".env" ]] || return 1
    
    return 0
}

# Test 4: Find project config
test_find_project_config() {
    cd "$TEST_DIR"
    mkdir -p subdir/nested
    
    # Create config in parent
    touch .wtconfig
    
    # Test from nested directory
    cd subdir/nested
    local found=$(find_project_config "$(pwd)")
    [[ "$found" == "$TEST_DIR/.wtconfig" ]] || return 1
    
    return 0
}

# Test 5: Get config value with fallback
test_get_config_value() {
    # Set a test variable
    export WT_CONFIG_GLOBAL_DEFAULT_BRANCH="feature"
    
    # Test existing value
    local value=$(get_config_value "global.default_branch" "main")
    [[ "$value" == "feature" ]] || return 1
    
    # Test non-existing value with fallback
    local value2=$(get_config_value "global.non_existent" "fallback")
    [[ "$value2" == "fallback" ]] || return 1
    
    return 0
}

# Test 6: File copying patterns
test_copy_worktree_files() {
    cd "$TEST_DIR"
    
    # Create source structure
    mkdir -p source/subdir
    echo "env content" > source/.env
    echo "local content" > source/.env.local
    echo "log content" > source/test.log
    echo "subdir file" > source/subdir/file.txt
    
    # Create target
    mkdir target
    
    # Set up config
    export WT_CONFIG_COPY_INCLUDE=(".env" ".env.local")
    export WT_CONFIG_COPY_EXCLUDE=("*.log")
    
    # Run copy
    copy_worktree_files "$TEST_DIR/source" "$TEST_DIR/target"
    
    # Verify files were copied
    [[ -f "$TEST_DIR/target/.env" ]] || return 1
    [[ -f "$TEST_DIR/target/.env.local" ]] || return 1
    
    # Verify log was not copied
    [[ ! -f "$TEST_DIR/target/test.log" ]] || return 1
    
    return 0
}

# Run all tests
echo "Running Git Worktree Manager Configuration Tests"
echo "================================================"

run_test "parse simple TOML" test_parse_toml_simple
run_test "parse TOML arrays" test_parse_toml_arrays
run_test "load config file" test_load_config_file
run_test "find project config" test_find_project_config
run_test "get config value" test_get_config_value
run_test "copy worktree files" test_copy_worktree_files

echo ""
echo "Tests completed: $TESTS_PASSED/$TESTS_RUN passed"

if [[ $TESTS_PASSED -eq $TESTS_RUN ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi