#!/usr/bin/env bash
# Unit tests for library functions in minecraft-modpack

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test framework
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/test-framework.sh"

test_suite "Minecraft Modpack Libraries - log.sh"

# Test log.sh functions
test_log_functions() {
    local log_script="$PROJECT_ROOT/minecraft-modpack/lib/log.sh"
    
    assert_file_exists "$log_script" "log.sh exists in minecraft-modpack"
    
    # Source the log script
    # shellcheck disable=SC1090
    source "$log_script"
    
    # Test that functions are defined
    assert_true "command -v log_info >/dev/null" "log_info function is defined"
    assert_true "command -v log_warn >/dev/null" "log_warn function is defined"
    assert_true "command -v log_error >/dev/null" "log_error function is defined"
    assert_true "command -v log__ts >/dev/null" "log__ts helper function is defined"
    
    # Test log output format
    local log_output
    log_output=$(log_info "test message" 2>&1)
    assert_contains "$log_output" "[INFO]" "log_info contains [INFO] prefix"
    assert_contains "$log_output" "test message" "log_info contains message"
    
    # Test log file writing
    local temp_log="/tmp/test-log-$$.log"
    LOG_FILE="$temp_log" log_info "file test"
    assert_file_exists "$temp_log" "Log file created when LOG_FILE is set"
    assert_contains "$(cat "$temp_log")" "file test" "Log file contains message"
    rm -f "$temp_log"
}

test_log_functions

print_summary
