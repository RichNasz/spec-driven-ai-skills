#!/usr/bin/env python3
"""Create a new tab in a Google Doc and print the new tabId.

Usage: python3 create_tab.py <doc_id> <tab_name>

The new tab is always appended at the end of the document.
Output (stdout): new tabId
Exit codes: 0 success, 1 error
"""
import json, subprocess, sys


def gws_update(doc_id, payload):
    result = subprocess.run(
        ['gws', 'docs', 'documents', 'batchUpdate',
         '--params', json.dumps({"documentId": doc_id}),
         '--json', json.dumps(payload)],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"Error: gws batchUpdate failed: {result.stderr.strip()}", file=sys.stderr)
        sys.exit(1)
    lines = '\n'.join(l for l in result.stdout.splitlines() if not l.startswith('Using keyring'))
    try:
        return json.loads(lines) if lines.strip() else {}
    except json.JSONDecodeError as e:
        print(f"Error: failed to parse gws response: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <doc_id> <tab_name>", file=sys.stderr)
        sys.exit(1)

    doc_id, tab_name = sys.argv[1], sys.argv[2]
    request = {"addDocumentTab": {"tabProperties": {"title": tab_name}}}

    d = gws_update(doc_id, {"requests": [request]})
    try:
        new_tab_id = d['replies'][0]['addDocumentTab']['tabProperties']['tabId']
        print(new_tab_id)
    except (KeyError, IndexError) as e:
        print(f"Error: could not extract new tabId from response: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
