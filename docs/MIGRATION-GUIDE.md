# Migration Guide: Custom Image → itzg/minecraft-server

This guide walks you through migrating from the custom minecraft-modpack image to the industry-standard itzg/minecraft-server image.

## Why Migrate?

- ✅ No custom code to maintain
- ✅ Better features (auto-updates, health checks, advanced config)
- ✅ Active community support (1000+ contributors)
- ✅ Comprehensive documentation
- ✅ Industry-standard approach
- ✅ Supports the same core functionality: downloading server files from URLs

## Before You Begin

1. **Backup your data**: Create a backup of `./data` directory
2. **Read the analysis**: Review `docs/ITZG-MIGRATION-ANALYSIS.md` for detailed comparison
3. **Test first**: Consider testing on a copy of your data before migrating production

## Migration Steps

### Step 1: Stop Current Setup

```bash
docker compose down
```

### Step 2: Backup Current Data

```bash
# Create backup directory
mkdir -p ./backups/pre-migration-$(date +%Y%m%d)

# Backup data directory
cp -r ./data ./backups/pre-migration-$(date +%Y%m%d)/

# Backup docker-compose.yml and .env
cp docker-compose.yml ./backups/pre-migration-$(date +%Y%m%d)/
cp .env ./backups/pre-migration-$(date +%Y%m%d)/
```

### Step 3: Update Configuration Files

```bash
# Backup and replace docker-compose.yml
cp docker-compose.yml docker-compose.old.yml
cp docker-compose.itzg.yml docker-compose.yml

# Update .env file
# Option A: Start fresh (recommended)
cp .env .env.old
cp .env.itzg.example .env
# Then edit .env with your MODPACK_URL and BORG_PASSPHRASE

# Option B: Update existing .env
# Just ensure MODPACK_URL is set to your server files URL
# Remove STARTSCRIPT (no longer needed)
```

### Step 4: Update Environment Variables

Edit your `.env` file:

**Before (Custom Image):**
```env
MODPACK_URL=https://mediafilez.forgecdn.net/files/7121/795/ServerFiles-4.14.zip
STARTSCRIPT=startserver.sh
BORG_PASSPHRASE=your-passphrase
```

**After (itzg):**
```env
MODPACK_URL=https://mediafilez.forgecdn.net/files/7121/795/ServerFiles-4.14.zip
BORG_PASSPHRASE=your-passphrase
```

### Step 5: Start with itzg Image

```bash
# Pull the new image
docker compose pull minecraft-modpack

# Start the services
docker compose up -d

# Watch the logs
docker compose logs -f minecraft-modpack
```

### Step 6: Verify Migration

1. **Check server startup**:
   ```bash
   docker compose logs minecraft-modpack | grep -i "done"
   ```

2. **Verify world loaded**:
   ```bash
   ls -la ./data/world/
   ```

3. **Test connection**: Connect to your server with Minecraft client

4. **Check server properties**:
   ```bash
   docker compose exec minecraft-modpack cat /data/server.properties
   ```

## Volume Path Changes

The itzg image uses `/data` instead of `/minecraft`:

| Old Path | New Path | Notes |
|----------|----------|-------|
| `/minecraft` | `/data` | Main server directory |
| `/minecraft/world` | `/data/world` | World data (mounted separately) |
| `/minecraft/logs` | `/data/logs` | Server logs (mounted separately) |
| `/minecraft/mods` | `/data/mods` | Mods directory |
| `/minecraft/config` | `/data/config` | Mod configs and server.properties |

**Note**: Your host paths (`./data/*`) remain the same! Only the container paths change.

## Troubleshooting

### Issue: Server won't start

**Check logs**:
```bash
docker compose logs minecraft-modpack
```

**Common causes**:
1. MODPACK_URL not accessible
2. Wrong server type (set TYPE in docker-compose.yml)
3. Insufficient memory

