---
name: generate-article
description: Use when given a Google Doc spec and a destination Google Doc to write a generated article into — reads all tabs from the source doc sequentially as a prompt chain, generates the article, then writes it to a named tab in the destination doc
compatibility: "Requires gws CLI, Python 3, and the gws-utils skill"
metadata:
  requires: gws-utils
  suite: rh-skills-articles
---

# Generate Article from Google Doc Spec

## Overview

Reads a multi-tab Google Doc where each tab is a sequential refinement prompt. Applies all prompts in order to generate an article. Writes the result to a named tab in a destination Google Doc using `gws`.

## Usage

```
/generate-article <source_doc_url> <dest_doc_url> [dest_tab_name]
/generate-article <config_yaml_path>
```

**Positional form:**
- `source_doc_url` — Google Doc URL containing the spec tabs (each tab is a prompt, applied in index order)
- `dest_doc_url` — Google Doc URL to write the generated article into
- `dest_tab_name` — Name of the tab to write into (default: `Generated Article`). Created if it doesn't exist.

**YAML form:** Pass the path to a YAML config file instead of positional URLs. Pass the same file to all three skills to run the full flywheel.
```yaml
spec_doc_url:    "https://docs.google.com/document/d/<SPEC_ID>/edit"
article_doc_url: "https://docs.google.com/document/d/<ARTICLE_ID>/edit"
dest_tab_name:   "Generated Article"  # optional, defaults to "Generated Article"
reference_docs:                        # optional — read as additional context during generation
  - url: "..."
    description: "..."
```
`dest_tab_name` is optional. `reference_docs` is optional — when present, the skill reads them as supplementary context (style guides, editorial checklists, author outlines) to inform article generation. See `config.example.yaml` in the plugin root for the full annotated template.

Extract the document ID from a URL like `https://docs.google.com/document/d/<DOC_ID>/edit`.

## Hard Constraints (enforce before doing anything else)

1. **Source doc is read-only.** Never call `batchUpdate` on the source document ID. Only `documents.get` is permitted against it.
2. **Source and destination must be different docs.** Extract the document ID from both URLs and compare them. If they are identical, stop immediately and tell the user: "Source and destination cannot be the same document."

## Step-by-Step Process

### 0. Validate inputs

**Resolve URLs from args or YAML.** If the argument ends in `.yaml` or `.yml`, load it; otherwise use positional args:
```python
import re, os

def doc_id(url):
    return re.search(r'/d/([a-zA-Z0-9_-]+)', url).group(1)

arg = "<first_argument>"
if arg.endswith(('.yaml', '.yml')):
    config = {'reference_docs': []}
    current_ref = None
    with open(os.path.expanduser(arg)) as f:
        for line in f:
            s = line.strip()
            if not s or s.startswith('#'):
                continue
            if s.startswith('- '):
                if current_ref is not None:
                    config['reference_docs'].append(current_ref)
                current_ref = {}
                s = s[2:].strip()
            elif not line[0:1].isspace() and current_ref is not None:
                config['reference_docs'].append(current_ref)
                current_ref = None
            if ':' in s:
                k, _, v = s.partition(':')
                k, v = k.strip(), v.strip().strip('"').strip("'")
                if current_ref is not None:
                    current_ref[k] = v
                elif v:
                    config[k] = v
    if current_ref is not None:
        config['reference_docs'].append(current_ref)
    source_doc_url = config.get('spec_doc_url', '')
    dest_doc_url   = config.get('article_doc_url', '')
    dest_tab_name  = config.get('dest_tab_name', 'Generated Article')
    reference_docs = config.get('reference_docs', [])  # list of {url, description}
else:
    source_doc_url = arg          # first positional
    dest_doc_url   = "<second_argument>"
    dest_tab_name  = "<third_argument_or_default: Generated Article>"
    reference_docs = []

src = doc_id(source_doc_url)
dst = doc_id(dest_doc_url)
assert src != dst, "Source and destination cannot be the same document."
```
Stop and report the error if IDs match. Never proceed to Step 1 until this passes.

### 1. Read all source tabs

```bash
python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/read_doc.py <SOURCE_ID>
```

### 1b. Read reference documents (if provided)

If `reference_docs` is non-empty, issue **all reference doc reads simultaneously in a single turn**:
```bash
python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/read_doc.py <REF_DOC_1_ID>
python3 ${CLAUDE_PLUGIN_PATH}/skills/gws-utils/scripts/read_doc.py <REF_DOC_2_ID>
# one call per reference doc, all in the same turn
```
Save the full text of each. Use the `description` field from the YAML to understand each doc's purpose (e.g., style guide, editorial checklist, author outline). Reference documents are read-only — never call any write script against them.

If `reference_docs` is empty, skip this step.

### 2. Generate the article

Process tabs in index order as a sequential prompt chain — each tab refines the output of the previous one. Apply all instructions cumulatively to produce a final article.

Common tab patterns (adapt to whatever is in the source doc):
- Early tabs: persona, concept, core content
- Middle tabs: structure, audience, technical details
- Later tabs: tone/style rewrite, quality scoring with rewrite loop, anti-cliché scrub

### 3. Find or create the destination tab

**Find the tab or create it:**
```bash
if TAB_INFO=$(python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/find_tab.py <DEST_ID> "<TAB_NAME>"); then
    TAB_ID=$(echo "$TAB_INFO" | cut -d'|' -f1)
    END_INDEX=$(echo "$TAB_INFO" | cut -d'|' -f2)
    python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/clear_tab.py <DEST_ID> "$TAB_ID" "$END_INDEX"
else
    TAB_ID=$(python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/create_tab.py <DEST_ID> "<TAB_NAME>")
fi
```
`find_tab.py` exits 0 with `tabId|endIndex` if found, exits 1 if not found. `clear_tab.py` silently skips if endIndex ≤ 2. `create_tab.py` prints the new tabId.

### 4. Write the article

Write the article text to `/tmp/article.txt` then pass it to the write script:

```bash
python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/write_tab.py <DEST_ID> "$TAB_ID" /tmp/article.txt
```

## Key Notes

- **Never write to the source doc** — gws-utils write scripts are only ever called with the destination doc ID
- **Always validate IDs match** before any API call — extract IDs from both URLs and compare
- All gws API calls, keyring-line stripping, and JSON encoding are handled by the gws-utils scripts — do not call gws directly
- Write the article text to `/tmp/article.txt` before calling `write_tab.py` — the script reads from a file to avoid shell quoting issues with large text
- If `read_doc.py` returns no tab output, the doc was fetched correctly but has no tabs — verify the doc ID is correct
