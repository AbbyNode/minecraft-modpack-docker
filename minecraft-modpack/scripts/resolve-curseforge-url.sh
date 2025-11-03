#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

# This script resolves a CurseForge modpack URL to a server files download URL
# Usage: resolve-curseforge-url.sh <modpack-url>
#
# Example input: https://www.curseforge.com/minecraft/modpacks/all-the-mods-10
# Example output: https://mediafilez.forgecdn.net/files/7121/795/ServerFiles-4.14.zip

if [ $# -ne 1 ]; then
    log_error "Usage: $0 <curseforge-modpack-url>"
    exit 1
fi

MODPACK_URL="$1"

# Configuration
PAGE_SIZE=20
CURL_TIMEOUT=30
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# Extract modpack slug from URL
# Example: https://www.curseforge.com/minecraft/modpacks/all-the-mods-10 -> all-the-mods-10
MODPACK_SLUG=$(echo "$MODPACK_URL" | sed -n 's|.*/modpacks/\([^/?]*\).*|\1|p')

if [ -z "$MODPACK_SLUG" ]; then
    log_error "Failed to extract modpack slug from URL: $MODPACK_URL"
    log_error "Expected format: https://www.curseforge.com/minecraft/modpacks/<modpack-name>"
    exit 1
fi

log_info "Modpack slug: $MODPACK_SLUG"

# Construct files list URL
FILES_URL="https://www.curseforge.com/minecraft/modpacks/${MODPACK_SLUG}/files/all?page=1&pageSize=${PAGE_SIZE}"
log_info "Fetching files list from: $FILES_URL"

# Download the files page with proper headers to avoid being blocked
TEMP_HTML=$(mktemp)
if ! curl -L -A "$USER_AGENT" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
    -H "Accept-Language: en-US,en;q=0.5" \
    --max-time "$CURL_TIMEOUT" \
    -s "$FILES_URL" > "$TEMP_HTML"; then
    log_error "Failed to fetch files list from CurseForge"
    rm -f "$TEMP_HTML"
    exit 1
fi

# Check if we got actual content
if [ ! -s "$TEMP_HTML" ]; then
    log_error "Received empty response from CurseForge"
    log_error "This may be due to rate limiting or blocking"
    rm -f "$TEMP_HTML"
    exit 1
fi

log_info "Files page downloaded, searching for server files..."

# First, try to find files with "server" in the filename directly on the main page
# Extract filenames that contain "server"
SERVER_FILENAME=$(grep -io 'server[^"<>]*\.zip' "$TEMP_HTML" | head -1 || true)

if [ -n "$SERVER_FILENAME" ]; then
    # Found a server filename, now find its file ID
    SERVER_FILE_ID=$(grep -i "$SERVER_FILENAME" "$TEMP_HTML" | sed -n 's|.*/files/\([0-9]\+\).*|\1|p' | head -1)
    
    if [ -n "$SERVER_FILE_ID" ]; then
        log_info "Found server file in main list: $SERVER_FILENAME (ID: $SERVER_FILE_ID)"
        rm -f "$TEMP_HTML"
    else
        SERVER_FILENAME=""
    fi
fi

# If no server file found in main list, check additional files for each file on the page
if [ -z "$SERVER_FILENAME" ]; then
    log_info "No server files in main list, checking additional files..."
    
    # Extract all file IDs from the page
    FILE_IDS=$(grep -oE '/files/[0-9]+' "$TEMP_HTML" | sed 's|/files/||' | sort -rn | uniq | head -${PAGE_SIZE} || true)
    
    rm -f "$TEMP_HTML"
    
    if [ -z "$FILE_IDS" ]; then
        log_error "No file IDs found on the files page"
        exit 1
    fi
    
    # Check each file's additional files page for server files
    for FILE_ID in $FILE_IDS; do
        log_info "Checking additional files for file ID: $FILE_ID"
        
        ADDITIONAL_URL="https://www.curseforge.com/minecraft/modpacks/${MODPACK_SLUG}/files/${FILE_ID}/additional-files"
        TEMP_ADDITIONAL=$(mktemp)
        
        # Fetch additional files page (don't exit on curl failure due to set -e)
        if curl -L -A "$USER_AGENT" \
            -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
            --max-time "$CURL_TIMEOUT" \
            -s "$ADDITIONAL_URL" > "$TEMP_ADDITIONAL" 2>/dev/null; then
            # Curl succeeded
            :
        else
            log_warn "Failed to fetch additional files for file ID $FILE_ID"
            rm -f "$TEMP_ADDITIONAL"
            continue
        fi
        
        # Check if page has content
        if [ ! -s "$TEMP_ADDITIONAL" ]; then
            rm -f "$TEMP_ADDITIONAL"
            continue
        fi
        
        # Look for server filenames in additional files
        SERVER_FILENAME=$(grep -io 'server[^"<>]*\.zip' "$TEMP_ADDITIONAL" | head -1 || true)
        
        if [ -n "$SERVER_FILENAME" ]; then
            # Found a server filename, now find its file ID
            SERVER_FILE_ID=$(grep -i "$SERVER_FILENAME" "$TEMP_ADDITIONAL" | sed -n 's|.*/files/\([0-9]\+\).*|\1|p' | head -1)
            rm -f "$TEMP_ADDITIONAL"
            
            if [ -n "$SERVER_FILE_ID" ]; then
                log_info "Found server file in additional files: $SERVER_FILENAME (ID: $SERVER_FILE_ID)"
                break
            else
                SERVER_FILENAME=""
            fi
        fi
        
        rm -f "$TEMP_ADDITIONAL"
    done
    
    if [ -z "$SERVER_FILENAME" ] || [ -z "$SERVER_FILE_ID" ]; then
        log_error "No server files found in main list or additional files"
        log_error "You can manually check: https://www.curseforge.com/minecraft/modpacks/${MODPACK_SLUG}/files"
        exit 1
    fi
else
    rm -f "$TEMP_HTML"
fi

# Construct the direct download URL
# CurseForge uses format: https://mediafilez.forgecdn.net/files/XXXX/YYY/filename.zip
# where file ID 7121795 becomes 7121/795

# Validate file ID has at least 3 digits
if [ ${#SERVER_FILE_ID} -lt 3 ]; then
    log_error "File ID '$SERVER_FILE_ID' is too short (< 3 digits) to construct a valid download URL"
    exit 1
fi

PART1=$(echo "$SERVER_FILE_ID" | sed 's/\(.*\)\(...\)/\1/')
PART2=$(echo "$SERVER_FILE_ID" | sed 's/.*\(...\)/\1/')

DOWNLOAD_URL="https://mediafilez.forgecdn.net/files/${PART1}/${PART2}/${SERVER_FILENAME}"

log_info "Resolved download URL: $DOWNLOAD_URL"
echo "$DOWNLOAD_URL"
exit 0
