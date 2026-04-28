# HOW: Google Workspace Document Write

## Purpose

Defines the standard pattern for writing content to a Google Doc tab via the `gws` CLI. All skills that write to Google Docs must follow this pattern.

## Constraints

- Always write content to a `/tmp/` file before building the JSON payload. Multi-KB strings passed directly in shell arguments cause quoting failures.
- Build the JSON payload via python3, not by concatenating strings in shell.
- Pass the payload to `gws docs documents batchUpdate` via `--json "$(cat /tmp/payload.json)"`.
- Never batch write operations across multiple tabs in a single `batchUpdate` call if subsequent operations depend on accurate `endIndex` values — endIndexes change after each write.
- After each write, treat all previously captured endIndexes as stale. Re-read the document if subsequent writes need accurate positions.

## Write Operations

**Insert text:** Use `insertText` with `location.index = 1` and the target `tabId`. This inserts at the beginning of the tab.

**Clear tab content:** Use `deleteContentRange` with `startIndex: 1` and `endIndex: endIndex - 1` (never include the final newline). Capture the current `endIndex` before any prior write changes it.

**Clear-then-rewrite** is the safest approach for replacing tab content. Delete existing content first, then insert new content. This avoids index arithmetic errors from partial replacements.

## Tmp File Naming

Name tmp files descriptively to avoid collisions between concurrent skill steps. Prefer `/tmp/<skill>_<purpose>.txt` (e.g., `/tmp/article.txt`, `/tmp/spec_coach_report.txt`, `/tmp/tab_<tabId>_new.txt`).
