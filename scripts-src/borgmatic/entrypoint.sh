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
DEFAULT_PASSPHRASE="minecraft-modpack-docker-default-passphrase"

echo "========== Borgmatic Container Starting =========="
echo "Using modpack slug: $CF_SLUG"
echo "Repository path: $REPO_PATH"

# Check if borg passphrase file has valid content (not just comments)
# If no passphrase is provided, use a default predefined passphrase for encryption
if ! /scripts/common/check-secret-file.sh "$BORG_PASSPHRASE_FILE"; then
    echo "WARNING: Borg passphrase file is missing, empty, or only contains comments"
    echo "Using default predefined passphrase for 'repokey' encryption"
    # Set BORG_PASSCOMMAND to use the default passphrase
    export BORG_PASSCOMMAND="echo $DEFAULT_PASSPHRASE"
else
    echo "Valid passphrase found. Using provided passphrase for 'repokey' encryption."
    # BORG_PASSCOMMAND is already set in docker-compose.yml to read from the secret file
fi

# Always use repokey encryption (with either provided or default passphrase)
: "${BORG_ENCRYPTION:=repokey}"

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
    
    echo "Using encryption mode: $BORG_ENCRYPTION"
    
    # Initialize the repository
    borgmatic init --encryption "$BORG_ENCRYPTION" --repository "$REPO_PATH"
    
    echo "Repository initialized successfully"
else
    echo "Repository already exists at $REPO_PATH"
fi

# Execute the original borgmatic entrypoint from borgmatic-collective/docker-borgmatic
echo "Starting borgmatic service..."
exec /init "$@"
