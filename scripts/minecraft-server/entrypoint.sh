#!/bin/bash
set -e

# Minecraft server entrypoint with CurseForge URL resolution support
# This script integrates with itzg/minecraft-server, providing automatic
# resolution of CurseForge modpack page URLs to direct download URLs.

# Execute the CurseForge URL resolver which will:
# 1. Check if MODPACK_URL is a CurseForge page URL and resolve it if needed
# 2. Set GENERIC_PACK environment variable for itzg/minecraft-server
# 3. Execute the itzg/minecraft-server entrypoint (/start)
exec /scripts/resolve-curseforge-url.sh
