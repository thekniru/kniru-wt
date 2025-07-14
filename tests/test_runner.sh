#!/usr/bin/env bash

# Test runner for wt
# This is a simplified test runner that works correctly

set -euo pipefail

# Test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$TEST_DIR")"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

echo -e "${YELLOW}Running wt tests...${NC}\n"

# Test 1: Help command
echo -n "Testing help command... "
if "$PROJECT_DIR/bin/wt" help 2>&1 | grep -q "Git Worktree Manager"; then
    echo -e "${GREEN}✓${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC}"
    ((TESTS_FAILED++))
fi

# Test 2: No arguments shows usage
echo -n "Testing no arguments... "
if "$PROJECT_DIR/bin/wt" 2>&1 | grep -q "USAGE:"; then
    echo -e "${GREEN}✓${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC}"
    ((TESTS_FAILED++))
fi

# Test 3: Script syntax
echo -n "Testing script syntax... "
if bash -n "$PROJECT_DIR/bin/wt" 2>/dev/null && bash -n "$PROJECT_DIR/bin/wt-utils" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC}"
    ((TESTS_FAILED++))
fi

# Test 4: Git repository detection
echo -n "Testing git repo detection... "
temp_dir=$(mktemp -d)
original_dir=$(pwd)
cd "$temp_dir"
# Remove color codes before checking
if "$PROJECT_DIR/bin/wt" test-branch 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep -q "Not in a git repository"; then
    echo -e "${GREEN}✓${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC}"
    ((TESTS_FAILED++))
fi
cd "$original_dir"
rmdir "$temp_dir"

# Test 5: Worktree creation (in a real git repo)
echo -n "Testing worktree creation... "
test_repo=$(mktemp -d)
cd "$test_repo"
git init --quiet
git config user.email "test@example.com"
git config user.name "Test User"
echo "test" > README.md
git add README.md
git commit -m "Initial commit" --quiet

if "$PROJECT_DIR/bin/wt" feature-test -n 2>&1 | grep -q "Created worktree at:"; then
    if [[ -d "${test_repo}-worktrees/feature-test" ]]; then
        echo -e "${GREEN}✓${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} (worktree directory not created)"
        ((TESTS_FAILED++))
    fi
else
    echo -e "${RED}✗${NC} (creation failed)"
    ((TESTS_FAILED++))
fi

# Cleanup
rm -rf "$test_repo" "${test_repo}-worktrees" 2>/dev/null || true

# Summary
echo -e "\n${YELLOW}Test Summary:${NC}"
echo "  Passed: ${GREEN}$TESTS_PASSED${NC}"
echo "  Failed: ${RED}$TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed!${NC}"
    exit 1
fi