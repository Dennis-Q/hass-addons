ARG BUILD_FROM=ghcr.io/hassio-addons/base:21.0.10
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Apache with SSL and proxy modules. The stock configuration (all modules,
# server-status, userdir, ...) is replaced by the minimal one in rootfs.
# hadolint ignore=DL3018
RUN apk add --no-cache \
        apache2 \
        apache2-proxy \
        apache2-ssl \
        apache2-utils \
        openssl \
    && mkdir -p /run/apache2 \
    && rm -f /etc/apache2/conf.d/*.conf

# s6-overlay services (init-httpd, httpd) and the Apache configuration
COPY rootfs /

# Healthy when Apache answers over TLS on 443 (403 for a direct request is fine);
# with "Watchdog" on, Supervisor restarts the add-on when it becomes unhealthy
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD ["curl", "--silent", "--insecure", "--output", "/dev/null", "--max-time", "5", "https://127.0.0.1/"]

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Dennis-Q" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/Dennis-Q/hass-addons" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
