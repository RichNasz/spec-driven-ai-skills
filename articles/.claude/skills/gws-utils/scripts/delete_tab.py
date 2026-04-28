#!/usr/bin/env python3
"""Delete a tab by tabId.

Usage: python3 delete_tab.py <doc_id> <tab_id>

Exit codes: 0 success, 1 error
"""
import json, subprocess, sys


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <doc_id> <tab_id>", file=sys.stderr)
        sys.exit(1)

    doc_id, tab_id = sys.argv[1], sys.argv[2]
    payload = {"requests": [{"deleteTab": {"tabId": tab_id}}]}

    result = subprocess.run(
        ['gws', 'docs', 'documents', 'batchUpdate',
         '--params', json.dumps({"documentId": doc_id}),
         '--json', json.dumps(payload)],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"Error: gws batchUpdate (deleteTab) failed: {result.stderr.strip()}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
