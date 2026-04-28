---
name: spec-auto-tune
description: Reads a Spec Coach report from a generated article doc and automatically applies the recommended improvements to the spec document. Accepts a YAML config file that identifies the spec doc, article doc, and any number of reference docs for research-backed improvements. Reports all changes made, including tab reorders performed via the create-verify-delete pattern.
compatibility: "Requires gws CLI, Python 3, and the gws-utils skill"
metadata:
  requires: gws-utils
  suite: rh-skills-articles
---

# Spec Auto-Tune — Automated Spec Improvement from Spec Coach Output

## Overview

Reads the "Spec Coach" tab in the article document, analyzes its recommendations, and applies improvements directly to the spec document. All factual additions are grounded in the provided reference documents — nothing is invented. Tab reordering uses a create-verify-delete pattern: replacement tabs are created in the desired order first (appending to the end), their content is verified, and only then are the originals deleted. At no point is content at risk — a failure before deletion leaves all originals intact.

## Usage

```
/spec-auto-tune <config_yaml_path>
```

- `config_yaml_path` — Path to a YAML file (absolute or relative to working directory) that identifies all documents needed for the run.

### Config YAML Format

```yaml
spec_doc_url: "https://docs.google.com/document/d/<SPEC_ID>/edit"
article_doc_url: "https://docs.google.com/document/d/<ARTICLE_ID>/edit"
reference_docs:
  - url: "https://docs.google.com/document/d/<REF_ID>/edit"
    description: "Red Hat Agentic AI FAQ — factual grounding for Red Hat product capabilities"
  - url: "https://docs.google.com/document/d/<REF2_ID>/edit"
    description: "Another reference document and what it contains"
```

`reference_docs` is optional. Omit the key or leave it empty if no research grounding is needed.

## Hard Constraints (enforce before doing anything else)

1. **Spec doc is the only write target.** Never call `batchUpdate` on the article doc ID or any reference doc ID.
2. **Spec and article must be different docs.** Extract IDs from both URLs and compare. If identical, stop immediately and tell the user: "Spec and article cannot be the same document."
3. **Never invent facts.** Any new factual content about products, capabilities, or technical details must come verbatim or paraphrased from one of the reference docs. If a recommendation requires factual grounding and no reference doc contains the relevant information, skip that recommendation and document why.
4. **Purely instructional changes need no research.** Adding/improving spec instructions (rubric fixes, checklist items, transition examples, structural requirements) does not require reference docs — apply these freely.
5. **Tab reordering uses create-verify-delete.** The Google Docs API does not support positional tab insertion (`insertionIndex` is not a valid field in `addDocumentTab` — confirmed by API validation error). To reorder: (1) find `first_affected_pos` = minimum of all positions involved in any TAB_REORDER recommendation; (2) buffer all tabs from `first_affected_pos` to end (saved to `/tmp/tab_<tabId>_content.txt` during Step 1 or overwritten by TAB_CONTENT writes); (3) create new tabs in the desired final order by appending — duplicates exist temporarily; (4) verify each new tab's content; (5) delete original tabs by tabId. Never delete before verifying — a mid-operation failure leaves all originals intact.

## Step-by-Step Process

### 0. Validate config and inputs

```python
import re, os

def doc_id(url):
    return re.search(r'/d/([a-zA-Z0-9_-]+)', url).group(1)

# Parse YAML manually — yaml module unavailable in this environment
config = {'reference_docs': []}
current_ref = None
with open(os.path.expanduser(config_yaml_path)) as f:
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

spec_id   = doc_id(config.get('spec_doc_url', ''))
article_id = doc_id(config.get('article_doc_url', ''))
assert spec_id != article_id, "Spec and article cannot be the same document."
ref_docs = config.get('reference_docs', [])
```

Stop and report the error if IDs match. Never proceed until this passes.

### 1. Read all documents

**Read all spec tabs (with content and endIndexes):**
```bash
python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/read_doc.py <SPEC_ID>
```

Save: tab index, title, tabId, endIndex, and full text for every spec tab. Each tab is delimited by a `=== TAB N: title | ID: tabId | endIndex=n ===` header line — parse these to build your tab registry.

