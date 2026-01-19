ARG ubuntu_ver=20.04
FROM entrypoint:local AS entrydata
FROM ubuntu:${ubuntu_ver}
LABEL description="Ubuntu, passwordless sudo, and SSH user via ENV."

ARG gui=false
ARG app_essentials=true

USER root
ENV DEBIAN_FRONTEND=noninteractive

ARG TZ=America/Bogota
ENV TZ=${TZ}

ARG docker_app=true
ENV DOCKER_APP=${docker_app}

EXPOSE 22

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    sudo supervisor openssh-server passwd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# SSH configuration
RUN mkdir -p /var/run/sshd && \
    ssh-keygen -A && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# App installation
RUN if [ "$app_essentials" = "true" ]; then \
    apt-get update && apt-get install -y build-essential curl nano git git-lfs wget htop \
    && apt-get clean && rm -rf /var/lib/apt/lists/*; \
    echo "App essentials installed."; \
    else \
    echo "App essentials installation skipped."; \
    fi

# Docker installation
RUN if [ "$docker_app" = "true" ]; then \
    echo "Installing Docker..."; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io && \
    docker --version && \
    apt-get clean && rm -rf /var/lib/apt/lists/*; \
    echo "Docker installed."; \
    else \
    echo "Docker installation skipped."; \
    fi

# Copy entrypoint scripts and configuration
COPY --from=entrydata /entrypoint/create-user.sh /usr/local/bin/create-user.sh
COPY --from=entrydata /entrypoint/start-dockerd.sh /usr/local/bin/start-dockerd.sh
COPY supervisord.conf /etc/supervisord.conf

# Configure
RUN chmod +x /usr/local/bin/start-dockerd.sh

# Run
CMD [ "supervisord", "-c", "/etc/supervisord.conf" ]