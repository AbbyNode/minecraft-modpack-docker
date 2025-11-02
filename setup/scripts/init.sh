#!/bin/sh
set -e

echo "=== Minecraft Modpack Docker - Setup & Initialization ==="
echo ""

# Create .env file if it doesn't exist
if [ ! -f /workspace/.env ]; then
    if [ -f /workspace/.env.example ]; then
        echo "Creating .env from .env.example..."
        cp /workspace/.env.example /workspace/.env
        echo "✓ .env created"
    else
        echo "⚠ Warning: .env.example not found, skipping .env creation"
    fi
else
    echo "✓ .env already exists"
fi

# Create required directories
echo ""
echo "Creating required directories..."
mkdir -p /workspace/data/world
mkdir -p /workspace/data/logs
mkdir -p /workspace/data/config
mkdir -p /workspace/data/mods/jars
mkdir -p /workspace/data/mods/config
mkdir -p /workspace/data/backups/borg-repository
mkdir -p /workspace/data/config/borgmatic
echo "✓ Directory structure created"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "You can now start the services with: docker compose up -d"
