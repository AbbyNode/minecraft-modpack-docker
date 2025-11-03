# Unmined Map Generator

This module provides automated Minecraft world map generation using [Unmined](https://unmined.net/).

## Features

- Generates interactive web-based maps of your Minecraft world
- Maps are viewable in any web browser
- Supports incremental updates (only new/changed regions are re-rendered)
- Works with both Java and Bedrock editions
- Can be scheduled for automatic generation

## Building the Image

### Standard Build

If you have access to unmined.net:

```bash
docker build -t eclarift/unmined:latest ./unmined
```

### Alternative Build (Restricted Environments)

If unmined.net is blocked in your environment:

1. Download Unmined CLI manually:
   ```bash
   curl -L "https://unmined.net/download/unmined-cli-linux-x64-dev.gz" -o unmined/unmined-cli.gz
   ```

2. Edit the `Dockerfile`:
   - Comment out the `RUN curl...` lines (lines 22-27)
   - Uncomment the `COPY unmined-cli.gz` line (line 21)

3. Build the image:
   ```bash
   docker build -t eclarift/unmined:latest ./unmined
   ```

## Usage

### Manual Map Generation

Generate a map on demand:

```bash
docker exec unmined /scripts/render-map.sh
```

The generated map will be available in `./data/unmined-map/`. Open `unmined.index.html` in a web browser to view it.

### Automatic Map Generation

To enable automatic map generation:

1. Edit `ofelia/config.ini`
2. Uncomment the `[job-exec "unmined-render"]` section
3. Customize the schedule if desired (default: daily at 4 AM)
4. Restart Ofelia:
   ```bash
   docker compose restart ofelia
   ```

**Note:** Map generation can take a long time for large worlds.

### Incremental Updates

If you regenerate the map, Unmined will only render new or changed regions, making updates much faster than the initial generation.

## Configuration

The Unmined container mounts:
- `/world` - Your Minecraft world directory (read-only)
- `/output` - Generated map output directory (`./data/unmined-map/`)

## More Information

- [Unmined Official Website](https://unmined.net/)
- [Unmined CLI Documentation](https://unmined.net/docs/cli/)
- [Getting Started Guide](https://unmined.net/docs/cli/getting-started/)
