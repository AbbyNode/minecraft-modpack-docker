# FROM itzg/minecraft-server:latest

# # Hybrid image: Extends itzg/minecraft-server with CurseForge URL resolution
# # 
# # Features from itzg base:
# # - GENERIC_PACK for direct modpack URLs
# # - Custom start script support (automatic detection)
# # - Server properties via environment variables
# # - Optimized JVM flags, health checks, auto-restart
# #
# # Added features:
# # - CurseForge page URL resolution without API key (web scraping)
# #
# # Usage with direct URL:
# #   MODPACK_URL=https://mediafilez.forgecdn.net/files/.../ServerFiles.zip
# # 
# # Usage with CurseForge page URL:
# #   MODPACK_URL=https://www.curseforge.com/minecraft/modpacks/all-the-mods-10
# #   The wrapper resolves this to a direct URL automatically

# # Add logging utilities
# COPY ./scripts/log.sh /usr/local/bin/log.sh
# RUN chmod +x /usr/local/bin/log.sh

# # Add CurseForge resolver entrypoint
# COPY ./scripts/resolve-curseforge-url.sh /usr/local/bin/resolve-curseforge-url.sh
# RUN chmod +x /usr/local/bin/resolve-curseforge-url.sh

# # Use resolver as entrypoint (handles URL resolution and starts server)
# ENTRYPOINT ["/usr/local/bin/resolve-curseforge-url.sh"]
