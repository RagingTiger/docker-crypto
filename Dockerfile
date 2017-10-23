FROM ubuntu:16.04

RUN apt-get update && apt-get -y install \
	openssl='1.0.2g-1ubuntu4.8' \
	gnupg2='2.1.11-6ubuntu2' \
	git \
	curl \
	wget \
	ascii

WORKDIR /root
