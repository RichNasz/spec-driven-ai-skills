# TEST: Pipeline Integration

## References

- `common-how/how-test-fixtures` — fixture catalog and reset protocol
- `common-how/how-test-verification` — all four checklists
- `generate-article/test-generate-article` — G-series verification steps
- `spec-coach/test-spec-coach` — C-series verification steps
- `spec-auto-tune/test-spec-auto-tune` — A-series verification steps

## Purpose

Pipeline tests verify the full skill chain: generate-article → spec-coach → spec-auto-tune. They confirm that handoffs between skills work correctly — the output of one skill is valid input for the next — and that each skill does not corrupt the state another skill depends on.

## Before Each Pipeline Test

1. Reset Standard Article Doc to empty state (per `how-test-fixtures` reset protocol).
2. Restore Standard Spec Doc to canonical state if it was modified by a prior spec-auto-tune run.
3. Confirm the Reference Doc is in its unmodified state (seeded inaccuracy present).

---

## P1 — Full Linear Pipeline

**Setup:** Standard Spec Doc (canonical). Standard Article Doc (reset — empty). `specs/fixtures/config-with-refs.yaml`.

**Invocation sequence:**

Step 1:
```
/generate-article specs/fixtures/config-with-refs.yaml
```

Step 2 (after Step 1 completes):
```
/spec-coach specs/fixtures/config-with-refs.yaml
```

Step 3 (after Step 2 completes):
```
/spec-auto-tune specs/fixtures/config-with-refs.yaml
```

**Expected state after each step:**

After Step 1:
- "Generated Article" tab exists in Standard Article Doc with content.
- Standard Spec Doc is unchanged.

After Step 2:
- "Spec Coach" tab exists in Standard Article Doc with a four-part report (reference docs provided).
- The seeded inaccuracy appears in PART 4 as an INACCURACY with TAB_CORRECTION source.
- Standard Spec Doc is unchanged.
- Reference Doc is unchanged.

After Step 3:
- Standard Spec Doc's Content tab no longer contains the seeded inaccuracy.
- At least one additional spec tab is modified per the Spec Coach recommendations.
- Auto-tune report (in conversation) is well-formed and accounts for every recommendation.
- Standard Article Doc's "Generated Article" and "Spec Coach" tabs are unchanged.
- Reference Doc is unchanged.

**Verification:**
- After Step 1: Apply Write-Target Fidelity Checklist (generate-article).
- After Step 2: Apply Spec Coach Report Structure Checklist (with reference docs variant). Apply Write-Target Fidelity Checklist (spec-coach, including reference doc).
- After Step 3: Apply Spec Auto-Tune Report Structure Checklist. Apply Write-Target Fidelity Checklist (spec-auto-tune). Confirm seeded inaccuracy is gone from spec Content tab.

---

## P2 — Second Iteration Cycle

**Setup:** Immediately follows P1. The Standard Spec Doc is now in its auto-tuned state. The Standard Article Doc has both "Generated Article" and "Spec Coach" tabs from the first cycle.

**Invocation sequence:**

Step 1 (regenerate article from improved spec):
```
/generate-article specs/fixtures/config-with-refs.yaml
```

Step 2 (re-evaluate improved spec and new article):
```
/spec-coach specs/fixtures/config-with-refs.yaml
```

**Expected state after each step:**

After Step 1:
- "Generated Article" tab in Standard Article Doc is overwritten with a new article (not appended).
- The "Spec Coach" tab from the first cycle is unchanged.
- The auto-tuned Standard Spec Doc is unchanged.

After Step 2:
- "Spec Coach" tab is overwritten with a new report reflecting the improved spec.
- The seeded inaccuracy should NOT appear in PART 4 of the new report (it was corrected in P1 Step 3).
- SATURATION VERDICT in the new report should be HEALTHY or no worse than the verdict from the first cycle.

**Verification:**
- After Step 1: Confirm "Generated Article" tab has new content and "Spec Coach" tab is unchanged.
- After Step 2: Apply Spec Coach Report Structure Checklist (with reference docs variant).
- Read SATURATION VERDICT from the new report. Compare to the verdict from P1 Step 2 — it must not be worse (e.g., if P1 was HEALTHY, P2 must be HEALTHY; if P1 was TIGHT, P2 must be TIGHT or HEALTHY).
- In PART 4, confirm the seeded inaccuracy is no longer listed as an INACCURACY (it was corrected in the spec).

---

## P3 — Non-Default Article Tab Name

**Setup:** Standard Spec Doc. Standard Article Doc (reset). Use positional args to write to a non-default tab name.

**Invocation sequence:**

Step 1 (write article to custom tab name):
```
/generate-article <standard-spec-doc-url> <standard-article-doc-url> "Custom Article Tab"
```

Step 2 (evaluate — spec-coach must find the article regardless of tab name):
```
/spec-coach <standard-spec-doc-url> <standard-article-doc-url>
```

**Expected state after each step:**

After Step 1:
- Standard Article Doc has a tab named "Custom Article Tab" with content.
- No tab named "Generated Article" exists.

After Step 2:
- "Spec Coach" tab is created in Standard Article Doc.
- The report was produced by reading the article content from "Custom Article Tab".
- The report contains substantive analysis (not empty or placeholder content), confirming spec-coach located the article despite the non-default tab name.

**Verification:**
- After Step 1: Confirm tab is named "Custom Article Tab" and contains content.
- After Step 2: Apply Spec Coach Report Structure Checklist (no reference docs variant). Confirm report contains actual scores and analysis, confirming the article tab was found and read.
