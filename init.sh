#!/bin/bash
set -e

echo ""
echo "=== Minecraft Modpack Docker - Setup & Initialization ==="
echo "Script version: 2025-11-17.10"


# ========== Update ==========

echo ""
echo "Fetching latest templates and scripts..."
REPO="https://github.com/AbbyNode/minecraft-modpack-docker"
SOURCE=$(mktemp -d)
git clone --depth 1 "$REPO" "$SOURCE"


# ========== Paths ==========

TEMPLATES_SRC="$SOURCE/templates"
SCRIPTS_SRC="$SOURCE/scripts"
WORKSPACE="/workspace"
SCRIPTS_VOL="/scripts"


# ========== Docker compose ==========

echo ""
cp "$SOURCE/docker-compose.yml" "$WORKSPACE/docker-compose.yml"
echo "✓ Docker Compose file updated"


# ========== Scripts Volume ==========

echo ""
mkdir -p "$SCRIPTS_VOL"
cp -r "$SCRIPTS_SRC/"* "$SCRIPTS_VOL/"
chmod +x "$SCRIPTS_VOL/"**/*.sh
echo "✓ Scripts volume updated"


# ========== Configuration Files ==========

# Ensure all files from $TEMPLATES_SRC exist in $WORKSPACE
echo ""
echo "Adding missing templates..."
if [[ ! -d $TEMPLATES_SRC ]]; then
	echo "ERROR: No templates found!"
fi

for template_file in $(find "$TEMPLATES_SRC" -type f); do
    relative_path="${template_file#$TEMPLATES_SRC/}" # Remove the templates base path
    relative_path="${relative_path%.example}" # Remove the .example suffix
    target_file="${WORKSPACE}/${relative_path}"
    
    if [[ ! -f "$target_file" ]]; then
        mkdir -p "$(dirname "$target_file")"
        cp "$template_file" "$target_file"
        echo "✓ Created ${relative_path}"
    else
        echo "• ${relative_path} already exists"
    fi
done


# ========== Cleanup ==========

rm -rf "$SOURCE"


# ========== Minecraft Data Directories ==========

mkdir -p "$WORKSPACE/data/world"
mkdir -p "$WORKSPACE/data/logs/minecraft"
mkdir -p "$WORKSPACE/data/mods/downloads"
mkdir -p "$WORKSPACE/data/mods/jars"
mkdir -p "$WORKSPACE/data/mods/config"
chown -R 1000:1000 "$WORKSPACE/data"


echo ""
echo "=== Setup Complete ==="
echo ""
echo "You can now start the services with:"
echo "docker compose up -d"
echo ""
echo "To rerun setup or update scripts, use:"
echo "docker compose --profile setup run --rm setup"
echo ""
