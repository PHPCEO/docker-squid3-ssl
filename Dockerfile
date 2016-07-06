FROM quay.io/genevera/ubuntu:xenial-daily
MAINTAINER Genevera <genevera.codes@gmail.com> (@genevera)


ENV TZ='America/New_York'
ENV MAKEOPTS="-j2"
ENV DEBIAN_FRONTEND=noninteractive
RUN echo 'Acquire::http { Proxy "http://apt-cacher-ng.docker:3142"; };' > /etc/apt/apt.conf.d/01proxy
RUN apt-get update && \
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
                    curl \
                    expect \
                    gawk && \
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
ADD squid.conf.extras /etc/squid/conf.d/extras.conf
ADD openssl.cnf /etc/squid/openssl.cnf
ADD mk-certs /usr/local/bin/mk-certs
ADD tail_logs /usr/local/bin/tail_logs
ADD run /usr/local/bin/run
RUN chmod +x /usr/local/bin/run
RUN cp /usr/share/zoneinfo/America/New_York /etc/timezone

EXPOSE 33128
EXPOSE 33129
CMD ["/usr/local/bin/run"]
