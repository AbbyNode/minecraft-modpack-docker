#!/bin/bash
set -e

# If the Unmined CLI binary does not exist, run the init script to download it
if [ ! -f /unmined/unmined-cli ]; then
    echo "Unmined CLI binary not found. Running initialization script."
    /scripts/common/install-basics.sh
    /scripts/unmined/init.sh
fi

# If a command was provided, execute it
if (( $# > 0 )); then
    exec "$@"
else
    # Keep container running for manual or external triggers
    # However, allow docker compose down to stop the container gracefully
    echo "Unmined is ready. Trigger jobs manually as needed."
    echo "Manual run: docker exec unmined /scripts/unmined/generate-map.sh"
    tail -f /dev/null
fi
