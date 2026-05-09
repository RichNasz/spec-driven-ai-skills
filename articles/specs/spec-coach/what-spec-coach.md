# WHAT: Spec Coach

## Vision

Give spec authors objective, structured feedback on how well their spec performed after article generation — and incorporate the author's own subjective reactions into that feedback. The skill reads both the spec and the generated article, evaluates the article against the spec's own criteria, and surfaces what to improve — in the spec, not just the article — so that each iteration produces better output. When the author provides freeform reactions to the article, the skill translates those reactions into concrete spec recommendations and PRESERVE markers, bridging algorithmic analysis and human judgment. The author is not editing the article — they are providing signal about spec quality, consistent with the project's principle that the spec is the artifact and the article is disposable.

## User Story

As a spec author, I want a structured evaluation of my spec's performance after generating an article — combining algorithmic analysis with my own reactions to the output — so that I understand what the spec got right, where it caused the article to drift or fail, and what changes to the spec would produce higher-quality output in the next iteration. When I write my reactions to the article, I want them translated into concrete spec changes and protection for the aspects I value, not treated as article edits.

## Functional Requirements

1. Accept a spec doc URL and an article doc URL, either as positional arguments or from a YAML config file. The optional `dest_tab_name` YAML key identifies the article tab to read (default: `"Generated Article"`).
2. Read all tabs from the spec doc and the generated article tab from the article doc.
3. Optionally accept reference documents for factual accuracy auditing.
4. Optionally read an "Author Feedback" tab from the article doc containing the author's freeform reactions to the generated article.
5. Analyze the article across up to five dimensions:
   - Constraint saturation: whether the spec's requirements are achievable within its word count
   - Spec quality scoring: how well the article met the spec's own rubric
   - Semantic drift: whether sequential tab processing caused the article to diverge from the full intent
   - Factual accuracy: whether article claims are supported by reference documents (only when reference docs are provided)
   - Author feedback: translation of the author's subjective reactions into concrete spec recommendations, with PRESERVE markers for aspects the author values (only when an "Author Feedback" tab is present)
6. Write a structured plain-text report to a tab named "Spec Coach" in the article doc. The tab name is fixed.
7. Never modify the spec doc. The "Author Feedback" tab is read-only.

## Success Criteria

- The "Spec Coach" tab in the article doc contains the full structured report.
- The report covers all applicable analysis sections (Part 4 omitted when no reference docs are provided; Part 5 omitted when no "Author Feedback" tab is present — each omission noted in the report header).
- When an "Author Feedback" tab is present, Part 5 contains positive observations with PRESERVE markers and negative observations translated into concrete spec recommendations.
- The spec doc is unchanged after the skill runs.
- The "Author Feedback" tab is unchanged after the skill runs.
- If spec and article doc IDs are identical, the skill stops before making any changes and reports the conflict.
- Scoring uses the rubric defined in the spec itself; an inferred rubric is noted explicitly.
- The report includes a SCORE HISTORY section that tracks the composite quality score across runs. On re-runs, the history carries forward prior scores and shows the delta from the previous run.
