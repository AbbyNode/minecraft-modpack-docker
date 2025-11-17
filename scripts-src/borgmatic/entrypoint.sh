#!/bin/bash
set -e

# Variables
CF_SLUG="${CF_SLUG:-default}"
BORGMATIC_CONFIG_DIR="/etc/borgmatic.d"
BORGMATIC_CONFIG="${BORGMATIC_CONFIG_DIR}/config.yaml"
REPO_PATH="/mnt/borg-repository/${CF_SLUG}"
SHARED_CONFIG_DIR="/config"
BORGMATIC_CONFIG_SOURCE="${SHARED_CONFIG_DIR}/config.yaml"
BORG_PASSPHRASE_FILE="/run/secrets/borg_passphrase"

echo "========== Borgmatic Container Starting =========="
echo "Using modpack slug: $CF_SLUG"
echo "Repository path: $REPO_PATH"

# Check if borg passphrase file has valid content (not just comments)
if ! /scripts/common/check-secret-file.sh "$BORG_PASSPHRASE_FILE"; then
    echo "ERROR: Borg passphrase file is missing, empty, or only contains comments"
    echo "Please add a valid passphrase to .secrets/borg_passphrase"
    exit 1
fi

# Ensure borgmatic config directory exists
mkdir -p "$BORGMATIC_CONFIG_DIR"

# Check if config exists in shared folder
if [ ! -f "$BORGMATIC_CONFIG_SOURCE" ]; then
    echo "ERROR: Borgmatic config not found at $BORGMATIC_CONFIG_SOURCE"
    exit 1
fi

# Link the config from shared folder into borgmatic config directory
echo "Linking borgmatic config from shared folder..."
ln -sf "$BORGMATIC_CONFIG_SOURCE" "$BORGMATIC_CONFIG"
echo "Config linked: $BORGMATIC_CONFIG_SOURCE -> $BORGMATIC_CONFIG"

# Update borgmatic config with correct repository path based on CF_SLUG
sed -i "s|/mnt/borg-repository/SLUG_PLACEHOLDER|${REPO_PATH}|g" "$BORGMATIC_CONFIG"
echo "Updated borgmatic config with repository path: $REPO_PATH"

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
