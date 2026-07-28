# Cylon Images — root justfile.
#
# Dockerfile-built native KVM bundles are the primary VM artifact. Historical
# Multipass recipes remain under multipass/ for cleanup only and are no longer
# imported into the supported command surface.

import 'container/justfile'

set shell := ["bash", "-uc"]

default:
    @just --list

# Build the Docker-composed guest and package it as an Aether KVM OCI artifact.
kvm-build version="dev" disk_size="16G":
    just --justfile "{{ justfile_directory() }}/container/kvm/justfile" build "{{ version }}" "{{ disk_size }}"

# Verify the fixed Aether image contract and qcow2 integrity.
kvm-verify version="dev":
    just --justfile "{{ justfile_directory() }}/container/kvm/justfile" verify "{{ version }}"

# Build, verify and push an Aether KVM artifact to GHCR.
kvm-push version="latest":
    just --justfile "{{ justfile_directory() }}/container/kvm/justfile" push "{{ version }}"

# Retained only to fail old automation before it copies credentials.
sync-github-token:
    @echo "sync-github-token retired: Multipass provisioning is unsupported" >&2
    @exit 2
