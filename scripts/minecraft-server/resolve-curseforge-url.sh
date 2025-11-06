#!/usr/bin/env bash
set -euo pipefail

# CurseForge modpack entrypoint: resolves CurseForge page URLs to direct server file URLs,
# then starts the Minecraft server via itzg entrypoint.
#
# Usage as entrypoint (with MODPACK_URL environment variable):
#   MODPACK_URL=https://www.curseforge.com/minecraft/modpacks/all-the-mods-10
#   Or: MODPACK_URL=https://mediafilez.forgecdn.net/files/.../ServerFiles.zip
#
# Usage as standalone resolver:
#   resolve-curseforge-url.sh <curseforge-modpack-url>
#   Example: https://www.curseforge.com/minecraft/modpacks/all-the-mods-10
#   Output: https://mediafilez.forgecdn.net/files/7121/795/ServerFiles-4.14.zip

# Load logging functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/log.sh" ]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/log.sh"
fi

# Entrypoint mode: handle MODPACK_URL environment variable
if [ $# -eq 0 ] && [ -n "${MODPACK_URL:-}" ]; then
    if echo "${MODPACK_URL}" | grep -qE '^https?://(www\.)?curseforge\.com/minecraft/modpacks/[a-zA-Z0-9_-]+/?$'; then
        log_info "Detected CurseForge modpack page URL, resolving to server files..."
        # Recursively call self in resolver mode
        RESOLVED_URL="$("${BASH_SOURCE[0]}" "${MODPACK_URL}")"
        log_info "Resolved to: ${RESOLVED_URL}"
        export GENERIC_PACK="${RESOLVED_URL}"
    else
        log_info "Using direct URL: ${MODPACK_URL}"
        export GENERIC_PACK="${MODPACK_URL}"
    fi
    log_info "Starting itzg/minecraft-server..."
    exec /start
fi

# Resolver mode: resolve URL from command line argument
if [ $# -ne 1 ]; then
    log_error "Usage: $0 <curseforge-modpack-url>" 2>/dev/null || echo "Usage: $0 <curseforge-modpack-url>" >&2
    exit 1
fi

MODPACK_URL="$1"

# Configuration
PAGE_SIZE=20
CURL_TIMEOUT=30
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# Extract modpack slug from URL
MODPACK_SLUG=$(echo "$MODPACK_URL" | sed -n 's|.*/modpacks/\([^/?]*\).*|\1|p')

if [ -z "$MODPACK_SLUG" ]; then
    log_error "Failed to extract modpack slug from URL: $MODPACK_URL" 2>/dev/null || echo "Failed to extract modpack slug from URL: $MODPACK_URL" >&2
    echo "Expected format: https://www.curseforge.com/minecraft/modpacks/<modpack-name>" >&2
    exit 1
fi

log_info "Modpack slug: $MODPACK_SLUG" 2>/dev/null || true

# Construct files list URL
FILES_URL="https://www.curseforge.com/minecraft/modpacks/${MODPACK_SLUG}/files/all?page=1&pageSize=${PAGE_SIZE}"
log_info "Fetching files list from: $FILES_URL" 2>/dev/null || true

# Download the files page with proper headers to avoid being blocked
TEMP_HTML=$(mktemp)
if ! curl -L -A "$USER_AGENT" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
    -H "Accept-Language: en-US,en;q=0.5" \
    --max-time "$CURL_TIMEOUT" \
    -s "$FILES_URL" > "$TEMP_HTML"; then
    log_error "Failed to fetch files list from CurseForge" 2>/dev/null || echo "Failed to fetch files list from CurseForge" >&2
    rm -f "$TEMP_HTML"
    exit 1
fi

# Check if we got actual content
if [ ! -s "$TEMP_HTML" ]; then
    log_error "Received empty response from CurseForge" 2>/dev/null || echo "Received empty response from CurseForge" >&2
    echo "This may be due to rate limiting or blocking" >&2
    rm -f "$TEMP_HTML"
    exit 1
fi

log_info "Files page downloaded, searching for server files..." 2>/dev/null || true

# Try to find server files on the main page
SERVER_FILENAME=$(grep -io 'server[^"<>]*\.zip' "$TEMP_HTML" | head -1 || true)

if [ -n "$SERVER_FILENAME" ]; then
    SERVER_FILE_ID=$(grep -i "$SERVER_FILENAME" "$TEMP_HTML" | sed -n 's|.*/files/\([0-9]\+\).*|\1|p' | head -1)
    if [ -n "$SERVER_FILE_ID" ]; then
        log_info "Found server file in main list: $SERVER_FILENAME (ID: $SERVER_FILE_ID)" 2>/dev/null || true
        rm -f "$TEMP_HTML"
    else
        SERVER_FILENAME=""
    fi
fi

# If not found, check additional files for recent entries
if [ -z "$SERVER_FILENAME" ]; then
    log_info "No server files in main list, checking additional files..." 2>/dev/null || true

    FILE_IDS=$(grep -oE '/files/[0-9]+' "$TEMP_HTML" | sed 's|/files/||' | sort -rn | uniq | head -${PAGE_SIZE} || true)
    rm -f "$TEMP_HTML"

    if [ -z "$FILE_IDS" ]; then
        log_error "No file IDs found on the files page" 2>/dev/null || echo "No file IDs found on the files page" >&2
        exit 1
    fi

    for FILE_ID in $FILE_IDS; do
        log_info "Checking additional files for file ID: $FILE_ID" 2>/dev/null || true

        ADDITIONAL_URL="https://www.curseforge.com/minecraft/modpacks/${MODPACK_SLUG}/files/${FILE_ID}/additional-files"
        TEMP_ADDITIONAL=$(mktemp)

        if curl -L -A "$USER_AGENT" \
            -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
            --max-time "$CURL_TIMEOUT" \
            -s "$ADDITIONAL_URL" > "$TEMP_ADDITIONAL" 2>/dev/null; then
            :
        else
            log_warn "Failed to fetch additional files for file ID $FILE_ID" 2>/dev/null || true
            rm -f "$TEMP_ADDITIONAL"
            continue
        fi

        if [ ! -s "$TEMP_ADDITIONAL" ]; then
            rm -f "$TEMP_ADDITIONAL"
            continue
        fi

        SERVER_FILENAME=$(grep -io 'server[^"<>]*\.zip' "$TEMP_ADDITIONAL" | head -1 || true)
        if [ -n "$SERVER_FILENAME" ]; then
            SERVER_FILE_ID=$(grep -i "$SERVER_FILENAME" "$TEMP_ADDITIONAL" | sed -n 's|.*/files/\([0-9]\+\).*|\1|p' | head -1)
            rm -f "$TEMP_ADDITIONAL"
            if [ -n "$SERVER_FILE_ID" ]; then
                log_info "Found server file in additional files: $SERVER_FILENAME (ID: $SERVER_FILE_ID)" 2>/dev/null || true
                break
            else
                SERVER_FILENAME=""
            fi
        fi

        rm -f "$TEMP_ADDITIONAL"
    done

    if [ -z "$SERVER_FILENAME" ] || [ -z "$SERVER_FILE_ID" ]; then
        log_error "No server files found in main list or additional files" 2>/dev/null || echo "No server files found in main list or additional files" >&2
        echo "You can manually check: https://www.curseforge.com/minecraft/modpacks/${MODPACK_SLUG}/files" >&2
        exit 1
    fi
fi

# Validate and construct download URL
if [ ${#SERVER_FILE_ID} -lt 3 ]; then
    log_error "File ID '$SERVER_FILE_ID' is too short (< 3 digits) to construct a valid download URL" 2>/dev/null || echo "File ID '$SERVER_FILE_ID' is too short (< 3 digits) to construct a valid download URL" >&2
    exit 1
fi

PART1=$(echo "$SERVER_FILE_ID" | sed 's/\(.*\)\(...\)/\1/')
PART2=$(echo "$SERVER_FILE_ID" | sed 's/.*\(...\)/\1/')
DOWNLOAD_URL="https://mediafilez.forgecdn.net/files/${PART1}/${PART2}/${SERVER_FILENAME}"

log_info "Resolved download URL: $DOWNLOAD_URL" 2>/dev/null || true


echo "$DOWNLOAD_URL"
