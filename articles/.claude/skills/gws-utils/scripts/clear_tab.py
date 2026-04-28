#!/usr/bin/env python3
"""Clear a tab's content. Skips silently if endIndex <= 2 (tab is empty).

Usage: python3 clear_tab.py <doc_id> <tab_id> <end_index>

Exit codes: 0 success or skipped, 1 error
"""
import json, subprocess, sys


def main():
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <doc_id> <tab_id> <end_index>", file=sys.stderr)
        sys.exit(1)

    doc_id, tab_id = sys.argv[1], sys.argv[2]
    try:
        end_index = int(sys.argv[3])
    except ValueError:
        print(f"Error: end_index must be an integer, got {sys.argv[3]!r}", file=sys.stderr)
        sys.exit(1)

    if end_index <= 2:
        sys.exit(0)

    payload = {"requests": [{"deleteContentRange": {"range": {
        "startIndex": 1,
        "endIndex": end_index - 1,
        "tabId": tab_id
    }}}]}

    result = subprocess.run(
        ['gws', 'docs', 'documents', 'batchUpdate',
         '--params', json.dumps({"documentId": doc_id}),
         '--json', json.dumps(payload)],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"Error: gws batchUpdate (clear) failed: {result.stderr.strip()}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
