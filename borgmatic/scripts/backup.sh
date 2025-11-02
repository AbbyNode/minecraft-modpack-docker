#!/bin/bash
set -e

echo "======================================"
echo "Starting Borgmatic Backup"
echo "Time: $(date)"
echo "======================================"

# Run borgmatic backup with stats and verbosity
borgmatic --stats --verbosity 1 --files

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "======================================"
    echo "Backup completed successfully"
    echo "Time: $(date)"
    echo "======================================"
else
    echo "======================================"
    echo "Backup failed with exit code: $EXIT_CODE"
    echo "Time: $(date)"
    echo "======================================"
    exit $EXIT_CODE
fi
