#!/usr/bin/env bash
# Main test runner - runs all tests and reports results

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTING_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Test tracking
declare -a PASSED_SUITES=()
declare -a FAILED_SUITES=()
TOTAL_SUITES=0

echo -e "${BOLD}${BLUE}========================================${NC}"
echo -e "${BOLD}${BLUE}Minecraft Modpack Docker - Test Runner${NC}"
echo -e "${BOLD}${BLUE}========================================${NC}"
echo ""

# Function to run a test suite
run_test_suite() {
    local test_script="$1"
    local test_name
    test_name=$(basename "$test_script" .sh)
    
    echo -e "${BOLD}Running: ${test_name}${NC}"
    echo "----------------------------------------"
    
    TOTAL_SUITES=$((TOTAL_SUITES + 1))
    
    if bash "$test_script"; then
        PASSED_SUITES+=("$test_name")
        echo -e "${GREEN}✓ ${test_name} PASSED${NC}"
    else
        FAILED_SUITES+=("$test_name")
        echo -e "${RED}✗ ${test_name} FAILED${NC}"
    fi
    
    echo ""
}

# Find and run all test scripts
echo -e "${YELLOW}Discovering test scripts...${NC}"
echo ""

# Array of test scripts in execution order
TEST_SCRIPTS=(
    "$TESTING_ROOT/scripts/test-shared-libs.sh"
    "$TESTING_ROOT/scripts/test-setup-service.sh"
    "$TESTING_ROOT/scripts/test-minecraft-modpack.sh"
    "$TESTING_ROOT/scripts/test-borgmatic.sh"
    "$TESTING_ROOT/scripts/test-mcaselector.sh"
    "$TESTING_ROOT/scripts/test-unmined.sh"
    "$TESTING_ROOT/scripts/test-ofelia.sh"
    "$TESTING_ROOT/scripts/test-integration.sh"
)

# Run each test suite
for test_script in "${TEST_SCRIPTS[@]}"; do
    if [ -f "$test_script" ]; then
        run_test_suite "$test_script"
    else
        echo -e "${YELLOW}Warning: Test script not found: $test_script${NC}"
        echo ""
    fi
done

# Print final summary
echo -e "${BOLD}${BLUE}========================================${NC}"
echo -e "${BOLD}${BLUE}Final Test Summary${NC}"
echo -e "${BOLD}${BLUE}========================================${NC}"
echo ""
echo "Total test suites run: ${TOTAL_SUITES}"
echo -e "${GREEN}Passed: ${#PASSED_SUITES[@]}${NC}"
echo -e "${RED}Failed: ${#FAILED_SUITES[@]}${NC}"
echo ""

if [ ${#PASSED_SUITES[@]} -gt 0 ]; then
    echo -e "${GREEN}Passed suites:${NC}"
    for suite in "${PASSED_SUITES[@]}"; do
        echo -e "  ${GREEN}✓${NC} $suite"
    done
    echo ""
fi

if [ ${#FAILED_SUITES[@]} -gt 0 ]; then
    echo -e "${RED}Failed suites:${NC}"
    for suite in "${FAILED_SUITES[@]}"; do
        echo -e "  ${RED}✗${NC} $suite"
    done
    echo ""
    exit 1
fi

echo -e "${BOLD}${GREEN}All tests passed!${NC}"
echo ""
exit 0
