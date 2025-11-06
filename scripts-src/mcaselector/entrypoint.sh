#!/bin/bash
set -e

# If the MCASelector jar does not exist, run the init script to download it
if [ ! -f /mcaselector/mcaselector.jar ]; then
    echo "MCASelector jar not found. Running initialization script."
    /scripts/common/install-basics.sh
    /scripts/mcaselector/init.sh
fi

# If a command was provided, execute it
if [ $# -gt 0 ]; then
    exec "$@"
else
    # Keep container running for manual or external triggers
    # However, allow docker compose down to stop the container gracefully
    echo "MCASelector is ready. Trigger jobs manually as needed."
    echo "Manual run: docker exec mcaselector /scripts/delete-chunks.sh"
    tail -f /dev/null
fi
