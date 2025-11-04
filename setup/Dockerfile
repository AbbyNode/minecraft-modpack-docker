FROM alpine:latest
RUN apk add --no-cache bash

COPY ./templates /templates

COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh

ENTRYPOINT ["/scripts/init.sh"]
