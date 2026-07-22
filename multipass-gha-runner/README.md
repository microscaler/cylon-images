# DEPRECATED — Multipass classic GitHub Actions runner

**Deprecated 2026-07-22.** Org CI now uses **ARC** on the shared k3s cluster.

| New home | Docs |
|----------|------|
| `shared-gitops-k8s-cluster` stack `arc` | [`docs/gha-arc.md`](../../shared-gitops-k8s-cluster/docs/gha-arc.md) |
| Node pool | Multipass `k8s-runner-*` (Day-0 `K8S_RUNNERS`) |

Workflows keep:

```yaml
runs-on: [self-hosted, linux, x64, microscaler]
```

## Do not launch new classic runners

```bash
# Retired — use ARC instead
# just launch && just register
```

To remove a leftover VM:

```bash
cd ~/Workspace/microscaler/cylon-images/multipass-gha-runner
just purge
```

This directory is kept only as an archive of the previous cloud-init / just recipes.
