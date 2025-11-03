#!/bin/sh
set -e

echo "=== Minecraft Modpack Docker - Setup & Initialization ==="
echo ""

# Extract scripts to data/config/setup-scripts
if [ ! -d /workspace/data/config/setup-scripts ]; then
    echo "Extracting setup scripts..."
    mkdir -p /workspace/data/config/setup-scripts
    cp -r /scripts/* /workspace/data/config/setup-scripts/
    chmod +x /workspace/data/config/setup-scripts/*.sh
    echo "✓ Scripts extracted to data/config/setup-scripts/"
    echo ""
fi

# Create .env file if it doesn't exist
if [ ! -f /workspace/.env ]; then
    if [ -f /workspace/.env.example ]; then
        echo "Creating .env from .env.example..."
        cp /workspace/.env.example /workspace/.env
        echo "✓ .env created"
    else
        echo "⚠ Warning: .env.example not found"
        echo "Creating default .env..."
        cp /templates/default.env /workspace/.env
        echo "✓ Default .env created"
    fi
else
    echo "✓ .env already exists"
fi

# Create ofelia config if it doesn't exist
if [ ! -f /workspace/data/config/ofelia/config.ini ]; then
    echo ""
    echo "Creating ofelia configuration..."
    mkdir -p /workspace/data/config/ofelia
    cp /templates/ofelia-config.ini /workspace/data/config/ofelia/config.ini
    echo "✓ Ofelia config created at data/config/ofelia/config.ini"
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
