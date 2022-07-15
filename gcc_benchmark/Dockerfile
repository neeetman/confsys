FROM ubuntu:focal as builder
LABEL maintainer "Haxx"

# Update the apt's source list
RUN grep ^deb /etc/apt/sources.list | \
    sed 's/^deb/deb-src /g' >> /etc/apt/sources.list

# Timezone
ARG DEBIAN_FRONTEND=noninteractive

# Install compiler, python and subversion
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates gnupg \
        build-essential cmake make python3 zlib1g binutils git unzip wget && \
        rm -rf /var/lib/apt/lists/*

ADD scripts /tmp/scripts

# Install polybench and PAPI
RUN /tmp/scripts/build_polybench_papi.sh

ENV POLYBENCH_DIR=/usr/local/polybench
ENV PAPI_DIR=/usr/local/papi
ENV PATH=${PAPI_DIR}/bin:$PATH
ENV LD_LIBRARY_PATH=${PAPI_DIR}/lib:$LD_LIBRARY_PATH

# 
ADD scripts/compile.sh /usr/local/bin/
