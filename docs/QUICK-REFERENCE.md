# Quick Reference Guide

## Daily Tasks

### Check Job Status
```bash
# View recent job executions
docker compose logs --tail 50 ofelia

# Check if services are running
docker compose ps
```

### Manual Backup
```bash
# Run backup now
docker exec borgmatic /scripts/backup.sh

# List all backups
docker exec borgmatic borgmatic list
```

### Manual Chunk Cleanup
```bash
# Run cleanup now
docker exec mcaselector /scripts/delete-chunks.sh
```

## Common Configurations

### Change Backup Schedule

Edit `ofelia/config.ini`:
```ini
[job-exec "borgmatic-backup"]
schedule = 0 3 * * *  # Daily at 3 AM
container = borgmatic
command = /scripts/backup.sh
no-overlap = true
```

Then restart:
```bash
docker compose restart ofelia
```

### Change Retention Policy

Edit `./data/config/borgmatic/config.yaml`:
```yaml
retention:
    keep_daily: 14    # Keep 14 daily backups
    keep_weekly: 8    # Keep 8 weekly backups
    keep_monthly: 12  # Keep 12 monthly backups
```

### Adjust Chunk Cleanup Rules

Edit `./data/config/mcaselector-options.yaml`:
```yaml
delete_chunks:
  - last_updated: "30 days"
    inhabited_time: "2 hours"
```

## Backup Management

### List Backups
```bash
docker exec borgmatic borgmatic list
```

### View Backup Info
```bash
docker exec borgmatic borgmatic info --archive <archive-name>
```

### Restore Files
```bash
# Create restore directory
mkdir -p ./restore

# Extract from backup
docker exec borgmatic borgmatic extract \
  --archive <archive-name> \
  --destination /tmp/restore

# Copy restored files
docker cp borgmatic:/tmp/restore ./restore/
```

### Prune Old Backups
```bash
docker exec borgmatic borgmatic prune --stats
```

## Monitoring

### Real-time Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f borgmatic
docker compose logs -f mcaselector
docker compose logs -f ofelia
```

### Check Disk Usage
```bash
# Backup repository size
du -sh ./data/backups/borg-repository

# World size
du -sh ./data/world

# Total data size
du -sh ./data
```

## Troubleshooting

### Restart All Services
```bash
docker compose restart
```

### Restart Specific Service
```bash
docker compose restart ofelia
docker compose restart borgmatic
docker compose restart mcaselector
```

### View Service Configuration
```bash
# Ofelia config
docker exec ofelia cat /etc/ofelia/config.ini

# Borgmatic config
docker exec borgmatic cat /etc/borgmatic.d/config.yaml

# MCASelector config
docker exec mcaselector cat /config/mcaselector-options.yaml
```

### Test Job Manually
```bash
# Test backup
docker exec borgmatic /scripts/backup.sh

# Test chunk cleanup
docker exec mcaselector /scripts/delete-chunks.sh
```

## Schedule Reference

### Cron Format
```
<minute> <hour> <day-of-month> <month> <day-of-week>
```

### Common Schedules
- `0 2 * * *` - Daily at 2 AM
- `0 */6 * * *` - Every 6 hours
- `0 3 * * 0` - Sunday at 3 AM
- `0 0 1 * *` - First day of month at midnight

### Predefined Schedules
- `@daily` - Once per day at midnight
- `@weekly` - Once per week on Sunday
- `@monthly` - Once per month
- `@hourly` - Once per hour
- `@every 1h30m` - Every 1.5 hours
