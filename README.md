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

Claude Code will ask where to install. Choose the scope that fits your situation:

| Scope | Who can use it | Committed to git | When to choose it |
|---|---|---|---|
| **User** | You only, in all your projects | No | You want these skills available everywhere you work, not just one project |
| **Project** | Everyone on the repo | Yes | Your whole team needs the skills; install settings are shared via version control |
| **Local** | You only, in this project | No | You want to try the skills in one project without affecting your team or your other projects |

> **Not sure?** Choose **User** if you're working solo or just want the skills for yourself. Choose **Project** if you're on a team and everyone should have access.

**Available plugins:**

| Plugin | Skills installed | Additional requirements |
|---|---|---|
| `articles` | `/articles:generate-article`, `/articles:spec-coach`, `/articles:spec-auto-tune` | [`gws` CLI](https://github.com/stoe/gws) with Google Workspace credentials; Python 3 |

See each plugin's README for usage details after installation.

## Managing and removing skills

**Update a plugin** to pick up the latest version from this repo:

```
/plugin marketplace update sdai-marketplace
```

**Disable a plugin** without uninstalling it:

```
/plugin disable articles@sdai-marketplace
```

**Uninstall a plugin** from your project:

```
/plugin uninstall articles@sdai-marketplace
```

**Remove this marketplace entirely** (also uninstalls any plugins you installed from it):

```
/plugin marketplace remove sdai-marketplace
```

You can also manage everything through the interactive UI — run `/plugin` to browse installed plugins and registered marketplaces by tab.

## Getting started

Navigate to the relevant skill category's README for full usage documentation.

## Background

[APPROACH.md](APPROACH.md) covers the philosophy and technical rationale behind spec-driven AI workflows.
