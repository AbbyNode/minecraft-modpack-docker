# Implementation Summary

## Components

### Ofelia
- Image: `mcuadros/ofelia:latest`
- Config: `ofelia/config.ini`
- Purpose: Schedule jobs via cron syntax

### Borgmatic
- Image: `eclarift/borgmatic:latest` (custom)
- Config: `./data/config/borgmatic/config.yaml` (auto-created)
- Purpose: Encrypted incremental backups
- Storage: `./data/backups/borg-repository`

### MCASelector  
- Image: `eclarift/mcaselector:latest`
- Config: `./data/config/mcaselector-options.yaml` (auto-created)
- Purpose: Delete old chunks based on LastUpdated + InhabitedTime

## Architecture

```
Ofelia (schedules) → Borgmatic (backups) → ./data
Ofelia (schedules) → MCASelector (cleanup) → ./data/world
```

**Separation**: Ofelia = when, Borgmatic = backup logic, MCASelector = cleanup logic

## Default Schedules

| Job | Schedule | Description |
|-----|----------|-------------|
| borgmatic-backup | 0 2 * * * | Daily 2 AM backup |
| mcaselector-cleanup | 0 3 * * 0 | Sunday 3 AM cleanup |

## Files Added

```
borgmatic/
├── Dockerfile
├── scripts/{backup.sh, entrypoint.sh}
└── templates/borgmatic-config.yaml

mcaselector/
└── scripts/entrypoint.sh (updated)
└── templates/mcaselector-options.yaml (renamed from options.yml)

ofelia/
└── config.ini

docs/
├── ARCHITECTURE.md
├── GETTING-STARTED.md
├── ORCHESTRATOR.md
└── QUICK-REFERENCE.md
```

## Volume Mounts

- Borgmatic: `./data` (ro), `./data/backups/borg-repository` (rw)
- MCASelector: `./data/world` (rw), `./data/config` (rw)
- Ofelia: `/var/run/docker.sock` (ro), `./ofelia/config.ini` (ro)

## Configuration Flow

1. User edits `ofelia/config.ini` for schedules
2. User edits `./data/config/borgmatic/config.yaml` for backup settings (after first run)
3. User edits `./data/config/mcaselector-options.yaml` for cleanup rules (after first run)
