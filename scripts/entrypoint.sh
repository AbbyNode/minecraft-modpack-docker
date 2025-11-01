#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

# Download modpack if needed
if [ ! -f "${STARTSCRIPT_PATH}" ]; then
    log_info "Start script not found at ${STARTSCRIPT_PATH}"
    bash "${SCRIPTS_DIR}/download.sh"
fi

# Run initial setup
if [ ! -f "${SETUP_COMPLETE_FLAG}" ]; then
    bash "${SCRIPTS_DIR}/first-time-setup.sh"
else
    log_info "First time setup already completed, skipping..."
fi

# Start the Minecraft server
log_info "Starting Minecraft server with ${STARTSCRIPT_PATH}..."
bash "${SCRIPTS_DIR}/pre-start.sh"
exec /bin/bash "${STARTSCRIPT_PATH}"
