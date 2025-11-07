#!/bin/bash
set -e

echo "=== Minecraft Modpack Docker - Setup & Initialization ==="
echo ""


# ========== Paths ==========

WORKSPACE="/workspace"
SETUP="/setup"
TEMPLATES="/templates"
SCRIPTS_SRC="/scripts-src"
SCRIPTS_VOL="/scripts"


# ========== Docker compose ==========

cp "$SETUP/docker-compose.yml" "$WORKSPACE/docker-compose.yml"
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


echo ""
echo "=== Setup Complete ==="
echo ""
echo "You can now start the services with: docker compose up -d"
