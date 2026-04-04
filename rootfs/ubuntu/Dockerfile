FROM ubuntu:25.04

# Expose buildx platform target argument
ARG TARGETARCH

# A minimal Ubuntu 25.04 image specifically tailored to be extracted into an ext4 rootfs for Firecracker
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
    wget \
    zip \
    unzip \
    tar \
    git \
    build-essential \
    gcc \
    g++ \
    clang \
    cmake \
    pkg-config \
    libssl-dev \
    bison \
    postgresql \
    postgresql-contrib \
    docker.io \
    docker-compose-v2 \
    linux-image-virtual \
    udev \
    ca-certificates \
    software-properties-common \
    systemd \
    python3 \
    python3-minimal \
    python3-pip \
    python3-venv \
    snapd \
    jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Supabase CLI
RUN curl -fsSL https://raw.githubusercontent.com/supabase/cli/main/install.sh | sh

# Install Rust via rustup
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path && \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME && \
    cargo install cargo-zigbuild

# Install Zig Compiler
RUN if [ "$TARGETARCH" = "arm64" ]; then ZIG_ARCH="aarch64"; else ZIG_ARCH="x86_64"; fi && \
    curl -Lo zig.tar.xz "https://ziglang.org/download/0.13.0/zig-linux-${ZIG_ARCH}-0.13.0.tar.xz" && \
    tar xf zig.tar.xz && \
    mv zig-linux-${ZIG_ARCH}-0.13.0 /usr/local/zig && \
    ln -s /usr/local/zig/zig /usr/local/bin/zig && \
    rm zig.tar.xz

# Install GVM (Go Version Manager)
ENV GVM_NO_UPDATE_PROFILE=1
RUN bash -c "bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)" && \
    echo 'source /root/.gvm/scripts/gvm' >> /etc/bash.bashrc

# Install kind
RUN curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-${TARGETARCH:-amd64} && \
    chmod +x /usr/local/bin/kind

# Pre-cache KinD Node Image to prevent 1.3GB dynamic network downloads during agent cluster creation
RUN if [ "$TARGETARCH" = "arm64" ]; then CRANE_ARCH="arm64"; else CRANE_ARCH="x86_64"; fi && \
    curl -sL "https://github.com/google/go-containerregistry/releases/latest/download/go-containerregistry_Linux_${CRANE_ARCH}.tar.gz" | tar -xz -C /usr/local/bin crane && \
    crane pull --platform linux/${TARGETARCH:-amd64} docker.io/kindest/node:v1.34.3 /opt/kind-node.tar && \
    echo "[Unit]\nDescription=Pre-load KinD Docker Image\nAfter=docker.service\nRequires=docker.service\n\n[Service]\nType=oneshot\nExecStart=/usr/bin/docker load -i /opt/kind-node.tar\nExecStartPost=/usr/bin/rm -f /opt/kind-node.tar\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/preload-kind.service && \
    systemctl enable preload-kind.service

# Install uv for extremely fast python package/MCP execution
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    cp /root/.local/bin/uv /usr/local/bin/uv && \
    cp /root/.local/bin/uvx /usr/local/bin/uvx

# Install nvm & Node.js 20 LTS
ENV NVM_DIR="/root/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install 20 && \
    nvm use 20 && \
    nvm alias default 20 && \
    npm install -g yarn @modelcontextprotocol/server-filesystem @modelcontextprotocol/server-github @modelcontextprotocol/server-postgres @playwright/mcp @modelcontextprotocol/server-memory @modelcontextprotocol/server-brave-search playwright && \
    npx playwright install --with-deps chromium && \
    ln -s $(nvm which 20) /usr/local/bin/node && \
    ln -s $(dirname $(nvm which 20))/npm /usr/local/bin/npm && \
    ln -s $(dirname $(nvm which 20))/npx /usr/local/bin/npx && \
    ln -s $(dirname $(nvm which 20))/yarn /usr/local/bin/yarn

# Install SDKMAN!
ENV SDKMAN_DIR="/root/.sdkman"
RUN curl -s "https://get.sdkman.io?rcupdate=false" | bash

# Pre-install the most common MCP python servers
RUN uv tool install mcp-server-sqlite && \
    uv tool install mcp-server-git && \
    uv tool install mcp-server-fetch

# Install Tilt for k8s development natively
RUN curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash

# Install Just command runner
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# Fix SSH environment loading and locale defaults
RUN sed -i -e 's/^AcceptEnv LANG LC_\*$/#AcceptEnv LANG LC_*/' /etc/ssh/sshd_config

# Set up simple default login for testing purposes
RUN echo "root:root" | chpasswd

# Prepare Cylon tool registry
COPY tools/bin/ /opt/cylon/bin/
COPY tools/etc/ /etc/cylon/tools.d/
RUN chmod +x /opt/cylon/bin/*

# Cylon specific configuration: Ensure systemd handles the init sequence seamlessly inside the VM
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
