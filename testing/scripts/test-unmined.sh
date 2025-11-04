#!/usr/bin/env bash
# Tests for unmined map generation service

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test framework
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/test-framework.sh"

test_suite "Unmined Service - Script Structure"

# Test unmined scripts exist and are valid
test_unmined_scripts() {
    local generate_map_script="$PROJECT_ROOT/unmined/scripts/generate-map.sh"
    local entrypoint_script="$PROJECT_ROOT/unmined/scripts/entrypoint.sh"
    
    assert_file_exists "$generate_map_script" "generate-map.sh exists"
    assert_file_exists "$entrypoint_script" "entrypoint.sh exists"
    
    assert_true "[ -x '$generate_map_script' ]" "generate-map.sh is executable"
    assert_true "[ -x '$entrypoint_script' ]" "entrypoint.sh is executable"
    
    # Check generate-map script calls unmined-cli
    assert_true "grep -q 'unmined-cli' '$generate_map_script'" "Script calls unmined-cli"
    assert_true "grep -q 'web render' '$generate_map_script'" "Script uses web render command"
    assert_true "grep -q '/world' '$generate_map_script'" "Script references world directory"
    assert_true "grep -q '/output' '$generate_map_script'" "Script references output directory"
    
    # Check for world directory validation
    assert_true "grep -q 'World directory not found' '$generate_map_script'" "Script validates world directory exists"
}

test_unmined_scripts

test_suite "Unmined Service - Dockerfile"

# Test unmined Dockerfile
test_unmined_dockerfile() {
    local dockerfile="$PROJECT_ROOT/unmined/Dockerfile"
    
    assert_file_exists "$dockerfile" "Unmined Dockerfile exists"
    
    # Check uses .NET runtime
    assert_true "grep -q 'FROM.*dotnet/runtime' '$dockerfile'" "Uses .NET runtime base image"
    assert_true "grep -q 'alpine' '$dockerfile'" "Uses Alpine variant"
    
    # Check downloads unmined-cli
    assert_true "grep -q 'unmined.net' '$dockerfile'" "Downloads from unmined.net"
    assert_true "grep -q 'unmined-cli' '$dockerfile'" "Downloads unmined-cli"
    assert_true "grep -q 'linux-musl-x64' '$dockerfile'" "Uses Alpine-compatible binary"
    
    # Check copies scripts
    assert_true "grep -q 'COPY.*scripts' '$dockerfile'" "Copies scripts"
    assert_true "grep -q 'ENTRYPOINT.*entrypoint.sh' '$dockerfile'" "Sets entrypoint"
}

test_unmined_dockerfile

test_suite "Unmined Service - Docker Compose Configuration"

# Test unmined service in docker-compose
test_unmined_compose() {
    local compose_file="$PROJECT_ROOT/docker-compose.yml"
    
    # Check unmined service is defined
    assert_true "grep -q 'unmined:' '$compose_file'" "unmined service is defined"
    
    # Check volume mounts
    assert_true "grep -A 10 'unmined:' '$compose_file' | grep -q './data/world:/world'" "Mounts world directory read-only"
    assert_true "grep -A 10 'unmined:' '$compose_file' | grep -q './data/unmined-map:/output'" "Mounts output directory"
}

test_unmined_compose

test_suite "Unmined Service - Web Hosting Integration"

# Test nginx and cloudflared integration for map hosting
test_map_hosting() {
    local compose_file="$PROJECT_ROOT/docker-compose.yml"
    
    # Check nginx service for serving the map
    assert_true "grep -q 'nginx:' '$compose_file'" "nginx service is defined"
    assert_true "grep -A 10 'nginx:' '$compose_file' | grep -q 'nginx:alpine'" "Uses nginx:alpine image"
    assert_true "grep -A 10 'nginx:' '$compose_file' | grep -q './data/unmined-map:/usr/share/nginx/html'" "Serves unmined map"
    
    # Check cloudflared service for tunneling
    assert_true "grep -q 'cloudflared:' '$compose_file'" "cloudflared service is defined"
    assert_true "grep -A 10 'cloudflared:' '$compose_file' | grep -q 'tunnel run'" "Runs cloudflare tunnel"
    assert_true "grep -A 10 'cloudflared:' '$compose_file' | grep -q 'nginx'" "Depends on nginx service"
}

test_map_hosting

print_summary
