# Setup Container

Provides initialization and wrapper scripts for the Minecraft modpack Docker environment.

## Scripts

### `scripts/init.sh`
Main initialization script. Supports two modes:
- `init` (default): Creates .env, directories, ofelia config, and extracts scripts
- `extract`: Only extracts scripts to `.minecraft-setup/`

### `scripts/ofelia-entrypoint.sh`
Wrapper for Ofelia that creates symlinks before starting the daemon. Extracted to host and mounted into the Ofelia container.

## Usage

```bash
# Initial setup
docker compose --profile setup run --rm setup

# Re-extract scripts only (e.g., after updating setup image)
docker compose --profile setup run --rm setup extract
```
