# https://unmined.net/
# Minecraft world mapper - generates web-based interactive maps

FROM alpine:latest

# Install required dependencies
RUN apk add --no-cache \
    bash \
    curl \
    ca-certificates

WORKDIR /unmined

# Download and install Unmined CLI (Linux musl x64)
# Using the DEV channel for latest version
RUN \
    curl -L "https://unmined.net/download/unmined-cli-linux-musl-x64-dev.gz" -o unmined-cli.gz && \
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
