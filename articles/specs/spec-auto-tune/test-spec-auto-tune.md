# TEST: Spec Auto-Tune

## References

- `common-how/how-test-fixtures` — fixture catalog and reset protocol
- `common-how/how-test-verification` — Spec Auto-Tune Report Structure checklist, Write-Target Fidelity checklist, Idempotence checklist

## Before Each Test

Unless otherwise noted, the Standard Spec Doc must be in its canonical state (not modified by a prior spec-auto-tune run). Restore it using the reset protocol in `how-test-fixtures` if needed. The Standard Article Doc must have a "Spec Coach" tab with a well-formed report. Run C2 or C3 to produce this before running A-series scenarios.

---

## A1 — Same-Doc Guard

**Setup:** `specs/fixtures/config-same-doc.yaml`.

**Invocation:**
```
/spec-auto-tune specs/fixtures/config-same-doc.yaml
```

**Expected outcome:**
- Claude emits exactly: "Spec and article cannot be the same document."
- No `gws` call is made.
- The fixture spec doc is not modified.

**Verification:**
- Confirm the error message matches exactly.
- Open the spec doc — spot-check one tab to confirm it is unchanged.

---

## A2 — Missing "Spec Coach" Tab

**Setup:** Standard Spec Doc. Standard Article Doc that has a "Generated Article" tab but no "Spec Coach" tab. `specs/fixtures/config-standard.yaml`.

**Invocation:**
```
/spec-auto-tune specs/fixtures/config-standard.yaml
```

**Expected outcome:**
- Claude emits exactly: "No 'Spec Coach' tab found in the article document. Run /spec-coach first."
- No write occurs on the spec doc.
- No "Spec Coach" tab is created in the article doc.

**Verification:**
- Confirm the error message matches exactly.
- Open the spec doc — unchanged.
- Open the article doc — still no "Spec Coach" tab.

---

## A3 — Happy Path (Instructional Changes Only, No Reference Docs)

**Setup:** Standard Spec Doc (canonical state). Standard Article Doc with a "Spec Coach" tab produced by C2 (no reference docs — all recommendations are INSTRUCTIONAL_ONLY or TAB_REMOVAL, none require research). `specs/fixtures/config-standard.yaml`.

**Invocation:**
```
/spec-auto-tune specs/fixtures/config-standard.yaml
```

**Expected outcome:**
- At least one spec tab is modified.
- Auto-tune report (in conversation) is well-formed.
- FACTUAL CORRECTIONS APPLIED section reads "Skipped — no reference documents provided."
- Any TAB_REORDER recommendations appear in MANUAL STEPS REQUIRED, not applied via API.
- Article doc is unchanged.
- After run: re-read modified spec tabs (skill confirms this internally); no discrepancy noted.

**Verification:**
- Apply Spec Auto-Tune Report Structure Checklist.
- Open the Standard Spec Doc — confirm at least one tab has different content than its canonical state.
- Apply Write-Target Fidelity Checklist (spec-auto-tune).
- Reset Standard Spec Doc before running any other A-series test.

---

## A4 — Factual Correction With Reference Docs

**Setup:** Standard Spec Doc (canonical state — contains the seeded inaccuracy in the Content tab). Standard Article Doc with a "Spec Coach" tab produced by C3 (with reference docs — PART 4 shows the seeded inaccuracy as a TAB_CORRECTION). `specs/fixtures/config-with-refs.yaml`.

**Invocation:**
```
/spec-auto-tune specs/fixtures/config-with-refs.yaml
```

**Expected outcome:**
- The spec's Content tab no longer contains the seeded inaccuracy.
- The corrected text matches what the Reference Doc says.
- FACTUAL CORRECTIONS APPLIED section in the report lists the correction with the reference doc as the source.
- Article doc and Reference Doc are unchanged.

**Verification:**
- Open the Standard Spec Doc's Content tab. Confirm the seeded inaccuracy text is gone and the corrected text is present.
- Read the FACTUAL CORRECTIONS APPLIED section in the report — confirm source is the Reference Doc.
- Apply Write-Target Fidelity Checklist (spec-auto-tune, including reference doc).
- Reset Standard Spec Doc before running any other A-series test.

