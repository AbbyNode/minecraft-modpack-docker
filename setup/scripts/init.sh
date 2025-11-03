#!/bin/sh
set -e

# Default mode is init
MODE="${1:-init}"

if [ "$MODE" = "extract" ]; then
    # Extract mode: copy scripts to workspace for mounting
    echo "Extracting scripts to current directory..."
    mkdir -p /workspace/.minecraft-setup
    cp -r /scripts/* /workspace/.minecraft-setup/
    chmod +x /workspace/.minecraft-setup/*.sh
    echo "✓ Scripts extracted to .minecraft-setup/"
    echo ""
    echo "Scripts are now available for docker-compose to mount."
    exit 0
fi

# Init mode: standard setup
echo "=== Minecraft Modpack Docker - Setup & Initialization ==="
echo ""

# Extract scripts first if they don't exist
if [ ! -d /workspace/.minecraft-setup ]; then
    echo "Extracting setup scripts..."
    mkdir -p /workspace/.minecraft-setup
    cp -r /scripts/* /workspace/.minecraft-setup/
    chmod +x /workspace/.minecraft-setup/*.sh
    echo "✓ Scripts extracted"
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
        cat > /workspace/.env << 'EOF'
# ATM 10
MODPACK_URL=https://mediafilez.forgecdn.net/files/7121/795/ServerFiles-4.14.zip
STARTSCRIPT=startserver.sh
EOF
        echo "✓ Default .env created"
    fi
else
    echo "✓ .env already exists"
fi

# Create ofelia config if it doesn't exist
if [ ! -d /workspace/ofelia ]; then
    echo ""
    echo "Creating ofelia configuration..."
    mkdir -p /workspace/ofelia
    cat > /workspace/ofelia/config.ini << 'EOF'
# Ofelia job configuration
# This file orchestrates scheduled tasks for the Minecraft server infrastructure

# Borgmatic Backup Job
# Runs daily backups at 2:00 AM
[job-exec "borgmatic-backup"]
schedule = 0 2 * * *
container = borgmatic
command = /scripts/backup.sh
no-overlap = true

# MCASelector Chunk Deletion Job
# Runs weekly on Sunday at 3:00 AM to clean up old chunks
[job-exec "mcaselector-cleanup"]
schedule = 0 3 * * 0
container = mcaselector
command = /scripts/delete-chunks.sh
no-overlap = true
EOF
    echo "✓ Ofelia config created"
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
