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
