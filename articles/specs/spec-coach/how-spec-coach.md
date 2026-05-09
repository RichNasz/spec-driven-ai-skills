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
- The "Author Feedback" tab in the article doc is read-only. Never write to it.
- The report must use plain text formatting — no markdown. Google Docs renders markdown syntax literally.
- Spec and article document IDs must be validated as distinct before any API call.

## Skill Structure

**Step 0 — Validate inputs.** Resolve URLs from positional args or YAML config. Extract doc IDs. Enforce same-doc guard. Identify whether reference docs were provided.

**Step 1 — Read all documents.** Issue the spec, article, author feedback, and prior Spec Coach tab reads simultaneously in a single turn (four bash calls at once). For the article, use `--tab <dest_tab_name>` where `dest_tab_name` comes from the YAML config (default: `"Generated Article"`); if the result is empty, fall back to a full read and locate the tab by its header. For author feedback, use `--tab "Author Feedback"` against the article doc; if the result is empty or the tab does not exist, record that no feedback was provided and continue (do not fail). For the prior Spec Coach tab, use `--tab "Spec Coach"` against the article doc; if the tab exists and contains a SCORE HISTORY section, extract the history entries for use in score delta calculation. If reference docs are present in config, issue all reference doc reads simultaneously in a single turn. All reads complete before any analysis begins.

**Step 2 — Constraint Saturation Analysis (Report Part 1).** Count coverage requirements by tier. Estimate minimum word budget. Detect redundant scoring passes and contradictory constraints. Assign a saturation verdict: HEALTHY, TIGHT, or OVER-DETERMINED.

**Step 3 — Spec Quality Scoring (Report Part 2).** Discover the spec's own rubric (infer if absent, and note that it was inferred). Score the article per criterion with evidence. Produce recommendations for pushing past the current ceiling — balanced between additions and removals.

**Step 4 — Semantic Drift Analysis (Report Part 3).** Analyze primacy bias, recency bias, lost-in-the-middle effects, and tab ordering effects independently. Synthesize into a composite drift verdict with the top three concrete spec modifications.

**Step 5 — Factual Accuracy Audit (Report Part 4, optional).** Skip entirely if no reference docs were provided; note the omission in the report header. When reference docs are present, extract factual claims, cross-reference each against reference docs, trace hallucination sources, and generate correction recommendations.

**Step 6 — Author Feedback Analysis (Report Part 5, optional).** Skip entirely if no "Author Feedback" tab was found in the article doc; note the omission in the report header. When feedback is present: parse the freeform text into discrete feedback items; classify each as positive (preserve) or negative (change) and map to the spec tab(s) that control the aspect of the article the author is reacting to; translate negative observations into spec recommendations using the existing category system (TAB_CONTENT, TAB_REMOVAL, TAB_REORDER, INSTRUCTIONAL_ONLY, NEEDS_RESEARCH); translate positive observations into PRESERVE markers identifying which spec constraints are load-bearing and must not be removed; surface conflicts between author feedback and recommendations from Parts 1-4, with author preference taking precedence.

**Step 7 — Compose the report.** Combine all analysis outputs into a single structured plain-text document written to a tmp file. The report includes a SCORE HISTORY section between the EXECUTIVE SUMMARY and PART 1 that carries forward prior composite quality scores and shows the delta from the previous run.

**Step 8 — Write the report to the "Spec Coach" tab.** Apply the tab lifecycle pattern. Use the standard write pattern to push the tmp file content into the tab.

## Report Format Standards

- Plain text only. No markdown characters.
- ALL-CAPS for part headers and machine-readable section anchors (SATURATION VERDICT, BEYOND THE CEILING, ADDITIONS, REMOVALS AND RELAXATIONS, CONFLICTS, COMPOSITE DRIFT ASSESSMENT, TOP 3 SPEC MODIFICATIONS, RECOMMENDED REORDERINGS, ACCURACY VERDICT, INACCURACIES, UNSUPPORTED CLAIMS, FEEDBACK SOURCE, POSITIVE OBSERVATIONS, SPEC CHANGE RECOMMENDATIONS, CONFLICTS WITH OTHER PARTS). Mixed case for body labels (Evidence:, Affected tabs:, Probability:, Article says:, Author says:, Status:, etc.).
- `===` separator lines between parts (exactly 70 `=` characters — keep within Google Docs page width).
- Each part is numbered (PART 1 through PART 5, with Parts 4 and 5 conditional on inputs).
- The report opens with an EXECUTIVE SUMMARY before PART 1. It shows all verdicts (up to five) and a ranked list of the top three actions for the iteration. The Spec Quality Score line includes the delta from the prior run when score history exists.
- A SCORE HISTORY section follows the EXECUTIVE SUMMARY, before PART 1. Each entry is one line with a date and composite score. The current run appends a new entry with a delta from the prior run (omitted on the first run). Prior entries are carried forward unchanged from the previous report.
- Within each part, the verdict or composite score appears first, before the supporting detail:
  - PART 1: SATURATION VERDICT leads, then COVERAGE REQUIREMENTS / WORD BUDGET / SCORING PASSES / CONTRADICTORY CONSTRAINTS
  - PART 2: COMPOSITE SCORE leads, then SCORING RUBRIC / SCORES / BEYOND THE CEILING
  - PART 3: COMPOSITE DRIFT ASSESSMENT leads, then the four mechanism analyses, then TOP 3 SPEC MODIFICATIONS and RECOMMENDED REORDERINGS as named sections
  - PART 4: ACCURACY VERDICT with inline claim counts leads, then REFERENCE DOCUMENTS USED / INACCURACIES / UNSUPPORTED CLAIMS / MINOR WORDING DIFFERENCES
- BEYOND THE CEILING uses explicit ADDITIONS / REMOVALS AND RELAXATIONS / CONFLICTS sub-sections rather than a flat numbered list.
- Part 5 uses three sub-sections: POSITIVE OBSERVATIONS (preserve in spec), SPEC CHANGE RECOMMENDATIONS (from negative observations), and CONFLICTS WITH OTHER PARTS. Each positive observation includes a PRESERVE marker. Each recommendation includes the author's quoted feedback, the target spec tab, the recommendation category, the specific change, and the rationale. When author feedback conflicts with a recommendation from Parts 1-4, the conflict is documented and the author's preference takes precedence.
- When Part 4 is omitted, include a note in the report header: "Factual accuracy audit: skipped (no reference documents provided)." The EXECUTIVE SUMMARY Factual Accuracy line shows "Not audited — no reference documents provided."
- When Part 5 is omitted, include a note in the report header: "Author feedback analysis: skipped (no 'Author Feedback' tab found in article document)." The EXECUTIVE SUMMARY Author Feedback line shows "Not analyzed — no 'Author Feedback' tab found."

## Implementation Standards

- All reads complete before any analysis step begins.
- The rubric used for scoring must be sourced from the spec. Inferred rubrics are noted explicitly in the report.
- The report is written to a tmp file in full before the write step — never stream partial content to the doc.
- Scoring recommendations must be balanced: every suggestion to add a spec instruction must be paired with what to remove or simplify.
