# default recipe
default:
	@just --list

# Build the Linux kernel (vmlinux). This automatically exports the built raw ELF binary directly to artifacts/ 
build-kernel:
	mkdir -p artifacts
	DOCKER_BUILDKIT=1 docker build \
		--file kernel/Dockerfile \
		--output type=local,dest=artifacts \
		kernel/
	@echo "Kernel successfully exported to artifacts/vmlinux"

# Build the Ubuntu Rootfs OCI image used by Cylon to create ext4 overlays
build-rootfs version="latest":
	docker build -t cylon-rootfs-ubuntu:{{version}} rootfs/ubuntu/
	@echo "OCI Rootfs image cylon-rootfs-ubuntu:{{version}} compiled successfully"
