#!/usr/bin/env bash
# Unit tests for shared library functions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test framework
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/test-framework.sh"

test_suite "Shared Libraries - log.sh"

# Test log.sh functions
test_log_functions() {
    local log_script="$PROJECT_ROOT/setup/lib/log.sh"
    
    assert_file_exists "$log_script" "log.sh exists"
    
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

test_suite "Shared Libraries - resolve-curseforge-url.sh"

# Test URL resolver script structure
test_url_resolver_structure() {
    local resolver_script="$PROJECT_ROOT/setup/lib/resolve-curseforge-url.sh"
    
    assert_file_exists "$resolver_script" "resolve-curseforge-url.sh exists"
    
    # Check script is executable
    assert_true "[ -x '$resolver_script' ]" "resolve-curseforge-url.sh is executable"
    
    # Check script has proper shebang
    local first_line
    first_line=$(head -1 "$resolver_script")
    assert_contains "$first_line" "bash" "Script has bash shebang"
    
    # Check for key functions/variables
    assert_true "grep -q 'MODPACK_SLUG' '$resolver_script'" "Script contains MODPACK_SLUG variable"
    assert_true "grep -q 'curseforge.com' '$resolver_script'" "Script references curseforge.com"
}

# Test URL slug extraction logic
test_url_slug_extraction() {
    local resolver_script="$PROJECT_ROOT/setup/lib/resolve-curseforge-url.sh"
    
    # Test slug extraction pattern (simulated)
    local test_url="https://www.curseforge.com/minecraft/modpacks/all-the-mods-10"
    local expected_slug="all-the-mods-10"
    local extracted_slug
    extracted_slug=$(echo "$test_url" | sed -n 's|.*/modpacks/\([^/?]*\).*|\1|p')
    
    assert_equals "$expected_slug" "$extracted_slug" "URL slug extraction pattern works"
}

test_url_resolver_structure
test_url_slug_extraction

print_summary
