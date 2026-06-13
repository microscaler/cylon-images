# Cylon Images — root justfile
#
# Layout:
#   container/  — Firecracker microVM OCI rootfs + kernel (GHCR)
#   multipass/  — resurrection-node host OS (Multipass cloud-init)

import 'container/justfile'
import 'multipass/justfile'

set shell := ["bash", "-uc"]

default:
	@just --list

# Copy GITHUB_TOKEN from tiffany/.env (used by multipass render-cloud-init).
sync-github-token:
	#!/usr/bin/env bash
	set -euo pipefail
	grep '^GITHUB_TOKEN=' ../tiffany/.env > .env
	chmod 600 .env
	echo "Synced GITHUB_TOKEN to cylon-images/.env"