Also save each tab's full text to `/tmp/tab_<tabId>_content.txt` during this step. For any tab subsequently modified by a TAB_CONTENT write in Step 3, overwrite the same file with the updated content. This ensures the reorder step always uses current content without requiring a second API read.

**Read the Spec Coach tab from the article doc:**
```bash
python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/read_doc.py <ARTICLE_ID>
```

Find the section starting with `=== TAB N: Spec Coach | ...` in the output and extract its text. If no such section exists, stop and tell the user: "No 'Spec Coach' tab found in the article document. Run /spec-coach first."

**Read reference docs (if any are listed in config):**
```bash
python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/read_doc.py <REF_ID>
```

Read all reference docs before the analysis phase. You will need their content when evaluating whether factual additions are supportable.

### 2. Read saturation state and categorize all recommendations

**2a. Read the Constraint Saturation verdict (PART 1).**
Find the SATURATION VERDICT line in the Spec Coach report. Record whether the spec is HEALTHY, TIGHT, or OVER-DETERMINED. This controls how recommendations are applied:
- HEALTHY: Apply additions and removals normally.
- TIGHT: Apply removals before additions. For any recommendation that adds a new coverage item, verify that the report also recommends removing or relaxing an existing item. If not, skip the addition and document why ("Spec is TIGHT — adding coverage without removing coverage would push toward OVER-DETERMINED").
- OVER-DETERMINED: Prioritize removals and relaxations. Do not apply any recommendation that increases the constraint count unless it simultaneously removes at least one existing constraint of equal or greater weight. Document all skipped additions.

**2b. Categorize recommendations from all report parts.**
Read all four parts of the Spec Coach report and extract every distinct recommendation:
- PART 1 (Constraint Saturation Analysis): Scoring pass reductions, contradictory constraint resolutions
- PART 2 (Spec Quality Scoring — "BEYOND THE CEILING" section): Quality improvements, organized as ADDITIONS, REMOVALS AND RELAXATIONS, and CONFLICTS
- PART 3 (Semantic Drift Analysis — "Top 3 spec modifications" and "Recommended reorderings"): Drift reduction changes
- PART 4 (Factual Accuracy Audit — if present): Spec corrections for inaccuracies and hallucination-causing instructions

For each distinct recommendation, assign a category:

**TAB_CORRECTION** — Fixes a factual inaccuracy in the spec identified by the Factual Accuracy Audit (PART 4). These are the highest-confidence changes: the report provides the exact spec tab, the incorrect text, and the corrected text sourced from reference documents. Apply these first, before other changes. Examples:
- "Tab 7, change 'Prometheus alerts' to 'cluster alerts'" (reference docs say "alerts or custom triggers" without naming Prometheus)
- "Tab 6, change 'supports the Anthropic Messages API' to 'plans to support the Anthropic Messages API'" (reference docs say "planned")

**TAB_REMOVAL** — Removes, relaxes, or merges existing spec constraints. These come from PART 2 (REMOVALS AND RELAXATIONS section) and PART 1 (saturation fixes). Apply these before any additions. Examples:
- "Remove the 9.7 scoring loop from Tab 8" (redundant scoring pass)
- "Downgrade 'dedicated paragraph' to 'substantive mention' for Tab 4 items" (freeing word budget)
- "Merge Tabs 8 and 9 into a single quality review tab"

**TAB_CONTENT** — Modifiable via API. Examples:
- Adding instructions, examples, or requirements to an existing tab
- Replacing a scoring rubric sentence
- Inserting a checklist item
- Appending a requirement section

**TAB_REORDER** — Automated via create-verify-delete. No `insertionIndex` used. Examples:
- "Move Tab X to position Y"
- "Consolidate tabs A and B"
- "Move Anti Beige before the scoring tabs"

**NEEDS_RESEARCH** — Requires facts from reference docs before applying. Examples:
- "Add concrete examples of [product capability] to Tab N"
- "Expand the description of [specific technology] with technical detail"

**INSTRUCTIONAL_ONLY** — Purely structural spec instructions, no research needed. Examples:
- "Add transition examples to Tab 3"
- "Fix the scoring rubric weights"
- "Add a coverage checklist item"
- "Add banned sentence patterns to Anti Beige tab"

