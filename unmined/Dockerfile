# https://unmined.net/

# Use debian slim as base for better package management
FROM debian:bookworm-slim

# Install minimal required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /unmined

# Download and install uNmINeD CLI for Linux x64
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

COPY ./templates /templates

ENTRYPOINT ["/scripts/entrypoint.sh"]
