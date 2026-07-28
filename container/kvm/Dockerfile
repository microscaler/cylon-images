# syntax=docker/dockerfile:1.7

# The guest filesystem remains an ordinary Dockerfile-built image. This stage
# turns that immutable filesystem into a thin KVM disk artifact; Docker is a
# build dependency, not a runtime dependency on Aether nodes.
ARG ROOTFS_IMAGE=ghcr.io/microscaler/cylon-rootfs-ubuntu:latest
FROM ${ROOTFS_IMAGE} AS guest

FROM ubuntu:24.04 AS disk-builder
ARG DISK_SIZE=16G
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    e2fsprogs \
    qemu-utils \
    && rm -rf /var/lib/apt/lists/*

COPY --from=guest / /rootfs/
COPY image.json /contract/image.json

RUN set -eux; \
    kernel="$(find /rootfs/boot -maxdepth 1 -type f -name 'vmlinuz-*' | sort | tail -n 1)"; \
    initrd="$(find /rootfs/boot -maxdepth 1 -type f -name 'initrd.img-*' | sort | tail -n 1)"; \
    test -n "${kernel}"; \
    test -n "${initrd}"; \
    mkdir -p /out; \
    : > /rootfs/etc/machine-id; \
    rm -f /rootfs/var/lib/dbus/machine-id /rootfs/etc/ssh/ssh_host_*; \
    ln -sf /etc/machine-id /rootfs/var/lib/dbus/machine-id; \
    passwd -R /rootfs -l root; \
    truncate -s "${DISK_SIZE}" /out/rootfs.raw; \
    mkfs.ext4 -F -L aether-root -d /rootfs /out/rootfs.raw; \
    qemu-img convert -f raw -O qcow2 -c /out/rootfs.raw /out/rootfs.qcow2; \
    cp "${kernel}" /out/vmlinuz; \
    cp "${initrd}" /out/initrd.img; \
    cp /contract/image.json /out/image.json; \
    qemu-img check -f qcow2 /out/rootfs.qcow2; \
    rm /out/rootfs.raw

FROM scratch AS artifact
LABEL org.opencontainers.image.title="Aether Ubuntu KVM guest"
LABEL io.microscaler.aether.image-contract="v1"
COPY --from=disk-builder /out/ /
