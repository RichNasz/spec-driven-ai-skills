#!/usr/bin/env python3
"""Write the contents of a file to a tab at index 1.

Usage: python3 write_tab.py <doc_id> <tab_id> <content_file>

Exit codes: 0 success, 1 error
"""
import json, subprocess, sys


def main():
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <doc_id> <tab_id> <content_file>", file=sys.stderr)
        sys.exit(1)

    doc_id, tab_id, content_file = sys.argv[1], sys.argv[2], sys.argv[3]

    try:
        with open(content_file) as f:
            text = f.read()
    except OSError as e:
        print(f"Error: cannot read {content_file!r}: {e}", file=sys.stderr)
        sys.exit(1)

    payload = {"requests": [{"insertText": {
        "location": {"index": 1, "tabId": tab_id},
        "text": text
    }}]}

    result = subprocess.run(
        ['gws', 'docs', 'documents', 'batchUpdate',
         '--params', json.dumps({"documentId": doc_id}),
         '--json', json.dumps(payload)],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"Error: gws batchUpdate (write) failed: {result.stderr.strip()}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
