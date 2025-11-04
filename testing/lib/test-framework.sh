#!/usr/bin/env bash
# Simple test framework for bash scripts

# Track test results
declare -g TESTS_RUN=0
declare -g TESTS_PASSED=0
declare -g TESTS_FAILED=0
declare -a FAILED_TESTS=()

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test result tracking
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="${3:-Assertion}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$expected" = "$actual" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} ${test_name}"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$test_name")
        echo -e "${RED}✗${NC} ${test_name}"
        echo "  Expected: ${expected}"
        echo "  Actual:   ${actual}"
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local test_name="${2:-Condition check}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if eval "$condition"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} ${test_name}"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$test_name")
        echo -e "${RED}✗${NC} ${test_name}"
        echo "  Condition failed: ${condition}"
        return 1
    fi
}

assert_file_exists() {
    local filepath="$1"
    local test_name="${2:-File exists: $filepath}"
    
    assert_true "[ -f '$filepath' ]" "$test_name"
}

assert_dir_exists() {
    local dirpath="$1"
    local test_name="${2:-Directory exists: $dirpath}"
    
    assert_true "[ -d '$dirpath' ]" "$test_name"
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="${3:-String contains check}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if echo "$haystack" | grep -q "$needle"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} ${test_name}"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$test_name")
        echo -e "${RED}✗${NC} ${test_name}"
        echo "  String did not contain: ${needle}"
        return 1
    fi
}

test_suite() {
    local suite_name="$1"
    echo ""
    echo -e "${BLUE}=== Test Suite: ${suite_name} ===${NC}"
}

print_summary() {
    echo ""
    echo "========================================"
    echo "Test Summary"
    echo "========================================"
    echo "Total tests run: ${TESTS_RUN}"
    echo -e "${GREEN}Passed: ${TESTS_PASSED}${NC}"
    echo -e "${RED}Failed: ${TESTS_FAILED}${NC}"
    
    if [ ${TESTS_FAILED} -gt 0 ]; then
        echo ""
        echo "Failed tests:"
        for test in "${FAILED_TESTS[@]}"; do
            echo -e "  ${RED}✗${NC} ${test}"
        done
        echo ""
        return 1
    else
        echo -e "\n${GREEN}All tests passed!${NC}\n"
        return 0
    fi
}
