# WHAT: Spec Auto-Tune

## Vision

Close the feedback loop between spec evaluation and spec improvement — including the author's own judgment about what works and what doesn't. After Spec Coach identifies what to change (through both algorithmic analysis and author feedback), Spec Auto-Tune reads those findings and applies the improvements directly to the spec — so the author doesn't have to manually translate a report into edits. When the author has marked spec constraints as valuable, auto-tune protects them from removal even when algorithmic analysis recommends simplification. The pipeline serves the author: human judgment takes precedence over algorithmic recommendations.

## User Story

As a spec author, I want the Spec Coach recommendations — including those derived from my own feedback on the article — applied to my spec automatically so that I can iterate quickly without manually editing each spec tab. I want constraints I explicitly value to be protected from removal, and I want to be informed of every change made, every recommendation skipped, and every removal my feedback blocked.

## Functional Requirements

1. Accept a YAML config file identifying the spec doc, article doc, and optional reference documents.
2. Read the "Spec Coach" tab from the article doc. If no such tab exists, stop and instruct the user to run spec-coach first.
3. Read all tabs from the spec doc.
4. Read all reference documents if provided.
5. Categorize every recommendation from the Spec Coach report (Parts 1-5) and apply changes to the spec doc in priority order: factual corrections first, then constraint removals, then content additions. The HEALTHY / TIGHT / OVER-DETERMINED saturation verdict from Spec Coach Part 1 gates whether additions are permitted: TIGHT requires a paired removal for each addition; OVER-DETERMINED blocks additions unless a constraint of equal or greater weight is simultaneously removed.
6. When Part 5 (Author Feedback Analysis) is present, respect PRESERVE markers: do not apply TAB_REMOVAL recommendations from any part that target a spec constraint marked as PRESERVE in Part 5. Document all PRESERVE-blocked removals in the output report.
7. Never add factual content that is not grounded in a provided reference document.
8. Purely instructional improvements (rubric fixes, structural additions, checklist items) require no reference doc and must be applied freely.
9. Tab reordering is performed automatically using a create-verify-delete pattern: new tabs are created in the desired order, each is verified, and only then are the original tabs deleted — content is never at risk.
10. After writing, re-read all modified tabs to confirm changes took effect.
11. Never modify the article doc or any reference doc.
12. Output a full change summary — every change applied (including feedback-derived changes in a dedicated section), every recommendation skipped (with reason), and every PRESERVE-blocked removal (with the author's feedback that triggered the block).

## Success Criteria

- All applicable Spec Coach recommendations (Parts 1-5) are applied to the spec doc.
- No factual content is added without a reference doc source.
- Every recommendation is accounted for in the output report — applied, skipped with a clear reason, or blocked by a PRESERVE marker with the author's feedback quoted.
- Tab reordering is confirmed via re-read: new tabs appear at the correct positions and originals are gone.
- The spec doc's content after the run matches what was intended, as confirmed by re-reading modified tabs.
- The article doc and all reference docs are unchanged.
