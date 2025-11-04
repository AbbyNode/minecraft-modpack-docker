# Architecture

## System Overview

```mermaid
graph TB
    Ofelia[Ofelia<br/>Job Scheduler]
    Borgmatic[Borgmatic<br/>Backup Service]
    MCASelector[MCASelector<br/>Chunk Cleanup]
    Minecraft[Minecraft Server]
    
    Ofelia -->|Daily 7AM| Borgmatic
    Ofelia -->|Daily 7AM| MCASelector
    
    Borgmatic -.->|Reads| Data[(./data)]
    MCASelector -.->|Modifies| World[(./data/world)]
    Minecraft -->|Generates| Data
    Minecraft -->|Generates| World
    
    Borgmatic -->|Writes| Backups[(./data/backups)]
```

## Components

| Component | Image | Config Location |
|-----------|-------|-----------------|
| Ofelia | `mcuadros/ofelia:latest` | `ofelia/config.ini` |
| Borgmatic | `eclarift/borgmatic:latest` | `./data/config/borgmatic/config.yaml` |
| MCASelector | `eclarift/mcaselector:latest` | `./data/config/mcaselector-options.yaml` |

## Custom Docker Images

Custom images are built for Borgmatic and MCASelector to include project-specific scripts and templates:

```
borgmatic/
├── Dockerfile
├── scripts/{backup.sh, entrypoint.sh}
└── templates/borgmatic-config.yaml

mcaselector/
├── scripts/entrypoint.sh
└── templates/mcaselector-options.yaml
```
