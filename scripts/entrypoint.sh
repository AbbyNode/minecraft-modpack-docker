#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

# Run initial setup
bash "${SCRIPTS_DIR}/setup.sh"

# Download modpack if needed
bash "${SCRIPTS_DIR}/download.sh"

# Start the Minecraft server
log_info "Starting Minecraft server with ${STARTSCRIPT_PATH}..."
exec /bin/bash "${STARTSCRIPT_PATH}"
