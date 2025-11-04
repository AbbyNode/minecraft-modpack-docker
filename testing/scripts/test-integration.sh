#!/usr/bin/env bash
# Integration tests for the full docker-compose stack

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test framework
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/test-framework.sh"

test_suite "Integration - Docker Compose Structure"

# Test main docker-compose file structure
test_compose_structure() {
    local compose_file="$PROJECT_ROOT/docker-compose.yml"
    
    assert_file_exists "$compose_file" "docker-compose.yml exists"
    
    # Check all services are defined
    assert_true "grep -q 'setup:' '$compose_file'" "setup service defined"
    assert_true "grep -q 'minecraft-modpack:' '$compose_file'" "minecraft-modpack service defined"
    assert_true "grep -q 'mcaselector:' '$compose_file'" "mcaselector service defined"
    assert_true "grep -q 'borgmatic:' '$compose_file'" "borgmatic service defined"
    assert_true "grep -q 'unmined:' '$compose_file'" "unmined service defined"
    assert_true "grep -q 'nginx:' '$compose_file'" "nginx service defined"
    assert_true "grep -q 'cloudflared:' '$compose_file'" "cloudflared service defined"
    assert_true "grep -q 'ofelia:' '$compose_file'" "ofelia service defined"
    
    # Check volumes are defined
    assert_true "grep -q '^volumes:' '$compose_file'" "Volumes section exists"
    assert_true "grep -q 'borgmatic-data:' '$compose_file'" "borgmatic-data volume defined"
    assert_true "grep -q 'shared-scripts:' '$compose_file'" "shared-scripts volume defined"
}

test_compose_structure

test_suite "Integration - Build Compose Structure"

# Test build compose file
test_build_compose() {
    local build_compose="$PROJECT_ROOT/build.compose.yml"
    
    assert_file_exists "$build_compose" "build.compose.yml exists"
    
    # Check services have build contexts
    assert_true "grep -q 'setup:' '$build_compose'" "setup build defined"
    assert_true "grep -q 'minecraft-modpack:' '$build_compose'" "minecraft-modpack build defined"
    assert_true "grep -q 'mcaselector:' '$build_compose'" "mcaselector build defined"
    assert_true "grep -q 'borgmatic:' '$build_compose'" "borgmatic build defined"
    assert_true "grep -q 'unmined:' '$build_compose'" "unmined build defined"
    
    # Check images are tagged
    assert_true "grep -q 'eclarift/minecraft-setup' '$build_compose'" "setup image tagged"
    assert_true "grep -q 'eclarift/minecraft-modpack' '$build_compose'" "minecraft-modpack image tagged"
    assert_true "grep -q 'eclarift/mcaselector' '$build_compose'" "mcaselector image tagged"
    assert_true "grep -q 'eclarift/borgmatic' '$build_compose'" "borgmatic image tagged"
    assert_true "grep -q 'eclarift/unmined' '$build_compose'" "unmined image tagged"
}

test_build_compose

test_suite "Integration - Shared Scripts Volume"

# Test shared scripts volume integration
test_shared_scripts_volume() {
    local compose_file="$PROJECT_ROOT/docker-compose.yml"
    
    # Check setup service populates shared-scripts
    assert_true "grep -A 10 'setup:' '$compose_file' | grep -q 'shared-scripts:/opt/shared'" "Setup service mounts shared-scripts"
    
    # Check minecraft-modpack service uses shared-scripts
    assert_true "grep -A 20 'minecraft-modpack:' '$compose_file' | grep -q 'shared-scripts:/opt/shared:ro'" "Minecraft service reads shared-scripts"
}

test_shared_scripts_volume

test_suite "Integration - Data Directory Structure"

