FROM entrypoint:local AS entrydata
FROM ubuntu:misc

RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy entrypoint scripts and configuration
COPY --from=entrydata /entrypoint/start-dockerd.sh /usr/local/bin/start-dockerd.sh

# Configure
RUN chmod +x /usr/local/bin/start-dockerd.sh
