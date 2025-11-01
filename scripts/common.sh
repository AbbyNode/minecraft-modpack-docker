#!/bin/bash

# Common functions and constants
set -euo pipefail

# Paths
: "${SCRIPTS_DIR:=/scripts}"
: "${MINECRAFT_DIR:=/minecraft}"
: "${CONFIG_DIR:=${MINECRAFT_DIR}/config}"

# TODO: move
: "${STARTSCRIPT:=startserver.sh}"
: "${STARTSCRIPT_PATH:=${MINECRAFT_DIR}/${STARTSCRIPT}}"

# If this file exists, first time setup is considered complete
SETUP_FLAG="${CONFIG_DIR}/server.properties"

# Logging functions
log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2
}

log_warn() {
    echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2
}
