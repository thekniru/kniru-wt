#!/usr/bin/env bash

# Simple test runner for wt

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Testing wt..."

# Test 1: Help works
echo -n "1. Help command: "
if "$PROJECT_DIR/bin/wt" help >/dev/null 2>&1; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 2: Syntax is valid
echo -n "2. Script syntax: "
if bash -n "$PROJECT_DIR/bin/wt" 2>/dev/null; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 3: Version is set
echo -n "3. Version check: "
if grep -q "Version: 1.0.0" "$PROJECT_DIR/bin/wt"; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

echo
echo "All tests passed!"