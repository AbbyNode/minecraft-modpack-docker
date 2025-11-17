#!/bin/bash
set -e

# Variables
CF_SLUG="${CF_SLUG:-default}"
BORGMATIC_CONFIG_DIR="/etc/borgmatic.d"
BORGMATIC_CONFIG="${BORGMATIC_CONFIG_DIR}/config.yaml"
REPO_PATH="/var/lib/borgmatic/repository/${CF_SLUG}"
SHARED_CONFIG_DIR="/config/"
BORGMATIC_CONFIG_LINK="${SHARED_CONFIG_DIR}/borgmatic-config.yaml"

echo "========== Borgmatic Container Starting =========="
echo "Using modpack slug: $CF_SLUG"
echo "Repository path: $REPO_PATH"

# Ensure borgmatic config directory exists
mkdir -p "$BORGMATIC_CONFIG_DIR"

# Update borgmatic config with correct repository path
if [ -f "$BORGMATIC_CONFIG" ]; then
    # Update the repository path in the config to use the CF_SLUG-based path
    sed -i "s|^path:.*|path: ${REPO_PATH}|g" "$BORGMATIC_CONFIG"
    echo "Updated borgmatic config with repository path: $REPO_PATH"
fi

# Create shared config directory if it doesn't exist
mkdir -p "$SHARED_CONFIG_DIR"

# Link borgmatic config into shared config folder
if [ -f "$BORGMATIC_CONFIG" ]; then
    echo "Linking borgmatic config to shared config folder..."
    ln -sf "$BORGMATIC_CONFIG" "$BORGMATIC_CONFIG_LINK"
    echo "Config linked at $BORGMATIC_CONFIG_LINK"
fi

# Check if repository exists, if not initialize it
if [ ! -d "$REPO_PATH" ]; then
    echo "Repository does not exist at $REPO_PATH. Creating..."
    
    # Create directory if needed
    mkdir -p "$REPO_PATH"
    
    # Determine encryption mode - use BORG_ENCRYPTION env var if provided, otherwise default to repokey
    ENCRYPTION="${BORG_ENCRYPTION:-repokey}"
    echo "Using encryption mode: $ENCRYPTION"
    
    # Initialize the repository
    borgmatic init --encryption "$ENCRYPTION" --repository "$REPO_PATH"
    
    echo "Repository initialized successfully"
else
    echo "Repository already exists at $REPO_PATH"
fi

# Execute the original borgmatic entrypoint from borgmatic-collective/docker-borgmatic
echo "Starting borgmatic service..."
exec /init "$@"
