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
ARG git_bug_version=0.8.0

# Go
FROM misc AS misc-go
RUN add-apt-repository -y ppa:longsleep/golang-backports && \
    apt-get update && \
    apt-get install -y golang-${go_version} \
    && rm -rf /var/lib/apt/lists/*

# Python python3 -m venv lab --without-pip
# curl -sS https://bootstrap.pypa.io/get-pip.py | /lab/bin/python3 -m ensurepip --upgrade
FROM misc AS misc-py
RUN add-apt-repository -y ppa:deadsnakes/ppa && apt-get update \
    && apt-get install -y \
    python${py_version} \
    python${py_version}-venv \
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

# Git Bug
FROM misc AS misc-git-bug
RUN apt-get update && apt-get install -y curl \
    && curl -Lo /usr/local/bin/git-bug https://github.com/MichaelMure/git-bug/releases/download/v${git_bug_version}/git-bug_linux_amd64 \
    && chmod +x /usr/local/bin/git-bug

# Configure
FROM misc AS tool
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    make cmake clang-format clang ninja-build libstdc++6

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Go
COPY --from=misc-go /usr/lib/go-${go_version} /usr/lib/go
ENV GOROOT=/usr/lib/go
ENV GOPATH=/go
ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH

# Python
COPY --from=misc-py /usr/bin/python${py_version} /usr/bin/python${py_version}
COPY --from=misc-py /usr/lib/python${py_version} /usr/lib/python${py_version}
RUN ln -s /usr/bin/python${py_version} /usr/bin/python

# Node
COPY --from=misc-node /usr/bin/node /usr/bin/node
COPY --from=misc-node /usr/lib/node_modules /usr/lib/node_modules

RUN ln -s /usr/bin/node /usr/local/bin/node && \
    ln -s /usr/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /usr/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# GCC
COPY --from=misc-gcc /usr/bin/gcc-${gcc_version} /usr/bin/gcc
COPY --from=misc-gcc /usr/bin/g++-${gcc_version} /usr/bin/g++

COPY --from=misc-gcc /usr/lib/gcc/x86_64-linux-gnu/${gcc_version} /usr/lib/gcc/x86_64-linux-gnu/${gcc_version}
COPY --from=misc-gcc /usr/include/c++/${gcc_version} /usr/include/c++/${gcc_version}
COPY --from=misc-gcc /usr/include/x86_64-linux-gnu/c++/${gcc_version} /usr/include/x86_64-linux-gnu/c++/${gcc_version}

# Git Bug
COPY --from=misc-git-bug /usr/local/bin/git-bug /usr/local/bin/git-bug
RUN ln -s /usr/local/bin/git-bug /usr/bin/git-bug
