#---
# name: ffmpeg
# group: core
# depends: [build-essential]
# notes: installs ffmpeg
# test: test.sh
#---

ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG GOBIN=/opt/go/bin

ARG SOC="ffmpeg"

ADD --chown=root:root https://repo.download.nvidia.com/jetson/jetson-ota-public.asc /etc/apt/trusted.gpg.d/jetson-ota-public.asc
RUN chmod 644 /etc/apt/trusted.gpg.d/jetson-ota-public.asc \
    && apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
    && echo "deb https://repo.download.nvidia.com/jetson/common main main" > /etc/apt/sources.list.d/nvidia-l4t-apt-source.list \
    && echo "deb https://repo.download.nvidia.com/jetson/${SOC} main main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list \

# Install ffmpeg
RUN set -ex \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends ffmpeg \
	&& apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# set Go env variables
ENV GOPATH=/opt/go \
	PATH=$PATH:$GOBIN

# Test ffmpeg version
RUN set -ex \
	&& ffmpeg -version \
	&& ffmpeg -encoders \
	&& ffmpeg -decoders
