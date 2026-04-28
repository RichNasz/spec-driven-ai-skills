# HOW: Spec Coach

## References

- `common-how/how-yaml-config` — shared YAML config schema and unknown-key rule
- `common-how/how-input-validation` — arg resolution and same-doc guard
- `common-how/how-gws-document-read` — reading spec tabs, article tabs, and reference docs
- `common-how/how-tab-lifecycle` — find/create/clear the "Spec Coach" tab
- `common-how/how-gws-document-write` — writing the report

## Constraints

- The spec doc is read-only. No write operation may target the spec document ID.
- The article doc is the only write target. All `batchUpdate` calls must use the article doc ID.
- All writes go to the "Spec Coach" tab only. The tab name is fixed — it is not user-configurable.
- Reference documents are read-only. Never call `batchUpdate` on a reference doc ID.
- The report must use plain text formatting — no markdown. Google Docs renders markdown syntax literally.
- Spec and article document IDs must be validated as distinct before any API call.

## Skill Structure

**Step 0 — Validate inputs.** Resolve URLs from positional args or YAML config. Extract doc IDs. Enforce same-doc guard. Identify whether reference docs were provided.

**Step 1 — Read all documents.** Read all spec tabs. Read all article tabs. If reference docs are present in config, read each one. All reads complete before any analysis begins.

**Step 2 — Constraint Saturation Analysis (Report Part 1).** Count coverage requirements by tier. Estimate minimum word budget. Detect redundant scoring passes and contradictory constraints. Assign a saturation verdict: HEALTHY, TIGHT, or OVER-DETERMINED.

**Step 3 — Spec Quality Scoring (Report Part 2).** Discover the spec's own rubric (infer if absent, and note that it was inferred). Score the article per criterion with evidence. Produce recommendations for pushing past the current ceiling — balanced between additions and removals.

**Step 4 — Semantic Drift Analysis (Report Part 3).** Analyze primacy bias, recency bias, lost-in-the-middle effects, and tab ordering effects independently. Synthesize into a composite drift verdict with the top three concrete spec modifications.

**Step 5 — Factual Accuracy Audit (Report Part 4, optional).** Skip entirely if no reference docs were provided; note the omission in the report header. When reference docs are present, extract factual claims, cross-reference each against reference docs, trace hallucination sources, and generate correction recommendations.

**Step 6 — Compose the report.** Combine all analysis outputs into a single structured plain-text document written to a tmp file.

**Step 7 — Write the report to the "Spec Coach" tab.** Apply the tab lifecycle pattern. Use the standard write pattern to push the tmp file content into the tab.

## Report Format Standards

- Plain text only. No markdown characters.
- ALL-CAPS section headers.
- `===` separator lines between parts.
- Each part is numbered (PART 1 through PART 4).
- When Part 4 is omitted, include a note in the report header: "Factual accuracy audit: skipped (no reference documents provided)."

## Implementation Standards

- All reads complete before any analysis step begins.
- The rubric used for scoring must be sourced from the spec. Inferred rubrics are noted explicitly in the report.
- The report is written to a tmp file in full before the write step — never stream partial content to the doc.
- Scoring recommendations must be balanced: every suggestion to add a spec instruction must be paired with what to remove or simplify.
