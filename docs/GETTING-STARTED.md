# Getting Started with Automated Orchestration

This guide will help you get started with the automated backup and maintenance system.

## Prerequisites

- Docker installed
- Docker Compose installed
- At least 50GB free disk space (for backups)

## Initial Setup

### 1. Download Configuration Files

```bash
# Download docker-compose.yml
curl -O https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/docker-compose.yml

# Download environment file
curl -o .env https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/.env.example

# Download Ofelia configuration
mkdir -p ofelia
curl -o ofelia/config.ini https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/ofelia/config.ini
```

### 2. Start Services

```bash
# Pull all images
docker compose pull

# Start all services
docker compose up -d
```

This will start:
- Minecraft server
- Borgmatic (backup system)
- MCASelector (chunk cleanup)
- Ofelia (job scheduler)

### 3. Verify Services are Running

```bash
# Check all services are up
docker compose ps

# Expected output:
# NAME               STATUS    PORTS
# minecraft-modpack  running   0.0.0.0:25565->25565/tcp
# borgmatic          running
# mcaselector        running
# ofelia             running
```

### 4. Initialize Backup Repository

The backup repository will be initialized automatically on first run, but you can verify:

```bash
# Check borgmatic logs
docker compose logs borgmatic

# You should see: "Repository initialized successfully"
```

## What Happens Automatically

### Daily Backups (2:00 AM)

Every day at 2:00 AM, Borgmatic will:
1. Create an encrypted, compressed backup of:
   - World data
   - Configuration files
   - Mods and mod configurations
   - Server logs
2. Store the backup in `./data/backups/borg-repository`
3. Remove old backups according to retention policy:
   - Keep 7 daily backups
   - Keep 4 weekly backups
   - Keep 6 monthly backups

### Weekly Chunk Cleanup (Sunday 3:00 AM)

Every Sunday at 3:00 AM, MCASelector will:
1. Analyze all chunks in your world
2. Delete chunks that match cleanup criteria:
   - Not updated in 30 days with <2 hours player time
   - Not updated in 7 days with <1 hour player time
   - Not updated in 12 hours with <15 minutes player time
   - Not updated in 1 hour with <5 minutes player time
3. Free up disk space

## Manual Operations

### Run Backup Now

```bash
docker exec borgmatic /scripts/backup.sh
```

### Run Chunk Cleanup Now

```bash
docker exec mcaselector /scripts/delete-chunks.sh
```

### List All Backups

```bash
docker exec borgmatic borgmatic list
```

### View Backup Details

```bash
docker exec borgmatic borgmatic info
```

## Monitoring

### View Orchestrator Logs

```bash
# Real-time logs
docker compose logs -f ofelia

# Recent logs
docker compose logs --tail 50 ofelia
```

### View All Service Logs

```bash
docker compose logs -f
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

## Customization

### Change Backup Schedule

Edit `ofelia/config.ini`:

```ini
[job-exec "borgmatic-backup"]
schedule = 0 3 * * *  # Change to 3:00 AM
container = borgmatic
command = /scripts/backup.sh
no-overlap = true
```

Then restart Ofelia:
```bash
docker compose restart ofelia
```

### Change Retention Policy

Create/edit `./data/config/borgmatic/config.yaml`:

```yaml
retention:
    keep_daily: 14    # Keep 14 daily backups
    keep_weekly: 8    # Keep 8 weekly backups
    keep_monthly: 12  # Keep 12 monthly backups
```

### Change Cleanup Rules

Create/edit `./data/config/mcaselector-options.yaml`:

```yaml
delete_chunks:
  - last_updated: "60 days"
    inhabited_time: "5 hours"
  - last_updated: "14 days"
    inhabited_time: "1 hour"
```

## Troubleshooting

### Services Not Starting

```bash
# Check service status
docker compose ps

# View service logs
docker compose logs <service-name>

# Restart specific service
docker compose restart <service-name>

# Restart all services
docker compose restart
```

### Jobs Not Running

```bash
# Check Ofelia is running
docker compose ps ofelia

# Check Ofelia logs for job execution
docker compose logs ofelia | grep "job"

# Verify Ofelia configuration
docker exec ofelia cat /etc/ofelia/config.ini

# Restart Ofelia
docker compose restart ofelia
```

### Backup Failing

```bash
# Check borgmatic logs
docker compose logs borgmatic

# Test backup manually
docker exec borgmatic /scripts/backup.sh

# Verify repository
docker exec borgmatic borgmatic check
```

### Chunk Cleanup Failing

```bash
# Check mcaselector logs
docker compose logs mcaselector

# Test cleanup manually
docker exec mcaselector /scripts/delete-chunks.sh

# Verify configuration
docker exec mcaselector cat /config/mcaselector-options.yaml
```

## Next Steps

1. **Monitor First Runs**: Watch the logs when jobs first execute
2. **Test Restore**: Verify you can restore from backups
3. **Customize Schedules**: Adjust timing to fit your needs
4. **Review Retention**: Ensure retention policy matches your requirements
5. **Check Disk Space**: Monitor backup storage growth

## Additional Resources

- [Architecture Documentation](ARCHITECTURE.md) - System design and component interactions
- [Orchestrator Configuration](ORCHESTRATOR.md) - Detailed configuration guide
- [Quick Reference](QUICK-REFERENCE.md) - Common commands and tasks
- [Implementation Summary](IMPLEMENTATION-SUMMARY.md) - Technical details

## Common Tasks Quick Reference

```bash
# View all logs
docker compose logs -f

# Run backup now
docker exec borgmatic /scripts/backup.sh

# List backups
docker exec borgmatic borgmatic list

# Run cleanup now
docker exec mcaselector /scripts/delete-chunks.sh

# Restart all services
docker compose restart

# Stop all services
docker compose down

# Start all services
docker compose up -d

# Check disk usage
du -sh ./data/backups/borg-repository
```

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the detailed documentation in the `docs/` directory
3. Check service logs for error messages
4. Open an issue on GitHub with relevant logs

## Security Notes

- Backups are encrypted with repokey-blake2
- Keep your backup encryption key secure
- The Docker socket is mounted read-only in Ofelia
- Consider remote backups for disaster recovery
- Regularly test your backup restores
