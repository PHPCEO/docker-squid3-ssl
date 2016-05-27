FROM ubuntu:xenial
MAINTAINER Genevera <genevera.codes@gmail.com> (@genevera)


ENV DEBIAN_FRONTEND=noninteractive
RUN echo 'Acquire::http { Proxy "http://192.168.64.8:3142"; };' >> /etc/apt/apt.conf.d/01proxy
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main" >> /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ trusty-updates main" >> /etc/apt/sources.list && \
    echo "deb http://security.ubuntu.com/ubuntu trusty-security main" >> /etc/apt/sources.list && \
    echo "deb-src http://archive.ubuntu.com/ubuntu trusty main" >> /etc/apt/sources.list && \
    echo "deb-src http://archive.ubuntu.com/ubuntu/ trusty-updates main" >> /etc/apt/sources.list && \
    echo "deb-src http://security.ubuntu.com/ubuntu trusty-security main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -qq \
                    apache2 \
                    logrotate \
                    squid-langpack \
                    ca-certificates \
                    libgssapi-krb5-2 \
                    libltdl7 \
                    libecap3 \
                    libnetfilter-conntrack3 \
                    curl && \
    apt-get clean

# Install packages
ADD debs /tmp/debs
RUN cd /tmp && \
    dpkg -i debs/*.deb && \
    rm -rf debs && \
    apt-get clean

# Create cache directory
VOLUME /var/cache/squid

# Initialize dynamic certs directory
RUN /usr/lib/squid3/ssl_crtd -c -s /var/lib/ssl_db
RUN mkdir -p /etc/squid/certs \
&& chown -R proxy:proxy /var/lib/ssl_db \
&& chown -R proxy:proxy /etc/squid

# Prepare configs and executable
ADD squid.conf /etc/squid/squid.conf
ADD openssl.cnf /etc/squid/openssl.cnf
ADD mk-certs /usr/local/bin/mk-certs
ADD run /usr/local/bin/run
RUN chmod +x /usr/local/bin/run

EXPOSE 3128
CMD ["/usr/local/bin/run"]
