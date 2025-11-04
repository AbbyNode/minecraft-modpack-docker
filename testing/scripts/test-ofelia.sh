#!/usr/bin/env bash
# Tests for ofelia job scheduling service

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test framework
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/test-framework.sh"

test_suite "Ofelia Service - Script Structure"

# Test ofelia entrypoint script
test_ofelia_scripts() {
    local entrypoint_script="$PROJECT_ROOT/setup/scripts/ofelia-entrypoint.sh"
    
    assert_file_exists "$entrypoint_script" "ofelia-entrypoint.sh exists"
    assert_true "[ -x '$entrypoint_script' ]" "ofelia-entrypoint.sh is executable"
    
    # Check script creates symlink to config
    assert_true "grep -q '/etc/ofelia' '$entrypoint_script'" "Script references ofelia config directory"
    assert_true "grep -q 'ln -sf' '$entrypoint_script'" "Script creates symlink"
    assert_true "grep -q '/usr/bin/ofelia' '$entrypoint_script'" "Script executes ofelia"
}

test_ofelia_scripts

test_suite "Ofelia Service - Configuration"

# Test ofelia configuration template
test_ofelia_config() {
    local config_template="$PROJECT_ROOT/setup/templates/ofelia-config.ini"
    
    assert_file_exists "$config_template" "ofelia-config.ini template exists"
    
    # Check for job definitions
    assert_true "grep -q '\[job-exec \"borgmatic-backup\"\]' '$config_template'" "Defines borgmatic backup job"
    assert_true "grep -q '\[job-exec \"mcaselector-cleanup\"\]' '$config_template'" "Defines mcaselector cleanup job"
    assert_true "grep -q '\[job-exec \"unmined-map-generation\"\]' '$config_template'" "Defines unmined map generation job"
    
    # Check schedule format (cron syntax)
    assert_true "grep -q 'schedule = 0 7 \* \* \*' '$config_template'" "Uses cron schedule format"
    
    # Check no-overlap setting
    assert_true "grep -q 'no-overlap = true' '$config_template'" "Prevents job overlap"
    
    # Check container references
    assert_true "grep -q 'container = borgmatic' '$config_template'" "References borgmatic container"
    assert_true "grep -q 'container = mcaselector' '$config_template'" "References mcaselector container"
    assert_true "grep -q 'container = unmined' '$config_template'" "References unmined container"
    
    # Check command paths
    assert_true "grep -q 'command = /scripts/backup.sh' '$config_template'" "References backup script"
    assert_true "grep -q 'command = /scripts/delete-chunks.sh' '$config_template'" "References delete-chunks script"
    assert_true "grep -q 'command = /scripts/generate-map.sh' '$config_template'" "References generate-map script"
}

test_ofelia_config

test_suite "Ofelia Service - Docker Compose Configuration"

# Test ofelia service in docker-compose
test_ofelia_compose() {
    local compose_file="$PROJECT_ROOT/docker-compose.yml"
    
    # Check ofelia service is defined
    assert_true "grep -q 'ofelia:' '$compose_file'" "ofelia service is defined"
    
    # Check uses official mcuadros/ofelia image
    assert_true "grep -A 10 'ofelia:' '$compose_file' | grep -q 'mcuadros/ofelia'" "Uses official ofelia image"
    
    # Check mounts docker socket
    assert_true "grep -A 10 'ofelia:' '$compose_file' | grep -q '/var/run/docker.sock'" "Mounts Docker socket"
    
    # Check mounts config directory
    assert_true "grep -A 10 'ofelia:' '$compose_file' | grep -q './data/config/ofelia:/config'" "Mounts config directory"
    
    # Check custom entrypoint
    assert_true "grep -A 10 'ofelia:' '$compose_file' | grep -q 'entrypoint:.*ofelia-entrypoint.sh'" "Uses custom entrypoint"
    
    # Check depends on scheduled services
    assert_true "grep -A 15 'ofelia:' '$compose_file' | grep -q 'borgmatic' && \
                 grep -A 15 'ofelia:' '$compose_file' | grep -q 'mcaselector' && \
                 grep -A 15 'ofelia:' '$compose_file' | grep -q 'unmined'" "Depends on scheduled services"
}

test_ofelia_compose

test_suite "Ofelia Service - Schedule Validation"

# Test that all scheduled jobs have valid cron expressions
test_schedule_validation() {
    local config_template="$PROJECT_ROOT/setup/templates/ofelia-config.ini"
    
    # Extract schedule lines
    local schedules
    schedules=$(grep "^schedule = " "$config_template" || true)
    
    if [ -n "$schedules" ]; then
        # Count schedule entries
        local schedule_count
        schedule_count=$(echo "$schedules" | wc -l)
        assert_true "[ $schedule_count -ge 3 ]" "Has at least 3 scheduled jobs"
        
        # Check all schedules use 5-field cron format
        while IFS= read -r line; do
            local cron_expr
            cron_expr=$(echo "$line" | sed 's/schedule = //')
            local field_count
            field_count=$(echo "$cron_expr" | awk '{print NF}')
            assert_equals "5" "$field_count" "Schedule has 5 cron fields: $cron_expr"
        done <<< "$schedules"
    fi
}

test_schedule_validation

print_summary
