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

RUN echo "deb [ allow-insecure=yes ] https://repo.download.nvidia.com/jetson/ffmpeg main main" | tee -a /etc/apt/sources.list \
    && echo "deb-src [ allow-insecure=yes ] https://repo.download.nvidia.com/jetson/ffmpeg main main" | tee -a /etc/apt/sources.list

# Install ffmpeg
RUN set -ex \
	&& apt update \
	&& apt install -y --no-install-recommends ffmpeg \
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
