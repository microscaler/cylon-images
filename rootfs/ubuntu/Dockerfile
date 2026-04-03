FROM ubuntu:24.04

# A minimal Ubuntu 24.04 image specifically tailored to be extracted into an ext4 rootfs for Firecracker
# This image contains the core lifecycle dependencies necessary for Cylon to orchestrate and proxy the microVM.

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    kmod \
    dbus \
    iproute2 \
    iputils-ping \
    net-tools \
    openssh-server \
    dnsutils \
    sudo \
    curl \
    linux-image-virtual \
    udev \
    ca-certificates \
    software-properties-common \
    systemd \
    jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Fix SSH environment loading and locale defaults
RUN sed -i -e 's/^AcceptEnv LANG LC_\*$/#AcceptEnv LANG LC_*/' /etc/ssh/sshd_config

# Set up simple default login for testing purposes
RUN echo "root:root" | chpasswd

# Cylon specific configuration: Ensure systemd handles the init sequence seamlessly inside the VM
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
