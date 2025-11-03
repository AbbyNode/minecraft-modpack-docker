#!/bin/bash
set -e

echo "===================="
echo "Unmined Map Renderer"
echo "===================="
echo ""

# Check if world directory exists
if [ ! -d /world ]; then
    echo "ERROR: World directory not found at /world"
    echo "Please mount the Minecraft world directory to /world"
    exit 1
fi

# Check if level.dat exists
if [ ! -f /world/level.dat ]; then
    echo "ERROR: level.dat not found in /world"
    echo "Please ensure /world points to a valid Minecraft world directory"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p /output

# Check if output directory is empty (excluding hidden files)
if [ -n "$(ls -A /output 2>/dev/null | grep -v '^\..*')" ]; then
    echo "WARNING: Output directory is not empty. Existing map will be updated."
    echo "Only new or changed regions will be rendered."
else
    echo "Output directory is empty. Starting fresh render."
fi

echo ""
echo "Starting map generation..."
echo "World: /world"
echo "Output: /output"
echo ""

# Run Unmined CLI to generate web map
# --world: path to Minecraft world directory
# --output: path to output directory for web map
unmined-cli web render \
    --world=/world \
    --output=/output

echo ""
echo "===================="
echo "Map generation complete!"
echo "===================="
echo "Open /output/unmined.index.html in a web browser to view the map"
