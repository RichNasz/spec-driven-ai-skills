# /spec-auto-tune

Reads the "Spec Coach" tab in the article doc and applies the recommended improvements directly to the spec doc. Prints a structured report of every change made and every recommendation skipped. Tab reordering recommendations — which the API cannot perform — are listed as step-by-step manual instructions.

Run this after `/spec-coach`.

## Usage

```
/spec-auto-tune <config_yaml_path>
```

spec-auto-tune accepts only a YAML config file (no positional URL form).

```
/spec-auto-tune my-article.yaml
```

## YAML config

The config format is identical to spec-coach:

```yaml
spec_doc_url:    "https://docs.google.com/document/d/<SPEC_ID>/edit"    # required
article_doc_url: "https://docs.google.com/document/d/<ARTICLE_ID>/edit" # required
reference_docs:                                                           # optional
  - url: "https://docs.google.com/document/d/<REF_ID>/edit"
    description: "Source of truth for factual corrections"
```

| Field | Required | Default | Description |
|---|---|---|---|
| `spec_doc_url` | Yes | — | Google Doc to improve (the spec) |
| `article_doc_url` | Yes | — | Google Doc that contains the "Spec Coach" tab |
| `reference_docs` | No | `[]` | Source-of-truth docs for factual corrections |

## Prerequisite

The "Spec Coach" tab must already exist in the article doc. Run `/spec-coach` first if it does not. If the tab is missing, the skill stops immediately:

```
"No 'Spec Coach' tab found in the article document. Run /spec-coach first."
```

## What you get

The spec doc is updated in-place. Changes are applied tab by tab. A changes report is printed to the terminal (not written to any doc) with five sections:

**CHANGES APPLIED** — every modification made to the spec, with the tab name, what changed, and why.

**TAB REORDERS APPLIED** — tab moves executed via the buffer-delete-recreate pattern, with source position, target position, and the Spec Coach rationale.

**RECOMMENDATIONS NOT APPLIED** — items from the Spec Coach report that were skipped, with the reason (e.g., spec is OVER-DETERMINED and the addition would worsen saturation; or a NEEDS_RESEARCH item was skipped because no reference doc contained the required information).

**CORRECTIONS APPLIED** _(only when reference_docs provided)_ — factual corrections made to spec instructions, with the source doc and passage that grounded each correction.

**ALREADY APPLIED** _(only on second run)_ — items that were already present from a previous run, confirming idempotence.

## Change categories

The skill classifies each Spec Coach recommendation before deciding what to do with it:

| Category | What it is | Handled by skill |
|---|---|---|
| INSTRUCTIONAL_ONLY | Rewording or adding spec instructions; no new facts needed | Applied automatically |
| TAB_CORRECTION | Fixing an incorrect instruction already in the spec | Applied automatically |
| TAB_REMOVAL | Removing a spec instruction that is redundant or harmful | Applied after confirming it exists |
| TAB_REORDER | Moving a tab to a different position in the sequence | Automated via buffer-delete-recreate |
| NEEDS_RESEARCH | Factual addition that requires grounding in a reference doc | Applied if reference doc contains support; skipped and logged otherwise |

## Idempotence

Running the skill twice on the same config produces the same spec state. On the second run, each recommended change is checked against the current spec content. If the change is already present, it is logged in ALREADY APPLIED and skipped. No content is duplicated.

## Hard constraints

| Constraint | Effect |
|---|---|
| Spec and article are the same doc | Stops immediately: `"Spec and article cannot be the same document."` |
| "Spec Coach" tab not found | Stops immediately with the message above |
| Spec doc is the only write target | The skill never calls `batchUpdate` on the article doc or any reference doc |
| Facts must come from reference docs | If a NEEDS_RESEARCH item has no reference support, it is skipped and logged — nothing is invented |

## Example

```yaml
# my-article.yaml
spec_doc_url:    "https://docs.google.com/document/d/1abc.../edit"
article_doc_url: "https://docs.google.com/document/d/1xyz.../edit"
reference_docs:
  - url: "https://docs.google.com/document/d/1ref.../edit"
    description: "Technical reference — source of truth for product facts"
```

```
/spec-coach my-article.yaml      # run first — produces "Spec Coach" tab
/spec-auto-tune my-article.yaml  # reads that tab; improves the spec
```

After `/spec-auto-tune` completes, run `/generate-article` again to regenerate the article from the improved spec, then run `/spec-coach` again to see whether the scores improved.

## Notes

- The skill reads the Spec Coach report as written — if the report contains a SATURATION VERDICT of OVER-DETERMINED, the skill skips any recommendations that would add new constraints and explains this in RECOMMENDATIONS NOT APPLIED.
- Tab reordering is automated: the `gws` API has no `moveTab`, but the skill buffers the tab's content, deletes the tab, recreates it at the target position via `addDocumentTab` with `insertionIndex`, and writes the content back.
- Factual corrections to spec instructions (not article text) are applied when a reference doc contradicts something the spec instructs the model to include.
- The report is printed to the terminal only. Nothing is appended to the article doc.
