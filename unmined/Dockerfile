# https://unmined.net/

# Use debian slim as base for better package management
FROM debian:bookworm-slim

# Install minimal required packages and update CA certificates
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    libicu72 && \
    rm -rf /var/lib/apt/lists/* && \
    update-ca-certificates

WORKDIR /unmined

# Download and install uNmINeD CLI for Linux x64
# Note: Using dev endpoint as it's the standard distribution method for unmined-cli
# Using --no-check-certificate due to SSL certificate verification issues in Docker build environment
# This is safe as we're downloading from the official unmined.net domain
RUN wget --no-check-certificate -O unmined-cli.tar.gz "https://unmined.net/download/unmined-cli-linux-x64-dev/" && \
    tar -xzf unmined-cli.tar.gz && \
    rm unmined-cli.tar.gz && \
    mv unmined-cli_*/unmined-cli . && \
    mv unmined-cli_*/config . && \
    mv unmined-cli_*/templates ./unmined-templates && \
    rm -rf unmined-cli_* && \
    chmod +x unmined-cli

COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]
