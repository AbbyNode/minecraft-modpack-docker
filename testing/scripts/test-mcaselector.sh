#!/usr/bin/env bash
# Tests for mcaselector chunk cleanup service

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test framework
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/test-framework.sh"

test_suite "MCASelector Service - Script Structure"

# Test mcaselector scripts exist and are valid
test_mcaselector_scripts() {
    local delete_chunks_script="$PROJECT_ROOT/mcaselector/scripts/delete-chunks.sh"
    local entrypoint_script="$PROJECT_ROOT/mcaselector/scripts/entrypoint.sh"
    
    assert_file_exists "$delete_chunks_script" "delete-chunks.sh exists"
    assert_file_exists "$entrypoint_script" "entrypoint.sh exists"
    
    assert_true "[ -x '$delete_chunks_script' ]" "delete-chunks.sh is executable"
    assert_true "[ -x '$entrypoint_script' ]" "entrypoint.sh is executable"
    
    # Check delete-chunks script logic
    assert_true "grep -q 'LastUpdated' '$delete_chunks_script'" "Script handles LastUpdated filter"
    assert_true "grep -q 'InhabitedTime' '$delete_chunks_script'" "Script handles InhabitedTime filter"
    assert_true "grep -q 'MCASelector.jar' '$delete_chunks_script'" "Script calls MCASelector.jar"
    assert_true "grep -q 'mcaselector-options.yaml' '$delete_chunks_script'" "Script reads config from YAML"
    
    # Check entrypoint copies config
    assert_true "grep -q 'mcaselector-options.yaml' '$entrypoint_script'" "Entrypoint handles config file"
}

test_mcaselector_scripts

test_suite "MCASelector Service - Configuration"

# Test mcaselector configuration template
test_mcaselector_config() {
    local config_template="$PROJECT_ROOT/mcaselector/templates/mcaselector-options.yaml"
    
    assert_file_exists "$config_template" "mcaselector-options.yaml template exists"
    
    # Check config has delete_chunks section
    assert_true "grep -q 'delete_chunks:' '$config_template'" "Config has delete_chunks section"
    
    # Check for multiple deletion rules
    assert_true "grep -q 'last_updated:.*30 days' '$config_template'" "Config has 30 day rule"
    assert_true "grep -q 'last_updated:.*7 days' '$config_template'" "Config has 7 day rule"
    assert_true "grep -q 'last_updated:.*12 hours' '$config_template'" "Config has 12 hour rule"
    assert_true "grep -q 'inhabited_time:.*2 hours' '$config_template'" "Config has 2 hour inhabited time"
    assert_true "grep -q 'inhabited_time:.*1 hour' '$config_template'" "Config has 1 hour inhabited time"
}

test_mcaselector_config

test_suite "MCASelector Service - Dockerfile"

# Test mcaselector Dockerfile
test_mcaselector_dockerfile() {
    local dockerfile="$PROJECT_ROOT/mcaselector/Dockerfile"
    
    assert_file_exists "$dockerfile" "MCASelector Dockerfile exists"
    
    # Check uses Java runtime
    assert_true "grep -q 'FROM.*temurin.*jre' '$dockerfile'" "Uses Java JRE base image"
    
    # Check downloads MCASelector from GitHub
    assert_true "grep -q 'github.com/repos/Querz/mcaselector' '$dockerfile'" "Downloads from MCASelector repo"
    assert_true "grep -q 'releases/latest' '$dockerfile'" "Gets latest release"
    assert_true "grep -q 'mcaselector.jar' '$dockerfile'" "Downloads JAR file"
    
    # Check copies scripts and templates
    assert_true "grep -q 'COPY.*scripts' '$dockerfile'" "Copies scripts"
    assert_true "grep -q 'COPY.*templates' '$dockerfile'" "Copies templates"
}

test_mcaselector_dockerfile

test_suite "MCASelector Service - Docker Compose Configuration"

# Test mcaselector service in docker-compose
test_mcaselector_compose() {
    local compose_file="$PROJECT_ROOT/docker-compose.yml"
    
    # Check mcaselector service is defined
    assert_true "grep -q 'mcaselector:' '$compose_file'" "mcaselector service is defined"
    
    # Check volume mounts
    assert_true "grep -A 10 'mcaselector:' '$compose_file' | grep -q './data/world:/world'" "Mounts world directory"
    assert_true "grep -A 10 'mcaselector:' '$compose_file' | grep -q './data/config:/config'" "Mounts config directory"
}

test_mcaselector_compose

test_suite "MCASelector Service - Documentation"

# Test that MCASelector documentation exists
test_mcaselector_docs() {
    local docs_dir="$PROJECT_ROOT/mcaselector/docs"
    
    assert_dir_exists "$docs_dir" "MCASelector docs directory exists"
    
    # Check for key documentation files
    if [ -d "$docs_dir" ]; then
        local cli_doc="$docs_dir/CLI-Mode.md"
        local filter_doc="$docs_dir/Chunk-Filter.md"
        
        if [ -f "$cli_doc" ]; then
            assert_file_exists "$cli_doc" "CLI-Mode.md documentation exists"
        fi
        
        if [ -f "$filter_doc" ]; then
            assert_file_exists "$filter_doc" "Chunk-Filter.md documentation exists"
        fi
    fi
}

test_mcaselector_docs

print_summary
