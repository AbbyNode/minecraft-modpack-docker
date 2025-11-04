#!/usr/bin/env bash
# Tests for minecraft-modpack service with URL resolution

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test framework
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/test-framework.sh"

test_suite "Minecraft Modpack Service - Script Structure"

# Test minecraft-modpack scripts exist and are valid
test_minecraft_scripts() {
    local resolve_wrapper="$PROJECT_ROOT/minecraft-modpack/scripts/resolve-url-wrapper.sh"
    
    assert_file_exists "$resolve_wrapper" "resolve-url-wrapper.sh exists"
    assert_true "[ -x '$resolve_wrapper' ]" "resolve-url-wrapper.sh is executable"
    
    # Check wrapper script references
    assert_true "grep -q 'MODPACK_URL' '$resolve_wrapper'" "Wrapper handles MODPACK_URL"
    assert_true "grep -q 'GENERIC_PACK' '$resolve_wrapper'" "Wrapper sets GENERIC_PACK for itzg"
    assert_true "grep -q '/start' '$resolve_wrapper'" "Wrapper calls itzg entrypoint"
    
    # Check for CurseForge URL detection
    assert_true "grep -q 'curseforge' '$resolve_wrapper'" "Wrapper detects CurseForge URLs"
}

test_minecraft_scripts

test_suite "Minecraft Modpack Service - Dockerfile"

# Test minecraft-modpack Dockerfile
test_minecraft_dockerfile() {
    local dockerfile="$PROJECT_ROOT/minecraft-modpack/Dockerfile"
    
    assert_file_exists "$dockerfile" "Minecraft-modpack Dockerfile exists"
    
    # Check uses itzg base image
    assert_true "grep -q 'FROM itzg/minecraft-server' '$dockerfile'" "Uses itzg/minecraft-server base"
    
    # Check copies lib directory
    assert_true "grep -q 'COPY.*lib' '$dockerfile'" "Copies lib directory"
    
    # Check copies wrapper script
    assert_true "grep -q 'COPY.*resolve-url-wrapper.sh' '$dockerfile'" "Copies URL wrapper script"
    assert_true "grep -q 'chmod.*resolve-url-wrapper.sh' '$dockerfile'" "Makes wrapper executable"
    
    # Check sets custom entrypoint
    assert_true "grep -q 'ENTRYPOINT.*resolve-url-wrapper.sh' '$dockerfile'" "Sets custom entrypoint"
    
    # Check has documentation comments
    assert_true "grep -q 'Hybrid image' '$dockerfile'" "Contains hybrid approach documentation"
}

test_minecraft_dockerfile

test_suite "Minecraft Modpack Service - Docker Compose Configuration"

# Test minecraft-modpack service in docker-compose
test_minecraft_compose() {
    local compose_file="$PROJECT_ROOT/docker-compose.yml"
    
    # Check minecraft-modpack service is defined
    assert_true "grep -q 'minecraft-modpack:' '$compose_file'" "minecraft-modpack service is defined"
    
    # Check environment variables
    assert_true "grep -A 20 'minecraft-modpack:' '$compose_file' | grep -q 'EULA.*TRUE'" "Sets EULA acceptance"
    assert_true "grep -A 20 'minecraft-modpack:' '$compose_file' | grep -q 'MEMORY'" "Configures memory"
    assert_true "grep -A 20 'minecraft-modpack:' '$compose_file' | grep -q 'USE_AIKAR_FLAGS'" "Uses Aikar flags"
    
    # Check volume mounts
    assert_true "grep -A 20 'minecraft-modpack:' '$compose_file' | grep -q './data:/data'" "Mounts data directory"
    
    # Check port mapping
    assert_true "grep -A 20 'minecraft-modpack:' '$compose_file' | grep -q '25565:25565'" "Exposes Minecraft port"
    
    # Check stdin/tty for interactive console
    assert_true "grep -A 20 'minecraft-modpack:' '$compose_file' | grep -q 'stdin_open: true'" "Enables stdin"
    assert_true "grep -A 20 'minecraft-modpack:' '$compose_file' | grep -q 'tty: true'" "Enables tty"
}

test_minecraft_compose

test_suite "Minecraft Modpack Service - Environment Configuration"

# Test .env.example has required configuration
test_minecraft_env_config() {
    local env_example="$PROJECT_ROOT/.env.example"
    
    assert_file_exists "$env_example" ".env.example exists"
    
    # Check for MODPACK_URL examples
    assert_true "grep -q 'MODPACK_URL.*mediafilez.forgecdn.net' '$env_example'" "Shows direct URL example"
    assert_true "grep -q 'MODPACK_URL.*curseforge.com/minecraft/modpacks' '$env_example'" "Shows CurseForge page URL example"
    
    # Check for server properties
    assert_true "grep -q 'MOTD' '$env_example'" "Has MOTD setting"
    assert_true "grep -q 'DIFFICULTY' '$env_example'" "Has difficulty setting"
    assert_true "grep -q 'MAX_PLAYERS' '$env_example'" "Has max players setting"
    assert_true "grep -q 'WHITE_LIST' '$env_example'" "Has whitelist setting"
}

test_minecraft_env_config

print_summary
