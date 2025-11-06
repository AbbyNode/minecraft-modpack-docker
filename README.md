# Minecraft Modded Server

Run a Minecraft modded server with automated backups and chunk cleanup. Uses [itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server) as the base with CurseForge URL resolution.

## Quick Start

Download compose file

```bash
curl -O https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/docker-compose.yml
```

Run setup container (creates .env, directories, and extracts scripts)

```bash
docker compose --profile setup run --rm setup
```

Edit `.secrets` file with your credentials

```bash
nano .secrets
```

Start the services

```bash
docker compose up -d
```

## Configuration

Edit `.env` to configure your modpack and server properties:

**Modpack URL - CurseForge page URL** (automatic resolution):

```bash
MODPACK_URL=https://www.curseforge.com/minecraft/modpacks/all-the-mods-10
```

**Modpack URL - Direct server file URL**:

```bash
MODPACK_URL=https://mediafilez.forgecdn.net/files/7121/795/ServerFiles-4.14.zip
```

## Server Management

### View Logs

```bash
docker compose logs -f server
```

### Interactive Console

```bash
docker attach server  # Ctrl+P, Ctrl+Q to detach
```

### Start/Stop

```bash
docker compose down
docker compose up --pull missing -d
```