Note: INSTRUCTIONAL_ONLY is a subset of TAB_CONTENT. Distinguish it explicitly so you know not to look for research support before applying.

After categorizing, assess each NEEDS_RESEARCH item against the reference doc content:
- If the reference doc contains relevant information: mark as **RESEARCHABLE** (will apply)
- If no reference doc covers it: mark as **CANNOT_APPLY** with the reason ("No reference doc covers [topic]")

### 3. Apply changes in priority order

Apply changes in this order: TAB_CORRECTION first, then TAB_REMOVAL, then TAB_CONTENT / INSTRUCTIONAL_ONLY / RESEARCHABLE. This ordering matters — corrections fix factual errors that could propagate if left in place, removals free constraint budget before additions consume it.

For each applicable recommendation, determine the most precise write operation:

**Append:** Add new text to the end of an existing tab (use endIndex-1 as insert position, OR clear+rewrite for clarity).

**Replace sentence:** When replacing a specific phrase or sentence within a tab, use delete+reinsert of the full tab content to avoid index arithmetic errors.

**Insert checklist item:** Use clear+rewrite of the full tab content.

**General approach — clear and rewrite is safest:**
```bash
# Write the new content to a temp file first
python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/clear_tab.py <SPEC_ID> "<TAB_ID>" <END_INDEX>
python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/write_tab.py <SPEC_ID> "<TAB_ID>" /tmp/tab_new_content.txt
```

Write new tab content to `/tmp/tab_<tabId>_new.txt` before calling `write_tab.py` — avoids shell quoting issues with large text.

**For TAB_REORDER items:** Apply after all TAB_CONTENT changes are complete. Use the create-verify-delete pattern.

```bash
# 1. Compute first_affected_pos = min(all positions involved in any reorder recommendation)
# 2. Build desired_order = full tab sequence from first_affected_pos to end, with all reorders applied
# 3. Content is already in /tmp/tab_<tabId>_content.txt from Step 1 (or overwritten by TAB_CONTENT writes)

# 4. CREATE all replacement tabs in desired_order by appending (doc has duplicates temporarily):
for each tab in desired_order:
    NEW_TAB_ID=$(python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/create_tab.py <SPEC_ID> "<TAB_TITLE>")
    python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/write_tab.py <SPEC_ID> "$NEW_TAB_ID" /tmp/tab_<OLD_TAB_ID>_content.txt
    # record OLD_TAB_ID → NEW_TAB_ID mapping

# 5. VERIFY each new tab: re-read the doc and check the last ~200 chars of each NEW_TAB_ID
#    match the expected content. If any verification fails, STOP — originals are still intact.
python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/read_doc.py <SPEC_ID>
# find each new tab by NEW_TAB_ID in the output and check content

# 6. DELETE all original tabs by tabId (order doesn't matter — deletion uses tabId, not position):
for each original tab (from first_affected_pos to end):
    python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/delete_tab.py <SPEC_ID> "<ORIGINAL_TAB_ID>"
```

**For RESEARCHABLE items:** Draft the new content using relevant facts from the reference doc, then apply it. Include the reference doc description in your internal tracking so you know the source.

**For CANNOT_APPLY items:** Skip the API call. Document these in the output report.

Apply changes one tab at a time. Never batch changes to multiple tabs in a single batchUpdate call if they depend on accurate endIndexes — endIndexes change after each write.

### 4. Compose the change summary report

After all writes complete, produce a structured plain-text report. Write it to `/tmp/spec_auto_tune_report.txt`.

