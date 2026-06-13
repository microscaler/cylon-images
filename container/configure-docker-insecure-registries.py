#!/usr/bin/env python3
"""Add ms02 dev registry to Docker insecure-registries."""
import json
from pathlib import Path

p = Path("/etc/docker/daemon.json")
data = json.loads(p.read_text()) if p.exists() else {}
regs = set(data.get("insecure-registries", []))
regs.update(["192.168.1.189:5001", "127.0.0.1:5001", "localhost:5001"])
data["insecure-registries"] = sorted(regs)
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"Updated {p}")
