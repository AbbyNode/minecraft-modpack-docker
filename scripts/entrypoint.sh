#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

# Run initial setup
bash "${SCRIPTS_DIR}/setup.sh"

# Download modpack if needed
bash "${SCRIPTS_DIR}/download.sh"

# Ensure start script is executable
chmod +x "${STARTSCRIPT_PATH}"

# Schedule post-server-init setup in background
if [ ! -f "${MINECRAFT_DIR}/.setup_complete" ]; then
    bash "${SCRIPTS_DIR}/setup.sh" --wait-for-server &
fi

# Start the Minecraft server
log_info "Starting Minecraft server with ${STARTSCRIPT_PATH}..."
exec /bin/bash "${STARTSCRIPT_PATH}"
