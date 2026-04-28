# WHAT: Spec Auto-Tune

## Vision

Close the feedback loop between spec evaluation and spec improvement. After Spec Coach identifies what to change, Spec Auto-Tune reads those findings and applies the improvements directly to the spec — so the author doesn't have to manually translate a report into edits.

## User Story

As a spec author, I want the Spec Coach recommendations applied to my spec automatically so that I can iterate quickly without manually editing each spec tab, while still being informed of every change made and any actions I need to complete myself.

## Functional Requirements

1. Accept a YAML config file identifying the spec doc, article doc, and optional reference documents.
2. Read the "Spec Coach" tab from the article doc. If no such tab exists, stop and instruct the user to run spec-coach first.
3. Read all tabs from the spec doc.
4. Read all reference documents if provided.
5. Categorize every recommendation from the Spec Coach report and apply changes to the spec doc in priority order: factual corrections first, then constraint removals, then content additions.
6. Never add factual content that is not grounded in a provided reference document.
7. Purely instructional improvements (rubric fixes, structural additions, checklist items) require no reference doc and must be applied freely.
8. Tab reordering cannot be done via the API. Report all reordering recommendations as step-by-step manual instructions for the user.
9. After writing, re-read all modified tabs to confirm changes took effect.
10. Never modify the article doc or any reference doc.
11. Output a full change summary — every change applied, every recommendation skipped, and every manual step required.

## Success Criteria

- All applicable Spec Coach recommendations are applied to the spec doc.
- No factual content is added without a reference doc source.
- Every recommendation is accounted for in the output report — applied, skipped, or flagged as manual.
- Manual steps include enough detail for the user to complete them in Google Docs without guessing.
- The spec doc's content after the run matches what was intended, as confirmed by re-reading modified tabs.
- The article doc and all reference docs are unchanged.
