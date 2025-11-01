#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/common.sh"


# Skip if already completed
if [ -f "${SETUP_FLAG}" ]; then
    log_info "Setup already completed, skipping..."
    exit 0
fi

# Wait for server files to be generated
log_info "Waiting for server files to be generated..."
while [ ! -f "${MINECRAFT_DIR}/server.properties" ]; do
    sleep 5
done

log_info "=== Starting Server Setup ==="

# Accept EULA
log_info "Accepting Minecraft EULA..."
echo "eula=true" > "${MINECRAFT_DIR}/eula.txt"

# Create necessary directories
log_info "Creating directories..."
mkdir -p "${MINECRAFT_DIR}"/{logs,backups,plugins,mods} 2>/dev/null || true

# Create default JSON files if they don't exist
for file in ops.json whitelist.json banned-players.json banned-ips.json; do
    if [ ! -f "${MINECRAFT_DIR}/${file}" ]; then
        log_info "Creating ${file}..."
        echo "[]" > "${MINECRAFT_DIR}/${file}"
    fi
done

# Configure server.properties if it exists
if [ -f "${MINECRAFT_DIR}/server.properties" ]; then
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
fi

# Set proper permissions
log_info "Setting permissions..."
chmod -R 755 "${MINECRAFT_DIR}" 2>/dev/null || true
chmod 644 "${MINECRAFT_DIR}"/*.json 2>/dev/null || true

# Mark setup as complete
touch "${SETUP_FLAG}"
log_info "=== Setup Complete ==="
