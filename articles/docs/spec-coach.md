# /articles:spec-coach

Evaluates a generated article against its spec. Scores the article using the rubric the spec itself defines, analyzes the tab chain for semantic drift, and — when reference documents are provided — audits every verifiable factual claim. Writes a structured plain-text report to a "Spec Coach" tab in the article doc.

Run this after `/articles:generate-article`.

## Usage

```
/articles:spec-coach <spec_doc_url> <article_doc_url>
/articles:spec-coach <config_yaml_path>
```

**Positional form:**

```
/articles:spec-coach "https://docs.google.com/document/d/<SPEC_ID>/edit" \
            "https://docs.google.com/document/d/<ARTICLE_ID>/edit"
```

**YAML form** (required for reference doc auditing):

```
/articles:spec-coach my-article.yaml
```

## YAML config

```yaml
spec_doc_url:    "https://docs.google.com/document/d/<SPEC_ID>/edit"    # required
article_doc_url: "https://docs.google.com/document/d/<ARTICLE_ID>/edit" # required
reference_docs:                                                           # optional
  - url: "https://docs.google.com/document/d/<REF_ID>/edit"
    description: "What this document covers — used to scope the audit"
```

| Field | Required | Default | Description |
|---|---|---|---|
| `spec_doc_url` | Yes | — | Google Doc containing the spec tabs |
| `article_doc_url` | Yes | — | Google Doc containing the generated article |
| `reference_docs` | No | `[]` | Source-of-truth docs for factual accuracy audit |

When `reference_docs` is absent or empty, the factual accuracy audit (Part 4) is skipped. The report header will say `"Factual accuracy audit: skipped (no reference documents provided)."` An empty list (`reference_docs: []`) behaves identically to omitting the key.

When no "Author Feedback" tab exists in the article doc (or the tab is empty), Part 5 is skipped. The report header will say `"Author feedback analysis: skipped (no 'Author Feedback' tab found in article document)."` To use this feature, create a tab named "Author Feedback" in the article doc and write your freeform reactions to the generated article before running spec-coach.

## What you get

A "Spec Coach" tab is created in the article doc (or overwritten if it already exists) containing a plain-text report with up to five parts:

**Part 1 — Constraint Saturation Analysis**
Determines whether the spec's requirements are achievable within the target word count. Assigns a verdict of HEALTHY, TIGHT, or OVER-DETERMINED. See [concepts.md](../../docs/concepts.md#constraint-saturation) for a full explanation of the saturation model and what each verdict means for iteration.

**Part 2 — Spec Quality Scoring**
Scores the article against the spec's own rubric (or a constructed rubric if the spec does not define one). Provides per-criterion scores with evidence and a weighted composite. Includes a "Path to 11/10" section with concrete recommendations for improving the spec beyond its current ceiling.

**Part 3 — Semantic Drift Analysis**
Analyzes whether sequential tab processing caused the article to drift from the full set of instructions. Reports probabilities (Low / Moderate / High) for four drift mechanisms: primacy bias, recency bias, lost-in-the-middle, and suboptimal tab ordering. Ends with the top 3 concrete modifications to reduce drift. See [concepts.md](../../docs/concepts.md#semantic-drift) for a full explanation of each mechanism.

**Part 4 — Factual Accuracy Audit** _(only when reference_docs provided)_
Cross-references every verifiable factual claim in the article against the reference documents. Categorizes findings as VERIFIED, INACCURACY, UNSUPPORTED, or MINOR. Traces each inaccuracy to its source (spec instruction vs. model hallucination). Provides correction text and identifies which spec tab to fix when the spec caused the error.

**Part 5 — Author Feedback Analysis** _(only when an "Author Feedback" tab exists in the article doc)_
Translates the author's freeform reactions to the generated article into concrete spec recommendations. Positive feedback becomes PRESERVE markers that protect valued spec constraints from removal by auto-tune. Negative feedback becomes actionable spec change recommendations (add instruction, remove constraint, reorder tabs). When author feedback conflicts with a recommendation from Parts 1-4, the conflict is documented and the author's preference takes precedence.

## Saturation verdicts

See [concepts.md](../../docs/concepts.md#constraint-saturation) for full definitions. Quick reference:

| Verdict | Meaning |
|---|---|
| HEALTHY | Minimum coverage needs under 85% of word target; zero or one scoring pass |
| TIGHT | Minimum coverage 85–100% of word target; or one contradictory constraint pair; or two scoring passes |
| OVER-DETERMINED | Minimum coverage exceeds word target; or multiple contradictory pairs; or three or more scoring passes. Iterative cycles will produce declining scores until constraints are reduced. |

## Hard constraints

| Constraint | Effect |
|---|---|
| Spec and article are the same doc | Stops immediately: `"Spec and article cannot be the same document."` |
| Spec doc is read-only | The skill never calls `batchUpdate` on the spec doc |
| Reference docs are read-only | The skill never writes to reference docs |
| "Author Feedback" tab is read-only | The skill reads but never writes to the author's feedback |
| All writes go to "Spec Coach" tab only | No other tab in the article doc is modified |

## Example

```yaml
# my-article.yaml
spec_doc_url:    "https://docs.google.com/document/d/1abc.../edit"
article_doc_url: "https://docs.google.com/document/d/1xyz.../edit"
reference_docs:
  - url: "https://docs.google.com/document/d/1ref.../edit"
    description: "Technical reference — authoritative source for all product claims"
```

```
/articles:spec-coach my-article.yaml
```

The skill reads both docs and the reference doc, runs all applicable analysis parts (up to five), and writes the full report to the "Spec Coach" tab in the article doc.

## Notes

- If the spec has no explicit scoring rubric, the skill constructs one from the spec's own stated goals and notes that the rubric was inferred.
- The report uses plain text with ALL-CAPS headers and no markdown characters — this is intentional so the report reads correctly inside Google Docs.
- Running the skill twice on the same unmodified docs produces a fresh report each time (overwrites the previous one).
