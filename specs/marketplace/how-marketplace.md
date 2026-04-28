# HOW: Skill Marketplace

## Standard

This marketplace follows the [Agent Skills open standard](https://agentskills.io), which is natively supported by Claude Code, VS Code with Claude extension, and Cursor 2.4+.

## Constraints

- No custom install tooling. Installation is handled entirely by Claude Code's built-in `/plugin` system.
- The root `marketplace.json` is the only file a contributor edits to register a new plugin. The plugin directory and its `plugin.json` are self-contained.
- Plugin names must match their directory names (e.g., plugin directory `articles/` → `"name": "articles"` in both `marketplace.json` and `plugin.json`).

## Root `marketplace.json` Schema

Location: `.claude-plugin/marketplace.json`

```json
{
  "name": "<marketplace-id>",
  "owner": { "name": "<github-username>" },
  "metadata": {
    "description": "<marketplace description>",
    "version": "<semver>"
  },
  "plugins": [
    {
      "name": "<plugin-name>",          // matches plugin directory name
      "source": "./<plugin-directory>", // relative path from repo root
      "description": "<one-line>",
      "version": "<semver>",
      "author": { "name": "<name>" },
      "homepage": "<url>",
      "repository": "<github-url>",
      "license": "<spdx-id>",
      "tags": ["<tag>", ...]
    }
  ]
}
```

## Plugin Directory Structure

```
<plugin-name>/
  .claude-plugin/
    plugin.json       Plugin metadata
  skills/
    <skill-name>/
      SKILL.md        Skill definition (frontmatter + implementation)
      [scripts/]      Supporting scripts if needed
      [*.yaml]        Config examples if needed
  README.md           User-facing plugin documentation
  docs/               Extended skill documentation (optional)
  specs/              Spec-driven development artifacts (internal)
```

## Per-Plugin `plugin.json` Schema

Location: `<plugin>/.claude-plugin/plugin.json`

```json
{
  "name": "<plugin-name>",
  "version": "<semver>",
  "description": "<full description>",
  "author": { "name": "<name>" },
  "homepage": "<url>",
  "repository": "<github-url>",
  "license": "<spdx-id>",
  "tags": ["<tag>", ...]
}
```

## Adding a New Plugin

1. Create the plugin directory at repo root: `<plugin-name>/`
2. Add `.claude-plugin/plugin.json` with full metadata
3. Add `skills/<skill-name>/SKILL.md` for each skill
4. Add a new entry to `.claude-plugin/marketplace.json`
5. No other files need to change

## Versioning

- Plugin versions in `marketplace.json` and `plugin.json` must match.
- Increment the root `marketplace.json` `metadata.version` when any plugin version changes.
