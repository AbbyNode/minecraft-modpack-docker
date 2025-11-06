# Minecraft Modded Server

Easy all-in-one Docker setup for hosting a modded Minecraft server.

## Features

* Uses [itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server) as base image
* Auto resolve custom server files from modpack CurseForge URL
* Chunk cleanup with mcaselector
* Web based map with unmined, hosted and tunneled for ease of use
* Coming soon: Automated backup with borgmatic

## Quick Start

Download compose file

```bash
curl -O https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/docker-compose.yml
```

Run setup container (creates .env, directories, and extracts scripts)  

```bash
docker compose --profile setup run --rm -it --pull always setup
```

(Optional) Edit `.secrets` to add 

(Optional) Edit `.env` to configure your modpack and server properties.

Start the services

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
