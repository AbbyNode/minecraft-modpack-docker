# Migration Analysis: Custom Image vs itzg/minecraft-server

## Executive Summary

**YES, the custom minecraft-modpack image CAN be replaced with itzg/minecraft-server!** 

The itzg/minecraft-server image fully supports downloading server files from direct URLs, which is the core functionality of the current custom image.

## Feature Comparison

| Feature | Current Custom Image | itzg/minecraft-server | Status |
|---------|---------------------|----------------------|--------|
| Download server .zip from URL | ✅ Via MODPACK_URL | ✅ Via GENERIC_PACK or CF_SERVER_MOD | ✅ Supported |
| CurseForge URL resolution | ✅ Custom script | ✅ Via TYPE=CURSEFORGE + CF_SERVER_MOD | ✅ Supported |
| Auto EULA acceptance | ✅ Manual script | ✅ Via EULA=TRUE | ✅ Supported |
| Server properties config | ✅ Custom template | ✅ Via environment variables | ✅ Supported (Better!) |
| Run custom start script | ✅ Via STARTSCRIPT | ❌ Uses own launcher | ⚠️ Limitation |
| First-time setup detection | ✅ Custom logic | ✅ Built-in | ✅ Supported |
| Volume persistence | ✅ /minecraft | ✅ /data | ✅ Supported |
| Auto-update modpack | ❌ | ✅ Via AUTO_CURSEFORGE | ✅ Bonus Feature! |
| Advanced server config | ❌ | ✅ 100+ env vars | ✅ Bonus Feature! |

## Migration Path

### Option 1: Direct Server File URL (RECOMMENDED)
For direct server file URLs from CurseForge "Additional Files":

```yaml
services:
  minecraft-modpack:
    image: itzg/minecraft-server
    environment:
      EULA: "TRUE"
      TYPE: "AUTO_CURSEFORGE"  # or "FORGE", "FABRIC", "NEOFORGE"
      GENERIC_PACK: "${MODPACK_URL}"  # Your direct .zip URL
      # Server properties
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

### Option 2: CurseForge Modpack URL
For CurseForge modpack page URLs:

```yaml
services:
  minecraft-modpack:
    image: itzg/minecraft-server
    environment:
      EULA: "TRUE"
      TYPE: "CURSEFORGE"
      CF_SERVER_MOD: "${MODPACK_URL}"
      # Same server properties as Option 1
```

### Option 3: Auto-Updating CurseForge (ADVANCED)
For automatic modpack updates:

```yaml
services:
  minecraft-modpack:
    image: itzg/minecraft-server
    environment:
      EULA: "TRUE"
      TYPE: "AUTO_CURSEFORGE"
      CF_API_KEY: "${CF_API_KEY}"  # CurseForge API key
      CF_PAGE_URL: "${MODPACK_URL}"  # Modpack page URL
      # Same server properties as Option 1
```

## Key Differences & Considerations

### 1. Start Script Handling
**Current**: Runs the modpack's own start script (e.g., `startserver.sh`)
**itzg**: Uses its own launcher with standard JVM arguments

**Impact**: 
- ✅ Most modpacks work fine with itzg's launcher
- ⚠️ Some modpacks with complex custom start scripts might need JVM args adjustment
- ✅ Can override with GENERIC_PACK_STRIP_DIRS and custom JVM_OPTS if needed

### 2. Server Properties Management
**Current**: Template-based with custom script
**itzg**: Environment variable-based (MUCH BETTER!)

**Benefits**:
- ✅ No need for custom scripts
- ✅ Easy to override in docker-compose.yml
- ✅ Consistent with Docker/Kubernetes best practices
- ✅ Over 100+ properties supported as env vars

### 3. Volume Structure
**Current**: `/minecraft` with custom subdirectory linking
**itzg**: Standard `/data` directory

**Migration**:
- Update volume paths in docker-compose.yml
- No data loss, just path changes

### 4. Maintenance & Updates
**Current**: Custom image requires manual maintenance
**itzg**: 
- ✅ Actively maintained by community (1000+ contributors)
- ✅ Regular updates and bug fixes
- ✅ Extensive documentation
- ✅ Large user base for support

## Advantages of Migrating to itzg

1. **No Custom Code to Maintain**: Eliminates custom scripts and Dockerfile
2. **Better Features**: Auto-updates, health checks, advanced configuration
3. **Community Support**: Large ecosystem and active development
4. **Standard Approach**: Industry-standard Minecraft Docker image
5. **Better Documentation**: Comprehensive docs at docker-minecraft-server.readthedocs.io
6. **More Flexibility**: Support for multiple modpack platforms and loaders
7. **Advanced Features**:
   - Automatic modpack updates
   - Health monitoring
   - Webhook notifications
   - RCON support
   - Backup integration
   - Performance tuning options

## Potential Issues & Solutions

### Issue 1: Modpack with Custom Start Script
**Solution**: Most modern modpacks work fine. If issues occur, can use GENERIC_PACK with custom JVM_OPTS

### Issue 2: JSON Config Files
**Current**: Manually linked from /config
**Solution**: itzg automatically handles config files in /data

### Issue 3: CurseForge URL Resolution
**Current**: Custom script to resolve modpack page to server files
**Solution**: itzg has built-in support via TYPE=CURSEFORGE or TYPE=AUTO_CURSEFORGE

## Environment Variable Mapping

| Current (.env) | itzg Equivalent | Notes |
|----------------|----------------|-------|
| MODPACK_URL (direct) | GENERIC_PACK | For direct .zip URLs |
| MODPACK_URL (CF page) | CF_SERVER_MOD | For CurseForge URLs |
| STARTSCRIPT | N/A | Handled automatically |
| BORG_PASSPHRASE | BORG_PASSPHRASE | Unchanged |

## Recommended Migration Steps

1. **Test First**: Create a test instance with itzg image
2. **Update docker-compose.yml**: Switch to itzg/minecraft-server
3. **Convert Environment Variables**: Map MODPACK_URL to GENERIC_PACK or CF_SERVER_MOD
4. **Update Volume Paths**: Change /minecraft to /data
5. **Remove Custom Image**: No longer need minecraft-modpack Dockerfile
6. **Test Thoroughly**: Ensure modpack loads correctly
7. **Update Documentation**: Reflect new setup in README

## Conclusion

**Recommendation: MIGRATE to itzg/minecraft-server**

The itzg/minecraft-server image fully supports the core requirement of downloading server files from URLs, including both direct URLs and CurseForge modpack URLs. The migration will:

- ✅ Simplify the setup (no custom image to maintain)
- ✅ Provide better features and flexibility
- ✅ Use industry-standard tooling
- ✅ Reduce maintenance burden
- ✅ Improve documentation and support

The only potential limitation is for modpacks with very complex custom start scripts, but this is rare and can be worked around if needed.
