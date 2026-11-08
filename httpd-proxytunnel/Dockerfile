ARG BUILD_FROM=ghcr.io/hassio-addons/base:21.0.10
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Apache with SSL and proxy modules. The stock ssl.conf is replaced by our own
# config (rootfs), the default document root is denied, the plain HTTP
# listener is off and the global logs go to the add-on log instead of files.
# hadolint ignore=DL3018
RUN apk add --no-cache \
        apache2 \
        apache2-proxy \
        apache2-ssl \
        apache2-utils \
        openssl \
    && mkdir -p /run/apache2 \
    && mv /etc/apache2/conf.d/ssl.conf /etc/apache2/conf.d/ssl.conf.original \
    && sed -i \
        -e 's/Require all granted/Require all denied/g' \
        -e 's/^Listen 80$/#Listen 80/' \
        -e 's#^ErrorLog .*#ErrorLog /proc/self/fd/2#' \
        -e 's#^\(\s*CustomLog logs/access.log\)#\#\1#' \
        /etc/apache2/httpd.conf

# s6-overlay services (init-httpd, httpd) and the static Apache config
COPY rootfs /

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
