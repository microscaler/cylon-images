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

# FAR guest binaries (built via `just stage-far-guest-rootfs` in cylon repo).
COPY tools/bin/ /usr/local/bin/
RUN chmod +x /usr/local/bin/* 2>/dev/null || true

# Baseline skills for guest-brain discovery (optional; empty dir ok).
COPY tools/cylon-skills-registry /opt/cylon/skills
ENV CYLON_SKILLS_ROOT=/opt/cylon/skills

COPY tools/systemd/vsock-hello.service /etc/systemd/system/vsock-hello.service
COPY tools/systemd/cylon-guest-brain.service /etc/systemd/system/cylon-guest-brain.service
RUN systemctl enable vsock-hello.service cylon-guest-brain.service

STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
