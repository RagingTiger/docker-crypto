# fixed base image
FROM ubuntu:16.04

# apt-get installs for ubuntu
RUN apt-get update && apt-get -y install \
	openssl='1.0.2g-1ubuntu4' \
	gnupg2='2.1.11-6ubuntu2' \
	git \
	curl \
	wget \
	pv \
	ascii \
	python python-dev python-pip python-virtualenv

# install python crypto tools
RUN pip install caesarcipher

# make working dir
RUN mkdir -p /home/crypto
WORKDIR /home/crypto
