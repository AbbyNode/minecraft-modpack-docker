# Minecraft Modded Server

Quick setup guide for running a Minecraft modded server with Docker.

## Setup

### Requirements

- Docker
- Docker Compose

### First Time Setup

For first time setup, run the following commands:

```bash
# Download required files
curl -O https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/docker-compose.yml
curl -o .env https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/.env.example

# Pull and Run
docker compose pull
docker compose up -d
```

### Edit `.env` to configure your modpack

Modify the values in `.env` to use a different modpack.
```
MODPACK_URL=https://mediafilez.forgecdn.net/files/7121/795/ServerFiles-4.14.zip
STARTSCRIPT=startserver.sh
```

You can usually find the server files in the Files tab of a modpack.  
https://www.curseforge.com/minecraft/modpacks/all-the-mods-10/files/7121777/additional-files

## Interacting with the server

### Log only console
To view the server logs, run:
```bash
docker compose logs -f minecraft-modpack
```

### Interactive Console
To attach to the Minecraft server console, run:
```bash
docker attach minecraft-modpack
```

Warning: Exiting the console with `Ctrl + C` will stop the server.

To detach without stopping the server, use `Ctrl + P` followed by `Ctrl + Q`.

### Stopping the server

To stop the server, run:

```bash
docker compose down
```

### Subsequent runs

When you want to start the server again, run:

```bash
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
# Run a backup immediately
docker exec borgmatic /scripts/backup.sh

# List all backups
docker exec borgmatic borgmatic list

# View backup info
docker exec borgmatic borgmatic info
```

**Configuration:**
- Edit `./data/config/borgmatic/config.yaml` to customize backup settings
- After first run, the configuration file will be created from the template

### Chunk Cleanup (MCASelector)

Old, unused chunks are automatically deleted to save disk space:

**Cleanup schedule:**
- Runs weekly on Sunday at 3:00 AM (configurable in `ofelia/config.ini`)

**Default cleanup rules:**
Chunks are deleted based on a combination of LastUpdated and InhabitedTime:
- Chunks not updated in 30 days with less than 2 hours of player time
- Chunks not updated in 7 days with less than 1 hour of player time
- Chunks not updated in 12 hours with less than 15 minutes of player time
- Chunks not updated in 1 hour with less than 5 minutes of player time

**Manual cleanup:**
```bash
# Run chunk cleanup immediately
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

## Documentation

- **[Orchestrator Configuration Guide](docs/ORCHESTRATOR.md)** - Detailed configuration options for Ofelia, Borgmatic, and MCASelector
- **[Quick Reference Guide](docs/QUICK-REFERENCE.md)** - Common commands and tasks
- **[MCASelector CLI Mode](mcaselector/docs/CLI-Mode.md)** - MCASelector command-line documentation
- **[Chunk Filter Guide](mcaselector/docs/Chunk-Filter.md)** - Understanding chunk filtering options