---

## A5 — Over-Determined Spec Blocks Additions

**Setup:** Over-Determined Spec Doc (canonical state). Standard Article Doc with a "Spec Coach" tab produced by running spec-coach against the Over-Determined Spec Doc (C5) — this report contains OVER-DETERMINED verdict, plus recommendations for both removals and additions. `specs/fixtures/config-over-determined.yaml`.

**Invocation:**
```
/spec-auto-tune specs/fixtures/config-over-determined.yaml
```

**Expected outcome:**
- TAB_REMOVAL recommendations are applied (spec tabs modified to remove or relax constraints).
- Addition recommendations that would increase constraint count without a paired removal are not applied.
- RECOMMENDATIONS NOT APPLIED section documents skipped additions with reason referencing the OVER-DETERMINED state.
- Net constraint count in the spec does not increase.

**Verification:**
- Read RECOMMENDATIONS NOT APPLIED section — confirm at least one entry with "OVER-DETERMINED" in the reason.
- Read CONSTRAINT CHANGES APPLIED section — confirm at least one removal.
- Apply Write-Target Fidelity Checklist (spec-auto-tune).
- Reset Over-Determined Spec Doc before running any other test.

---

## A6 — Tab Reorder Becomes Manual Instruction

**Setup:** Standard Spec Doc. Standard Article Doc with a "Spec Coach" tab whose PART 3 (Semantic Drift) recommends moving one tab to a different position. (If the C2/C3 report does not contain a reorder recommendation, add one manually to the "Spec Coach" tab content before running.)

**Invocation:**
```
/spec-auto-tune specs/fixtures/config-standard.yaml
```

**Expected outcome:**
- No `gws` call attempts to reorder tabs in the spec doc.
- MANUAL STEPS REQUIRED section lists the reorder with: tab name, current position, target position, and step-by-step UI instructions for Google Docs.
- Spec tab order is unchanged.

**Verification:**
- Open the Standard Spec Doc — tab order is the same as before the run.
- Read MANUAL STEPS REQUIRED section — confirm it names the tab, positions, and UI steps.

---

## A7 — Idempotence

**Setup:** Use the Standard Spec Doc in its post-A3 state (after A3 has already been run and the spec has been modified). Standard Article Doc with the same "Spec Coach" tab used in A3. Same config.

**Invocation:**
```
/spec-auto-tune specs/fixtures/config-standard.yaml
```

**Expected outcome:**
- The skill detects that the A3 changes are already present in the spec.
- No duplicate content is added to any spec tab.
- The report indicates that previously applied recommendations were recognized as already in place.

**Verification:**
- Apply Idempotence Checklist (compare spec tab content before and after second run).
- Read the report — confirm the previously applied changes are noted as already present, not re-applied.

---

## A8 — NEEDS_RESEARCH Without Reference Docs

**Setup:** Standard Spec Doc (canonical state). Standard Article Doc with a "Spec Coach" tab that includes at least one recommendation requiring factual content about a specific product or capability (NEEDS_RESEARCH category). Config YAML has no `reference_docs`. `specs/fixtures/config-standard.yaml`.

If the standard Spec Coach report does not naturally contain a NEEDS_RESEARCH item, manually add one to the "Spec Coach" tab under PART 2's "BEYOND THE CEILING" section: "Add concrete examples of [product capability] to Tab 3."

**Invocation:**
```
/spec-auto-tune specs/fixtures/config-standard.yaml
```

**Expected outcome:**
- The NEEDS_RESEARCH recommendation is not applied to the spec.
- The spec tab that would have been modified is unchanged.
- RECOMMENDATIONS NOT APPLIED section lists the item with reason: "No reference doc contains information about [topic]" or similar.

**Verification:**
- Read RECOMMENDATIONS NOT APPLIED section — confirm the NEEDS_RESEARCH item is listed with a reason.
- Open the spec tab that would have been affected — confirm it is unchanged.
