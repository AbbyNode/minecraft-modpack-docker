# Minecraft Modded Server

Quick setup guide for running a Minecraft modded server with Docker.

## Setup

```bash
# Download required files
curl -O https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/docker-compose.yml
curl -o .env https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/.env.example

# Run
docker compose pull
docker compose up -d

# Show logs
docker compose logs -f minecraft-modpack
```

## Subsequent runs

```bash
docker compose up --pull missing -d
```

## Edit `.env` to configure your modpack:

Modify the values in `.env` to use a different modpack.
```
MODPACK_URL=https://mediafilez.forgecdn.net/files/7121/795/ServerFiles-4.14.zip
STARTSCRIPT=startserver.sh
```

You can usually find the server files in the Files tab of a modpack.
https://www.curseforge.com/minecraft/modpacks/all-the-mods-10/files/7121777/additional-files
