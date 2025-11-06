FROM alpine:latest
RUN apk add --no-cache bash

COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh

COPY ./templates /templates

ENTRYPOINT ["/scripts/init.sh"]
