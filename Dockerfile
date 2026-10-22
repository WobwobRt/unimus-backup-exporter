FROM alpine:3.24

ARG SUPERCRONIC_VERSION=v0.2.51
ARG SUPERCRONIC_SHA1SUM=1692066e350a88ff4d7d6474fe3c7a6c41ec5e89

RUN apk add --no-cache bash curl jq git openssh-client coreutils tzdata \
    && curl -fsSLo /usr/local/bin/supercronic \
       "https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64" \
    && echo "${SUPERCRONIC_SHA1SUM}  /usr/local/bin/supercronic" | sha1sum -c - \
    && chmod +x /usr/local/bin/supercronic

WORKDIR /exporter
RUN curl -sLo unimus-backup-exporter.sh \
      https://raw.githubusercontent.com/netcore-jsa/unimus-backup-exporter/main/unimus-backup-exporter.sh \
    && chmod +x unimus-backup-exporter.sh

COPY entrypoint.sh run-job.sh /exporter/
RUN chmod +x /exporter/entrypoint.sh /exporter/run-job.sh

VOLUME ["/exporter/backups"]
ENTRYPOINT ["/exporter/entrypoint.sh"]
