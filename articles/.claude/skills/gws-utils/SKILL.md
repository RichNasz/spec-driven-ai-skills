---
name: gws-utils
description: "Shared utility scripts for Google Workspace document operations via the gws CLI. Required by generate-article, spec-coach, and spec-auto-tune. Not invoked directly."
compatibility: "Requires gws CLI and Python 3. Install alongside generate-article, spec-coach, and spec-auto-tune."
metadata:
  suite: rh-skills-articles
  role: shared-dependency
---

# gws-utils — Google Workspace Document Utilities

Bundled scripts used by generate-article, spec-coach, and spec-auto-tune. Not a task skill — do not activate directly.

All scripts are called with `python3 .claude/skills/gws-utils/scripts/<script>.py` from the project root.

## Available scripts

- **`scripts/read_doc.py`** — Read all tabs from a Google Doc
- **`scripts/find_tab.py`** — Find a tab by exact name, return its tabId and endIndex
- **`scripts/create_tab.py`** — Create a new tab, return the new tabId
- **`scripts/clear_tab.py`** — Clear a tab's content (skips if tab is empty)
- **`scripts/write_tab.py`** — Write a file's content to a tab at index 1
- **`scripts/delete_tab.py`** — Delete a tab by tabId

## Script interfaces

### read_doc.py

```
python3 .claude/skills/gws-utils/scripts/read_doc.py <doc_id>
```

Reads all tabs from the document. Strips the gws keyring line internally.

stdout — one block per tab:
```
=== TAB 0: Tab Title | ID: <tabId> | endIndex=<n> ===
tab text content...

=== TAB 1: Next Tab | ID: <tabId> | endIndex=<n> ===
...
```

Exit codes: 0 success, 1 gws error or parse failure.

### find_tab.py

```
python3 .claude/skills/gws-utils/scripts/find_tab.py <doc_id> <tab_name>
```

Finds the tab whose title exactly matches `tab_name` (case-sensitive).

stdout on success: `<tabId>|<endIndex>`
Exit codes: 0 found, 1 not found or error (error message on stderr).

### create_tab.py

```
python3 .claude/skills/gws-utils/scripts/create_tab.py <doc_id> <tab_name> [insertion_index]
```

Creates a new tab. `insertion_index` is the 0-based target position (optional; omit to append).

stdout: new `tabId`
Exit codes: 0 success, 1 error.

### clear_tab.py

```
python3 .claude/skills/gws-utils/scripts/clear_tab.py <doc_id> <tab_id> <end_index>
```

Clears content from index 1 to `end_index - 1`. Silently exits 0 if `end_index <= 2` (tab is effectively empty — do not attempt to clear).

Exit codes: 0 success or skipped, 1 gws error.

### write_tab.py

```
python3 .claude/skills/gws-utils/scripts/write_tab.py <doc_id> <tab_id> <content_file>
```

Reads `content_file` and inserts its text at index 1 of the tab. Always write content to a `/tmp/` file first to avoid shell quoting failures on large inputs.

Exit codes: 0 success, 1 error.

### delete_tab.py

```
python3 .claude/skills/gws-utils/scripts/delete_tab.py <doc_id> <tab_id>
```

Deletes the tab. Uses `deleteTab` (not `deleteDocumentTab`).

Exit codes: 0 success, 1 error.

## Common patterns

**Read all spec tabs and use their content:**
```bash
python3 .claude/skills/gws-utils/scripts/read_doc.py <SPEC_ID>
```
Parse the header lines to extract tabId and endIndex when needed:
`=== TAB N: <title> | ID: <tabId> | endIndex=<n> ===`

**Find or create a named tab, then write content:**
```bash
# Try to find the tab
python3 .claude/skills/gws-utils/scripts/find_tab.py <DOC_ID> "Tab Name"
# Returns: <tabId>|<endIndex>  (exit 0) or error (exit 1)

# If not found — create it:
python3 .claude/skills/gws-utils/scripts/create_tab.py <DOC_ID> "Tab Name"
# Returns: <new_tabId>

# If found and endIndex > 2 — clear it:
python3 .claude/skills/gws-utils/scripts/clear_tab.py <DOC_ID> <TAB_ID> <END_INDEX>

# Write content:
python3 .claude/skills/gws-utils/scripts/write_tab.py <DOC_ID> <TAB_ID> /tmp/content.txt
```

**Reorder a tab (buffer-delete-recreate):**
```bash
# Content already captured from read_doc.py — save to /tmp/tab_<tabId>_content.txt
python3 .claude/skills/gws-utils/scripts/delete_tab.py <DOC_ID> <SOURCE_TAB_ID>
python3 .claude/skills/gws-utils/scripts/create_tab.py <DOC_ID> "<TAB_TITLE>" <TARGET_INDEX>
# Capture new tabId from above output
python3 .claude/skills/gws-utils/scripts/write_tab.py <DOC_ID> <NEW_TAB_ID> /tmp/tab_<SOURCE_TAB_ID>_content.txt
```
