FROM ubuntu:25.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
	apt-get install -y --no-install-recommends locales ca-certificates curl git build-essential procps file ruby-full lsb-release sudo && \
	rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -f UTF-8 en_US.UTF-8

RUN useradd -m -s /bin/bash linuxbrew && \
	echo "linuxbrew ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER linuxbrew

COPY setmeup.sh .

RUN ./setmeup.sh

COPY ./config/ /home/linuxbrew/.config

WORKDIR /workspace

CMD [ "bash" ]
