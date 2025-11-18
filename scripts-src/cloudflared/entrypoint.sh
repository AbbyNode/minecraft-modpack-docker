#!/bin/bash
set -e

TOKEN_FILE="/run/secrets/cloudflared_token"
UNMINED_URL="http://unmined-webserver:80"

# Install cloudflared

URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"

wget -q -O cloudflared "$URL" || curl -fsSL -o cloudflared "$URL"
chmod +x cloudflared

exec ./cloudflared "$@"

echo "========== Cloudflared Container Starting =========="

# Check if token file has valid content (not just comments)
if /scripts/common/check-secret-file.sh "$TOKEN_FILE"; then
    TOKEN=$(cat "$TOKEN_FILE")
    echo "Valid token found. Running tunnel with token..."
    exec cloudflared tunnel run --token "$TOKEN"
fi

# If we reach here, no valid token was found
echo "No valid token found. Running tunnel with --url pointing to unmined-webserver..."
exec cloudflared tunnel --url "$UNMINED_URL"
