ARG BUILD_FROM=ghcr.io/hassio-addons/base:15.0.3
FROM $BUILD_FROM
ENV LANG C.UTF-8

# Create directory for apache2 to store PID file
RUN mkdir /run/apache2

RUN apk update && apk upgrade
RUN apk --no-cache add openssl
RUN apk --no-cache add apache2 apache2-ssl apache2-proxy apache2-utils
RUN mv /etc/apache2/conf.d/ssl.conf /etc/apache2/conf.d/ssl.conf.original

RUN sed -i \
        -e 's/Require all granted/Require all denied/g' \
        /etc/apache2/httpd.conf


# Copy data for add-on
COPY run.sh /
#COPY index.html /
RUN chmod a+x /run.sh
#RUN chmod a+x /index.html

COPY 10-proxy-connect.conf /etc/apache2/conf.d/10-proxy-connect.conf

CMD [ "/run.sh" ]

# REMOVED: httpd-ssl.conf not used, we use our own config instead.
#        -e 's/^#\(Include .*httpd-ssl.conf\)/\1/' \

# do enable SSL/proxy
#RUN sed -i \
#        -e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
#        -e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
#		-e 's/Require all granted/Require all denied/g' \
#        conf/httpd.conf

#RUN echo 'Include conf/10-proxy-connect.conf' >> conf/httpd.conf

