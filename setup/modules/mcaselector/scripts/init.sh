#!/bin/sh
set -eu

# https://github.com/Querz/mcaselector

echo "========== MCSelector Setup =========="

echo "Fetching latest MCSelector release URL"
latest_url=$(
	curl -fsSL "https://api.github.com/repos/Querz/mcaselector/releases/latest" |
	jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url'
)

echo "Downloading MCSelector from $latest_url"
curl -fsSL -o mcaselector.jar "$latest_url"

echo "Setting execute permissions"
chmod +x mcaselector.jar

echo "========== MCSelector setup complete =========="
