# HOW: Test Verification Checklists

## Purpose

Defines reusable verification checklists for skill test scenarios. Each `test-*.md` file references checklists by name rather than repeating them. Run each checklist item after the skill completes.

---

## Checklist: Spec Coach Report Structure

Apply after any spec-coach run. Open the "Spec Coach" tab in the article doc and verify:

- [ ] Tab title is exactly "Spec Coach"
- [ ] Content begins with the text "SPEC COACH REPORT"
- [ ] Line 2 begins with "Generated:"
- [ ] "Spec document:" line is present and contains the spec doc URL
- [ ] "Article document:" line is present and contains the article doc URL
- [ ] Exactly four `================================================================================` separator lines are present
- [ ] "PART 1: CONSTRAINT SATURATION ANALYSIS" is present
- [ ] "PART 2: SPEC QUALITY SCORING" is present
- [ ] "PART 3: SEMANTIC DRIFT ANALYSIS" is present
- [ ] "SATURATION VERDICT:" line is present and value is one of: HEALTHY, TIGHT, OVER-DETERMINED
- [ ] "COMPOSITE SCORE:" line is present in PART 2
- [ ] No markdown characters are present (`#`, `*`, `` ` ``, or lines beginning with `-` used as bullets)

**When reference docs were provided:**
- [ ] "PART 4: FACTUAL ACCURACY AUDIT" is present
- [ ] "REFERENCE DOCUMENTS USED" section lists the reference docs
- [ ] "CLAIMS CHECKED:" line is present and non-zero
- [ ] "ACCURACY VERDICT:" line is present

**When no reference docs were provided:**
- [ ] "Factual accuracy audit: skipped (no reference documents provided)" appears in the report header
- [ ] No "PART 4" section is present

---

## Checklist: Spec Auto-Tune Report Structure

Apply after any spec-auto-tune run. Verify in the conversation output (the report is printed to the terminal, not written to a doc):

- [ ] Report begins with "SPEC AUTO-TUNE REPORT"
- [ ] "Generated:" line is present
- [ ] "Saturation state:" line is present and value is one of: HEALTHY, TIGHT, OVER-DETERMINED
- [ ] "FACTUAL CORRECTIONS APPLIED" section header is present
- [ ] "CONSTRAINT CHANGES APPLIED" section header is present
- [ ] "OTHER CHANGES APPLIED" section header is present
- [ ] "MANUAL STEPS REQUIRED" section header is present
- [ ] "RECOMMENDATIONS NOT APPLIED" section header is present
- [ ] "END OF REPORT" appears at the close

---

## Checklist: Write-Target Fidelity

Apply after every skill run. Verify that no document that should be read-only was modified.

**generate-article:**
- [ ] Spec doc tab count is unchanged
- [ ] Spec doc tab titles are unchanged
- [ ] Spot-check one spec tab — content is unchanged

**spec-coach:**
- [ ] Spec doc tab count is unchanged
- [ ] Spec doc tab titles are unchanged
- [ ] Spot-check one spec tab — content is unchanged
- [ ] If reference docs were used: open each reference doc and confirm tab count and content are unchanged

**spec-auto-tune:**
- [ ] Article doc has no new tabs beyond what existed before the run
- [ ] "Spec Coach" tab content in the article doc is unchanged
- [ ] If reference docs were used: open each reference doc and confirm tab count and content are unchanged

---

## Checklist: Idempotence

Apply when running a skill a second time with identical inputs against a fixture that is already in its post-run state.

1. Note the exact state of the output tab or spec tabs before the second run.
2. Run the skill again with the same inputs.
3. Verify:
   - [ ] The output tab (or spec tabs) contain the same content as before the second run
   - [ ] No new tabs were created
   - [ ] No content was duplicated or appended
   - [ ] No error was emitted about stale endIndexes or conflicting content

For spec-auto-tune idempotence specifically, the report from the second run must show that previously applied changes were recognized as already present and were not re-applied.
