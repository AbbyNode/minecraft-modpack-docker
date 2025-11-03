# itzg/minecraft-server Migration Guide

## Can I Replace My Custom Image?

**YES** - with important considerations based on your use case.

## Testing Results

Tested with 9 popular modpacks - **8/9 successful**:
- ✅ ATM 3, 7, 9, 10, RLCraft, Dawn Craft, Better MC, Pixelmon
- ❌ FTB Revelation (server files not in latest 3 versions)

[Full test results and URLs](#testing-results)

## Quick Decision Guide

### Use Direct Server File URLs? → Hybrid Approach Recommended

```yaml
services:
  minecraft-modpack:
    build:
      context: ./minecraft-modpack-itzg
    environment:
      EULA: "TRUE"
      GENERIC_PACK: "https://mediafilez.forgecdn.net/files/5622/996/ServerFiles-4.14.zip"
      # Server properties as env vars
      MOTD: "Minecraft Modpack Server"
      DIFFICULTY: "normal"
      VIEW_DISTANCE: "32"
```

**Benefits:**
- Uses itzg base with community maintenance
- Custom server files handled if present in modpack
- No API key needed
- Manual version control

### Use CurseForge Page URLs Without API Key?

The custom script resolves page URLs without an API key (via web scraping).
The hybrid Dockerfile can use this script to download, then let itzg handle the server.

### Want Auto-Updates?

Use pure itzg with `TYPE: "AUTO_CURSEFORGE"` + CurseForge API key (free from https://console.curseforge.com/)

## Key Differences: Custom vs itzg vs Hybrid

| Feature | Custom Image | Pure itzg | Hybrid (Recommended) |
|---------|--------------|-----------|---------------------|
| Direct URLs | ✅ MODPACK_URL | ✅ GENERIC_PACK | ✅ GENERIC_PACK |
| Page URLs (no API) | ✅ Web scraping | ❌ Requires API | ✅ Via download script |
| Custom start scripts | ✅ Uses modpack's | ❌ Own launcher | ✅ Uses if present |
| Server properties | ⚠️ Template | ✅ Env vars | ✅ Env vars |
| Maintenance | ⚠️ You | ✅ Community | ✅ Community |

## Hybrid Approach (Recommended)

Create a minimal Dockerfile extending itzg:

```dockerfile
FROM itzg/minecraft-server:latest

# Add download script for CurseForge resolution (optional)
COPY scripts/resolve-url.sh /scripts/
RUN chmod +x /scripts/*.sh

# Use itzg's entrypoint - it handles everything
```

**What it does:**
- Downloads modpack (direct URL or resolved from page URL)
- Uses custom start script if present in modpack
- Falls back to itzg's optimized launcher if not
- Handles all server setup via itzg's proven logic

## Migration Steps

1. **Update docker-compose.yml:**
   ```yaml
   services:
     minecraft-modpack:
       build:
         context: ./minecraft-modpack-itzg
       environment:
         EULA: "TRUE"
         GENERIC_PACK: "${MODPACK_URL}"
         # Add server properties as env vars (see .env.example)
       volumes:
         - ./data:/data
   ```

2. **Update .env:**
   - Keep `MODPACK_URL` (direct server file URL)
   - Remove `STARTSCRIPT` (handled automatically)
   - Add server property env vars (see .env.example for defaults)

3. **Test:**
   ```bash
   docker compose build
   docker compose up -d
   docker compose logs -f minecraft-modpack
   ```

## Configuration

### Server Properties (Environment Variables)

Set in docker-compose.yml or .env:
```yaml
MOTD: "Minecraft Modpack Server"
DIFFICULTY: "normal"
GAMEMODE: "survival"
FORCE_GAMEMODE: "TRUE"
PVP: "FALSE"
WHITE_LIST: "TRUE"
ENFORCE_WHITELIST: "TRUE"
SPAWN_PROTECTION: "0"
ALLOW_FLIGHT: "TRUE"
VIEW_DISTANCE: "32"
SIMULATION_DISTANCE: "16"
MAX_PLAYERS: "8"
```

### JSON Configs (Bind Mount Folders)

```yaml
volumes:
  - ./data:/data
  - ./data/config:/data/config  # For custom configs
```

Files accessible on host:
- `./data/whitelist.json`
- `./data/ops.json`
- `./data/banned-players.json`
- `./data/server.properties`

All in `/data` - no symlinks, just direct mounts.

## Testing Results

### Successfully Resolved Modpacks

| Modpack | Resolved URL |
|---------|--------------|
| ATM 10 | `https://mediafilez.forgecdn.net/files/5622/996/ServerFiles-4.14.zip` |
| ATM 9 | `https://mediafilez.forgecdn.net/files/5354/808/Server-Files-1.1.1.zip` |
| ATM 7 | `https://mediafilez.forgecdn.net/files/3513/421/server.zip` |
| ATM 3 | `https://mediafilez.forgecdn.net/files/2556/240/SERVER-FULL-6.1.1.zip` |
| RLCraft | `https://mediafilez.forgecdn.net/files/2533/561/Server Pack 1.12.2 - Release v2.9.3.zip` |
| Dawn Craft | `https://mediafilez.forgecdn.net/files/4730/261/Serverpack.zip` |
| Better MC | `https://mediafilez.forgecdn.net/files/5982/075/Server_Pack_v53.zip` |
| Pixelmon | `https://mediafilez.forgecdn.net/files/4838/829/serverpack939.zip` |

### Custom Script vs itzg AUTO_CURSEFORGE

**Custom Script (no API key):**
- Searches first 20 files + first 3 additional file sections
- Works for 8/9 tested modpacks
- May miss server files not in latest versions (e.g., FTB Revelation v3.2.0)

**itzg AUTO_CURSEFORGE (API key required):**
- Uses official API to find all server files
- Automatic updates when new versions released
- More reliable for long-term use

## Troubleshooting

**Server won't start:**
- Check logs: `docker compose logs minecraft-modpack`
- Verify MODPACK_URL is accessible: `curl -I "$MODPACK_URL"`
- Ensure EULA is set to "TRUE"

**Modpack not downloading:**
- Direct URLs work with both approaches
- Page URLs: Use custom script to resolve, then use direct URL

**Server properties not applied:**
- Verify environment variables are set correctly
- Check `./data/server.properties` after first run

## Files Provided

- **docker-compose.itzg.yml** - Ready-to-use configuration
- **.env.itzg.example** - Environment template with defaults
- **minecraft-modpack-itzg/Dockerfile** - Hybrid Dockerfile (to be created)

## Recommendation

**Use the hybrid approach** for best of both worlds:
- itzg's community-maintained base and features
- Support for custom start scripts if present
- No API key needed for CurseForge page URLs
- Simple migration path
- Reversible if needed
