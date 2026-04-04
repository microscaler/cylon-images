#!/usr/bin/env python3
import sys
import json
import os

try:
    payload = sys.stdin.read()
    if not payload.strip():
        sys.stderr.write("No payload received on STDIN\n")
        sys.exit(1)
    
    args = json.loads(payload)
    file_path = args.get('path')
    if not file_path:
        sys.stderr.write("Missing 'path' argument\n")
        sys.exit(1)

    if not os.path.exists(file_path):
        sys.stderr.write(f"File not found: {file_path}\n")
        sys.exit(1)

    with open(file_path, 'r', encoding='utf-8') as f:
        sys.stdout.write(f.read())
except Exception as e:
    sys.stderr.write(f"Error reading file: {str(e)}\n")
    sys.exit(1)
