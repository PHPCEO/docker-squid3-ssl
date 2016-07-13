current_dir:=$(shell pwd)
build_tag = 'squid3-ssl-build'
end_tag = 'quay.io/genevera/squid3-ssl-proxy'

.PHONY: debs build_debs copy_debs release_debs the_proxy_itself get_keys_install

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
	docker kill squid-ssl-proxy || true 
	docker rm squid-ssl-proxy || true
	docker run -d --restart=always --name=squid-ssl-proxy --hostname=squid-ssl-proxy.docker -e HOST="squid-ssl-proxy.docker" -v /var/cache/squid:/var/cache/squid quay.io/genevera/squid3-ssl-proxy
	./get_install_keys.sh
	sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $(current_dir)/squid-ssl.docker.crt
	mv $(current_dir)/squid-ssl.docker.crt ${current_dir}/certs/
	mv $(current_dir)/private.pem ${current_dir}/certs/

