FROM mcuadros/ofelia:latest

# Copy entrypoint script
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["daemon", "--config=/etc/ofelia/config.ini"]
