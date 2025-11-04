# Minecraft Modded Server

Run a Minecraft modded server with automated backups and chunk cleanup.

## Quick Start

```bash
curl -O https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/docker-compose.yml
curl -o .env https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/.env.example
docker compose pull && docker compose up -d
```

## Configuration

Edit `.env` to configure your modpack:

**Direct server file URL** (recommended):
```
MODPACK_URL=https://mediafilez.forgecdn.net/files/7121/795/ServerFiles-4.14.zip
```

**CurseForge page URL** (searches first 20 files only):
```
MODPACK_URL=https://www.curseforge.com/minecraft/modpacks/all-the-mods-10
```

**Set backup passphrase** (required for encryption):
```
BORG_PASSPHRASE=your-strong-passphrase
```

## Server Management

### View Logs
```bash
docker compose logs -f minecraft-modpack
```

### Interactive Console
```bash
docker attach minecraft-modpack  # Ctrl+P, Ctrl+Q to detach
```

### Start/Stop
```bash
docker compose down
docker compose up --pull missing -d
```

## Automated Management

This setup includes automated orchestration for backups and maintenance tasks.

### Backup System (Borgmatic)

The server automatically backs up important data using Borgmatic with BorgBackup:

**What gets backed up:**
- World data
- Server configuration
- Mods and mod configurations
- Server logs

**Backup schedule:**
- Runs daily at 2:00 AM (configurable in `ofelia/config.ini`)

**Retention policy:**
- 7 daily backups
- 4 weekly backups
- 6 monthly backups

**Backup location:**
- Local: `./data/backups/borg-repository`

**Manual backup:**
```bash
# Manual backup
docker exec borgmatic /scripts/backup.sh

# List backups
docker exec borgmatic borgmatic list

# Restore
docker exec borgmatic borgmatic extract --archive <name> --destination /tmp/restore
docker cp borgmatic:/tmp/restore ./restore/
```

**Configuration:** `./data/config/borgmatic/config.yaml` (auto-created on first run)

### Chunk Cleanup (Daily 7:00 AM)
Deletes old chunks based on age and player activity to save disk space.

**Default rules:**
- Not updated in 30 days + <2 hours player time
- Not updated in 7 days + <1 hour player time
- Not updated in 12 hours + <15 minutes player time
- Not updated in 1 hour + <5 minutes player time

```bash
# Manual cleanup
docker exec mcaselector /scripts/delete-chunks.sh
```

**Configuration:**
- Edit `./data/config/mcaselector-options.yaml` to customize cleanup rules
- After first run, the configuration file will be created from the template

### Job Orchestration (Ofelia)

Ofelia manages all scheduled tasks. View job logs:

```bash
# View Ofelia logs
docker compose logs -f ofelia

# View all service logs
docker compose logs -f
```

**Customize schedules:**
Edit `ofelia/config.ini` to change when jobs run. Uses standard cron syntax:
- `@daily` - Once per day at midnight
- `@weekly` - Once per week on Sunday at midnight
- `@hourly` - Once per hour
- Custom: `0 2 * * *` - Daily at 2:00 AM

After editing, restart Ofelia:
```bash
docker compose restart ofelia
```

## Additional Documentation

- **[Architecture](docs/Architecture.md)** - System design and component overview
- **[Bind Mounts](docs/bind-mounts.md)** - Host-container path mappings
- **[MCASelector CLI](mcaselector/docs/CLI-Mode.md)** - Command-line reference
- **[Chunk Filters](mcaselector/docs/Chunk-Filter.md)** - Chunk filtering options
