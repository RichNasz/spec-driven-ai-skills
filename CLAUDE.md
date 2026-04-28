# Project context for Claude Code

## What this project is

A collection of Claude Code skill suites organized by category. Each subdirectory is an independent skill plugin with its own `.claude-plugin/plugin.json`, `skills/`, `docs/`, `specs/`, and `CLAUDE.md`.

## Structure

```
spec-driven-ai-skills/
  .claude-plugin/    Marketplace registry (marketplace.json)
  articles/          Spec-driven article generation plugin
  docs/              Project-level concept documentation
  specs/             Project-level specs (project/, marketplace/)
```

## Convention

When working inside a skill category subdirectory, read that subdirectory's `CLAUDE.md` for context specific to those skills.

## Current plugins

| Directory | Skills | Notes |
|---|---|---|
| `articles/` | `/articles:generate-article`, `/articles:spec-coach`, `/articles:spec-auto-tune` | Requires `gws` CLI and Google Workspace credentials |
