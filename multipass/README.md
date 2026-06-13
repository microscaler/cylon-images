# Resurrection-node Multipass images

**Resurrection nodes** are Multipass guests on bare-metal dev hosts (e.g. ms02) that run the **Cylon host daemon** (`crates/cylon`) and host nested **Firecracker microVMs**. They are distinct from:

| Surface | Where | Role |
|---|---|---|
| **Platform `cylon-daemon`** | Kind on ms02 | Portal / hub integration |
| **Resurrection node** | Multipass on ms02 | Host daemon + Firecracker VMM for agent microVMs |
| **FAR guest rootfs** | `rootfs/ubuntu/` in this repo | OCI image inside each microVM |

## Binary supply chain

Tiffany **does not compile Rust inside resurrection nodes**. Binaries are:

1. **Built in GitHub Actions** — [`.github/workflows/release-binaries.yml`](../../tiffany/.github/workflows/release-binaries.yml) in the `tiffany` repo (on `v*` tags).
2. **Downloaded in cloud-init** — `install-cylon-from-release` pulls `cylon-linux-x86_64` (+ sha256) from **private** [GitHub Releases](https://github.com/microscaler/tiffany/releases) using **`/etc/cylon/github-token`**.
3. **Pinned** via `/etc/cylon/release-pin` (`latest` or e.g. `v0.1.0`).

### GITHUB_TOKEN (required until open-source)

Tiffany is private today. Each resurrection node needs a classic PAT with **`repo`** scope at **`/etc/cylon/github-token`** (mode `0600`, root-only).

**At `build-base` time** — token is merged into cloud-init (never committed):

| Source | How |
|---|---|
| `$GITHUB_TOKEN` | Export before `just build-base` |
| `../../tiffany/.env` | Canonical — same token as Tiffany dev secrets |
| `cylon-images/.env` | Copy of `GITHUB_TOKEN=` line only (gitignored) |
| `cloud-init.github-token.patch.yaml` | Copy from `.example`; gitignored |

```bash
# ms02 — token in tiffany .env after just decrypt-dev
cd ~/Workspace/microscaler/cylon-images/multipass
just build-base
# renders ~/resurrection-node-cloud-init.yaml (mode 600); safe to rm after build
```

**On running nodes** — sync from ms02 without rebuilding base:

```bash
cd ~/Workspace/microscaler/tiffany
just resurrection-nodes-sync-github-token
just resurrection-nodes-install-binary-from-release
```

**First release:** publish at least one tag before `build-base`, or cloud-init fails on download.

## Roll-out images

**Two layers:**

1. **`cloud-init.yaml`** — portable git artifact: KVM, Firecracker, authenticated release download, systemd unit.
2. **`resurrection-node-base`** — built once per host, then **cloned** to `resurrection-node-1..N`.

## Build on ms02

```bash
cd ~/Workspace/microscaler/cylon-images/multipass
just build-base
```

Provision workers (Ansible — preferred):

```bash
cd ~/Workspace/microscaler/cylon-local-infra
just resurrection-nodes-up
```

Per-node env + certs:

```bash
cd ~/Workspace/microscaler/tiffany
just resurrection-nodes-deploy-host-daemon
just resurrection-nodes-bridge
```

## Files

| File | Purpose |
|---|---|
| `cloud-init.yaml` | Guest provisioning (Firecracker, authenticated Cylon install, `cylon-host.service`) |
| `cloud-init.github-token.patch.yaml.example` | Local token patch template (gitignored `.yaml` variant) |
| `justfile` | `render-cloud-init`, `build-base`, `clone-node`, … |

## Operator docs

See [`cylon-local-infra/docs/far-multipass.md`](../../cylon-local-infra/docs/far-multipass.md).
