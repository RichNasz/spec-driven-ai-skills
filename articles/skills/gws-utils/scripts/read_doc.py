#!/usr/bin/env python3
"""Read tabs from a Google Doc and print formatted content.

Usage:
  python3 read_doc.py <doc_id>                 # all tabs
  python3 read_doc.py <doc_id> --tab <name>    # one tab by name (case-insensitive)

Output (stdout) — one block per tab:
  === TAB 0: Tab Title | ID: <tabId> | endIndex=<n> ===
  tab text content...

Exit codes: 0 success, 1 error
"""
import argparse, json, subprocess, sys


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
    parser = argparse.ArgumentParser(description='Read tabs from a Google Doc')
    parser.add_argument('doc_id', help='Google Doc ID')
    parser.add_argument('--tab', default=None, metavar='NAME',
                        help='Print only the tab with this name (case-insensitive)')
    args = parser.parse_args()

    d = gws_get({"documentId": args.doc_id, "includeTabsContent": True})

    tabs = d.get('tabs', [])
    if not tabs:
        print("Warning: no tabs returned — verify includeTabsContent is supported", file=sys.stderr)

    tab_filter = args.tab.lower() if args.tab else None

    for i, tab in enumerate(tabs):
        props = tab.get('tabProperties', {})
        title = props.get('title', '(default)')
        if tab_filter and title.lower() != tab_filter:
            continue
        body = tab.get('documentTab', {}).get('body', {})
        content = body.get('content', [])
        end_index = content[-1].get('endIndex', 1) if content else 1
        text = ''.join(
            el.get('textRun', {}).get('content', '')
            for block in content
            for el in block.get('paragraph', {}).get('elements', [])
        )
        tab_id = props.get('tabId', '')
        print(f'=== TAB {i}: {title} | ID: {tab_id} | endIndex={end_index} ===')
        print(text)


if __name__ == '__main__':
    main()
