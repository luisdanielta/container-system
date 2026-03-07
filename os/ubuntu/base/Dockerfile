ARG ubuntu_ver=22.04
FROM entrypoint:local AS entrydata
FROM ubuntu:${ubuntu_ver} AS base
LABEL description="Ubuntu, passwordless sudo, and SSH user via ENV."

ENV DEBIAN_FRONTEND=noninteractive

ARG TZ
ENV TZ=${TZ}

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
RUN apt-get update && apt-get install -y build-essential curl nano git git-lfs wget htop \
    && apt-get clean && rm -rf /var/lib/apt/lists/*;

# Copy entrypoint scripts and configuration
COPY --from=entrydata /entrypoint/create-user.sh /usr/local/bin/create-user.sh
COPY --from=entrydata /entrypoint/start-dockerd.sh /usr/local/bin/start-dockerd.sh
COPY supervisord.conf /etc/supervisord.conf

# Configure
RUN chmod +x /usr/local/bin/start-dockerd.sh
RUN chmod +x /usr/local/bin/create-user.sh

# Run
CMD [ "supervisord", "-c", "/etc/supervisord.conf" ]