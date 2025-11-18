#!/bin/bash
set -e

echo "========== Cloudflared Container Starting =========="

: "${INTERNAL_URL:=http://webserver:80}"

CLOUDFLARED_DOWNLOAD="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"
TOKEN_FILE="/run/secrets/cloudflared_token"

# Install cloudflared

echo "Downloading cloudflared client..."
curl -fL --progress-bar -o cloudflared "$CLOUDFLARED_DOWNLOAD"
chmod +x cloudflared

# Check if token file has valid content (not just comments)
if /scripts/common/check-secret-file.sh "$TOKEN_FILE"; then
    TOKEN=$(cat "$TOKEN_FILE")
    echo "Valid token found. Running tunnel with token..."
    exec ./cloudflared tunnel run --token "$TOKEN"
fi

# If we reach here, no valid token was found
echo "No valid token found. Running tunnel with --url pointing to webserver..."
exec ./cloudflared tunnel --url "$INTERNAL_URL"
