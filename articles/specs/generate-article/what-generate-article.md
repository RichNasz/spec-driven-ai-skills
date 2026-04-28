# WHAT: Generate Article

## Vision

Enable spec-driven article generation from a multi-tab Google Doc. A content creator defines a spec as an ordered sequence of tabs — each tab a refinement prompt — and the skill applies them in order to produce a finished article written directly into a destination Google Doc.

## User Story

As a content creator, I want to point the skill at a spec doc and a destination doc so that it reads my spec tabs in sequence, applies them as a cumulative prompt chain, and writes the resulting article into the correct tab — without me manually copying prompts or output between tools.

## Functional Requirements

1. Accept a spec doc URL and a destination doc URL, either as positional arguments or from a YAML config file.
2. Read all tabs from the spec doc in index order.
3. Apply the tabs sequentially as a prompt chain, where each tab refines the output of the previous one.
4. Write the generated article to a named tab in the destination doc. Create the tab if it does not exist; overwrite it if it does.
5. Never modify the spec doc.
6. Default the destination tab name to "Generated Article" when not specified.

## Success Criteria

- The generated article appears in the correct named tab of the destination doc.
- The spec doc is unchanged after the skill runs.
- If source and destination doc IDs are identical, the skill stops before making any changes and reports the conflict.
- The full tab sequence from the spec was applied — no tabs were skipped.
