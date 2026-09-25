FROM alpine:3.24

ARG SUPERCRONIC_VERSION=v0.2.49
ARG SUPERCRONIC_SHA1SUM=e63c11a9726b775a6a11801e81af4f3fb926aa68

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
