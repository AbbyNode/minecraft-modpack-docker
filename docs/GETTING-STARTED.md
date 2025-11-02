# Getting Started

## Quick Start

```bash
# Download files
curl -O https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/docker-compose.yml
curl -o .env https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/.env.example
mkdir -p ofelia
curl -o ofelia/config.ini https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/ofelia/config.ini

# Start services
docker compose pull
docker compose up -d
```

## What Runs Automatically

- **Daily 2 AM**: Backup (world, config, mods, logs) → `./data/backups/borg-repository`
- **Sunday 3 AM**: Delete old chunks based on age + player activity

## Manual Operations

```bash
# Backup now
docker exec borgmatic /scripts/backup.sh

# Cleanup now
docker exec mcaselector /scripts/delete-chunks.sh

# List backups
docker exec borgmatic borgmatic list

# View logs
docker compose logs -f ofelia
```

## Configuration

Edit these files to customize:
- `ofelia/config.ini` - Job schedules
- `./data/config/borgmatic/config.yaml` - Backup settings (created on first run)
- `./data/config/mcaselector-options.yaml` - Cleanup rules (created on first run)

After editing `ofelia/config.ini`: `docker compose restart ofelia`

## Monitoring

```bash
# Job execution
docker compose logs ofelia

# Disk usage
du -sh ./data/backups/borg-repository
du -sh ./data/world
```

## Troubleshooting

```bash
# Test jobs manually
docker exec borgmatic /scripts/backup.sh
docker exec mcaselector /scripts/delete-chunks.sh

# Check configs
docker exec ofelia cat /etc/ofelia/config.ini
docker exec borgmatic cat /etc/borgmatic.d/config.yaml

# Restart services
docker compose restart
```

## More Documentation

- [ORCHESTRATOR.md](ORCHESTRATOR.md) - Configuration reference
- [ARCHITECTURE.md](ARCHITECTURE.md) - System design
- [QUICK-REFERENCE.md](QUICK-REFERENCE.md) - Common commands
