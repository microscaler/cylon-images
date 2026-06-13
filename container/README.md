# Container artifacts

Firecracker **microVM** build outputs — kernel ELF and OCI rootfs images published to GHCR.

| Path | Purpose |
|---|---|
| `kernel/` | Linux `vmlinux` build (Firecracker guest config 6.1.102) |
| `rootfs/ubuntu/` | Full agent guest OCI image (`cylon-rootfs-ubuntu`) |
| `rootfs/minimal/` | Fast systemd smoke rootfs for dev (`cylon-rootfs-minimal`) |
| `artifacts/` | Local build output (`just build-kernel`) — gitignored |

## Commands

Run from repo root (`just build-kernel`) or here:

```bash
cd container
just build-kernel
just build-rootfs
just push-rootfs-minimal
```

**CI:** `.github/workflows/kernel.yml` and `rootfs.yml` use paths under `container/`.
