# default recipe
default:
	@just --list

dev_registry := "kind-registry"
dev_registry_port := "5001"
dev_registry_host := env_var_or_default("MS02_LAN_IP", "192.168.1.189")

# Copy GITHUB_TOKEN from tiffany/.env into this repo (gitignored .env for multipass render-cloud-init).
sync-github-token:
	#!/usr/bin/env bash
	set -euo pipefail
	grep '^GITHUB_TOKEN=' ../tiffany/.env > .env
	chmod 600 .env
	echo "Synced GITHUB_TOKEN to cylon-images/.env"

# Bind local registry on all interfaces so resurrection nodes can pull OCI layers.
expose-dev-registry:
	#!/usr/bin/env bash
	set -euo pipefail
	docker rm -f {{dev_registry}} 2>/dev/null || true
	docker run -d --restart=always \
		-p "0.0.0.0:{{dev_registry_port}}:5000" \
		--name {{dev_registry}} registry:2
	echo "Dev registry: {{dev_registry_host}}:{{dev_registry_port}}"

# One-time ms02 host setup: allow plain-HTTP pushes/pulls to the dev registry.
configure-docker-insecure-registries:
	#!/usr/bin/env bash
	set -euo pipefail
	sudo python3 - <<'PY'
import json, pathlib
p = pathlib.Path("/etc/docker/daemon.json")
data = json.loads(p.read_text()) if p.exists() else {}
regs = set(data.get("insecure-registries", []))
regs.update(["192.168.1.189:5001", "127.0.0.1:5001", "localhost:5001"])
data["insecure-registries"] = sorted(regs)
p.write_text(json.dumps(data, indent=2) + "\n")
print("Updated", p)
PY
	sudo systemctl restart docker
	echo "Docker restarted with insecure-registries for :5001"

# Build the Linux kernel (vmlinux). Exports to artifacts/
build-kernel:
	mkdir -p artifacts
	DOCKER_BUILDKIT=1 docker build \
		--file kernel/Dockerfile \
		--output type=local,dest=artifacts \
		kernel/
	@echo "Kernel exported to artifacts/vmlinux"

# Fast minimal rootfs for Firecracker boot smoke (seconds, not hours).
build-rootfs-minimal tag="dev":
	docker build -t cylon-rootfs-minimal:{{tag}} rootfs/minimal/
	@echo "Built cylon-rootfs-minimal:{{tag}}"

# Push minimal rootfs to ms02 dev registry (resurrection nodes pull from MS02_LAN_IP:5001).
push-rootfs-minimal tag="dev": configure-docker-insecure-registries expose-dev-registry build-rootfs-minimal
	docker tag cylon-rootfs-minimal:{{tag}} {{dev_registry_host}}:{{dev_registry_port}}/cylon-rootfs-minimal:{{tag}}
	docker push {{dev_registry_host}}:{{dev_registry_port}}/cylon-rootfs-minimal:{{tag}}
	@echo "Pushed {{dev_registry_host}}:{{dev_registry_port}}/cylon-rootfs-minimal:{{tag}}"

# Copy Firecracker kernel to resurrection-node-1 (quick path before full kernel roll-out).
stage-kernel-node-1:
	multipass transfer artifacts/vmlinux resurrection-node-1:/tmp/vmlinux
	multipass exec resurrection-node-1 -- sudo install -o cylon -g cylon -m 644 /tmp/vmlinux /home/cylon/cylon-images/vmlinux

# Build the Ubuntu Rootfs OCI image used by Cylon to create ext4 overlays
build-rootfs version="latest":
	rm -rf rootfs/ubuntu/cylon-skills-registry
	cp -r ../cylon-skills rootfs/ubuntu/cylon-skills-registry
	docker build -t cylon-rootfs-ubuntu:{{version}} rootfs/ubuntu/
	@echo "OCI Rootfs image cylon-rootfs-ubuntu:{{version}} compiled successfully"

# Push full ubuntu rootfs to dev registry
push-rootfs-ubuntu version="latest": expose-dev-registry build-rootfs
	docker tag cylon-rootfs-ubuntu:{{version}} {{dev_registry_host}}:{{dev_registry_port}}/cylon-rootfs-ubuntu:{{version}}
	docker push {{dev_registry_host}}:{{dev_registry_port}}/cylon-rootfs-ubuntu:{{version}}
	@echo "Pushed {{dev_registry_host}}:{{dev_registry_port}}/cylon-rootfs-ubuntu:{{version}}"
