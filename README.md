# Minecraft Modded Server

Easy all-in-one Docker setup for hosting a modded Minecraft server.

## Features

* Uses [itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server) as base image
* Auto resolve custom server files from modpack CurseForge URL
* Chunk cleanup with mcaselector
* Web based map with unmined, hosted and tunneled for ease of use
* Coming soon: Automated backup with borgmatic

## Quick Start

### Download compose file

```bash
curl -O https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/docker-compose.yml
```

###  Run setup container

Creates .env, directories, scripts, and secrets templates.  

```bash
docker compose --profile setup run --rm -it --pull always setup
```

### Add secret values

Put raw values (no KEY= prefix) into files under `.secrets/` created from templates:

```shell
# Required
cf_api_key          # CurseForge API key

# Optional
borg_passphrase     # encryption passphrase
cloudflared_token   # tunnel token
```

### (Optional) Edit `.env`

To configure your modpack and server properties.

### Start the services

```bash
docker compose up -d
```

## Server Management

### Configuration

### Stop/Start

```bash
docker compose down
docker compose up -d
```

### View Logs

```bash
docker compose logs -f server
```

### Interactive Console

To run commands on the Minecraft server console:

```bash
docker attach server  # Ctrl+P, Ctrl+Q to detach
```

### Chunk Cleanup

To delete old chunks based on configured rules in `data/config/mcaselector/mcaselector-options.yaml`:

```bash
docker compose run --rm mcaselector
```
