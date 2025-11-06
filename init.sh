#!/bin/bash
set -e

echo "=== Minecraft Modpack Docker - Setup & Initialization ==="
echo ""

WORKSPACE="/workspace"
SETUP="/setup"
TEMPLATES="/templates"
SCRIPTS_SRC="/scripts-src"
SCRIPTS_VOL="/scripts"

# ========== Base Setup Files ==========

# Update docker-compose.yml with the latest version
echo "Updating docker-compose.yml..."
if [[ -f $WORKSPACE/docker-compose.yml ]]; then
    timestamp=$(date +"%Y%m%d_%H%M%S")
    echo "Backing up existing docker-compose.yml"
    cp "${WORKSPACE}/docker-compose.yml $WORKSPACE/docker-compose.yml.${timestamp}.bak"
    echo "✓ Backup created"
fi
cp $SETUP/docker-compose.yml $WORKSPACE/docker-compose.yml
echo "✓ docker-compose.yml updated"

# Setup scripts virtual volume
echo "Updating scripts volume..."
mkdir -p $SCRIPTS_VOL
cp -r $SCRIPTS_SRC/* $SCRIPTS_VOL/
chmod +x $SCRIPTS_VOL/*.sh
echo "✓ Scripts volume updated"


# ========== Configuration Files ==========

# Loop all files recursively in /templates/config and ensure they exist
echo "Adding missing templates..."
if [[ ! -d $TEMPLATES ]]; then
	echo "ERROR: No templates found!"
fi

# TODO: reduce indent
    find $TEMPLATES -type f | while read -r template_file; do
        relative_path="${template_file#$TEMPLATES/}"
        target_file="${WORKSPACE}/${relative_path}"
        target_dir=$(dirname "$target_file")
        
        if [[ ! -f "$target_file" ]]; then
            mkdir -p "$target_dir"
            cp "$template_file" "$target_file"
            echo "✓ Created $relative_path"
        else
            echo "✓ $relative_path already exists"
        fi
    done


echo ""
echo "=== Setup Complete ==="
echo ""
echo "You can now start the services with: docker compose up -d"
