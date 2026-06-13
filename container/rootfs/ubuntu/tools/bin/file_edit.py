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
    old_text = args.get('old_text')
    new_text = args.get('new_text')
    
    if not file_path or old_text is None or new_text is None:
        sys.stderr.write("Missing path, old_text, or new_text arguments\n")
        sys.exit(1)

    if not os.path.exists(file_path):
        sys.stderr.write(f"File not found: {file_path}\n")
        sys.exit(1)

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    if old_text not in content:
        sys.stderr.write("old_text not found in file\n")
        sys.exit(1)

    new_content = content.replace(old_text, new_text)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

    sys.stdout.write("File successfully edited.\n")
except Exception as e:
    sys.stderr.write(f"Error editing file: {str(e)}\n")
    sys.exit(1)
