# WHAT: Skill Marketplace

## Vision

Make skill suites from this repository installable into any user project through Claude Code's native plugin system — no custom tooling required. A developer registers this repo as a marketplace once, then installs any available plugin with a single command.

## User Story

As a developer who wants to use the spec-driven AI skills in my own project, I want to add this repo as a Claude Code marketplace and install the skill suite I need so that the skills are available in my project without manual file management.

## Functional Requirements

1. Provide a `.claude-plugin/marketplace.json` at the repo root that registers the marketplace and lists all available plugins with their source paths, metadata, and tags.
2. Each plugin directory contains a `.claude-plugin/plugin.json` with its own metadata.
3. Each plugin's skills live in a `skills/` subdirectory within the plugin directory, following the Claude Code agent skills standard.
4. Installation uses Claude Code's native `/plugin` commands — no custom install skill is needed.
5. Adding a new plugin suite requires only a new directory with `.claude-plugin/plugin.json` and `skills/`, plus a new entry in the root `marketplace.json`.

## Installation Flow

```
# Register the marketplace (once per machine)
/plugin marketplace add https://github.com/RichNasz/spec-driven-ai-skills

# Install a plugin into the current project
/plugin install articles@sdai-marketplace
```

## Success Criteria

- A developer can install the `articles` plugin using the two commands above and immediately use `/generate-article`, `/spec-coach`, and `/spec-auto-tune` in their project.
- The root `marketplace.json` is the single source of truth for available plugins.
- Adding a new skill category to the marketplace requires no changes to existing files — only a new plugin directory and a new `marketplace.json` entry.
