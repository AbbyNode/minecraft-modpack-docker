#!/bin/bash
set -e

# Variables
CF_SLUG="${CF_SLUG:-default}"
REPO_PATH="/mnt/borg-repository/${CF_SLUG}"

BORGMATIC_CONFIG_SOURCE="/config/config.yaml"

BORGMATIC_CONFIG_DIR="/etc/borgmatic.d"
BORGMATIC_CONFIG="${BORGMATIC_CONFIG_DIR}/config.yaml"

BORG_PASSPHRASE_FILE="/run/secrets/borg_passphrase"


echo "========== Borgmatic Container Starting =========="
echo "Using modpack slug: $CF_SLUG"
echo "Repository path: $REPO_PATH"

# Check if borg passphrase file has valid content (not just comments)
if ! /scripts/common/check-secret-file.sh "$BORG_PASSPHRASE_FILE"; then
    echo "WARNING: Borg passphrase file is missing, empty, or only contains comments"
    echo "Will use 'none' encryption mode (no encryption)"
    # Unset BORG_PASSCOMMAND to avoid errors when using 'none' encryption
    unset BORG_PASSCOMMAND
    : "${BORG_ENCRYPTION:=none}"
else
    echo "Valid passphrase found. Will use 'repokey' encryption mode."
    # Set BORG_PASSCOMMAND to read from the secret file
    export BORG_PASSCOMMAND="cat $BORG_PASSPHRASE_FILE"
    : "${BORG_ENCRYPTION:=repokey}"
fi

# Ensure borgmatic config directory exists
mkdir -p "$BORGMATIC_CONFIG_DIR"

# Check if config exists in shared folder
if [ ! -f "$BORGMATIC_CONFIG_SOURCE" ]; then
    echo "ERROR: Borgmatic config not found at $BORGMATIC_CONFIG_SOURCE"
    exit 1
fi

# Copy the config from shared folder into borgmatic config directory
# Note: We copy instead of symlink because we need to modify the repository path
echo "Copying borgmatic config from shared folder..."
cp "$BORGMATIC_CONFIG_SOURCE" "$BORGMATIC_CONFIG"
echo "Config copied: $BORGMATIC_CONFIG_SOURCE -> $BORGMATIC_CONFIG"

# Update the repository path in the config to CF_SLUG
sed -i 's|^[[:space:]]*path:.*|path: '"$REPO_PATH"'|' "$BORGMATIC_CONFIG"

echo "Final borgmatic config:"
echo "----------------------------------------"
cat "$BORGMATIC_CONFIG"
echo "----------------------------------------"

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
