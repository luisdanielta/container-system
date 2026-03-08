FROM ubuntu:local AS misc

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    build-essential

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG go_version=1.24
ARG py_version=3.12
ARG gcc_version=10
ARG node_version=20

# Go
FROM misc AS misc-go
RUN add-apt-repository -y ppa:longsleep/golang-backports && \
    apt-get update && \
    apt-get install -y golang-${go_version} \
    && rm -rf /var/lib/apt/lists/*

# Python
FROM misc AS misc-py
RUN add-apt-repository -y ppa:deadsnakes/ppa && apt-get update \
    && apt-get install -y \
    python${py_version} \
    python${py_version}-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# NodeJS
FROM misc AS misc-node
RUN curl -fsSL https://deb.nodesource.com/setup_${node_version}.x | bash -
RUN apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

# GCC
FROM misc AS misc-gcc
RUN apt-get update && apt-get install -y \
    gcc-${gcc_version} \
    g++-${gcc_version} && rm -rf /var/lib/apt/lists/*

FROM misc AS tool

COPY --from=misc-go /usr/lib/go-${go_version}/bin/go /usr/bin/go
COPY --from=misc-py /usr/bin/python${py_version} /usr/bin/python

# Set module gcc version
COPY --from=misc-gcc /usr/bin/gcc-${gcc_version} /usr/bin/gcc
COPY --from=misc-gcc /usr/bin/g++-${gcc_version} /usr/bin/g++

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    make cmake clang-format clang ninja-build

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Node
COPY --from=misc-node /usr/bin/node /usr/bin/node
COPY --from=misc-node /usr/lib/node_modules /usr/lib/node_modules
RUN ln -s /usr/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm && \
    ln -s /usr/lib/node_modules/npm/bin/npx-cli.js /usr/bin/npx