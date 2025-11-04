#!/usr/bin/env bash
# Test utilities for docker-based testing

# Start a service and wait for it to be healthy
docker_start_service() {
    local service_name="$1"
    local timeout="${2:-30}"
    
    echo "Starting service: ${service_name}"
    docker compose up -d "$service_name" 2>&1 | grep -v "Warning"
    
    # Wait for container to be running
    local elapsed=0
    while [ $elapsed -lt $timeout ]; do
        if docker compose ps "$service_name" 2>/dev/null | grep -q "Up"; then
            echo "Service ${service_name} is running"
            return 0
        fi
        sleep 1
        elapsed=$((elapsed + 1))
    done
    
    echo "Service ${service_name} failed to start within ${timeout}s"
    return 1
}

# Execute command in a running container
docker_exec() {
    local container_name="$1"
    shift
    docker exec "$container_name" "$@"
}

# Check if a container is running
docker_is_running() {
    local container_name="$1"
    docker ps --filter "name=${container_name}" --filter "status=running" --format "{{.Names}}" | grep -q "^${container_name}$"
}

# Get container logs
docker_get_logs() {
    local container_name="$1"
    local lines="${2:-50}"
    docker logs --tail "$lines" "$container_name" 2>&1
}

# Clean up test containers and volumes
docker_cleanup() {
    echo "Cleaning up test containers and volumes..."
    docker compose down -v 2>&1 | grep -v "Warning" || true
}

# Create a temporary test workspace
create_test_workspace() {
    local workspace_dir="/tmp/test-workspace-$$"
    mkdir -p "$workspace_dir"
    echo "$workspace_dir"
}

# Clean up test workspace
cleanup_test_workspace() {
    local workspace_dir="$1"
    if [ -n "$workspace_dir" ] && [ -d "$workspace_dir" ]; then
        rm -rf "$workspace_dir"
    fi
}
