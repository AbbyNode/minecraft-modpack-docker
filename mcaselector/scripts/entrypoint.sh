#!/bin/bash

# Ensure config file exists
if [ ! -f /config/mcaselector-options.yaml ]; then
    echo "Copying default mcaselector configuration..."
    cp /templates/mcaselector-options.yaml /config/mcaselector-options.yaml
fi

# If a command was provided, execute it
if [ $# -gt 0 ]; then
    exec "$@"
else
    # Keep container running for Ofelia to execute jobs
    echo "MCASelector is ready. Jobs are scheduled via Ofelia."
    echo "Manual run: docker exec mcaselector /scripts/delete-chunks.sh"
    exec tail -f /dev/null
fi
