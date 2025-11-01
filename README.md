# Minecraft Modded Server

Quick setup guide for running a Minecraft modded server with Docker.

## Setup

### Requirements

- Docker
- Docker Compose

### First Time Setup

For first time setup, run the following commands:

```bash
# Download required files
curl -O https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/docker-compose.yml
curl -o .env https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/.env.example

# Pull and Run
docker compose pull
docker compose up -d
```

### Edit `.env` to configure your modpack

Modify the values in `.env` to use a different modpack.
```
MODPACK_URL=https://mediafilez.forgecdn.net/files/7121/795/ServerFiles-4.14.zip
STARTSCRIPT=startserver.sh
```

You can usually find the server files in the Files tab of a modpack.  
https://www.curseforge.com/minecraft/modpacks/all-the-mods-10/files/7121777/additional-files

## Interacting with the server

### Log only console
To view the server logs, run:
```bash
docker compose logs -f minecraft-modpack
```

### Interactive Console
To attach to the Minecraft server console, run:
```bash
docker attach minecraft-modpack
```

Warning: Exiting the console with `Ctrl + C` will stop the server.

To detach without stopping the server, use `Ctrl + P` followed by `Ctrl + Q`.

### Stopping the server

To stop the server, run:

```bash
docker compose down
```

### Subsequent runs

When you want to start the server again, run:

```bash
docker compose up --pull missing -d
```
