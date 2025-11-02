# Orchestrator Configuration Guide

This guide explains how to configure and customize the automated orchestration system for backups and maintenance.

## Overview

The orchestration system consists of three components:

1. **Ofelia** - Job scheduler that orchestrates all automated tasks
2. **Borgmatic** - Backup system using BorgBackup
3. **MCASelector** - Chunk cleanup tool for Minecraft worlds

## Ofelia Configuration

### Location
`ofelia/config.ini`

### Job Types

Ofelia supports executing commands in running containers using the `job-exec` type:

```ini
[job-exec "job-name"]
schedule = @daily
container = container-name
command = /path/to/script.sh
no-overlap = true
```

### Schedule Formats

**Predefined schedules:**
- `@yearly` or `@annually` - Once a year at midnight on January 1st
- `@monthly` - Once a month at midnight on the first day
- `@weekly` - Once a week at midnight on Sunday
- `@daily` or `@midnight` - Once a day at midnight
- `@hourly` - Once an hour at the beginning of the hour
- `@every <duration>` - Every duration (e.g., `@every 1h30m`)

**Cron syntax:** `<second> <minute> <hour> <day-of-month> <month> <day-of-week>`
- Seconds field is optional
- Use `*` for "every"
- Examples:
  - `0 2 * * *` - Daily at 2:00 AM
  - `0 0 3 * * 0` - Weekly on Sunday at 3:00 AM
  - `0 */6 * * *` - Every 6 hours

### Options

- `no-overlap: true` - Prevents the same job from running simultaneously
- `save-folder` - Save job output to a file
- `save-only-on-error: true` - Only save output if job fails

### Example Configuration

```ini
# Backup every day at 2 AM
[job-exec "borgmatic-backup"]
schedule = 0 2 * * *
container = borgmatic
command = /scripts/backup.sh
no-overlap = true

# Cleanup chunks every Sunday at 3 AM
[job-exec "mcaselector-cleanup"]
schedule = 0 3 * * 0
container = mcaselector
command = /scripts/delete-chunks.sh
no-overlap = true

# Prune old backups monthly
[job-exec "borgmatic-prune"]
schedule = @monthly
container = borgmatic
command = borgmatic prune --stats
no-overlap = true
```

After modifying `ofelia/config.ini`, restart Ofelia:
```bash
docker compose restart ofelia
```

## Borgmatic Configuration

### Location
`./data/config/borgmatic/config.yaml`

This file is created automatically from the template on first run. You can customize it after that.

### Basic Structure

```yaml
location:
    source_directories:
        - /mnt/source/world
        - /mnt/source/config
    
    repositories:
        - path: /mnt/borg-repository
          label: minecraft-local

retention:
    keep_daily: 7
    keep_weekly: 4
    keep_monthly: 6

storage:
    compression: lz4
```

### Common Customizations

**Add exclusion patterns:**
```yaml
location:
    exclude_patterns:
        - '*.tmp'
        - '*.log'
        - '*/.cache'
        - '/mnt/source/world/DIM*/region/*.tmp'
```

**Change compression:**
- `lz4` - Fast compression (default)
- `zstd` - Better compression ratio
- `lzma` - Best compression, slowest
- `none` - No compression

**Remote repository:**
```yaml
location:
    repositories:
        - path: ssh://user@example.com:22/path/to/repo
          label: minecraft-remote
```

**Hooks for server management:**
```yaml
hooks:
    before_backup:
        - echo "save-off" | docker attach minecraft-modpack
        - echo "save-all" | docker attach minecraft-modpack
        - sleep 5
    
    after_backup:
        - echo "save-on" | docker attach minecraft-modpack
```

### Advanced Options

**Consistency checks:**
```yaml
consistency:
    checks:
        - name: repository
          frequency: 2 weeks
        - name: archives
          frequency: 1 month
    
    check_last: 3
```

**Multiple repositories:**
```yaml
location:
    repositories:
        - path: /mnt/borg-repository
          label: local
        - path: ssh://backup@remote.com/minecraft
          label: remote
```

### Manual Operations

```bash
# Create a backup immediately
docker exec borgmatic /scripts/backup.sh

# List all backups
docker exec borgmatic borgmatic list

# View backup information
docker exec borgmatic borgmatic info

# Extract files from a backup
docker exec borgmatic borgmatic extract --archive <archive-name> --destination /tmp/restore

# Prune old backups
docker exec borgmatic borgmatic prune --stats

# Verify repository integrity
docker exec borgmatic borgmatic check --verbosity 1
```

