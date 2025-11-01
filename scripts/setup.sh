#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

# If this file exists, first time setup is considered complete
SETUP_COMPLETE_FLAG="${CONFIG_DIR}/server.properties"

# If this file exists, server is ready for post-setup
READY_FOR_SETUP_FLAG="${MINECRAFT_DIR}/server.properties"

# Skip if already completed
if [ -f "${SETUP_COMPLETE_FLAG}" ]; then
    log_info "Setup already completed, skipping..."
    exit 0
fi

log_info "=== Starting first time server setup ==="

log_info "Creating Minecraft directory at ${MINECRAFT_DIR}..."
mkdir -p "${MINECRAFT_DIR}"

log_info "Accepting Minecraft EULA..."
echo "eula=true" > "${MINECRAFT_DIR}/eula.txt"

# Link existing files 

# Set proper permissions
log_info "Setting permissions..."
chmod -R 755 "${MINECRAFT_DIR}" 2>/dev/null || true
chmod 644 "${MINECRAFT_DIR}"/*.json 2>/dev/null || true

post_start_setup() {
    if [ ! -f "${MINECRAFT_DIR}/server.properties" ]; then
        log_error "server.properties not found at ${MINECRAFT_DIR}/server.properties"
        exit 1
    fi

    log_info "Configuring server.properties..."
    sed -i \
        -e 's/^allow-flight=.*/allow-flight=true/' \
        -e 's/^difficulty=.*/difficulty=normal/' \
        -e 's/^enforce-whitelist=.*/enforce-whitelist=true/' \
        -e 's/^force-gamemode=.*/force-gamemode=false/' \
        -e 's/^gamemode=.*/gamemode=survival/' \
        -e 's/^pvp=.*/pvp=false/' \
        -e 's/^simulation-distance=.*/simulation-distance=32/' \
        -e 's/^spawn-protection=.*/spawn-protection=0/' \
        -e 's/^view-distance=.*/view-distance=16/' \
        -e 's/^white-list=.*/white-list=true/' \
        "${MINECRAFT_DIR}/server.properties"

    # Mark setup as complete
    touch "${SETUP_COMPLETE_FLAG}"
    log_info "=== Setup Complete ==="
}

log_info "Waiting for server to initialize for post-start setup..."
(
    while [ ! -f "${READY_FOR_SETUP_FLAG}" ]; do
        sleep 5
    done
    post_start_setup
) &
