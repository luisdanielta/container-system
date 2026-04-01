ARG alpine_ver=3.20
FROM alpine:${alpine_ver}

VOLUME [ "/data", "/research" ]

COPY setup_ssh.sh /usr/local/bin/setup_ssh.sh
RUN chmod +x /usr/local/bin/setup_ssh.sh