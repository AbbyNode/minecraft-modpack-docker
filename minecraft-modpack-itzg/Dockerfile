FROM itzg/minecraft-server:latest

# Hybrid image: itzg/minecraft-server with CurseForge URL resolution support
# 
# This extends itzg/minecraft-server to add the ability to resolve CurseForge
# modpack page URLs without requiring an API key (via web scraping).
#
# Key features from itzg base:
# - Automatic modpack download and extraction via GENERIC_PACK
# - Custom start script support (looks for startserver.sh, ServerStart.sh, etc.)
# - Server property management via environment variables
# - Health checks, auto-restarts, optimized JVM flags (Aikar)
#
# This image adds:
# - Optional CurseForge page URL resolution without API key
#
# Usage:
#   MODPACK_URL=https://www.curseforge.com/minecraft/modpacks/all-the-mods-10
#   The entrypoint will resolve this to a direct server file URL and pass to itzg

# Add URL resolution helper
COPY scripts/resolve-url-wrapper.sh /usr/local/bin/resolve-url-wrapper.sh
RUN chmod +x /usr/local/bin/resolve-url-wrapper.sh

# Use wrapper entrypoint that resolves URLs then calls itzg entrypoint
ENTRYPOINT ["/usr/local/bin/resolve-url-wrapper.sh"]
