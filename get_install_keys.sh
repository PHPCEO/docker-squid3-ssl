#!/bin/bash
sleep 2;
docker cp squid-ssl-proxy:/etc/squid/certs/squid-ssl.docker.crt $(pwd)/squid-ssl.docker.crt;
docker cp squid-ssl-proxy:/etc/squid/certs/private.pem $(pwd)/private.pem;
