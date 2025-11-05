FROM itzg/minecraft-server:latest

# Hybrid image: Extends itzg/minecraft-server with custom wrapper
# 
# Features from itzg base:
# - GENERIC_PACK for direct modpack URLs
# - Custom start script support (automatic detection)
# - Server properties via environment variables
# - Optimized JVM flags, health checks, auto-restart
#
# Usage:
#   MODPACK_URL=https://mediafilez.forgecdn.net/files/.../ServerFiles.zip
#   Find server pack URLs on your modpack's CurseForge Files page

# Add lib directory with shared utilities
COPY ./lib /usr/local/lib/minecraft
RUN chmod +x /usr/local/lib/minecraft/*.sh

# Add URL wrapper script
COPY ./scripts/resolve-url-wrapper.sh /usr/local/bin/resolve-url-wrapper.sh
RUN chmod +x /usr/local/bin/resolve-url-wrapper.sh

# Use wrapper entrypoint that validates URLs then calls itzg entrypoint
ENTRYPOINT ["/usr/local/bin/resolve-url-wrapper.sh"]
