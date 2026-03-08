FROM ubuntu:local

ARG go_version=1.24

RUN add-apt-repository -y ppa:longsleep/golang-backports && \
    apt-get update && \
    apt-get install -y golang-${go_version} && \
    rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/lib/go-${go_version}/bin/go /usr/bin/go