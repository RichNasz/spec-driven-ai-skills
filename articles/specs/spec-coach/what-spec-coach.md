# WHAT: Spec Coach

## Vision

Give spec authors objective, structured feedback on how well their spec performed after article generation. The skill reads both the spec and the generated article, evaluates the article against the spec's own criteria, and surfaces what to improve — in the spec, not just the article — so that each iteration produces better output.

## User Story

As a spec author, I want a structured evaluation of my spec's performance after generating an article so that I understand what the spec got right, where it caused the article to drift or fail, and what changes to the spec would produce higher-quality output in the next iteration.

## Functional Requirements

1. Accept a spec doc URL and an article doc URL, either as positional arguments or from a YAML config file.
2. Read all tabs from the spec doc and the generated article from the article doc.
3. Optionally accept reference documents for factual accuracy auditing.
4. Analyze the article across four dimensions:
   - Constraint saturation: whether the spec's requirements are achievable within its word count
   - Spec quality scoring: how well the article met the spec's own rubric
   - Semantic drift: whether sequential tab processing caused the article to diverge from the full intent
   - Factual accuracy: whether article claims are supported by reference documents (only when reference docs are provided)
5. Write a structured plain-text report to a tab named "Spec Coach" in the article doc. The tab name is fixed.
6. Never modify the spec doc.

## Success Criteria

- The "Spec Coach" tab in the article doc contains the full structured report.
- The report covers all four analysis sections (Part 4 omitted when no reference docs are provided, with a note explaining the omission).
- The spec doc is unchanged after the skill runs.
- If spec and article doc IDs are identical, the skill stops before making any changes and reports the conflict.
- Scoring uses the rubric defined in the spec itself; an inferred rubric is noted explicitly.
