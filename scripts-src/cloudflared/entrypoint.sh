#!/bin/bash
set -e

TOKEN_FILE="/run/secrets/cloudflared_token"
UNMINED_URL="http://unmined-webserver:80"

echo "========== Cloudflared Container Starting =========="

# Check if token file exists and has content
if [ -f "$TOKEN_FILE" ] && [ -s "$TOKEN_FILE" ]; then
    TOKEN=$(cat "$TOKEN_FILE")
    
    # Check if token is not empty or just whitespace
    if [ -n "$(echo "$TOKEN" | tr -d '[:space:]')" ]; then
        echo "Valid token found. Running tunnel with token..."
        exec cloudflared tunnel run --token "$TOKEN"
    fi
fi

# If we reach here, no valid token was found
echo "No valid token found. Running tunnel with --url pointing to unmined-webserver..."
exec cloudflared tunnel --url "$UNMINED_URL"
