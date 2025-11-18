#!/bin/bash
set -eu

echo "========== Container Setup =========="

apt-get update
apt-get install -y --no-install-recommends curl jq
apt-get clean
rm -rf /var/lib/apt/lists/*
