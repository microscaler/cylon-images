#!/usr/bin/env python3
import sys
import json
import os
import glob

try:
    payload = sys.stdin.read()
    if not payload.strip():
        sys.stderr.write("No payload received on STDIN\n")
        sys.exit(1)
        
    args = json.loads(payload)
    pattern = args.get('pattern')
    root = args.get('root')
    
    if not pattern or not root:
        sys.stderr.write("Missing pattern or root arguments\n")
        sys.exit(1)

    target_pattern = os.path.join(root.rstrip('/'), pattern)
    
    # recursive=True allows matching **
    matches = glob.glob(target_pattern, recursive=True)
    
    sys.stdout.write("\n".join(matches) + "\n" if matches else "")
except Exception as e:
    sys.stderr.write(f"Error searching files: {str(e)}\n")
    sys.exit(1)
