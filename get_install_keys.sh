#!/bin/bash
sleep 2;
docker cp squid_ssl_proxy.docker:/etc/squid/certs/squid-ssl.docker.crt $(pwd)/squid-ssl.docker.crt;
docker cp squid_ssl_proxy.docker:/etc/squid/certs/private.pem $(pwd)/private.pem;
