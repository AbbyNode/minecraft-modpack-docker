# https://unmined.net/
# Minecraft world mapper - generates web-based interactive maps

# Use Debian slim instead of Alpine for better package availability
FROM debian:bookworm-slim

# Install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    ca-certificates \
    gzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /unmined

# Download and install Unmined CLI (Linux glibc x64 for Debian/Ubuntu)
# Using the DEV channel for latest version
# 
# If building in a restricted environment, you can manually download the file:
#   curl -L "https://unmined.net/download/unmined-cli-linux-x64-dev.gz" -o unmined-cli.gz
# Then UNCOMMENT the COPY line below AND COMMENT OUT the RUN curl command:
# COPY unmined-cli.gz /unmined/unmined-cli.gz
#
RUN \
    curl -L "https://unmined.net/download/unmined-cli-linux-x64-dev.gz" -o unmined-cli.gz && \
    gunzip unmined-cli.gz && \
    chmod +x unmined-cli && \
    mv unmined-cli /usr/local/bin/unmined-cli && \
    echo "Unmined CLI installed successfully"

# Verify installation
RUN unmined-cli --help

# Copy scripts
COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh

# Copy templates
COPY ./templates /templates

ENTRYPOINT ["/scripts/entrypoint.sh"]
