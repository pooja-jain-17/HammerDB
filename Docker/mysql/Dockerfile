FROM docker.io/tpcorg/hammerdb:base

# Install and configuring MySQL client libraries
RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y libaio-dev mecab-ipadic-utf8 && \
	wget https://downloads.mysql.com/archives/get/p/23/file/mysql-server_8.4.0-1ubuntu24.04_amd64.deb-bundle.tar && \
	tar -xvf mysql-server_8.4.0-1ubuntu24.04_amd64.deb-bundle.tar && \
	dpkg -i *.deb 

