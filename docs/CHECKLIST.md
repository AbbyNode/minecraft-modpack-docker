# Action Checklist: Migrating to itzg/minecraft-server

This checklist helps you decide whether to migrate and guides you through the process.

## ✅ Decision Checklist

Review these points to decide if you should migrate:

- [ ] I want to reduce maintenance of custom Docker images
- [ ] I want access to advanced features (auto-updates, health checks, etc.)
- [ ] I want better community support and documentation
- [ ] My modpack is from CurseForge or similar (standard modpack)
- [ ] I'm comfortable with environment variable configuration
- [ ] I can spare 1 hour for migration and testing

**If you checked most of these, migration is recommended!**

## 📚 Pre-Migration Reading

Choose your reading path based on your needs:

### Quick Path (15 minutes)
1. [ ] Read [ANSWER.md](docs/ANSWER.md) - Direct answer to your question
2. [ ] Skim [QUICK-COMPARISON.md](docs/QUICK-COMPARISON.md) - Side-by-side comparison
3. [ ] Skip to migration steps below

### Thorough Path (30 minutes)
1. [ ] Read [ANSWER.md](docs/ANSWER.md) - Direct answer to your question
2. [ ] Read [QUICK-COMPARISON.md](docs/QUICK-COMPARISON.md) - Quick overview
3. [ ] Read [ITZG-MIGRATION-ANALYSIS.md](docs/ITZG-MIGRATION-ANALYSIS.md) - Detailed analysis
4. [ ] Review [MIGRATION-GUIDE.md](docs/MIGRATION-GUIDE.md) - Step-by-step guide
5. [ ] Proceed to migration steps below

## 🔧 Migration Steps

### Step 1: Preparation (5 minutes)
- [ ] Read the documentation (see above)
- [ ] Ensure you have Docker and Docker Compose installed
- [ ] Note your current MODPACK_URL from `.env`
- [ ] Have your BORG_PASSPHRASE ready

### Step 2: Backup (5 minutes)
```bash
# Stop current setup
docker compose down

# Create backup directory
mkdir -p ./backups/pre-migration-$(date +%Y%m%d)

# Backup critical files
cp -r ./data ./backups/pre-migration-$(date +%Y%m%d)/
cp docker-compose.yml ./backups/pre-migration-$(date +%Y%m%d)/
cp .env ./backups/pre-migration-$(date +%Y%m%d)/
```

- [ ] Backups created successfully
- [ ] Verified backup directory exists and has files

### Step 3: Update Configuration (5 minutes)
```bash
# Backup current config
cp docker-compose.yml docker-compose.old.yml
cp .env .env.old

# Use itzg version
cp docker-compose.itzg.yml docker-compose.yml
cp .env.itzg.example .env

# Edit .env with your values
nano .env  # or vim, code, etc.
```

Update these values in `.env`:
- [ ] Set `MODPACK_URL` to your server files URL
- [ ] Set `BORG_PASSPHRASE` to your backup passphrase
- [ ] Remove any `STARTSCRIPT` line (not needed)
- [ ] Save and close `.env`

### Step 4: Review docker-compose.yml (5 minutes)
```bash
# Review the new configuration
cat docker-compose.yml
```

Check these settings match your needs:
- [ ] `MEMORY` setting is appropriate (default: 4G)
- [ ] `VIEW_DISTANCE` is what you want (default: 32)
- [ ] `DIFFICULTY` is correct (default: normal)
- [ ] `MAX_PLAYERS` is correct (default: 8)
- [ ] `WHITE_LIST` is TRUE (default: TRUE)

Optional: Edit docker-compose.yml to adjust any settings

### Step 5: Start with itzg (10 minutes)
```bash
# Pull the new image
docker compose pull minecraft-modpack

# Start services
docker compose up -d

# Watch the logs
docker compose logs -f minecraft-modpack
```

