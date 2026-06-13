#!/usr/bin/env python3
"""Deep-merge cloud-init YAML files (concatenate list keys like write_files)."""

from __future__ import annotations

import sys
from pathlib import Path

import yaml


def merge(base: dict, patch: dict) -> dict:
    result = dict(base)
    for key, patch_val in patch.items():
        base_val = result.get(key)
        if isinstance(base_val, list) and isinstance(patch_val, list):
            result[key] = base_val + patch_val
        elif isinstance(base_val, dict) and isinstance(patch_val, dict):
            result[key] = merge(base_val, patch_val)
        else:
            result[key] = patch_val
    return result


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: merge_cloud_init.py base.yaml patch.yaml out.yaml", file=sys.stderr)
        return 2
    base_path, patch_path, out_path = map(Path, sys.argv[1:4])
    base_doc = yaml.safe_load(base_path.read_text()) or {}
    patch_doc = yaml.safe_load(patch_path.read_text()) or {}
    merged = merge(base_doc, patch_doc)
    out_path.write_text(yaml.safe_dump(merged, sort_keys=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
