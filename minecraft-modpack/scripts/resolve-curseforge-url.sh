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

# Extract file IDs that have "server" in their associated file name
# Get the highest (most recent) file ID
SERVER_FILE_ID=$(grep -i 'server.*\.zip' "$TEMP_HTML" | grep -oP '/files/\K[0-9]+' | sort -rn | head -1)

if [ -z "$SERVER_FILE_ID" ]; then
    log_error "No server files found on the files list page"
    log_error "You can manually check: https://www.curseforge.com/minecraft/modpacks/${MODPACK_SLUG}/files"
    rm -f "$TEMP_HTML"
    exit 1
fi

# Extract filename for this file ID
# Find the line containing this specific file ID and extract the filename
SERVER_FILENAME=$(grep "/files/${SERVER_FILE_ID}" "$TEMP_HTML" | grep -ioP '[^"/<>]*server[^"/<>]*\.zip' | head -1)

rm -f "$TEMP_HTML"

if [ -z "$SERVER_FILENAME" ]; then
    log_error "Failed to extract server filename for file ID: $SERVER_FILE_ID"
    exit 1
fi

log_info "Found server file: $SERVER_FILENAME (ID: $SERVER_FILE_ID)"

# Construct the direct download URL
# CurseForge uses format: https://mediafilez.forgecdn.net/files/XXXX/YYY/filename.zip
# where file ID 7121795 becomes 7121/795
PART1=$(echo "$SERVER_FILE_ID" | sed 's/\(.*\)\(...\)/\1/')
PART2=$(echo "$SERVER_FILE_ID" | sed 's/.*\(...\)/\1/')

DOWNLOAD_URL="https://mediafilez.forgecdn.net/files/${PART1}/${PART2}/${SERVER_FILENAME}"

log_info "Resolved download URL: $DOWNLOAD_URL"
echo "$DOWNLOAD_URL"
exit 0
