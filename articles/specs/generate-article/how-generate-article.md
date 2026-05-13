# HOW: Generate Article

## References

- `common-how/how-yaml-config` — shared YAML config schema and unknown-key rule
- `common-how/how-input-validation` — arg resolution and same-doc guard
- `common-how/how-gws-document-read` — reading spec tabs
- `common-how/how-tab-lifecycle` — find/create/clear the destination tab
- `common-how/how-gws-document-write` — writing the article

## Constraints

- The spec doc is read-only. No write operation may target the spec document ID under any circumstances.
- Reference documents are read-only. No write operation may target any reference document ID.
- Source and destination document IDs must be validated as distinct before any API call.
- Tabs are processed strictly in index order. No tab may be skipped or reordered.
- The destination tab name defaults to "Generated Article" when not provided via positional arg or YAML.

## Skill Structure

**Step 0 — Validate inputs.** Resolve URLs from positional args or YAML config. Extract doc IDs. Enforce same-doc guard. Do not proceed until this passes.

**Step 1 — Read all spec tabs.** Use the standard document read pattern. Capture every tab's title and full text in index order.

**Step 1b — Read reference documents (if provided).** If `reference_docs` is non-empty in the YAML config, issue all reference doc reads simultaneously in a single turn. Save the full text of each. Use the `description` field to understand each doc's purpose. If `reference_docs` is absent or empty, skip this step.

**Step 2 — Generate the article.** Process spec tabs as a sequential prompt chain. Each tab's instructions refine the output of the previous tab cumulatively. Reference document content informs the generation as supplementary context (style guides, editorial checklists, author outlines). The final output of the chain is the article.

**Step 3 — Write the article to the destination doc.** Apply the tab lifecycle pattern to find or create the destination tab by name, clear it if it has content, and write the generated article using the standard write pattern.

## Implementation Standards

- Input validation must complete fully before any `gws` call is made.
- The article text must be written to a tmp file before the JSON payload is built.
- If no tabs are returned from the spec doc read, recheck that `includeTabsContent: true` was sent — do not assume the document is empty.
