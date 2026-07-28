# Aether native KVM image

This directory packages the existing Dockerfile-built Ubuntu guest filesystem
as a native QEMU/KVM boot bundle. It does not require Docker, Multipass, Cylon,
or Regenesis on an Aether node.

The published OCI image contains exactly four contract files:

| File | Purpose |
|---|---|
| `image.json` | Versioned `aetherd` image contract |
| `rootfs.qcow2` | Immutable Dockerfile-built base disk |
| `vmlinuz` | Direct-boot guest kernel |
| `initrd.img` | Matching initramfs with virtio/ext4 support |

`aetherd` pulls `oci://ghcr.io/microscaler/aether-kvm-ubuntu:<tag>`, caches the
bundle by manifest digest, creates a per-workload qcow2 overlay, and starts
QEMU with KVM acceleration. The NoCloud ISO remains a small, instance-specific
metadata layer; software and filesystem composition stay in the Dockerfile.

Build and verify locally:

```bash
just --justfile container/kvm/justfile build dev
just --justfile container/kvm/justfile verify dev
```

The Ubuntu rootfs includes `cloud-init` and `qemu-guest-agent`. Machine identity
and SSH host keys are cleared during disk construction, and the inherited test
root password is locked. Each VM regenerates its identity and receives any
authorized access through its instance-specific Cloud-Init seed.
