FROM ubuntu:24.04

# Minimal bootable rootfs for Firecracker smoke tests (fast build vs full ubuntu/).
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    systemd-sysv \
    ca-certificates \
    curl \
    iproute2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Marker consumed by cylon host boot-arg selection.
RUN mkdir -p /etc/cylon && echo "minimal" > /etc/cylon/rootfs-flavor

STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
