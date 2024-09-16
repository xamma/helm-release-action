FROM alpine:3.20

RUN apk add --no-cache \
    curl \
    git \
    bash \
    openssl \
    && curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash \
    && rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN useradd -S appuser

USER appuser

ENTRYPOINT ["/entrypoint.sh"]
