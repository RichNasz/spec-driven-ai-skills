# HOW: Skill Marketplace

## Constraints

- The install skill is read-only with respect to this repository. It never writes to or modifies any file under the repo root.
- `import yaml` is unavailable. Parse `catalog.yaml` using string operations (`split(':', 1)`, `.strip()`, `.strip('"')`). Do not use PyYAML.
- Installation target is always `<target>/.claude/skills/` — never a different path structure.
- The install skill lives at the repo root's `.claude/skills/install-skills/SKILL.md` so it is available whenever this repo is opened in Claude Code.

## catalog.yaml Schema

Location: `marketplace/catalog.yaml` (repo root)

```yaml
suites:
  <suite-key>:                        # short identifier, no spaces (e.g. "articles")
    name: <display name>
    description: <multi-line string>
    version: "<semver>"
    docs: <relative path to suite README>
    system_requires:                  # list of system prerequisites (strings)
      - <requirement with URL>
    skills:
      - name: <skill-name>            # matches the .claude/skills/<name>/ directory
        source: <relative path to source skill directory>
        role: <optional — "shared-dependency" for utility skills>
```

A suite's `skills` list must include all skills the suite needs, including shared dependencies (e.g., `gws-utils`). The install step copies them all without distinguishing roles — `role` is informational only.

## install-skills Behavior

**Step 0 — Parse invocation args**

Accept `[suite-name]` and `[target-path]` as positional arguments from the invocation text. Both are optional:
- If `suite-name` is omitted: read the catalog, print available suites (key, name, description), and ask the user to specify one.
- If `target-path` is omitted: ask the user for it. Do not default to the current directory — always ask explicitly.

**Step 1 — Read and parse catalog**

Read `marketplace/catalog.yaml` with Python string parsing. Extract the requested suite's `name`, `description`, `version`, `docs`, `system_requires`, and `skills` list.

If the suite key is not found in the catalog, stop and list available suite keys.

**Step 2 — Confirm**

Print a summary before touching anything:
- Suite name and version
- Target path
- Skills to be installed (names only)
- System prerequisites

Ask the user to confirm. Do not proceed until confirmed.

**Step 3 — Install**

For each skill in the suite's skills list:
```
mkdir -p <target>/.claude/skills/<skill.name>
cp <skill.source>/SKILL.md <target>/.claude/skills/<skill.name>/SKILL.md
if <skill.source>/scripts/ exists:
    cp -r <skill.source>/scripts <target>/.claude/skills/<skill.name>/scripts
if <skill.source>/config.example.yaml exists:
    cp <skill.source>/config.example.yaml <target>/.claude/skills/<skill.name>/config.example.yaml
```

**Step 4 — Report**

Print:
1. Every file copied (full target path)
2. System prerequisites the user must satisfy before the skills will work
3. Link to the suite's docs file

## install-skills Frontmatter

```yaml
---
name: install-skills
description: >
  Install a skill suite from the spec-driven-ai-skills marketplace into a
  target project. Run with no arguments to see available suites.
compatibility: Requires Python 3
metadata:
  suite: sdai-marketplace
---
```

## What Gets Copied

| File | Copied? |
|---|---|
| `SKILL.md` | Always |
| `scripts/` directory | If present in source |
| `config.example.yaml` | If present in source |
| Any other files in source dir | Yes — copy everything present |

The install step does a broad copy of the source directory contents rather than an allowlist, so new supporting files added to a skill are automatically included in future installs without catalog changes.
