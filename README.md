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

Install any skill plugin into your own project using Claude Code's native plugin system:

```
/plugin marketplace add https://github.com/RichNasz/spec-driven-ai-skills
/plugin install articles@sdai-marketplace
```

Available plugins are listed in [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json).

## Getting started

Navigate to the relevant skill category and follow its README.

## Background

[APPROACH.md](APPROACH.md) covers the philosophy and technical rationale behind spec-driven AI workflows.
