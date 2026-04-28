# HOW: Spec Auto-Tune

## References

- `common-how/how-yaml-config` — shared YAML config schema and unknown-key rule
- `common-how/how-input-validation` — YAML config resolution and same-doc guard
- `common-how/how-gws-document-read` — reading spec tabs, the Spec Coach tab, and reference docs
- `common-how/how-gws-document-write` — writing updated tab content

## Constraints

- The spec doc is the only write target. No `batchUpdate` call may use the article doc ID or any reference doc ID.
- Spec and article document IDs must be validated as distinct before any API call.
- Factual content (product names, capabilities, statuses, version numbers) must come verbatim or paraphrased from a reference doc. If no reference doc supports the fact, skip the recommendation and document why.
- Purely instructional changes (rubric fixes, checklist items, structural requirements, transition examples) require no reference doc and must be applied without hesitation.
- Tab reordering uses a create-verify-delete pattern. The Google Docs API does not support positional tab insertion — `addDocumentTab` always appends. To reorder: (1) buffer all tab content from `first_affected_pos` to end; (2) create new replacement tabs in the desired final order by appending; (3) verify each new tab contains the expected content; (4) only then delete the original tabs by tabId. At step 3, all original content still exists — a failed verify stops the run before any original is deleted.
- Never apply a recommendation that was already applied in a prior run. Check current spec tab content before writing.

## Input Form

YAML config only — no positional argument form. See `common-how/how-yaml-config` for the full schema.

## Skill Structure

**Step 0 — Validate config.** Load YAML. Extract and compare spec and article doc IDs. Enforce same-doc guard. Do not proceed until this passes.

**Step 1 — Read all documents.** Read all spec tabs (capturing index, title, tabId, endIndex, and full text for each). Read the "Spec Coach" tab from the article doc — if absent, stop and tell the user to run spec-coach first. Read all reference docs if listed in config.

**Step 2 — Read saturation state and categorize recommendations.** Extract the SATURATION VERDICT from Part 1 of the Spec Coach report. Read all four report parts and assign every distinct recommendation to one of these categories: TAB_CORRECTION, TAB_REMOVAL, TAB_CONTENT, TAB_REORDER, NEEDS_RESEARCH, or INSTRUCTIONAL_ONLY. Resolve NEEDS_RESEARCH items against reference doc content — mark as RESEARCHABLE if supportable, CANNOT_APPLY if not.

**Step 3 — Apply changes in priority order.** Apply TAB_CORRECTION first, then TAB_REMOVAL, then TAB_CONTENT / INSTRUCTIONAL_ONLY / RESEARCHABLE. The saturation state governs additions: TIGHT requires a paired removal for each addition; OVER-DETERMINED blocks additions unless they simultaneously remove a constraint of equal or greater weight. Apply changes one tab at a time. Never assume a previously captured endIndex is still valid after any write.

**Step 4 — Compose the change summary report.** Produce a structured plain-text report covering: factual corrections applied, constraint changes applied, other changes applied, tab reorders applied (via create-verify-delete), and recommendations not applied. Write to a tmp file. Also print the full report to the terminal.

**Step 5 — Confirm spec changes.** Re-read all modified tabs and verify their content matches what was intended. Report any discrepancy explicitly — never fail silently.

## Recommendation Categories

| Category | Description | Requires research? | Can be API-applied? |
|---|---|---|---|
| TAB_CORRECTION | Fixes a factual inaccuracy identified by Part 4 of the Spec Coach report | Yes (sourced from report) | Yes |
| TAB_REMOVAL | Removes, relaxes, or merges an existing constraint | No | Yes |
| TAB_CONTENT | Modifies content of an existing tab | Depends | Yes |
| TAB_REORDER | Reorders tabs | No | Yes — create-verify-delete |
| NEEDS_RESEARCH | Requires reference doc content to apply | Yes | Only if RESEARCHABLE |
| INSTRUCTIONAL_ONLY | Pure structural/instructional change | No | Yes |

## Saturation Rules

- HEALTHY: Apply additions and removals normally.
- TIGHT: Apply removals before additions. Skip any addition not paired with a removal in the same report.
- OVER-DETERMINED: Prioritize removals. Block additions unless they simultaneously remove a constraint of equal or greater weight. Document all skipped additions.

## Implementation Standards

- All reads complete before any write begins.
- Write each tab's new content to a named tmp file before building the JSON payload.
- Use clear-then-rewrite for all tab modifications — delete existing content, then insert new content.
- Re-read all modified tabs after writes complete to confirm content matches intent.
- The output report must account for every recommendation — applied, skipped with reason, or flagged as manual.
- Manual step instructions must name the tab, the target position, and the exact UI actions needed in Google Docs.
