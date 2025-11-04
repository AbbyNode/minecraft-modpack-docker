FROM alpine:latest
RUN apk add --no-cache bash

COPY ./templates /templates

COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh

COPY lib /opt/shared
RUN chmod +x /opt/shared/*.sh

ENTRYPOINT ["/scripts/init.sh"]
