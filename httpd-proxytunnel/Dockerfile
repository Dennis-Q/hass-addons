ARG BUILD_FROM=ghcr.io/hassio-addons/base:21.0.10
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Apache with SSL and proxy modules. The stock ssl.conf is replaced by our own
# config, the default document root is denied and the plain HTTP listener is off.
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
        /etc/apache2/httpd.conf

COPY 10-proxy-connect.conf /etc/apache2/conf.d/10-proxy-connect.conf
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]

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
