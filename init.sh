#!/bin/bash
set -e

echo "=== Minecraft Modpack Docker - Setup & Initialization ==="


# ========== Paths ==========

SOURCE="/source"
WORKSPACE="/workspace"
TEMPLATES="$SOURCE/templates"
SCRIPTS_SRC="$SOURCE/scripts-src"
SCRIPTS_VOL="/scripts"


# ========== Update ==========

echo "Fetching latest templates and scripts..."

# Clone full repo to a temp directory
REPO="https://github.com/AbbyNode/minecraft-modpack-docker"
TEMP=$(mktemp -d)
git clone --depth 1 "$REPO" "$TEMP"

# Copy only the directories/files we care about to current directory
cp -r "$TEMP"/{templates,scripts-src,docker-compose.yml} "$SOURCE"
rm -rf "$TEMP"


# ========== Docker compose ==========

cp "$SOURCE/docker-compose.yml" "$WORKSPACE/docker-compose.yml"
echo "✓ Docker Compose file updated"


# ========== Scripts Volume ==========

mkdir -p "$SCRIPTS_VOL"
cp -r "$SCRIPTS_SRC/"* "$SCRIPTS_VOL/"
chmod +x "$SCRIPTS_VOL/"**/*.sh
echo "✓ Scripts volume updated"


# ========== Configuration Files ==========

# Ensure all files from $TEMPLATES exist in $WORKSPACE
echo ""
echo "Adding missing templates..."
if [[ ! -d $TEMPLATES ]]; then
	echo "ERROR: No templates found!"
fi

for template_file in $(find "$TEMPLATES" -type f); do
    relative_path="${template_file#$TEMPLATES/}" # Remove the templates base path
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


# ========== Minecraft Data Directories ==========

mkdir -p "$WORKSPACE/data/world"
mkdir -p "$WORKSPACE/data/logs/minecraft"
mkdir -p "$WORKSPACE/data/mods/downloads"
mkdir -p "$WORKSPACE/data/mods/jars"
mkdir -p "$WORKSPACE/data/mods/config"
chown -R 1000:1000 "$WORKSPACE/data"

echo "=== Setup Complete ==="
echo "You can now start the services with: docker compose up -d"
echo "To rerun setup or update scripts, use: docker compose --profile setup run --rm setup"
