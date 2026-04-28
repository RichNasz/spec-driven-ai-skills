# WHAT: Skill Marketplace

## Vision

Make skill suites from this repository installable into any user project with a single Claude Code command. A developer should be able to clone this repo, invoke `/install-skills`, and have a complete, working skill suite copied into their target project — ready to use without manual file management.

## User Story

As a developer who wants to use the spec-driven AI skills in my own project, I want to run a single command that installs the skill suite I need so that I don't have to manually copy files, resolve dependencies, or figure out which scripts belong where.

## Functional Requirements

1. Provide a `marketplace/catalog.yaml` at the repo root that lists all available skill suites with their skills, source paths, and system prerequisites.
2. Provide an `/install-skills` Claude Code skill that reads the catalog and installs a chosen suite into a user-specified target project directory.
3. When invoked without arguments, `/install-skills` lists available suites and prompts the user to choose.
4. When invoked with a suite name and target path, `/install-skills` confirms the selection then proceeds without further prompting.
5. Installation copies all required files — SKILL.md plus any supporting scripts and config examples — into `<target>/.claude/skills/<skill-name>/`.
6. After installation, the skill reports every file copied and lists any system prerequisites the user must satisfy before the skills will work.
7. The catalog is the single source of truth for suite definitions. Adding a new suite requires only a catalog entry — no changes to the install skill itself.

## Success Criteria

- A developer can install the `articles` suite by running `/install-skills articles ~/my-project` and immediately use `/generate-article`, `/spec-coach`, and `/spec-auto-tune` in that project (after satisfying system prerequisites).
- Running `/install-skills` with no arguments shows a readable list of available suites with descriptions.
- The install skill never modifies files in this repository — it only reads from the catalog and source skill directories.
- Adding a new skill suite to the marketplace requires only a new entry in `marketplace/catalog.yaml` and the skill source files — no changes to the install skill.
