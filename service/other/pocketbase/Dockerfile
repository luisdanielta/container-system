ARG go_ver=1.23
FROM golang:${go_ver} AS builder

ARG pocket_ver=master

RUN apt-get update && apt-get install -y git && \
    git clone --depth 1 --branch ${pocket_ver} https://github.com/pocketbase/pocketbase.git /pb && \
    cd /pb && \
    go mod tidy

WORKDIR /pb/examples/base

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /pocketbase

# Build a small image
FROM alpine:3.20

ENV DATA_DIR=/pb_data

COPY --from=builder /pocketbase /usr/local/bin/pocketbase
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/pocketbase /usr/local/bin/entrypoint.sh

EXPOSE 8090

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
