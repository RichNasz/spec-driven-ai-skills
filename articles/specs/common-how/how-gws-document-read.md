# HOW: Google Workspace Document Read

## Purpose

Defines the standard pattern for reading tab content from a Google Doc via the `gws` CLI. All skills that read Google Docs must follow this pattern.

## Constraints

- Always include `includeTabsContent: true` in the params — omitting it returns an empty `tabs` array.
- Always pipe `gws` output through python3 before JSON parsing. The CLI prepends a `Using keyring backend: keyring` line that breaks `json.loads` if not stripped.
- Never call `documents.get` and assume the tab order is stable across reads — always re-index from the response.
- If `tabs` is empty after a read, the most likely cause is a missing `includeTabsContent: true` param, not an empty document.

## Tab Filter (`--tab`)

`read_doc.py` accepts an optional `--tab <name>` argument (case-insensitive) that prints only the matching tab. Use it when a skill needs a single known tab from a multi-tab document to avoid feeding irrelevant content into context:

```bash
python3 read_doc.py <DOC_ID> --tab "Generated Article"   # one tab only
python3 read_doc.py <DOC_ID>                             # all tabs (default)
```

If `--tab` produces no output (empty result), the doc uses a different tab name — fall back to a full read and identify the target tab by its `=== TAB N: ...` header.

## Parallel Reads

When a skill must read multiple independent documents (e.g., spec + article, or multiple reference docs), issue all reads **in a single turn** so they execute concurrently. Do not issue one read, wait for the result, then issue the next.

## What to Extract Per Tab

For each tab in the response, capture:
- Tab index (position in the array)
- `tabProperties.title`
- `tabProperties.tabId`
- `endIndex` (last element's endIndex from `body.content`) — needed before any write operation
- Full plain text (concatenation of all `textRun.content` values within `body.content`)

## Reference Docs

Reference documents are read-only in every skill that accepts them. Apply the same read pattern — never call `batchUpdate` on a reference doc ID.

## Error Handling

If a required document cannot be read (bad ID, permission denied), stop and report the error with the document URL. Do not proceed to downstream steps.
