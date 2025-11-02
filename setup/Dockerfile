FROM alpine:latest

# Copy setup scripts
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

WORKDIR /workspace

ENTRYPOINT ["/scripts/init.sh"]
