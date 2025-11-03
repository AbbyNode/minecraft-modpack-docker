#!/bin/bash
set -e

echo "Unmined is ready to generate Minecraft world maps."
echo "Manual run: docker exec unmined /scripts/render-map.sh"
echo ""
echo "The generated web map will be available in /output directory"
echo "Open unmined.index.html in a web browser to view the map"

# If a command was provided, execute it
if [ $# -gt 0 ]; then
    exec "$@"
else
    # Keep container running for Ofelia to execute jobs or manual execution
    exec tail -f /dev/null
fi
