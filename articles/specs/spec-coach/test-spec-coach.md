# TEST: Spec Coach

## References

- `common-how/how-test-fixtures` — fixture catalog and reset protocol
- `common-how/how-test-verification` — Spec Coach Report Structure checklist, Write-Target Fidelity checklist

## Before Each Test

Ensure the Standard Article Doc has a "Generated Article" tab with content before running spec-coach. If starting from a reset doc, run G2 first to populate it.

---

## C1 — Same-Doc Guard

**Setup:** `specs/fixtures/config-same-doc.yaml` (both URLs point to the same Google Doc).

**Invocation:**
```
/spec-coach specs/fixtures/config-same-doc.yaml
```

**Expected outcome:**
- Claude emits exactly: "Spec and article cannot be the same document."
- No `gws` call is made.
- The fixture doc is not modified.
- No "Spec Coach" tab is created.

**Verification:**
- Confirm the error message matches exactly.
- Open the fixture doc — no "Spec Coach" tab was created.

---

## C2 — Happy Path (No Reference Docs)

**Setup:** Standard Spec Doc. Standard Article Doc with a "Generated Article" tab containing an article (run G2 first if needed). `specs/fixtures/config-standard.yaml` (no `reference_docs`).

**Invocation:**
```
/spec-coach specs/fixtures/config-standard.yaml
```

**Expected outcome:**
- "Spec Coach" tab is created in the Standard Article Doc.
- Report opens with EXECUTIVE SUMMARY showing all three verdicts (Constraint Saturation, Spec Quality Score, Semantic Drift Risk) and "Not audited" for Factual Accuracy, followed by Top actions list.
- SCORE HISTORY section appears between the EXECUTIVE SUMMARY and PART 1, containing one entry (current date and composite score, no delta on first run).
- PART 1 opens with SATURATION VERDICT before the detail sections.
- PART 2 opens with COMPOSITE SCORE before SCORING RUBRIC.
- PART 3 opens with COMPOSITE DRIFT ASSESSMENT before the four mechanism analyses.
- Part 4 is absent; the report header notes "Factual accuracy audit: skipped (no reference documents provided)."
- Standard Spec Doc is unchanged.

**Verification:**
- Apply Spec Coach Report Structure Checklist (no reference docs variant).
- Apply Write-Target Fidelity Checklist (spec-coach).

---

## C3 — Happy Path (With Reference Docs)

**Setup:** Standard Spec Doc. Standard Article Doc with a "Generated Article" tab. `specs/fixtures/config-with-refs.yaml` (includes the Reference Doc with the seeded inaccuracy).

**Invocation:**
```
/spec-coach specs/fixtures/config-with-refs.yaml
```

**Expected outcome:**
- "Spec Coach" tab created with all four PARTS.
- EXECUTIVE SUMMARY shows all four verdicts including a Factual Accuracy verdict.
- SCORE HISTORY section appears between the EXECUTIVE SUMMARY and PART 1.
- PART 4 opens with ACCURACY VERDICT and inline claim counts before any detail.
- PART 4 includes "REFERENCE DOCUMENTS USED" and "INACCURACIES".
- The seeded inaccuracy (spec says "generally available", reference doc says "in preview") appears in PART 4 under INACCURACIES.
- Reference Doc is unchanged.

**Verification:**
- Apply Spec Coach Report Structure Checklist (with reference docs variant).
- In PART 4, confirm ACCURACY VERDICT is the first line, followed by claim counts, before REFERENCE DOCUMENTS USED.
- Confirm the seeded inaccuracy is listed under INACCURACIES with a SOURCE and CORRECTION.
- Apply Write-Target Fidelity Checklist (spec-coach, including reference doc).

---

## C4 — Overwrite Existing "Spec Coach" Tab

**Setup:** Standard Spec Doc. Standard Article Doc has both a "Generated Article" tab and an existing "Spec Coach" tab containing the text "OLD REPORT — SHOULD BE REPLACED". (Add this manually before running.)

**Invocation:**
```
/spec-coach specs/fixtures/config-standard.yaml
```

**Expected outcome:**
- The "Spec Coach" tab exists after the run — not duplicated.
- The tab does not contain "OLD REPORT — SHOULD BE REPLACED".
- The tab contains a fresh report beginning with "SPEC COACH REPORT".

**Verification:**
- Open the "Spec Coach" tab. Search for "OLD REPORT". Confirm zero results.
- Confirm only one tab named "Spec Coach" exists.

---

## C5 — Over-Determined Saturation Detection

**Setup:** Over-Determined Spec Doc. Standard Article Doc with a "Generated Article" tab produced from the Over-Determined Spec Doc (run generate-article against it first). `specs/fixtures/config-over-determined.yaml`.

