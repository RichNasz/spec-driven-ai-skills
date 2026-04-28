# HOW: Test Scripts

## Purpose

Documents the `tests/` directory — persistent shell scripts that automate the bookend steps of each test scenario. Testers no longer need to read the full `test-*.md` spec to set up or verify a scenario; they run the corresponding setup and verify scripts and invoke the Claude skill in between.

---

## Directory Structure

```
tests/
  lib.sh                          # shared library — source this in all scripts
  reset-article-doc.sh            # standalone: reset Standard Article Doc to empty
  reset-spec-doc.sh               # standalone: restore a spec doc to canonical state
  generate-article/
    setup-G1.sh … setup-G7.sh
    verify-G2.sh … verify-G7.sh   # G1 has no verify script (error-path test)
  spec-coach/
    setup-C1.sh … setup-C7.sh
    verify-C2.sh … verify-C7.sh   # C1 has no verify script (error-path test)
  spec-auto-tune/
    setup-A1.sh … setup-A8.sh
    verify-A3.sh … verify-A8.sh   # A1, A2 have no verify scripts (error-path tests)
  pipeline/
    setup-P1.sh, setup-P2.sh, setup-P3.sh
    verify-P1-step1.sh, verify-P1-step2.sh, verify-P1-step3.sh
    verify-P2-step1.sh, verify-P2-step2.sh
    verify-P3-step1.sh, verify-P3-step2.sh
```

All scripts must be run from the **project root** (`articles/`). They will error if run from any other directory.

---

## lib.sh Interface

`lib.sh` is sourced by all scripts. It provides:

### Constants
- `SCRIPTS_DIR` — path to gws-utils Python scripts
- `FIXTURES_YAML` — path to `specs/fixtures/fixtures.yaml`
- `CONTENT_DIR` — path to `specs/fixtures/content/`

### `get_doc_id <fixture_key>`
Extracts the Google Doc ID from `fixtures.yaml` by fixture key name.

```bash
ARTICLE_DOC=$(get_doc_id "standard_article_doc")
```

Supported keys: `standard_spec_doc`, `over_determined_spec`, `minimal_spec_doc`, `standard_article_doc`, `reference_doc`.

### Assert helpers
All assert functions print `PASS: ...` or `FAIL: ...` and return 0/1 accordingly.

| Function | Arguments | Checks |
|---|---|---|
| `assert_tab_exists` | `doc_id tab_name` | Tab with that exact name is present |
| `assert_tab_absent` | `doc_id tab_name` | Tab with that exact name is not present |
| `assert_tab_contains` | `doc_id tab_name string` | Tab content contains the literal string |
| `assert_tab_not_contains` | `doc_id tab_name string` | Tab content does not contain the literal string |
| `assert_tab_matches` | `doc_id tab_name pattern` | Tab content matches a grep-E pattern |
| `assert_tab_count` | `doc_id expected_count` | Doc has exactly N tabs |
| `count_tabs` | `doc_id` | Prints number of tabs to stdout (no PASS/FAIL) |

### Fixture management helpers

**`reset_article_doc <doc_id>`** — deletes all tabs except the first, then clears the first tab. Use before any scenario that writes to the Standard Article Doc.

**`restore_spec_doc <doc_id> <content_dir>`** — clears each tab in the doc and rewrites it from the corresponding `tab-N-*.txt` file in `content_dir`. Tab index `N` in the doc is matched to the file `tab-N-<title>.txt`.

**`create_sentinel_tab <doc_id> <tab_name> <sentinel_text>`** — creates a tab and writes sentinel text into it. Used by overwrite-scenario setups (G4, C4).

**`require_tab <doc_id> <tab_name> <context_message>`** — checks that the named tab exists; prints a prerequisite message and exits 1 if it is absent. Used by setup scripts that depend on output from a prior skill run.

---

## Tester Workflow

For each scenario, the workflow is three shell commands with a manual Claude invocation in the middle:

```sh
# 1. Prepare fixture state
./tests/generate-article/setup-G2.sh

# 2. Run the Claude skill (in this Claude Code session)
# /generate-article specs/fixtures/config-standard.yaml

# 3. Verify outcome
./tests/generate-article/verify-G2.sh
```

For pipeline scenarios (P1, P2, P3), the workflow interleaves multiple skill invocations with multiple verify scripts:

```sh
./tests/pipeline/setup-P1.sh
# /generate-article ...
./tests/pipeline/verify-P1-step1.sh
# /spec-coach ...
./tests/pipeline/verify-P1-step2.sh
# /spec-auto-tune ...
./tests/pipeline/verify-P1-step3.sh
```

---

## Output Conventions

**Verify scripts** print one `PASS:` or `FAIL:` line per check, then either `ALL CHECKS PASSED` or `N CHECK(S) FAILED`. Exit code 0 = all pass; exit code 1 = at least one failure.

**Setup scripts** print progress lines (what was reset, what was created) and then print the invocation command(s) for the human step. Setup scripts use `set -euo pipefail` and exit immediately on any failure.

**Manual check notices** are printed by verify scripts when a check requires reading the Claude conversation output (e.g., confirming report section content or error message wording). These are informational — they do not affect the exit code.

---

## Scenarios Without Verify Scripts

The following scenarios use error-path guards whose expected outcome is an exact error message from Claude. These cannot be verified by reading the doc state.

- **G1** — error: "Source and destination cannot be the same document."
- **C1** — error: "Spec and article cannot be the same document."
- **A1** — error: "Spec and article cannot be the same document."
- **A2** — error: "No 'Spec Coach' tab found in the article document. Run /spec-coach first."

For these, check the exact wording in the Claude conversation output. Confirm in a browser that no doc was modified.

---

## Running All Tests for a Skill

There is no single "run all tests" script. Scenarios must be run individually because each Claude invocation requires a human in the loop. Run them in numerical order within a series to maintain correct fixture state.

Between A-series scenarios, restore the Standard Spec Doc:

```sh
./tests/reset-spec-doc.sh standard_spec_doc
```

After A5, also restore the Over-Determined Spec Doc:

```sh
./tests/reset-spec-doc.sh over_determined_spec
```