## MCASelector Configuration

### Location
`./data/config/mcaselector-options.yaml`

This file is created automatically from the template on first run.

### Structure

```yaml
delete_chunks:
  - last_updated: "30 days"
    inhabited_time: "2 hours"
  - last_updated: "7 days"
    inhabited_time: "1 hour"
```

### Understanding the Rules

Each rule defines a condition for chunk deletion. A chunk is deleted if it matches ANY rule:

- `last_updated`: How long since the chunk was last modified
- `inhabited_time`: Total time players have spent in the chunk

**Time formats:**
- Minutes: `"15 minutes"` or `"15m"`
- Hours: `"2 hours"` or `"2h"`
- Days: `"30 days"` or `"30d"`

### Example Configurations

**Conservative (keep more chunks):**
```yaml
delete_chunks:
  - last_updated: "90 days"
    inhabited_time: "5 hours"
  - last_updated: "30 days"
    inhabited_time: "2 hours"
```

**Aggressive (delete more chunks):**
```yaml
delete_chunks:
  - last_updated: "14 days"
    inhabited_time: "1 hour"
  - last_updated: "3 days"
    inhabited_time: "30 minutes"
  - last_updated: "6 hours"
    inhabited_time: "5 minutes"
```

**Custom for specific scenarios:**
```yaml
delete_chunks:
  # Delete very old, barely visited chunks
  - last_updated: "60 days"
    inhabited_time: "10 hours"
  
  # Delete recent chunks with no player activity
  - last_updated: "7 days"
    inhabited_time: "1 minute"
  
  # Delete chunks from quick exploration
  - last_updated: "24 hours"
    inhabited_time: "2 minutes"
```

### Manual Operations

```bash
# Run chunk cleanup immediately
docker exec mcaselector /scripts/delete-chunks.sh

# View mcaselector logs
docker compose logs mcaselector
```

## Monitoring Jobs

### View Ofelia Logs

```bash
# Real-time logs
docker compose logs -f ofelia

# Last 100 lines
docker compose logs --tail 100 ofelia
```

### View Job Execution

Ofelia logs show when jobs start and complete:

```
[job "borgmatic-backup"] Running
[job "borgmatic-backup"] Completed
```

### View Service Logs

```bash
# View backup logs
docker compose logs -f borgmatic

# View cleanup logs
docker compose logs -f mcaselector

# View all logs
docker compose logs -f
```

## Troubleshooting

### Job Not Running

1. Check Ofelia is running:
   ```bash
   docker ps | grep ofelia
   ```

2. Check Ofelia configuration:
   ```bash
   docker exec ofelia cat /etc/ofelia/config.ini
   ```

3. Restart Ofelia:
   ```bash
   docker compose restart ofelia
   ```

### Backup Failing

1. Check borgmatic logs:
   ```bash
   docker compose logs borgmatic
   ```

2. Test backup manually:
   ```bash
   docker exec borgmatic /scripts/backup.sh
   ```

3. Verify repository:
   ```bash
   docker exec borgmatic borgmatic check
   ```

### Chunk Cleanup Failing

1. Check mcaselector logs:
   ```bash
   docker compose logs mcaselector
   ```

2. Test cleanup manually:
   ```bash
   docker exec mcaselector /scripts/delete-chunks.sh
   ```

3. Verify configuration:
   ```bash
   docker exec mcaselector cat /config/mcaselector-options.yaml
   ```

## Best Practices

1. **Test schedules** - Use `@every 5m` to test jobs before setting production schedules
2. **Monitor first runs** - Watch logs when jobs first execute to ensure they work correctly
3. **Regular repository checks** - Add a monthly borgmatic check job
4. **Backup before cleanup** - Ensure backups run before chunk cleanup
5. **Keep logs** - Save Ofelia and service logs for troubleshooting
6. **Test restores** - Periodically test restoring from backups
7. **Document changes** - Keep notes on configuration modifications

## Security Notes

- The Docker socket is mounted read-only in Ofelia for security
- Borgmatic uses encryption (repokey-blake2) for backup repositories
- Keep backup encryption keys secure and backed up separately
- Consider using remote repositories for disaster recovery
