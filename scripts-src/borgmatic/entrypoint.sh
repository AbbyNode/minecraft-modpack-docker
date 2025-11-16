#!/bin/bash
set -e

echo "========== Borgmatic Container Starting =========="

# Get the modpack slug from environment variable, default to 'default' if not set
CF_SLUG="${CF_SLUG:-default}"
echo "Using modpack slug: $CF_SLUG"

# Define repository path using the CF_SLUG
REPO_PATH="/var/lib/borgmatic/repository/${CF_SLUG}"

# Create shared config directory if it doesn't exist
SHARED_CONFIG_DIR="/config/borgmatic"
mkdir -p "$SHARED_CONFIG_DIR"

# Link borgmatic config into shared config folder
BORGMATIC_CONFIG="/etc/borgmatic.d/config.yaml"
if [ -f "$BORGMATIC_CONFIG" ]; then
    echo "Linking borgmatic config to shared config folder..."
    ln -sf "$BORGMATIC_CONFIG" "$SHARED_CONFIG_DIR/config.yaml"
    echo "Config linked at $SHARED_CONFIG_DIR/config.yaml"
fi

# Check if repository exists, if not run init script
if [ ! -d "$REPO_PATH" ]; then
    echo "Repository not found. Running initialization..."
    /scripts/borgmatic/init.sh
fi

# Execute the original borgmatic entrypoint from borgmatic-collective/docker-borgmatic
echo "Starting borgmatic service..."
exec /init "$@"
