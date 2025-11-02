#!/bin/sh
set -e

# Ensure config directory exists
mkdir -p /etc/ofelia

# Link config file from mounted config directory to expected location
# This allows mounting the directory instead of the file
if [ -f /config/config.ini ]; then
    ln -sf /config/config.ini /etc/ofelia/config.ini
    echo "Linked Ofelia configuration from /config/config.ini"
else
    echo "ERROR: Ofelia configuration not found at /config/config.ini"
    exit 1
fi

# Execute the command passed to the container
exec "$@"
