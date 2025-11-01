#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

if [ ! -f "${LINKED_PROPS}" ]; then
    log_info "First time setup not detected, running first time setup..."
    exec "${SCRIPTS_DIR}/first-time-run.sh"
else
    log_info "First time setup already completed, skipping..."
    log_info "Starting Minecraft server with ${STARTSCRIPT_PATH}..."
    exec "${SCRIPTS_DIR}/regular-run.sh"
fi
