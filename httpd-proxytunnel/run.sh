#!/command/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# httpd-proxytunnel: validate the options, prepare certificate and credentials,
# generate the virtual host and start Apache in the foreground.
# ==============================================================================

readonly VHOST_CONF="/etc/apache2/conf.d/20-proxy-vhost.conf"
readonly HTPASSWD="/etc/apache2/.htpasswd"
readonly SELF_SIGNED_DIR="/data/ssl"

readonly PORTS_REGEX='^[0-9]+(-[0-9]+)?([[:space:]]+[0-9]+(-[0-9]+)?)*$'
readonly HOST_REGEX='^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$'
readonly USERNAME_REGEX='^[^:[:space:]]+$'
readonly SSL_PATH_REGEX='^/ssl/[^"[:space:]]+$'

###########
# Options #
###########

limit_ports=""
limit_host=""

if bashio::config.true 'enable_limit_connect'; then
    limit_ports=$(bashio::config 'limit_allowconnect_port')
    limit_host=$(bashio::config 'limit_connect_host')
    [[ "${limit_ports}" == "null" ]] && limit_ports=""
    [[ "${limit_host}" == "null" ]] && limit_host=""

    if [[ -z "${limit_ports}" && -z "${limit_host}" ]]; then
        bashio::exit.nok "enable_limit_connect is enabled, but limit_allowconnect_port and limit_connect_host are both empty."
    fi
    if [[ -n "${limit_ports}" && ! "${limit_ports}" =~ ${PORTS_REGEX} ]]; then
        bashio::exit.nok "limit_allowconnect_port '${limit_ports}' is invalid. Use e.g. '22' or '22 2200-2210'."
    fi
    if [[ -n "${limit_host}" && ! "${limit_host}" =~ ${HOST_REGEX} ]]; then
        bashio::exit.nok "limit_connect_host '${limit_host}' is invalid. Use an IPv4 address or a host name."
    fi
fi

if bashio::config.false 'enable_basic_auth' && [[ -z "${limit_host}" ]]; then
    bashio::exit.nok "enable_basic_auth is disabled without limit_connect_host: that would be an open proxy. Enable authentication or limit the proxy to one host."
fi

###################
# SSL certificate #
###################

if bashio::config.true 'use_own_ssl_cert'; then
    certfile=$(bashio::config 'certfile')
    keyfile=$(bashio::config 'keyfile')
    for file in "${certfile}" "${keyfile}"; do
        if [[ ! "${file}" =~ ${SSL_PATH_REGEX} ]]; then
            bashio::exit.nok "'${file}' is invalid: certfile and keyfile must be stored in /ssl/ (no spaces or quotes)."
        fi
        if [[ ! -r "${file}" ]]; then
            bashio::exit.nok "'${file}' does not exist or is not readable."
        fi
    done
    bashio::log.info "Using the provided SSL certificate '${certfile}'."
else
    certfile="${SELF_SIGNED_DIR}/server.crt"
    keyfile="${SELF_SIGNED_DIR}/server.key"

    # Keep the certificate (and its fingerprint) until it expires or is unusable
    if [[ -s "${certfile}" && -s "${keyfile}" ]] \
        && openssl x509 -checkend 0 -noout -in "${certfile}" > /dev/null 2>&1 \
        && [[ "$(openssl x509 -noout -pubkey -in "${certfile}" 2> /dev/null)" \
            == "$(openssl pkey -pubout -in "${keyfile}" 2> /dev/null)" ]]; then
        bashio::log.info "Using the existing self-signed certificate."
    else
        bashio::log.info "Generating a new self-signed certificate (valid for 10 years)."
        mkdir -p "${SELF_SIGNED_DIR}"
        chmod 700 "${SELF_SIGNED_DIR}"
        (umask 077 && openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
            -subj "/CN=httpd-proxytunnel.homeassistant.local" \
            -keyout "${keyfile}" -out "${certfile}" > /dev/null 2>&1) \
            || bashio::exit.nok "Generating the self-signed certificate failed."
    fi
