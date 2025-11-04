#!/usr/bin/env bash
# Tests for setup service initialization

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test framework
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/test-framework.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/docker-utils.sh"

test_suite "Setup Service - Script Structure"

# Test setup script exists and is valid
test_setup_script_structure() {
    local init_script="$PROJECT_ROOT/setup/scripts/init.sh"
    
    assert_file_exists "$init_script" "init.sh exists"
    assert_true "[ -x '$init_script' ]" "init.sh is executable"
    
    # Check for key operations in the script
    assert_true "grep -q 'data/setup-scripts' '$init_script'" "Script creates setup-scripts directory"
    assert_true "grep -q '\\.env' '$init_script'" "Script handles .env file"
    assert_true "grep -q 'ofelia' '$init_script'" "Script handles ofelia config"
    assert_true "grep -q '/opt/shared' '$init_script'" "Script populates shared scripts volume"
}

test_setup_script_structure

test_suite "Setup Service - Templates"

# Test that required templates exist
test_setup_templates() {
    local templates_dir="$PROJECT_ROOT/setup/templates"
    
    assert_dir_exists "$templates_dir" "Templates directory exists"
    assert_file_exists "$templates_dir/.env.example" ".env.example template exists"
    assert_file_exists "$templates_dir/ofelia-config.ini" "ofelia-config.ini template exists"
    
    # Check .env.example has required variables
    local env_example="$templates_dir/.env.example"
    assert_true "grep -q 'MODPACK_URL' '$env_example'" ".env.example contains MODPACK_URL"
    assert_true "grep -q 'BORG_PASSPHRASE' '$env_example'" ".env.example contains BORG_PASSPHRASE"
    
    # Check ofelia config has scheduled jobs
    local ofelia_config="$templates_dir/ofelia-config.ini"
    assert_true "grep -q 'borgmatic-backup' '$ofelia_config'" "Ofelia config includes borgmatic job"
    assert_true "grep -q 'mcaselector-cleanup' '$ofelia_config'" "Ofelia config includes mcaselector job"
    assert_true "grep -q 'unmined-map-generation' '$ofelia_config'" "Ofelia config includes unmined job"
}

test_setup_templates

test_suite "Setup Service - Shared Libraries"

# Test that shared libraries are properly structured
test_shared_libraries() {
    local lib_dir="$PROJECT_ROOT/setup/lib"
    
    assert_dir_exists "$lib_dir" "Shared lib directory exists"
    assert_file_exists "$lib_dir/log.sh" "log.sh library exists"
    assert_file_exists "$lib_dir/resolve-curseforge-url.sh" "resolve-curseforge-url.sh exists"
    
    # Both should be executable
    assert_true "[ -x '$lib_dir/log.sh' ]" "log.sh is executable"
    assert_true "[ -x '$lib_dir/resolve-curseforge-url.sh' ]" "resolve-curseforge-url.sh is executable"
}

test_shared_libraries

test_suite "Setup Service - Dockerfile"

# Test setup Dockerfile
test_setup_dockerfile() {
    local dockerfile="$PROJECT_ROOT/setup/Dockerfile"
    
    assert_file_exists "$dockerfile" "Setup Dockerfile exists"
    
    # Check Dockerfile structure
    assert_true "grep -q 'FROM alpine' '$dockerfile'" "Uses Alpine base image"
    assert_true "grep -q 'COPY.*templates' '$dockerfile'" "Copies templates"
    assert_true "grep -q 'COPY.*scripts' '$dockerfile'" "Copies scripts"
    assert_true "grep -q 'COPY.*lib' '$dockerfile'" "Copies shared lib"
    assert_true "grep -q 'ENTRYPOINT.*init.sh' '$dockerfile'" "Sets init.sh as entrypoint"
}

test_setup_dockerfile

print_summary
