#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

log_info "============ Configuring properties ============"

# Process default.properties if it exists
if [ -f "${DEFAULT_PROPS}" ]; then
    log_info "default.properties found at ${DEFAULT_PROPS}"

    # Process each property from default.properties
    while IFS='=' read -r key value || [ -n "$key" ]; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Trim whitespace
        key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Update the property if it exists in server.properties
        if grep -q "^${key}=" "${SERVER_PROPS}"; then
            sed -i "s|^${key}=.*|${key}=${value}|" "${SERVER_PROPS}"
            log_info "Updated ${key}=${value}"
        fi
    done < "${DEFAULT_PROPS}"
fi

# Copy the configured server.properties to linked location
log_info "Copying configured server.properties to ${LINKED_PROPS}..."
cp "${SERVER_PROPS}" "${LINKED_PROPS}"

log_info "Copying JSON config files to config directory if not present..."
shopt -s nullglob
for file in "${MINECRAFT_DIR}"/*.json; do
    if [ ! -f "${CONFIG_DIR}/$(basename "$file")" ]; then
        log_info "Copying $(basename "$file") to config directory..."
        cp "$file" "${CONFIG_DIR}/$(basename "$file")"
    fi
done
shopt -u nullglob
