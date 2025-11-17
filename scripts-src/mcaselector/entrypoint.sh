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
    # Run delete-chunks.sh script by default
    echo "Running chunk deletion script..."
    exec /scripts/mcaselector/delete-chunks.sh
fi
