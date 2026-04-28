[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Built with Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-blueviolet)
![Spec-Driven](https://img.shields.io/badge/Approach-Spec--Driven-green)

# Spec-Driven AI Skills

A growing collection of Claude Code skill suites that implement spec-driven workflows. Each category is a self-contained subdirectory with its own skills, docs, and tests.

## Skill categories

| Category | What it does |
|---|---|
| [`articles/`](articles/README.md) | Spec-driven article generation — generate articles from Google Doc specs, evaluate spec quality, and auto-tune specs for the next iteration |

## Installing skills

Skills are installed into your own project using Claude Code's native plugin system.

**Prerequisite:** [Claude Code](https://claude.ai/code) installed and authenticated.

**Step 1 — Register this marketplace** (once per machine):

```
/plugin marketplace add https://github.com/RichNasz/spec-driven-ai-skills
```

**Step 2 — Install the plugin you want** (run from inside your project):

```
/plugin install articles@sdai-marketplace
```

This copies the plugin's skills into your project's `.claude/skills/` directory, where Claude Code picks them up automatically as slash commands.

**Available plugins:**

| Plugin | Installs | Additional requirements |
|---|---|---|
| `articles` | `/articles:generate-article`, `/articles:spec-coach`, `/articles:spec-auto-tune` | [`gws` CLI](https://github.com/stoe/gws) with Google Workspace credentials; Python 3 |

See each plugin's README for usage details after installation.

## Getting started

Navigate to the relevant skill category's README for full usage documentation.

## Background

[APPROACH.md](APPROACH.md) covers the philosophy and technical rationale behind spec-driven AI workflows.