**Solutions**:
- Verify MODPACK_URL is accessible: `curl -I "${MODPACK_URL}"`
- Check TYPE is set correctly (AUTO_CURSEFORGE, FORGE, FABRIC, etc.)
- Increase MEMORY in docker-compose.yml

### Issue: Modpack not downloading

**Symptoms**: Server starts vanilla instead of with modpack

**Causes**:
1. MODPACK_URL pointing to wrong file
2. Network issues

**Solutions**:
```bash
# Test URL manually
docker compose exec minecraft-modpack curl -I "${MODPACK_URL}"

# Check environment variables
docker compose exec minecraft-modpack env | grep MODPACK
```

### Issue: Server properties not applied

**Symptoms**: Server settings different from docker-compose.yml

**Cause**: OVERRIDE_SERVER_PROPERTIES may be disabled

**Solution**: Ensure these are NOT set in environment:
- `OVERRIDE_SERVER_PROPERTIES: "FALSE"`

### Issue: Mods not loading

**Symptoms**: Mods folder empty or server runs vanilla

**Cause**: GENERIC_PACK may not be extracting correctly

**Solutions**:
1. Verify zip file structure contains mods/ directory
2. Try setting TYPE explicitly (FORGE, FABRIC, NEOFORGE)
3. Check logs for extraction errors

### Issue: Custom start script not running

**Explanation**: itzg uses its own launcher, not modpack start scripts

**Solution**: 
- Most modpacks work fine with itzg's launcher
- If issues occur, can customize JVM args:
  ```yaml
  environment:
    JVM_OPTS: "-Xms4G -Xmx4G -XX:+UseG1GC"
  ```

## Rollback Instructions

If you need to rollback to the custom image:

```bash
# Stop current setup
docker compose down

# Restore old files
cp docker-compose.old.yml docker-compose.yml
cp .env.old .env

# Start with old image
docker compose up -d
```

Your data in `./data/` is compatible with both versions.

## Advanced Configuration

### Enable Auto-Updates

To automatically update your modpack when new versions are released:

1. Get a CurseForge API key from https://console.curseforge.com/
2. Update docker-compose.yml:
   ```yaml
   environment:
     TYPE: "AUTO_CURSEFORGE"
     CF_API_KEY: "${CF_API_KEY}"
     CF_PAGE_URL: "${MODPACK_URL}"  # Use modpack page URL
   ```
3. Add to .env:
   ```env
   CF_API_KEY=your-api-key-here
   MODPACK_URL=https://www.curseforge.com/minecraft/modpacks/all-the-mods-10
   ```

### Customize JVM Arguments

```yaml
environment:
  MEMORY: "6G"
  JVM_OPTS: "-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200"
  USE_AIKAR_FLAGS: "TRUE"  # Recommended for performance
```

### Add Custom Mods

Place additional mod jars in `./data/mods/jars/` - they will be loaded alongside modpack mods.

## Post-Migration Cleanup

After successful migration and testing:

```bash
# Remove old backup files (optional)
rm docker-compose.old.yml
rm .env.old

# Remove custom image files (if no longer needed)
# NOTE: Only do this if you're certain you won't rollback
rm -rf ./minecraft-modpack/

# Update .gitignore if needed
echo "docker-compose.old.yml" >> .gitignore
echo ".env.old" >> .gitignore
```

## Getting Help

- **itzg Documentation**: https://docker-minecraft-server.readthedocs.io/
- **itzg GitHub**: https://github.com/itzg/docker-minecraft-server
- **itzg Discord**: https://discord.gg/ScbTrAw
- **Original Analysis**: See `docs/ITZG-MIGRATION-ANALYSIS.md`

## Next Steps

After successful migration:

1. ✅ Test all server functionality
2. ✅ Verify backups still work with Borgmatic
3. ✅ Update your documentation/README
4. ✅ Consider enabling auto-updates (optional)
5. ✅ Explore advanced itzg features
