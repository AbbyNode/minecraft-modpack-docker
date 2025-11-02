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
    --compressed \
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

log_info "Files page downloaded, searching for file IDs..."

# Extract file IDs from the HTML
# CurseForge uses URLs like /minecraft/modpacks/all-the-mods-10/files/7121777
# We'll extract these file IDs and check each one for additional files
FILE_IDS=$(grep -oP '/minecraft/modpacks/[^/]+/files/\K[0-9]+' "$TEMP_HTML" | sort -u | head -${PAGE_SIZE})

if [ -z "$FILE_IDS" ]; then
    log_error "No file IDs found on the files page"
    log_error "CurseForge may have changed their page structure or the page failed to load"
    rm -f "$TEMP_HTML"
    exit 1
fi

rm -f "$TEMP_HTML"

log_info "Found file IDs to check for server files"

# Check each file ID for additional files
for FILE_ID in $FILE_IDS; do
    log_info "Checking file ID: $FILE_ID"
    
    ADDITIONAL_FILES_URL="https://www.curseforge.com/minecraft/modpacks/${MODPACK_SLUG}/files/${FILE_ID}/additional-files"
    
    TEMP_ADDITIONAL=$(mktemp)
    if ! curl -L -A "$USER_AGENT" \
        -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
        --compressed \
        -s "$ADDITIONAL_FILES_URL" > "$TEMP_ADDITIONAL"; then
        log_warn "Failed to fetch additional files page for file ID $FILE_ID"
        rm -f "$TEMP_ADDITIONAL"
        continue
    fi
    
    # Check if page has content
    if [ ! -s "$TEMP_ADDITIONAL" ]; then
        log_info "No additional files for file ID $FILE_ID"
        rm -f "$TEMP_ADDITIONAL"
        continue
    fi
    
    # Look for server files (case-insensitive search for "server")
    # The download URL format is typically like: https://mediafilez.forgecdn.net/files/XXXX/YYY/filename.zip
    # or displayed as links with file names containing "server"
    
    # Try to find download URLs with "server" in the filename - optimized single grep
    SERVER_FILE_URL=$(grep -oiE 'https?://[^"]*forgecdn\.net/files/[0-9]+/[0-9]+/[^"]*server[^"]*\.zip' "$TEMP_ADDITIONAL" | head -1)
    
    if [ -n "$SERVER_FILE_URL" ]; then
        log_info "Found server file URL: $SERVER_FILE_URL"
        echo "$SERVER_FILE_URL"
        rm -f "$TEMP_ADDITIONAL"
        exit 0
    fi
    
    # Alternative: look for file names containing "server" and try to construct the download URL
    # This looks for patterns like: ServerFiles-4.14.zip
    SERVER_FILENAME=$(grep -ioE '[^"/<>]*server[^"/<>]*\.zip' "$TEMP_ADDITIONAL" | head -1)
    
    if [ -n "$SERVER_FILENAME" ]; then
        log_info "Found server file name: $SERVER_FILENAME"
        
        # Try to find the corresponding download link
        # Look for forgecdn.net URLs that contain this filename or similar pattern
        DOWNLOAD_URL=$(grep -oE "https?://[^\"']*forgecdn\.net/files/[0-9]+/[0-9]+/[^\"']*\.zip" "$TEMP_ADDITIONAL" | grep -i "server" | head -1)
        
        if [ -n "$DOWNLOAD_URL" ]; then
            log_info "Resolved download URL: $DOWNLOAD_URL"
            echo "$DOWNLOAD_URL"
            rm -f "$TEMP_ADDITIONAL"
            exit 0
        fi
    fi
    
    rm -f "$TEMP_ADDITIONAL"
done

# If we get here, we didn't find any server files
log_error "No server files found in the first page of files for this modpack"
log_error "Server files may not be available, or they may be on a later page"
log_error "You can manually check: https://www.curseforge.com/minecraft/modpacks/${MODPACK_SLUG}/files"
exit 1
