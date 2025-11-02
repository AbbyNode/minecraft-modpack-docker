# Architecture Overview

## System Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     Docker Compose Stack                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐                                              │
│  │    Ofelia    │  Job Scheduler (Orchestrator)                │
│  │  (mcuadros)  │                                              │
│  └──────┬───────┘                                              │
│         │                                                       │
│         │ Schedules & Executes                                 │
│         │                                                       │
│    ┌────┴─────────────────────────────┐                        │
│    │                                  │                        │
│    ▼                                  ▼                        │
│  ┌─────────────────┐          ┌─────────────────┐             │
│  │   Borgmatic     │          │   MCASelector   │             │
│  │   (Backups)     │          │  (Chunk Cleanup)│             │
│  └────────┬────────┘          └────────┬────────┘             │
│           │                            │                       │
│           │ Reads                      │ Modifies              │
│           │                            │                       │
│           ▼                            ▼                       │
│  ┌─────────────────────────────────────────────┐              │
│  │         Shared Data Volumes                 │              │
│  │  ┌────────┬─────────┬──────────┬─────────┐ │              │
│  │  │ World  │ Config  │   Mods   │  Logs   │ │              │
│  │  └────────┴─────────┴──────────┴─────────┘ │              │
│  └─────────────────────────────────────────────┘              │
│           ▲                                                    │
│           │ Generates                                          │
│           │                                                    │
│  ┌────────┴────────┐                                          │
│  │  Minecraft      │                                          │
│  │  Modpack Server │                                          │
│  └─────────────────┘                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Component Interactions

### 1. Ofelia (Orchestrator)
**Role**: Central job scheduler
**Responsibilities**:
- Monitor time and trigger scheduled jobs
- Execute commands in other containers
- Prevent job overlap
- Log job execution

**Interactions**:
- Reads: Docker socket, config.ini
- Executes: Commands in borgmatic and mcaselector containers
- No direct file system access

### 2. Borgmatic (Backup System)
**Role**: Backup manager
**Responsibilities**:
- Create incremental backups
- Manage retention policies
- Compress and encrypt backups
- Verify backup integrity

**Interactions**:
- Reads: /mnt/source (world, config, mods, logs) - Read-only
- Writes: /mnt/borg-repository (backup storage)
- Triggered by: Ofelia (scheduled) or manual execution
- Dependencies: None (can run independently)

### 3. MCASelector (Chunk Cleanup)
**Role**: World maintenance
**Responsibilities**:
- Analyze chunk usage
- Delete old, unused chunks
- Free up disk space

**Interactions**:
- Reads/Writes: /world (Minecraft world data)
- Reads: /config/mcaselector-options.yaml
- Triggered by: Ofelia (scheduled) or manual execution
- Dependencies: None (can run independently)

### 4. Minecraft Server
**Role**: Game server
**Responsibilities**:
- Run Minecraft modpack
- Generate world data
- Create logs and configuration

**Interactions**:
- Generates: World data, logs, configuration
- Independent of orchestration system
- Benefits from automated backups and cleanup

## Data Flow

### Backup Flow
```
1. Ofelia triggers borgmatic at 2:00 AM daily
2. Borgmatic reads source data (read-only)
3. Borgmatic creates compressed, encrypted backup
4. Backup stored in borg-repository
5. Old backups pruned according to retention policy
6. Success/failure logged
```

### Cleanup Flow
```
1. Ofelia triggers mcaselector at 3:00 AM Sunday
2. MCASelector reads configuration
3. MCASelector analyzes chunks in world data
4. Chunks matching deletion criteria are removed
5. World data size reduced
6. Success/failure logged
```

## Configuration Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Configuration Files                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ofelia/config.ini                                          │
│  ├─ Defines WHEN jobs run (schedules)                      │
│  ├─ Defines WHICH container to execute in                  │
│  └─ Defines WHAT command to run                            │
│                                                             │
│  ./data/config/borgmatic/config.yaml                        │
│  ├─ Defines WHAT to backup (source directories)            │
│  ├─ Defines WHERE to store backups (repository)            │
│  ├─ Defines HOW LONG to keep backups (retention)           │
│  └─ Defines HOW to backup (compression, encryption)        │
│                                                             │
│  ./data/config/mcaselector-options.yaml                     │
│  ├─ Defines WHICH chunks to delete (criteria)              │
│  └─ Defines WHEN chunks are considered old                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Volume Mounts

### Borgmatic
```
./data                        → /mnt/source (ro)    # Source data to backup
./data/backups/borg-repository → /mnt/borg-repository # Backup storage
./data/config/borgmatic       → /etc/borgmatic.d     # Configuration
borgmatic-config (volume)     → /root/.config/borg   # Borg config state
borgmatic-cache (volume)      → /root/.cache/borg    # Borg cache
borgmatic-state (volume)      → /root/.local/state   # Borgmatic state
```

### MCASelector
```
./data/world  → /world   # Minecraft world (read-write)
./data/config → /config  # Configuration (read-only)
```

### Ofelia
```
/var/run/docker.sock    → /var/run/docker.sock (ro) # Docker control
./ofelia/config.ini     → /etc/ofelia/config.ini (ro) # Job schedules
```

## Security Considerations

1. **Read-only mounts**: Borgmatic uses read-only mount for source data
2. **Docker socket**: Ofelia has read-only access to Docker socket
3. **Encryption**: Borgmatic uses repokey-blake2 encryption
4. **Isolation**: Each service runs in its own container
5. **No privileged access**: No containers require privileged mode

## Scalability

### Easy to Add More Jobs
```ini
# In ofelia/config.ini
[job-exec "new-job"]
schedule = 0 4 * * *
container = some-container
command = /path/to/script.sh
no-overlap = true
```

### Easy to Add More Backups
```yaml
# In borgmatic-config.yaml
location:
    repositories:
        - path: /mnt/borg-repository
          label: local
        - path: ssh://user@remote:/backups
          label: remote
```

### Easy to Customize Schedules
```ini
# Change from daily to every 6 hours
schedule = 0 */6 * * *

# Change from weekly to bi-weekly
schedule = 0 3 */14 * *
```

## Failure Handling

### Job Failure
- Logged to container logs
- Ofelia continues with other jobs
- No impact on other services
- Can retry manually

### Container Failure
- Docker restart policy: `unless-stopped`
- Ofelia will reconnect when container restarts
- Jobs resume on next schedule

### Disk Space Issues
- Borgmatic prunes old backups automatically
- MCASelector frees space by deleting chunks
- Monitor with: `docker exec borgmatic borgmatic list`

## Monitoring Points

### Check Job Execution
```bash
docker compose logs ofelia
# Look for: [job "name"] Running
# Look for: [job "name"] Completed
```

### Check Backup Status
```bash
docker exec borgmatic borgmatic list
docker exec borgmatic borgmatic info
```

### Check Disk Usage
```bash
du -sh ./data/backups/borg-repository
du -sh ./data/world
```

### Check Service Health
```bash
docker compose ps
docker compose logs -f
```

## Design Principles Applied

1. **Separation of Concerns**: Each component has one clear responsibility
2. **Modularity**: Components can be enabled/disabled independently
3. **Configuration over Code**: Behavior controlled by configuration files
4. **Fail-Safe Defaults**: Safe, sensible defaults that work out of the box
5. **Observability**: All operations logged for debugging
6. **Idempotency**: Jobs can be run multiple times safely
7. **No-Overlap**: Jobs won't run concurrently
8. **Documentation**: Comprehensive guides for all use cases