Watch for these log messages:
- [ ] "Downloading GENERIC_PACK..." (or similar)
- [ ] "Extracting..." 
- [ ] Server starting messages
- [ ] "Done!" or "Server started"

**Note**: First startup may take 5-10 minutes depending on modpack size.

### Step 6: Verify Migration (10 minutes)
```bash
# Check server status
docker compose ps

# Verify world loaded
ls -la ./data/world/

# Check server properties
docker compose exec minecraft-modpack cat /data/server.properties | grep -E "difficulty|gamemode|view-distance"

# Test connection with Minecraft client
```

Verify:
- [ ] Container is running (status: Up)
- [ ] World files exist in ./data/world/
- [ ] Server properties are correct
- [ ] Can connect with Minecraft client
- [ ] World loads correctly
- [ ] Mods are working

### Step 7: Test Backups (5 minutes)
```bash
# Run manual backup
docker exec borgmatic /scripts/backup.sh

# Verify backup completed
docker exec borgmatic borgmatic list
```

- [ ] Backup runs without errors
- [ ] New backup appears in list

### Step 8: Test Chunk Cleanup (5 minutes)
```bash
# Run manual cleanup (won't delete much on new world)
docker exec mcaselector /scripts/delete-chunks.sh
```

- [ ] Cleanup runs without errors

### Step 9: Monitor for Issues (1-2 days)
- [ ] Check logs daily: `docker compose logs -f`
- [ ] Verify players can connect
- [ ] Check that backups run (daily at 2 AM)
- [ ] Confirm chunk cleanup runs (Sunday at 3 AM)

## 🎉 Post-Migration (After 1 week)

Once you're confident the migration is successful:

### Cleanup (Optional)
```bash
# Remove old backup files
rm docker-compose.old.yml
rm .env.old

# Remove custom image directory (CAUTION: only if you're sure!)
# This will remove the custom Dockerfile and scripts
# git rm -r minecraft-modpack/
```

- [ ] Old config files removed (optional)
- [ ] Custom image directory removed (optional)

### Update .gitignore
Add these lines to `.gitignore`:
```
docker-compose.old.yml
.env.old
.env.test
```

- [ ] .gitignore updated

### Documentation
- [ ] Update any personal notes or documentation
- [ ] Share success story (optional!)

## 🔄 Rollback (If Needed)

If you encounter issues and need to rollback:

```bash
# Stop current setup
docker compose down

# Restore old configuration
cp docker-compose.old.yml docker-compose.yml
cp .env.old .env

# Start with old image
docker compose up -d
```

Your `./data/` directory is compatible with both versions, so no data loss!

## ❓ Troubleshooting

If you encounter issues, check:

1. **Logs**: `docker compose logs minecraft-modpack`
2. **MODPACK_URL**: Verify it's accessible with `curl -I "${MODPACK_URL}"`
3. **Server Type**: May need to set TYPE explicitly (FORGE, FABRIC, NEOFORGE)
4. **Memory**: May need to increase MEMORY setting
5. **Documentation**: See [MIGRATION-GUIDE.md](docs/MIGRATION-GUIDE.md) troubleshooting section

## 📞 Getting Help

- **itzg Documentation**: https://docker-minecraft-server.readthedocs.io/
- **itzg GitHub Issues**: https://github.com/itzg/docker-minecraft-server/issues
- **itzg Discord**: https://discord.gg/ScbTrAw
- **Your Documentation**: 
  - [ANSWER.md](docs/ANSWER.md)
  - [MIGRATION-GUIDE.md](docs/MIGRATION-GUIDE.md)
  - [ITZG-MIGRATION-ANALYSIS.md](docs/ITZG-MIGRATION-ANALYSIS.md)

## 📋 Summary

**Total Time**: ~1 hour (including testing)
**Difficulty**: Easy to Moderate
**Reversible**: Yes (easy rollback)
**Risk**: Low (backups created first)

**Recommendation**: Proceed with migration! The benefits far outweigh the minimal effort required.

---

Good luck with your migration! 🚀
