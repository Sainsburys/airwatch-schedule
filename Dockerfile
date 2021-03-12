FROM alpine:3.10

RUN apk add --no-cache curl
RUN apk add --no-cache jq
RUN apk add --no-cache coreutils

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
