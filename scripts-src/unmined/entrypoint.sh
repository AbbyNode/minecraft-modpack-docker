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
    # Install cron if not present
    if ! command -v cron &> /dev/null; then
        echo "Installing cron..."
        apt-get update -qq
        apt-get install -y -qq cron
    fi

    # Set up cron job to run map generation every hour
    echo "Setting up cron job for hourly map generation..."
    echo "0 * * * * /scripts/unmined/generate-map.sh >> /var/log/unmined-cron.log 2>&1" > /etc/cron.d/unmined-map-gen
    chmod 0644 /etc/cron.d/unmined-map-gen
    
    # Create log file
    touch /var/log/unmined-cron.log
    
    # Load the cron job
    crontab /etc/cron.d/unmined-map-gen
    
    echo "Unmined is ready. Map generation will run every hour."
    echo "Manual run: docker exec unmined-generator /scripts/unmined/generate-map.sh"
    echo "Cron log: docker exec unmined-generator cat /var/log/unmined-cron.log"
    
    # Start cron in foreground mode to keep container running
    cron -f
fi
