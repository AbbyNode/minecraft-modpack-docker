# Configuration Guide

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

### Cleanup Rules

```yaml
delete_chunks:
  - last_updated: "30 days"       # Chunk not modified in 30 days
    inhabited_time: "2 hours"     # AND less than 2 hours player time
  - last_updated: "7 days"
    inhabited_time: "1 hour"
```

Chunks matching ANY rule are deleted.

### Manual Operations

```bash
# Run cleanup now
docker exec mcaselector /scripts/delete-chunks.sh
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
