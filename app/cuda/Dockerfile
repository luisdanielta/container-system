ARG cuda_ver=11.8.0
ARG ubuntu_ver=20.04
ARG cuda_level=devel
ARG alpine_ver=3.20
FROM nvidia/cuda:${cuda_ver}-${cuda_level}-ubuntu${ubuntu_ver} AS cuda-base

# Alpine Linux as lightweight runtime and file maintainer
FROM alpine:${alpine_ver}
USER root

# Copies entire CUDA installation from stage 1 to a temporary Alpine location
COPY --from=cuda-base /usr/local/cuda /cuda

# Moves the copied files to the final location in Alpine and removes the temporary copy
RUN cp -a /cuda/. /usr/local/cuda
RUN rm -rf /cuda

CMD [ "ls", "-la", "/usr/local/cuda" ]