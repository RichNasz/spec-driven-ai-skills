# Testing

## Why tests exist for AI skills

Traditional software tests verify deterministic behavior: given input X, the output is always Y. Skills built on large language models do not work that way. The same invocation produces different outputs on different runs. The quality of the output — whether the article is good, whether the Spec Coach analysis is insightful — cannot be cheaply automated without either a human judge or a second LLM, both of which introduce their own unreliability.

What can be reliably tested is the mechanical contract each skill makes:

- Does the skill write to the right document and only that document?
- Does it create, clear, or overwrite tabs correctly?
- Does it surface the right error when given invalid input and stop there?
- Does it produce the structural output the next skill in the pipeline expects?

These tests verify the plumbing, not the thinking. That is the correct scope for automated verification of LLM-backed skills.


## Why tests are structured as setup / invoke / verify

Each test has two or three scripts: a `setup-*.sh`, an invocation step the tester runs manually, and usually a `verify-*.sh`. The human runs the actual skill in between.

This is intentional. The alternatives are worse:

**Mocking the LLM** would test nothing real. The skills' most failure-prone behavior — hallucination, drift, ignoring instructions — only appears with a real model. A mock that returns a fixed string would pass every structural check and tell you nothing.

**Automated end-to-end execution** would require orchestrating Claude Code from the shell, which is expensive, slow, and fragile. Each test would consume a full LLM context window. Tests that depend on AI output quality would be non-deterministic and would fail sporadically on valid runs.

**Human-in-the-loop as a design choice, not a limitation.** The human running the skill is reading the conversation, watching for error messages, observing model behavior. That observation is itself part of the test. The verify script then confirms the observable state of the Google Docs, which is what the skill actually changed.


## What is programmatically verified vs. manually checked

**Programmatic (via verify scripts):**

- Tab existence and absence — did the skill create, skip, or avoid the right tabs?
- Tab count — did the skill avoid duplicating tabs?
- Tab content guards — did sentinel text get overwritten? Did a seeded inaccuracy get removed?
- Report section presence — does the Spec Coach report contain PART 1, PART 2, PART 3?
- Write target isolation — did spec-coach leave the spec doc alone? Did spec-auto-tune leave the article doc alone?
- Content change detection — did spec-auto-tune actually modify the spec (A3)? Did it correctly do nothing on the second run (A7)?

**Manual (human judgment required):**

- Error message exact text — the error guard tests (G1, C1, A1, A2) emit a specific sentence; the verify script confirms no writes happened, but a human reads the actual message
- Report substance — the Spec Coach report contains section headers, but whether the analysis inside them is meaningful is a human call
- Spec content quality — after spec-auto-tune runs, a human should read what changed and judge whether it was a reasonable improvement
- Conversation report coherence — spec-auto-tune writes its summary to the conversation, not a doc; its structure and completeness are a human check


## Test series and what each covers

| Series | Skill | Scenarios |
|---|---|---|
| G1–G7 | `/generate-article` | Same-doc guard, YAML/positional forms, tab creation, overwrite, default name, minimal spec, extra YAML keys |
| C1–C7 | `/spec-coach` | Same-doc guard, report structure, factual audit, tab overwrite, saturation detection, empty refs, rubric inference |
| A1–A8 | `/spec-auto-tune` | Same-doc guard, missing Spec Coach tab, instructional changes, factual correction, over-determined blocking, tab reorder instructions, idempotence, no-research skip |
| P1–P3 | Pipeline | Full linear pipeline, second iteration cycle, non-default article tab name |


## How to run a test

All scripts must be run from the project root (`articles/`).

**Standard flow for most tests:**

```bash
# 1. Prepare fixtures
./tests/<series>/setup-<ID>.sh

# 2. Run the skill (in Claude Code)
/<skill> specs/fixtures/config-standard.yaml

# 3. Verify state
./tests/<series>/verify-<ID>.sh
```

**For pipeline tests** (P-series), the setup script prints a multi-step invocation sequence. Run each skill step, run the corresponding verify script, then proceed to the next step.

**Fixture setup prerequisite:** Copy `specs/fixtures/fixtures.yaml.example` to `specs/fixtures/fixtures.yaml` and fill in your own doc IDs. Create the `config-*.yaml` files from their `.example` counterparts. Without this, all scripts will fail on `get_doc_id`.

**Resetting fixtures between tests:**

```bash
./tests/reset-spec-doc.sh standard      # restore standard spec to canonical content
./tests/reset-spec-doc.sh over-determined
./tests/reset-article-doc.sh            # delete all tabs except default, clear default
```

Several tests leave the fixtures in a modified state intentionally (A7 requires the post-A3 state). The setup script for each test tells you whether to reset first.


## Interpreting results

**`PASS: ...`** — the assertion succeeded; this specific check is green.

**`FAIL: ...`** — the assertion failed; see the message for what was wrong.

**`ALL AUTOMATED CHECKS PASSED`** — all programmatic checks passed. This does not mean the test passed — read the manual check notes printed below this line.

**`N CHECK(S) FAILED` / exit 1** — at least one programmatic check failed. Investigate before proceeding; subsequent tests may depend on this state being correct.

**`PREREQUISITE MISSING`** — a required fixture tab is absent. Run the listed prerequisite setup script first.

**`WARN: snapshot file not found`** — a before-snapshot from setup is missing. This usually means setup was not run before verify. Re-run setup and the skill, then re-run verify.


## When to update tests

**Add a new verify script** when a new scenario is added and the setup script currently says "confirm manually" for something that could be checked programmatically (tab existence, count, content guards).

**Update canonical content files** in `specs/fixtures/content/` when you intentionally change the standard spec fixture doc. After updating the doc, run `./tests/reset-spec-doc.sh` and confirm the content files match.

**Do not try to automate content quality checks.** If a test is failing because the LLM produced a lower-quality report than expected on a given run, that is expected variance, not a bug. The programmatic checks are scoped to mechanical behavior; quality assessment belongs in the human verification step.
