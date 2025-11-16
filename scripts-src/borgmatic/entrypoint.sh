#!/bin/bash
set -e

echo "========== Borgmatic Container Starting =========="

# Get the modpack slug from environment variable, default to 'default' if not set
CF_SLUG="${CF_SLUG:-default}"
echo "Using modpack slug: $CF_SLUG"

# Define repository path using the CF_SLUG
REPO_PATH="/var/lib/borgmatic/repository/${CF_SLUG}"
echo "Repository path: $REPO_PATH"

# Ensure borgmatic config directory exists
mkdir -p /etc/borgmatic.d

# Update borgmatic config with correct repository path
if [ -f /etc/borgmatic.d/config.yaml ]; then
    # Update the repository path in the config to use the CF_SLUG-based path
    sed -i "s|path: /var/lib/borgmatic/repository|path: ${REPO_PATH}|g" /etc/borgmatic.d/config.yaml
    echo "Updated borgmatic config with repository path: $REPO_PATH"
fi

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