fi

bashio::log.info "Certificate valid until $(openssl x509 -noout -enddate -in "${certfile}" | cut -d= -f2)."
bashio::log.info "Certificate $(openssl x509 -noout -fingerprint -sha256 -in "${certfile}")"

##################
# Authentication #
##################

auth_config=""
require_client="Require all granted"

if bashio::config.true 'enable_basic_auth'; then
    auth_username=$(bashio::config 'auth_username')
    if ! bashio::config.has_value 'auth_username' || ! bashio::config.has_value 'auth_password'; then
        bashio::exit.nok "auth_username and auth_password are required when enable_basic_auth is enabled."
    fi
    if [[ ! "${auth_username}" =~ ${USERNAME_REGEX} ]]; then
        bashio::exit.nok "auth_username may not contain spaces or ':'."
    fi
    bashio::config.suggest.safe_password 'auth_password'

    printf '%s\n' "$(bashio::config 'auth_password')" \
        | htpasswd -B -i -c "${HTPASSWD}" "${auth_username}" > /dev/null 2>&1 \
        || bashio::exit.nok "Creating the password file failed."
    chown root:apache "${HTPASSWD}"
    chmod 640 "${HTPASSWD}"
    bashio::log.info "Basic authentication enabled for user '${auth_username}'."

    auth_config="AuthType Basic
        AuthName \"Password Required\"
        AuthBasicProvider file
        AuthUserFile ${HTPASSWD}"
    require_client="Require valid-user"
else
    bashio::log.warning "Basic authentication is disabled; anyone can connect to '${limit_host}'."
fi

#########
# Proxy #
#########

require_method="Require method CONNECT"
if bashio::config.true 'allow_http_proxy'; then
    require_method=""
    bashio::log.warning "allow_http_proxy is enabled: plain HTTP proxy requests are allowed as well as CONNECT."
fi

allow_connect="# AllowCONNECT: default ports (443 563)"
if [[ -n "${limit_ports}" ]]; then
    allow_connect="AllowCONNECT ${limit_ports}"
    bashio::log.info "CONNECT limited to port(s) '${limit_ports}'."
fi

access_rules="
        ${auth_config}
        <RequireAll>
            ${require_client}
            ${require_method}
        </RequireAll>"

if [[ -n "${limit_host}" ]]; then
    bashio::log.info "Proxy limited to host '${limit_host}'."
    # <Proxy host> is a prefix match (10.0.0.1 would also match 10.0.0.10),
    # so match the exact host, with an optional port and path.
    proxy_sections="
    <Proxy *>
        Require all denied
    </Proxy>

    <ProxyMatch \"^(https?://)?${limit_host//./\\.}(:[0-9]+)?(/.*)?\$\">${access_rules}
    </ProxyMatch>"
else
    proxy_sections="
    <Proxy *>${access_rules}
    </Proxy>"
fi

cat > "${VHOST_CONF}" << EOF
# Generated by run.sh at add-on start; changes are lost on restart.
<VirtualHost _default_:443>
    ServerName homeassistant.local:443
    DocumentRoot "/var/www/localhost/htdocs"

    ErrorLog /proc/self/fd/2
    CustomLog /proc/self/fd/1 "%t %h %u %{SSL_PROTOCOL}x \"%r\" %>s %b"

    SSLEngine on
    SSLCertificateFile "${certfile}"
    SSLCertificateKeyFile "${keyfile}"

    <Directory />
        Require all denied
        Options None
        AllowOverride None
    </Directory>

    ProxyRequests On
    ProxyVia Off
    ${allow_connect}
${proxy_sections}
</VirtualHost>
EOF

httpd -t > /dev/null 2>&1 || {
    httpd -t
    bashio::exit.nok "The generated Apache configuration is invalid."
}

bashio::log.info "Starting Apache2."
exec /usr/sbin/httpd -D FOREGROUND
