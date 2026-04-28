[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Built with Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-blueviolet)
![Spec-Driven](https://img.shields.io/badge/Approach-Spec--Driven-green)

# Spec-Driven AI Skills

A growing collection of Claude Code skill suites that implement spec-driven workflows. Each category is a self-contained subdirectory with its own skills, docs, and tests.

## Skill categories

| Category | What it does |
|---|---|
| [`articles/`](articles/README.md) | Spec-driven article generation — generate articles from Google Doc specs, evaluate spec quality, and auto-tune specs for the next iteration |

## Marketplace

Install any skill suite into your own project with a single command. Clone this repo, open it in Claude Code, then run:

```
/install-skills articles ~/path/to/your-project
```

Available suites are listed in [`marketplace/catalog.yaml`](marketplace/catalog.yaml). Run `/install-skills` with no arguments to browse them interactively.

## Getting started

Navigate to the relevant skill category and follow its README.

## Background

[APPROACH.md](APPROACH.md) covers the philosophy and technical rationale behind spec-driven AI workflows.