```
SPEC AUTO-TUNE REPORT
Generated: <current date>
Config: <config_yaml_path>
Spec document: <spec_doc_url>
Article document: <article_doc_url>
Saturation state: <HEALTHY / TIGHT / OVER-DETERMINED> (from Spec Coach PART 1)

================================================================================
FACTUAL CORRECTIONS APPLIED
================================================================================

  <N> factual corrections applied from the Spec Coach accuracy audit.

  1. <Tab name> (Tab ID: <tabId>)
     Was: "<original text>"
     Now: "<corrected text>"
     Source: <reference doc that provides the correct fact>

  2. ...

  (If no accuracy audit was performed: "Skipped — no reference documents provided.")

================================================================================
CONSTRAINT CHANGES APPLIED
================================================================================

  <N> constraint removals or relaxations applied.

  1. <Tab name> (Tab ID: <tabId>)
     Change: <what was removed, relaxed, or merged>
     Rationale: <Spec Coach recommendation that prompted this>

  2. ...

================================================================================
OTHER CHANGES APPLIED
================================================================================

  <N> instructional and content changes applied.

  1. <Tab name> (Tab ID: <tabId>)
     Recommendation: <which Spec Coach recommendation this addresses>
     Change: <what was added, replaced, or restructured>
     Research: <"No research required" or "Sourced from: <reference doc description>">

  2. ...

================================================================================
TAB REORDERS APPLIED (create-verify-delete)
================================================================================

  <N> tab reordering operations performed.

  1. "<Tab title>" moved from position <old_index> to position <new_index>
     Why: <the Spec Coach rationale>
     Method: Created replacement tab at end of doc, verified content, deleted original.
     Verification: tab appears at position <new_index> in the spec doc

  2. ...

================================================================================
RECOMMENDATIONS NOT APPLIED
================================================================================

  <N> recommendations were skipped.

  1. <Recommendation summary>
     Reason: <"No reference doc contains information about [topic]" or other reason>
     To apply: <what information would be needed, or what manual action could address it>

================================================================================
END OF REPORT
================================================================================
```

Print this report to the user's terminal as well (output the full text).

### 5. Confirm spec changes

After all writes, re-read the spec to confirm modified tabs contain the expected content:
```bash
python3 ${CLAUDE_PLUGIN_ROOT}/skills/gws-utils/scripts/read_doc.py <SPEC_ID>
```

Find each modified tab by its `=== TAB N: title | ID: tabId | endIndex=n ===` header and verify the last ~200 characters match what was written. If any tab's content does not match what was intended, report the discrepancy rather than silently failing.

## Key Notes

- **Never write to the article doc or any reference doc** — all gws-utils write scripts use the spec document ID only
- **Always validate spec != article IDs** before any API call
- All gws API calls, keyring-line stripping, and JSON encoding are handled by the gws-utils scripts — do not call gws directly
- Write tab content to `/tmp/` files before calling `write_tab.py` — avoids shell quoting issues with large text
- Use `clear_tab.py` + `write_tab.py` when modifying existing tabs. For TAB_REORDER, use create-verify-delete: create new tabs in desired order (append), verify content, then delete originals. Never delete before verifying — a failure mid-operation leaves all originals intact.
- endIndexes change after each write — always use the endIndex captured in Step 1 before the first write to that tab; re-read via `read_doc.py` if you need to make additional changes to the same tab
- Save each tab's text to `/tmp/tab_<tabId>_content.txt` during Step 1. Overwrite after any TAB_CONTENT write so the reorder step has current content without requiring a second API read.
- `insertionIndex` is NOT a valid field in `addDocumentTab` — the API rejects it. Tab position is controlled entirely by creation order.
- The Spec Coach report has up to four parts. Recommendation sources by priority: PART 4 (Factual Accuracy — corrections) first, PART 1 (Constraint Saturation — removals), PART 2 ("BEYOND THE CEILING" — quality improvements), PART 3 ("Top 3 spec modifications" — drift fixes)
- TAB_CORRECTION changes from PART 4 are highest confidence — they include exact text, source tracing, and replacement wording. Apply these first without hesitation
- TAB_REMOVAL changes should be applied before TAB_CONTENT additions to maintain constraint budget
- When the saturation verdict is TIGHT or OVER-DETERMINED, enforce a one-in-one-out rule: do not add a new constraint without removing or relaxing an existing one
- Purely instructional improvements (rubric fixes, transition examples, checklist additions, structural requirements) require no reference doc research — apply them freely based on the Spec Coach analysis alone
- If the Spec Coach report references changes already applied (e.g., a recommendation from a prior run that is already in the spec), skip them — check the current spec tab content before applying