**Invocation:**
```
/spec-coach specs/fixtures/config-over-determined.yaml
```

**Expected outcome:**
- SCORE HISTORY section appears between the EXECUTIVE SUMMARY and PART 1.
- SATURATION VERDICT is the first line of PART 1 and reads "OVER-DETERMINED".
- The saturation explanation (immediately after SATURATION VERDICT) contains language about declining scores.
- WORD BUDGET section shows utilization above 100%.
- SCORING PASSES section shows 3 or more scoring-rewrite loops.
- EXECUTIVE SUMMARY Constraint Saturation line reads "OVER-DETERMINED".

**Verification:**
- Open the "Spec Coach" tab. Confirm SATURATION VERDICT is the first content line of PART 1.
- Confirm SATURATION VERDICT line reads "OVER-DETERMINED".
- Confirm word budget utilization percentage exceeds 100%.

---

## C6 — Empty `reference_docs` List

**Setup:** Standard Spec Doc. Standard Article Doc with a "Generated Article" tab. A YAML config with `reference_docs: []` (empty list).

**Invocation:**
```
/spec-coach /path/to/config-empty-refs.yaml
```

**Expected outcome:**
- Behavior is identical to C2 — Part 4 is omitted.
- Report header contains "Factual accuracy audit: skipped (no reference documents provided)."

**Verification:**
- Apply Spec Coach Report Structure Checklist (no reference docs variant).
- Confirm no PART 4 section is present.

---

## C7 — Rubric Inference (No Explicit Rubric in Spec)

**Setup:** A variant of the Standard Spec Doc with the Quality tab's scoring rubric removed (delete the explicit weights and threshold). Standard Article Doc with a "Generated Article" tab produced from this modified spec.

**Invocation:**
```
/spec-coach <no-rubric-spec-url> <standard-article-doc-url>
```

**Expected outcome:**
- The "Spec Coach" tab is created.
- COMPOSITE SCORE is the first line of PART 2.
- SCORING RUBRIC section (following COMPOSITE SCORE) contains a note that the rubric was inferred (e.g., "rubric was inferred" or "no explicit rubric found in the spec").
- Scores are still present — the skill does not fail when the rubric is absent.

**Verification:**
- Open the "Spec Coach" tab. Confirm COMPOSITE SCORE is the first content line of PART 2.
- Read the SCORING RUBRIC section and confirm a note about inference is present.
- Confirm COMPOSITE SCORE line is present (skill completed scoring despite the absent rubric).

---

## C8 — Happy Path with Author Feedback (No Reference Docs)

**Setup:** Standard Spec Doc. Standard Article Doc with a "Generated Article" tab containing an article (run G2 first if needed). Create an "Author Feedback" tab in the Standard Article Doc containing freeform feedback such as: "I liked the conversational tone and the opening hook. The middle section dragged — too many bullet points. The security section used too much jargon." `specs/fixtures/config-standard.yaml` (no `reference_docs`).

**Invocation:**
```
/spec-coach specs/fixtures/config-standard.yaml
```

**Expected outcome:**
- "Spec Coach" tab is created with Parts 1, 2, 3, and 5.
- Part 4 is absent; the report header notes "Factual accuracy audit: skipped (no reference documents provided)."
- SCORE HISTORY section appears between the EXECUTIVE SUMMARY and PART 1.
- Part 5 header reads "PART 5: AUTHOR FEEDBACK ANALYSIS".
- FEEDBACK SOURCE line references "Author Feedback" tab.
- POSITIVE OBSERVATIONS section contains at least one entry with a PRESERVE marker.
- SPEC CHANGE RECOMMENDATIONS section contains at least one entry with a target spec tab, category, and change.
- EXECUTIVE SUMMARY includes an "Author Feedback" line showing the item count.
- Standard Spec Doc is unchanged.
- "Author Feedback" tab content is unchanged.

**Verification:**
- Apply Spec Coach Report Structure Checklist (no reference docs, with feedback variant).
- Confirm Part 5 is present between Part 3 and END OF REPORT.
- Confirm POSITIVE OBSERVATIONS entries reference specific spec tabs and include PRESERVE status.
- Confirm SPEC CHANGE RECOMMENDATIONS entries include Author says, Category, Target, Change, and Rationale fields.
- Apply Write-Target Fidelity Checklist (spec-coach).

---

## C9 — Happy Path with Author Feedback AND Reference Docs

**Setup:** Standard Spec Doc. Standard Article Doc with a "Generated Article" tab, an "Author Feedback" tab with feedback (same content as C8 or similar). `specs/fixtures/config-with-refs.yaml` (includes reference docs).

**Invocation:**
```
/spec-coach specs/fixtures/config-with-refs.yaml
```

