ARG ubuntu_ver=22.04
FROM ubuntu:${ubuntu_ver} AS base
LABEL description="Ubuntu, passwordless sudo, and SSH user via ENV."

ENV DEBIAN_FRONTEND=noninteractive

ARG TZ
ENV TZ=${TZ}

# Define non-root user credentials for a secure development environment.
ARG USERNAME=dev
ENV USERNAME=$USERNAME
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create non-root user and configure passwordless sudo.
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# SSH configuration
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    supervisor openssh-server passwd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd && \
    ssh-keygen -A && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# App installation
RUN apt-get update && apt-get install -y build-essential curl nano git git-lfs wget htop \
    && apt-get clean && rm -rf /var/lib/apt/lists/*;

# Copy entrypoint scripts and configuration
COPY supervisord.conf /etc/supervisord.conf

# Run
EXPOSE 22
ENTRYPOINT ["supervisord"]
CMD ["-c", "/etc/supervisord.conf"]