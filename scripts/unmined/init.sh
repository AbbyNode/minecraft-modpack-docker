#!/bin/bash
set -eu

# https://unmined.net/

echo "========== Unmined CLI Setup =========="

mkdir -p /unmined
cd /unmined

echo "Downloading Unmined CLI"
curl -fL --progress-bar -o unmined-cli.tar.gz "https://unmined.net/download/unmined-cli-linux-x64-dev/"

echo "Extracting Unmined CLI"
tar -xzf unmined-cli.tar.gz
rm -f unmined-cli.tar.gz

echo "Setting execute permissions"
chmod +x unmined-cli_*/unmined-cli

echo "Creating symlink to unmined-cli"
# Find the extracted directory (there should be only one after fresh download)
CLI_DIR=$(ls -d unmined-cli_* | head -n1)
ln -sf "$(pwd)/${CLI_DIR}/unmined-cli" /unmined/unmined-cli

echo "========== Unmined CLI setup complete =========="
