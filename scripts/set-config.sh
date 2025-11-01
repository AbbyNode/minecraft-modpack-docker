#!/bin/bash
set -e

# Path to the server.properties file
SERVER_PROPERTIES_FILE="/minecraft/server.properties"

# Check if the server.properties file exists
if [ ! -f "$SERVER_PROPERTIES_FILE" ]; then
    echo "server.properties file not found at $SERVER_PROPERTIES_FILE. Exiting."
    exit 1
fi

echo "Updating server.properties with new values..."

# Update the specified properties in the server.properties file
sed -i 's/^allow-flight=.*/allow-flight=true/' "$SERVER_PROPERTIES_FILE"
sed -i 's/^difficulty=.*/difficulty=normal/' "$SERVER_PROPERTIES_FILE"
sed -i 's/^enforce-whitelist=.*/enforce-whitelist=true/' "$SERVER_PROPERTIES_FILE"
sed -i 's/^force-gamemode=.*/force-gamemode=false/' "$SERVER_PROPERTIES_FILE"
sed -i 's/^gamemode=.*/gamemode=survival/' "$SERVER_PROPERTIES_FILE"
sed -i 's/^pvp=.*/pvp=false/' "$SERVER_PROPERTIES_FILE"
sed -i 's/^simulation-distance=.*/simulation-distance=16/' "$SERVER_PROPERTIES_FILE"
sed -i 's/^spawn-protection=.*/spawn-protection=0/' "$SERVER_PROPERTIES_FILE"
sed -i 's/^view-distance=.*/view-distance=16/' "$SERVER_PROPERTIES_FILE"
sed -i 's/^white-list=.*/white-list=true/' "$SERVER_PROPERTIES_FILE"

echo "server.properties updated successfully!"
