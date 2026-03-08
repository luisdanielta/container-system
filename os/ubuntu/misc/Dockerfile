FROM ubuntu:golang

# Python
ARG py_version=3.12

RUN add-apt-repository -y ppa:deadsnakes/ppa && apt-get update \
    && apt-get install -y \
    python${py_version} \
    python${py_version}-venv \
    python3-pip

RUN ln -s /usr/bin/python${py_version} /usr/bin/python

# NodeJS
ARG node_version=20

RUN curl -fsSL https://deb.nodesource.com/setup_${node_version}.x | bash -
RUN apt-get update && apt-get install -y nodejs

# Clean
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*
