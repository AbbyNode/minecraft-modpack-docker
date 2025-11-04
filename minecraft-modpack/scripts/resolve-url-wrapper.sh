#!/bin/bash
set -e

# Wrapper entrypoint for hybrid itzg image
# Resolves CurseForge page URLs to direct server file URLs, then calls itzg entrypoint

# Source logging library
# shellcheck disable=SC1091
source /usr/local/lib/minecraft/log.sh

resolve_if_needed() {
    if [ -z "${MODPACK_URL:-}" ]; then
        return
    fi
    if echo "${MODPACK_URL}" | grep -qE '^https?://(www\.)?curseforge\.com/minecraft/modpacks/[a-zA-Z0-9_-]+/?$'; then
        log_warn "CurseForge page URL detected but resolution not yet implemented"
        log_warn "Please use a direct server files URL instead"
        exit 1
    else
        log_info "Using direct URL: ${MODPACK_URL}"
        export GENERIC_PACK="${MODPACK_URL}"
    fi
}

resolve_if_needed

log_info "Starting itzg/minecraft-server..."
exec /start
