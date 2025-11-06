#!/bin/bash
set -e

# If a command was provided, execute it
if (( $# > 0 )); then
    exec "$@"
else
    # Keep container running for manual or external triggers
    echo "Unmined is ready. Trigger jobs manually as needed."
    echo "Manual run: docker exec unmined /scripts/generate-map.sh"
    exec tail -f /dev/null
fi