# Test expected data directory structure
test_data_directory_structure() {
    # These directories should be created by the setup service
    local expected_dirs=(
        "world"
        "logs"
        "config"
        "mods/jars"
        "mods/config"
        "backups/borg-repository"
        "config/borgmatic"
        "config/ofelia"
    )
    
    # We test that the init script references these
    local init_script="$PROJECT_ROOT/setup/scripts/init.sh"
    
    for dir in "${expected_dirs[@]}"; do
        # Convert slashes to escape for grep
        local escaped_dir="${dir//\//\\/}"
        assert_true "grep -q '$escaped_dir' '$init_script'" "Init script creates directory: $dir"
    done
}

test_data_directory_structure

test_suite "Integration - Service Dependencies"

# Test service dependencies are properly configured
test_service_dependencies() {
    local compose_file="$PROJECT_ROOT/docker-compose.yml"
    
    # Ofelia should depend on services it schedules
    assert_true "grep -A 20 'ofelia:' '$compose_file' | grep -q 'borgmatic'" "Ofelia depends on borgmatic"
    assert_true "grep -A 20 'ofelia:' '$compose_file' | grep -q 'mcaselector'" "Ofelia depends on mcaselector"
    assert_true "grep -A 20 'ofelia:' '$compose_file' | grep -q 'unmined'" "Ofelia depends on unmined"
    
    # Cloudflared should depend on nginx
    assert_true "grep -A 10 'cloudflared:' '$compose_file' | grep -q 'nginx'" "Cloudflared depends on nginx"
}

test_service_dependencies

test_suite "Integration - Environment File"

# Test environment file configuration
test_env_file_integration() {
    local compose_file="$PROJECT_ROOT/docker-compose.yml"
    
    # Check services that need env_file
    assert_true "grep -B 5 'env_file:' '$compose_file' | grep -q 'minecraft-modpack:'" "minecraft-modpack uses env_file"
    assert_true "grep -B 5 'env_file:' '$compose_file' | grep -q 'mcaselector:'" "mcaselector uses env_file"
    assert_true "grep -B 5 'env_file:' '$compose_file' | grep -q 'borgmatic:'" "borgmatic uses env_file"
    assert_true "grep -B 5 'env_file:' '$compose_file' | grep -q 'unmined:'" "unmined uses env_file"
}

test_env_file_integration

test_suite "Integration - Documentation Completeness"

# Test documentation exists and covers all components
test_documentation() {
    local readme="$PROJECT_ROOT/README.md"
    local architecture_doc="$PROJECT_ROOT/docs/Architecture.md"
    
    assert_file_exists "$readme" "README.md exists"
    assert_file_exists "$architecture_doc" "Architecture.md exists"
    
    # Check README covers key topics
    assert_true "grep -q 'Quick Start' '$readme'" "README has Quick Start section"
    assert_true "grep -q 'Configuration' '$readme'" "README has Configuration section"
    assert_true "grep -q 'Backups' '$readme'" "README covers backups"
    assert_true "grep -q 'Chunk Cleanup' '$readme'" "README covers chunk cleanup"
    
    # Check Architecture doc describes components
    assert_true "grep -q 'Borgmatic' '$architecture_doc'" "Architecture doc describes Borgmatic"
    assert_true "grep -q 'MCASelector' '$architecture_doc'" "Architecture doc describes MCASelector"
    assert_true "grep -q 'Ofelia' '$architecture_doc'" "Architecture doc describes Ofelia"
}

test_documentation

test_suite "Integration - All Dockerfiles Present"

# Test all custom images have Dockerfiles
test_all_dockerfiles() {
    assert_file_exists "$PROJECT_ROOT/setup/Dockerfile" "setup/Dockerfile exists"
    assert_file_exists "$PROJECT_ROOT/minecraft-modpack/Dockerfile" "minecraft-modpack/Dockerfile exists"
    assert_file_exists "$PROJECT_ROOT/mcaselector/Dockerfile" "mcaselector/Dockerfile exists"
    assert_file_exists "$PROJECT_ROOT/borgmatic/Dockerfile" "borgmatic/Dockerfile exists"
    assert_file_exists "$PROJECT_ROOT/unmined/Dockerfile" "unmined/Dockerfile exists"
}

test_all_dockerfiles

print_summary
