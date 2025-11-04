#!/bin/bash
set -e

echo "=== Minecraft Modpack Docker - Setup & Initialization ==="
echo ""

# Extract scripts to data/setup-scripts
if [[ ! -d /workspace/data/setup-scripts ]]; then
    echo "Extracting setup scripts..."
    mkdir -p /workspace/data/setup-scripts
    cp -r /scripts/* /workspace/data/setup-scripts/
    chmod +x /workspace/data/setup-scripts/*.sh
    echo "✓ Scripts extracted to data/setup-scripts/"
    echo ""
fi

# Create .env file if it doesn't exist
if [[ ! -f /workspace/.env ]]; then
    echo "Creating .env from template..."
    cp /templates/.env.example /workspace/.env
    echo "✓ .env created"
else
    echo "✓ .env already exists"
fi

# Create ofelia config if it doesn't exist
if [[ ! -f /workspace/data/config/ofelia/config.ini ]]; then
    echo ""
    echo "Creating ofelia configuration..."
    mkdir -p /workspace/data/config/ofelia
    cp /templates/ofelia-config.ini /workspace/data/config/ofelia/config.ini
    echo "✓ Ofelia config created at data/config/ofelia/config.ini"
fi

# Create required directories
echo ""
echo "Creating required directories..."
dirs=(
    /workspace/data/world
    /workspace/data/logs
    /workspace/data/config
    /workspace/data/mods/jars
    /workspace/data/mods/config
    /workspace/data/backups/borg-repository
    /workspace/data/config/borgmatic
)
for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
done
echo "✓ Directory structure created"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "You can now start the services with: docker compose up -d"
