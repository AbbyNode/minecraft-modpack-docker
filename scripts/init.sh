#!/bin/bash
set -e

echo "=== Minecraft Modpack Docker - Setup & Initialization ==="
echo ""

# Create docker-compose.yml if it doesn't exist
if [[ ! -f /workspace/docker-compose.yml ]]; then
    echo "Creating docker-compose.yml from template..."
    cp /templates/docker-compose.example.yml /workspace/docker-compose.yml
    echo "✓ docker-compose.yml created"
else
    echo "✓ docker-compose.yml already exists"
fi

# Create .env file if it doesn't exist
if [[ ! -f /workspace/.env ]]; then
    echo "Creating .env from template..."
    cp /templates/.env.example /workspace/.env
    echo "✓ .env created"
else
    echo "✓ .env already exists"
fi

# Create .secrets file if it doesn't exist
if [[ ! -f /workspace/.secrets ]]; then
    echo "Creating .secrets from template..."
    cp /templates/.secrets.example /workspace/.secrets
    echo "✓ .secrets created"
else
    echo "✓ .secrets already exists"
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
)
for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
done
echo "✓ Directory structure created"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "You can now start the services with: docker compose up -d"
