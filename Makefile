current_dir:=$(shell pwd)
build_tag = 'squid3-ssl-build'
end_tag = 'quay.io/genevera/squid3-ssl-proxy'

.PHONY: debs build_debs copy_debs

debs: build_debs copy_debs

everything: debs the_proxy_itself get_keys_install

the_proxy_itself:
	docker build -t $(end_tag) .

build_debs:
	docker build -t $(build_tag) - < Dockerfile.build

copy_debs:
	@mkdir -p debs
	docker run -v $(current_dir)/debs:/src/debs $(build_tag) /bin/sh -c 'cp /src/*.deb /src/debs/'
	rm -f $(current_dir)/debs/squid3*.deb

release_debs:
	sudo chown ${USER}:${USER} debs/*
	tar -zcvf squid-$(shell date +%Y%m%d).tgz debs/

get_keys_install:
	docker kill squid_ssl_proxy || true 
	docker rm squid_ssl_proxy || true
	docker run -d --restart=always --add-host=coreos:192.168.64.8 --name=squid_ssl_proxy --hostname="squid_ssl_proxy" -e HOST="squid_ssl_proxy" -p 33129:3128 -p 33443:3129 quay.io/genevera/squid3-ssl-proxy
	./get_install_keys.sh
	sudo security add-trusted-cert -d -r trustRoot -k ${HOME}/Library/Keychains/login.keychain $(current_dir)/squid-ssl.docker.crt
	rm $(current_dir)/squid-ssl.docker.crt
	rm $(current_dir)/private.pem

