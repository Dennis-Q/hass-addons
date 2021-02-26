#!/usr/bin/env bashio

use_own_ssl_cert=$(bashio::config 'use_own_ssl_cert')
certfile=$(bashio::config 'certfile')
keyfile=$(bashio::config 'keyfile')
enable_basic_auth=$(bashio::config 'enable_basic_auth')
auth_username=$(bashio::config 'auth_username')
auth_password=$(bashio::config 'auth_password')
enable_limit_connect=$(bashio::config 'enable_limit_connect')
limit_allowconnect_port=$(bashio::config 'limit_allowconnect_port')
limit_connect_host=$(bashio::config 'limit_connect_host')


###################
# SSL certificate #
###################

if [ $use_own_ssl_cert = "true" ]; then
    echo "INFO: Using provided SSL-cert instead of self-signed."
    if [ ! -f ${certfile} ]; then
        echo "ERROR: Provided certfile '${certfile}' does not exist."
        exit 2
    fi
    if [ ! -f ${keyfile} ]; then
        echo "ERROR: Provided keyfile '${keyfile}' does not exist."
        exit 3
    fi
else
    echo "INFO: use_own_ssl_cert is set to false, generating self-sign SSL certificate."
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj "/C=NL/CN=httpd-proxytunnel.homeassistant.local" -keyout /etc/ssl/private/server.key -out /etc/ssl/certs/server.crt
    certfile="/etc/ssl/certs/server.crt"
    keyfile="/etc/ssl/private/server.key"
fi

# replace certificate file/key with the right locations
sed -i \
    -e "s:REPLACE_ME_CERTIFICATE:${certfile}:g" \
    -e "s:REPLACE_ME_KEYFILE:${keyfile}:g" \
    /etc/apache2/conf.d/10-proxy-connect.conf

#################
# Limit Connect #
#################

if [ ${enable_limit_connect} = "true" ]; then
    if [ -z ${limit_allowconnect_port} ] && [ -z ${limit_connect_host} ]; then
        echo "ERROR: enable_limit_connect is enabled but limit_allowconnect_port and limit_connect_host are not configured."
        exit 4
    fi

    if [ ! -z ${limit_allowconnect_port} ]; then
        echo "INFO: Setting AllowConnect to '${limit_allowconnect_port}' in httpd configuration file."
        sed -i \
            -e "s:#\(AllowConnect REPLACE_ME_ALLOWCONNECT_PORT\):\1:" \
            -e "s:REPLACE_ME_ALLOWCONNECT_PORT:${limit_allowconnect_port}:" \
            /etc/apache2/conf.d/10-proxy-connect.conf
    fi

    if [ ! -z ${limit_connect_host} ]; then
        echo "INFO: Limiting Proxy to host '${limit_connect_host}'"
        sed -i \
            -e "s:#\(<Proxy REPLACE_ME_CONNECT_HOST>\):\1:" \
            -e "s:#\(Require all granted\):\1:" \
            -e "s:#\(</Proxy>\):\1:" \
            -e "s:REPLACE_ME_CONNECT_HOST:${limit_connect_host}:" \
            /etc/apache2/conf.d/10-proxy-connect.conf
    fi


else
    echo "INFO: enable_limit_connect set to false, using default HTTPD AllowConnect and no host limitation"
    limit_allowconnect_port=""
    limit_connect_host=""
fi

########################
# Authentication stuff #
########################
    

if [ ${enable_basic_auth} = "true" ]; then
    if [ -z ${auth_username} ] || [ -z ${auth_password} ]; then
        echo "ERROR: auth_username and auth_password need to be filled when enable_basic_auth is set to true. Please enter this information or disable enable_basic_auth."
        exit 1
    fi
    echo "INFO: Adding password to htaccess file for user '${auth_username}'"
    echo "${auth_password}" | htpasswd -i -c /etc/apache2/.htpasswd ${auth_username}

    sed -i \
        -e "s:#\(Authtype Basic\):\1:" \
        -e "s:#\(Authname \"Password Required\"\):\1:" \
        -e "s:#\(AuthUserFile /etc/apache2/.htpasswd\):\1:" \
        /etc/apache2/conf.d/10-proxy-connect.conf

    if [ ! -z ${limit_connect_host} ]; then
        sed -i \
            -e "s:Require all granted:Require valid-user:g" \
            /etc/apache2/conf.d/10-proxy-connect.conf
    else
        sed -i \
            -e "s:#\(Require valid-user\):\1:" \
            /etc/apache2/conf.d/10-proxy-connect.conf
    fi
else
    echo "INFO: enable_basic_auth set to false, authentication disabled."
    sed -i \
        -e "s:Require all denied:Require all granted:g" \
        /etc/apache2/conf.d/10-proxy-connect.conf
fi

# start apache in foreground
echo "INFO: Starting Apache2 - This is the last message in the log. If no error occured your httpd-proxytunnel should work."
exec /usr/sbin/httpd -D FOREGROUND
