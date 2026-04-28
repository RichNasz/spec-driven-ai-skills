# Project context for Claude Code

## What this project is

Four Claude Code skills (`/articles:generate-article`, `/articles:spec-coach`, `/articles:spec-auto-tune`, plus the shared `gws-utils` dependency) that implement a spec-driven article generation pipeline using Google Docs and the `gws` CLI.

## Skill locations

Skills live in `skills/<name>/SKILL.md` and are invoked as slash commands.

| Command | Skill file | Notes |
|---|---|---|
| `/articles:generate-article` | `skills/generate-article/SKILL.md` | |
| `/articles:spec-coach` | `skills/spec-coach/SKILL.md` | |
| `/articles:spec-auto-tune` | `skills/spec-auto-tune/SKILL.md` | |
| (not invoked directly) | `skills/gws-utils/SKILL.md` | Shared gws utility scripts |

An example YAML config is at `skills/spec-auto-tune/config.example.yaml`.

## gws-utils shared dependency

`gws-utils` is a shared skill that contains prebuilt Python scripts for all Google Docs API operations. The three main skills call these scripts instead of building inline Python. Scripts live at `skills/gws-utils/scripts/` and handle keyring-line stripping, JSON encoding, and correct batchUpdate request types internally.

All three main skills declare `metadata.requires: gws-utils` in their frontmatter. Install `gws-utils` alongside any of the three main skills.

## Fixture docs

Test fixture Google Docs are catalogued in `specs/fixtures/fixtures.yaml` — this is the authoritative URL registry. Fixture configs (YAML files passed to skills during testing) are in `specs/fixtures/`.

**Never modify a fixture doc without resetting it afterward.** Reset procedure is in `specs/common-how/how-test-fixtures.md`. Canonical tab content for resetting is in `specs/fixtures/content/`.

## gws quirks

- `gws` output always begins with `Using keyring backend: keyring` — strip this line before JSON parsing. (gws-utils scripts handle this internally.)
- `import yaml` is unavailable in this environment. Parse YAML config files with string operations (`split(':', 1)`, `.strip().strip('"')`).
- Use `addDocumentTab` (not `createTab`) in batchUpdate requests.
- Use `deleteTab` (not `deleteDocumentTab`) to remove tabs.

## Spec development conventions

Internal specs in `specs/` follow a three-file naming pattern per skill:

- `what-<skill>.md` — vision, requirements, user story, success criteria
- `how-<skill>.md` — constraints, structure, implementation standards
- `test-<skill>.md` — test scenarios (G/C/A/P series) with setup, invocation, expected outcome, and verification checklist

`test-*.md` files are executed by a human tester against live fixture docs using real `gws` API calls.

## Write targets

Each skill has exactly one permitted write target:

- `/articles:generate-article` → named tab in the article doc only; spec doc is read-only
- `/articles:spec-coach` → "Spec Coach" tab in the article doc only; spec doc and reference docs are read-only
- `/articles:spec-auto-tune` → spec doc tabs only; article doc and reference docs are read-only

## Test scripts

Persistent shell scripts for running test scenarios live in `tests/`. Each scenario has a `setup-<ID>.sh` and (where applicable) a `verify-<ID>.sh`. A shared `tests/lib.sh` provides fixture management and assert helpers.

Run all scripts from the project root: `./tests/articles:generate-article/setup-G2.sh`

For fixture reset utilities: `./tests/reset-article-doc.sh` and `./tests/reset-spec-doc.sh <fixture_key>`.

Full reference: `specs/common-how/how-test-scripts.md`.
