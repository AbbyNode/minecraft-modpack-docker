# Setup Container

Provides initialization and wrapper scripts for the Minecraft modpack Docker environment.

## Scripts

### `scripts/init.sh`
Main initialization script that creates .env, directories, ofelia config, and extracts scripts to `data/setup-scripts/`.

### `scripts/ofelia-entrypoint.sh`
Wrapper for Ofelia that creates symlinks before starting the daemon. Extracted to host and mounted into the Ofelia container.

## Templates

### `templates/.env.example`
Environment configuration template (from repository's .env.example).

### `templates/ofelia-config.ini`
Default Ofelia job configuration for scheduled tasks.

## Usage

```bash
# Initial setup
docker compose --profile setup run --rm setup
```
