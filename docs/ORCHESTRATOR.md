# Configuration Guide

## Ofelia (Job Scheduler)

**File**: `ofelia/config.ini`

```ini
[job-exec "job-name"]
schedule = 0 2 * * *              # Cron: minute hour day month weekday
container = container-name
command = /path/to/script.sh
no-overlap = true                 # Prevent concurrent runs
```

**Schedule Examples**:
- `@daily` - Midnight
- `@weekly` - Sunday midnight
- `@hourly` - Every hour
- `0 2 * * *` - Daily 2 AM
- `0 3 * * 0` - Sunday 3 AM
- `0 */6 * * *` - Every 6 hours

After editing, restart: `docker compose restart ofelia`

## Borgmatic (Backups)

**File**: `./data/config/borgmatic/config.yaml` (auto-created on first run)

**Important**: Borgmatic requires a `BORG_PASSPHRASE` environment variable to encrypt backups. This is set in your `.env` file and should be changed from the default value to a strong, unique passphrase. You will need this passphrase to restore backups.

### Key Settings

```yaml
location:
    source_directories:
        - /mnt/source/world
        - /mnt/source/config
    exclude_patterns:
        - '*.tmp'
    repositories:
        - path: /mnt/borg-repository
          label: minecraft-local

retention:
    keep_daily: 7
    keep_weekly: 4
    keep_monthly: 6

storage:
    compression: lz4              # Options: lz4, zstd, lzma, none
```

### Remote Backups

```yaml
location:
    repositories:
        - path: ssh://user@host:/path/to/repo
          label: remote
```

### Manual Operations

```bash
# Run backup now
docker exec borgmatic /scripts/backup.sh

# List backups
docker exec borgmatic borgmatic list

# Show info
docker exec borgmatic borgmatic info

# Extract files
docker exec borgmatic borgmatic extract --archive <name> --destination /tmp/restore

# Prune old backups
docker exec borgmatic borgmatic prune

# Verify integrity
docker exec borgmatic borgmatic check
```

## MCASelector (Chunk Cleanup)

**File**: `./data/config/mcaselector-options.yaml` (auto-created on first run)

### Cleanup Rules

```yaml
delete_chunks:
  - last_updated: "30 days"       # Chunk not modified in 30 days
    inhabited_time: "2 hours"     # AND less than 2 hours player time
  - last_updated: "7 days"
    inhabited_time: "1 hour"
```

Chunks matching ANY rule are deleted.

**Time Formats**: `"15 minutes"`, `"2 hours"`, `"30 days"`

### Conservative Settings
```yaml
delete_chunks:
  - last_updated: "90 days"
    inhabited_time: "5 hours"
```

### Aggressive Settings
```yaml
delete_chunks:
  - last_updated: "14 days"
    inhabited_time: "1 hour"
  - last_updated: "6 hours"
    inhabited_time: "5 minutes"
```

### Manual Operations

```bash
# Run cleanup now
docker exec mcaselector /scripts/delete-chunks.sh
```

## Monitoring

```bash
# View job execution
docker compose logs ofelia

# View service logs
docker compose logs borgmatic
docker compose logs mcaselector

# Check disk usage
du -sh ./data/backups/borg-repository
du -sh ./data/world
```

## Troubleshooting

```bash
# Restart services
docker compose restart ofelia

# View config
docker exec ofelia cat /etc/ofelia/config.ini
docker exec borgmatic cat /etc/borgmatic.d/config.yaml
docker exec mcaselector cat /config/mcaselector-options.yaml

# Test jobs manually
docker exec borgmatic /scripts/backup.sh
docker exec mcaselector /scripts/delete-chunks.sh
```
