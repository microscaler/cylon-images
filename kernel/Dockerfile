# syntax=docker/dockerfile:1.4
FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        bc \
        bison \
        build-essential \
        flex \
        git \
        libelf-dev \
        libncurses-dev \
        libssl-dev \
        ca-certificates \
        kmod \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV SRC_DIR=/usr/src \
    LINUX_DIR=/usr/src/linux \
    LINUX_REPO_URL=https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git

ARG KERNEL_VERSION=6.1.102
ARG TARGETARCH

RUN mkdir -p ${SRC_DIR} && \
    git clone --depth 1 --branch v${KERNEL_VERSION} ${LINUX_REPO_URL} ${LINUX_DIR}

WORKDIR ${LINUX_DIR}

COPY configs/${TARGETARCH}/linux-${TARGETARCH}-${KERNEL_VERSION}.config .config

RUN make olddefconfig
RUN make -j$(nproc) vmlinux

# Export stage: only contains the final vmlinux binary
FROM scratch
COPY --from=builder /usr/src/linux/vmlinux /
