#!/usr/bin/env bash

# Test runner for wt
# Runs all test files in the tests directory

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$TEST_DIR")"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test framework functions
test_start() {
    echo -e "\n${YELLOW}Running tests...${NC}"
}

test_file() {
    local file="$1"
    echo -e "\n${YELLOW}Testing: $(basename "$file")${NC}"
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    ((TESTS_RUN++))
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $message"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        ((TESTS_FAILED++))
    fi
}

assert_true() {
    local condition="$1"
    local message="${2:-}"
    
    ((TESTS_RUN++))
    
    if eval "$condition"; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $message"
        echo "  Condition failed: $condition"
        ((TESTS_FAILED++))
    fi
}

assert_false() {
    local condition="$1"
    local message="${2:-}"
    
    ((TESTS_RUN++))
    
    if ! eval "$condition"; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $message"
        echo "  Condition should have failed: $condition"
        ((TESTS_FAILED++))
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-}"
    
    ((TESTS_RUN++))
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $message"
        echo "  String does not contain: $needle"
        echo "  In: $haystack"
        ((TESTS_FAILED++))
    fi
}

test_summary() {
    echo -e "\n${YELLOW}Test Summary:${NC}"
    echo "  Total tests: $TESTS_RUN"
    echo -e "  Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "  Failed: ${RED}$TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "\n${RED}Some tests failed!${NC}"
        return 1
    fi
}

# Export functions and variables for test files
export -f assert_equals assert_true assert_false assert_contains
export TEST_DIR PROJECT_DIR

# Run tests
test_start

# Source and run each test file
for test_file_path in "$TEST_DIR"/test_*.sh; do
    if [[ -f "$test_file_path" ]]; then
        test_file "$test_file_path"
        source "$test_file_path"
    fi
done

# Show summary
test_summary