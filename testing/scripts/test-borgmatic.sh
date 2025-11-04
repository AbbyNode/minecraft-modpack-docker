#!/usr/bin/env bash
# Tests for borgmatic backup service

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test framework
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/test-framework.sh"

test_suite "Borgmatic Service - Script Structure"

# Test borgmatic scripts exist and are valid
test_borgmatic_scripts() {
    local backup_script="$PROJECT_ROOT/borgmatic/scripts/backup.sh"
    local entrypoint_script="$PROJECT_ROOT/borgmatic/scripts/entrypoint.sh"
    
    assert_file_exists "$backup_script" "backup.sh exists"
    assert_file_exists "$entrypoint_script" "entrypoint.sh exists"
    
    assert_true "[ -x '$backup_script' ]" "backup.sh is executable"
    assert_true "[ -x '$entrypoint_script' ]" "entrypoint.sh is executable"
    
    # Check backup script calls borgmatic
    assert_true "grep -q 'borgmatic' '$backup_script'" "backup.sh calls borgmatic"
    assert_true "grep -q 'stats' '$backup_script'" "backup.sh uses --stats flag"
    
    # Check entrypoint initializes repository
    assert_true "grep -q 'borgmatic init' '$entrypoint_script'" "entrypoint.sh initializes repository"
    assert_true "grep -q '/mnt/borg-repository' '$entrypoint_script'" "entrypoint.sh references correct repo path"
}

test_borgmatic_scripts

test_suite "Borgmatic Service - Configuration"

# Test borgmatic configuration template
test_borgmatic_config() {
    local config_template="$PROJECT_ROOT/borgmatic/templates/borgmatic-config.yaml"
    
    assert_file_exists "$config_template" "borgmatic-config.yaml template exists"
    
    # Check config has required sections
    assert_true "grep -q 'source_directories:' '$config_template'" "Config has source_directories"
    assert_true "grep -q 'repositories:' '$config_template'" "Config has repositories"
    assert_true "grep -q 'retention:' '$config_template'" "Config has retention policy"
    assert_true "grep -q 'keep_daily:' '$config_template'" "Config has daily retention"
    assert_true "grep -q 'keep_weekly:' '$config_template'" "Config has weekly retention"
    assert_true "grep -q 'keep_monthly:' '$config_template'" "Config has monthly retention"
    
    # Check backup sources
    assert_true "grep -q '/mnt/source/world' '$config_template'" "Config backs up world"
    assert_true "grep -q '/mnt/source/config' '$config_template'" "Config backs up config"
    assert_true "grep -q '/mnt/source/mods' '$config_template'" "Config backs up mods"
    assert_true "grep -q '/mnt/source/logs' '$config_template'" "Config backs up logs"
    
    # Check compression
    assert_true "grep -q 'compression:' '$config_template'" "Config has compression setting"
}

test_borgmatic_config

test_suite "Borgmatic Service - Dockerfile"

# Test borgmatic Dockerfile
test_borgmatic_dockerfile() {
    local dockerfile="$PROJECT_ROOT/borgmatic/Dockerfile"
    
    assert_file_exists "$dockerfile" "Borgmatic Dockerfile exists"
    
    # Check uses official borgmatic image
    assert_true "grep -q 'FROM.*borgmatic' '$dockerfile'" "Uses borgmatic base image"
    
    # Check installs necessary tools
    assert_true "grep -q 'bash' '$dockerfile'" "Installs bash"
    
    # Check copies scripts and templates
    assert_true "grep -q 'COPY.*scripts' '$dockerfile'" "Copies scripts"
    assert_true "grep -q 'COPY.*templates' '$dockerfile'" "Copies templates"
    assert_true "grep -q 'ENTRYPOINT.*entrypoint.sh' '$dockerfile'" "Sets entrypoint"
}

test_borgmatic_dockerfile

test_suite "Borgmatic Service - Docker Compose Configuration"

# Test borgmatic service in docker-compose
test_borgmatic_compose() {
    local compose_file="$PROJECT_ROOT/docker-compose.yml"
    
    assert_file_exists "$compose_file" "docker-compose.yml exists"
    
    # Check borgmatic service is defined
    assert_true "grep -q 'borgmatic:' '$compose_file'" "borgmatic service is defined"
    
    # Check volume mounts
    assert_true "grep -A 10 'borgmatic:' '$compose_file' | grep -q './data:/mnt/source'" "Mounts data directory as source"
    assert_true "grep -A 10 'borgmatic:' '$compose_file' | grep -q 'borg-repository'" "Mounts borg repository"
    assert_true "grep -A 10 'borgmatic:' '$compose_file' | grep -q '/etc/borgmatic.d'" "Mounts borgmatic config"
}

test_borgmatic_compose

print_summary
