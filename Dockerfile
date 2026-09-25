FROM alpine:3.20

RUN apk add --no-cache bash curl jq git openssh-client coreutils

WORKDIR /exporter

# Pull the exporter scripts at build time
RUN curl -sLo unimus-backup-exporter.sh \
      https://raw.githubusercontent.com/netcore-jsa/unimus-backup-exporter/main/unimus-backup-exporter.sh \
    && chmod +x unimus-backup-exporter.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/exporter/backups"]
ENTRYPOINT ["/entrypoint.sh"]