**Expected outcome:**
- "Spec Coach" tab created with all five PARTS (1 through 5).
- EXECUTIVE SUMMARY shows all five verdict lines.
- SCORE HISTORY section appears between the EXECUTIVE SUMMARY and PART 1.
- Parts 1-4 are present and well-formed.
- Part 5 is present with feedback analysis.
- Reference Doc and "Author Feedback" tab are unchanged.

**Verification:**
- Apply Spec Coach Report Structure Checklist (with reference docs, with feedback variant).
- Confirm all five PART headers are present in order.
- Apply Write-Target Fidelity Checklist (spec-coach, including reference doc).

---

## C10 — Empty Author Feedback Tab

**Setup:** Standard Spec Doc. Standard Article Doc with a "Generated Article" tab. Create an "Author Feedback" tab in the Standard Article Doc that is empty (no text content). `specs/fixtures/config-standard.yaml`.

**Invocation:**
```
/spec-coach specs/fixtures/config-standard.yaml
```

**Expected outcome:**
- Behavior is identical to C2 — Part 5 is omitted.
- Report header contains "Author feedback analysis: skipped (no 'Author Feedback' tab found in article document)."
- No PART 5 section is present.

**Verification:**
- Apply Spec Coach Report Structure Checklist (no reference docs, no feedback variant).
- Confirm no PART 5 section is present.

---

## C11 — Author Feedback Conflicts with Part 2 Recommendation

**Setup:** Standard Spec Doc. Standard Article Doc with a "Generated Article" tab. Create an "Author Feedback" tab with feedback that explicitly praises an aspect of the article that Part 2 is likely to recommend changing (e.g., "I love how every topic gets its own dedicated paragraph — don't reduce this" when Part 2 is likely to recommend downgrading dedicated paragraphs to substantive mentions). `specs/fixtures/config-standard.yaml`.

**Invocation:**
```
/spec-coach specs/fixtures/config-standard.yaml
```

**Expected outcome:**
- Part 5 CONFLICTS WITH OTHER PARTS section is non-empty.
- At least one conflict entry shows the author's feedback versus the Part 2 recommendation.
- The resolution states that the author's preference takes precedence.
- The POSITIVE OBSERVATIONS section includes a PRESERVE marker for the constraint the author values.

**Verification:**
- Open the "Spec Coach" tab. Read the CONFLICTS WITH OTHER PARTS section in Part 5.
- Confirm at least one entry references "Part 2" and quotes the author's feedback.
- Confirm the resolution favors the author's stated preference.

---

## C12 — Score History on First Run

**Setup:** Standard Spec Doc. Standard Article Doc with a "Generated Article" tab (run G2 first if needed). No existing "Spec Coach" tab in the article doc. `specs/fixtures/config-standard.yaml`.

**Invocation:**
```
/spec-coach specs/fixtures/config-standard.yaml
```

**Expected outcome:**
- "Spec Coach" tab is created with a SCORE HISTORY section between the EXECUTIVE SUMMARY and PART 1.
- SCORE HISTORY contains exactly one entry: the current date and the composite score.
- The entry has no delta suffix (first run).
- The EXECUTIVE SUMMARY Spec Quality Score line has no delta text.

**Verification:**
- Open the "Spec Coach" tab. Locate the SCORE HISTORY section.
- Confirm it contains exactly one date/score line.
- Confirm no delta (no parenthetical +/- value) appears on the entry.
- Confirm the score matches the COMPOSITE SCORE in PART 2.

---

## C13 — Score History on Re-Run

**Setup:** Standard Spec Doc. Standard Article Doc with a "Generated Article" tab and an existing "Spec Coach" tab from a prior C12 or C2 run (the tab contains a report with a SCORE HISTORY section). `specs/fixtures/config-standard.yaml`.

**Invocation:**
```
/spec-coach specs/fixtures/config-standard.yaml
```

**Expected outcome:**
- The "Spec Coach" tab is overwritten with a new report.
- SCORE HISTORY contains two entries: the prior run's entry (carried forward unchanged) and the current run's entry.
- The current entry includes a delta from the prior score (e.g., `(+0.3)` or `(-0.5)`).
- The EXECUTIVE SUMMARY Spec Quality Score line includes the same delta.
- Prior history entries are preserved exactly as they appeared in the previous report.

**Verification:**
- Open the "Spec Coach" tab. Locate the SCORE HISTORY section.
- Confirm it contains two date/score lines.
- Confirm the first line matches the prior run's date and score (unchanged).
- Confirm the second line shows the current date, current score, and a delta value.
- Confirm the delta sign is correct (positive if score improved, negative if it dropped).
- Confirm the EXECUTIVE SUMMARY Spec Quality Score line includes the delta.
