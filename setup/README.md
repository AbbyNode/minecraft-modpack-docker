# Setup Container

This directory contains the setup/orchestrator container that handles initialization tasks for the Minecraft modpack Docker environment.

## Purpose

The setup container provides version-controlled initialization scripts that:
- Create `.env` file from `.env.example` if it doesn't exist
- Create required directory structure
- Provide wrapper scripts for services that need setup logic

## Benefits

1. **Version Controlled**: All setup logic is in the repository and can be updated via git
2. **Cross-Platform**: Runs in a container, works on any platform with Docker
3. **No Inline Bash**: Keeps docker-compose.yml clean and declarative
4. **Updatable**: Users get script updates when they pull the latest images

## Usage

### First Time Setup

Run the setup container before starting other services:

```bash
docker compose --profile setup run --rm setup
```

This will:
- Create `.env` from `.env.example`
- Create required directories (`data/world`, `data/config`, etc.)
- Display confirmation when complete

### Normal Usage

After initial setup, just start the services normally:

```bash
docker compose up -d
```

### Re-running Setup

You can safely re-run the setup container anytime. It will:
- Skip creating `.env` if it already exists
- Create any missing directories
- Not overwrite existing data

## Scripts

### `scripts/init.sh`

Main initialization script that runs when the setup container starts.

### `scripts/ofelia-entrypoint.sh`

Wrapper script for Ofelia that creates necessary symlinks before starting the daemon. This script is mounted into the Ofelia container, keeping the setup logic version-controlled while using the official Ofelia image.

## Architecture

The setup container uses a lightweight Alpine Linux base image with the initialization scripts baked in. The container:
- Mounts the repository root as `/workspace`
- Runs the init script
- Exits after completion (does not stay running)

Wrapper scripts (like `ofelia-entrypoint.sh`) are mounted into their respective service containers, allowing them to use official images while still having version-controlled setup logic.
