#!/bin/bash
set -e

# Wrapper entrypoint for hybrid itzg image
# Resolves CurseForge page URLs to direct server file URLs, then calls itzg entrypoint

# If MODPACK_URL is a CurseForge page URL, resolve it to direct URL
if [ -n "${MODPACK_URL}" ]; then
    if echo "${MODPACK_URL}" | grep -qE '^https?://(www\.)?curseforge\.com/minecraft/modpacks/[a-zA-Z0-9_-]+/?$'; then
        echo "[INFO] Detected CurseForge modpack page URL, resolving to server files..."
        
        # Simple resolution - scrape the files page for server files
        MODPACK_SLUG=$(echo "${MODPACK_URL}" | sed -n 's|.*/modpacks/\([^/?]*\).*|\1|p')
        FILES_URL="https://www.curseforge.com/minecraft/modpacks/${MODPACK_SLUG}/files/all?page=1&pageSize=20"
        
        # Download and search for server files
        TEMP_HTML=$(mktemp)
        curl -L -A "Mozilla/5.0" -s "${FILES_URL}" > "${TEMP_HTML}"
        
        # Look for server filename
        SERVER_FILENAME=$(grep -io 'server[^"<>]*\.zip' "${TEMP_HTML}" | head -1 || true)
        
        if [ -n "${SERVER_FILENAME}" ]; then
            SERVER_FILE_ID=$(grep -i "${SERVER_FILENAME}" "${TEMP_HTML}" | sed -n 's|.*/files/\([0-9]\+\).*|\1|p' | head -1)
            
            if [ -n "${SERVER_FILE_ID}" ]; then
                # Construct direct URL
                PART1=$(echo "${SERVER_FILE_ID}" | sed 's/\(.*\)\(...\)/\1/')
                PART2=$(echo "${SERVER_FILE_ID}" | sed 's/.*\(...\)/\1/')
                RESOLVED_URL="https://mediafilez.forgecdn.net/files/${PART1}/${PART2}/${SERVER_FILENAME}"
                
                echo "[INFO] Resolved to: ${RESOLVED_URL}"
                export GENERIC_PACK="${RESOLVED_URL}"
            fi
        fi
        
        rm -f "${TEMP_HTML}"
    else
        # Direct URL, just pass it through
        export GENERIC_PACK="${MODPACK_URL}"
    fi
fi

# Call itzg's original entrypoint
exec /start
