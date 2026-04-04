FROM ubuntu:25.04

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
    postgresql \
    postgresql-contrib \
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
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME

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
    npm install -g @modelcontextprotocol/server-filesystem @modelcontextprotocol/server-github @modelcontextprotocol/server-postgres @playwright/mcp @modelcontextprotocol/server-memory @modelcontextprotocol/server-brave-search playwright && \
    npx playwright install --with-deps chromium && \
    ln -s $(nvm which 20) /usr/local/bin/node && \
    ln -s $(dirname $(nvm which 20))/npm /usr/local/bin/npm && \
    ln -s $(dirname $(nvm which 20))/npx /usr/local/bin/npx

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
