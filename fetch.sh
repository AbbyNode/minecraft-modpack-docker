#!/bin/bash
set -euo pipefail

echo ""
echo "=== Eclariftn | Minecraft Modpack Docker | Setup ==="
echo "Script version: 2025-11-30.1"

echo ""
echo "Fetching latest templates and scripts..."
REPO="https://github.com/AbbyNode/minecraft-modpack-docker"
SOURCE=$(mktemp -d)
git clone --depth 1 "$REPO" "$SOURCE"

# Run init
exec "$SOURCE/init.sh" "$SOURCE"
