#!/usr/bin/env python3
"""Find a tab by exact name in a Google Doc.

Usage: python3 find_tab.py <doc_id> <tab_name>

Output (stdout) on success: <tabId>|<endIndex>
Exit codes: 0 found, 1 not found or error
"""
import json, subprocess, sys


def gws_get(params):
    result = subprocess.run(
        ['gws', 'docs', 'documents', 'get', '--params', json.dumps(params)],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"Error: gws get failed: {result.stderr.strip()}", file=sys.stderr)
        sys.exit(1)
    lines = '\n'.join(l for l in result.stdout.splitlines() if not l.startswith('Using keyring'))
    try:
        return json.loads(lines)
    except json.JSONDecodeError as e:
        print(f"Error: failed to parse gws response: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <doc_id> <tab_name>", file=sys.stderr)
        sys.exit(1)

    doc_id, tab_name = sys.argv[1], sys.argv[2]
    d = gws_get({"documentId": doc_id, "includeTabsContent": True})

    for tab in d.get('tabs', []):
        props = tab.get('tabProperties', {})
        if props.get('title') == tab_name:
            tab_id = props.get('tabId', '')
            body = tab.get('documentTab', {}).get('body', {})
            content = body.get('content', [])
            end_index = content[-1].get('endIndex', 1) if content else 1
            print(f'{tab_id}|{end_index}')
            sys.exit(0)

    print(f"Error: tab '{tab_name}' not found in doc {doc_id}", file=sys.stderr)
    sys.exit(1)


if __name__ == '__main__':
    main()
