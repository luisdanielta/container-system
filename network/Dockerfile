ARG alpine_ver=3.20
FROM alpine:${alpine_ver}

RUN apk add --no-cache \
    nftables openssh-server \
    && rm -rf /var/cache/apk/*

COPY /conf/nftables.nft /etc/nftables.nft