# Project context for Claude Code

## What this project is

A collection of Claude Code skill suites organized by category. Each subdirectory is an independent skill suite with its own `.claude/skills/`, `docs/`, `specs/`, and `CLAUDE.md`.

## Structure

```
spec-driven-ai-skills/
  articles/          Spec-driven article generation (generate-article, spec-coach, spec-auto-tune)
```

## Convention

When working inside a skill category subdirectory, read that subdirectory's `CLAUDE.md` for context specific to those skills.

## Current categories

| Directory | Skills | Notes |
|---|---|---|
| `articles/` | `/generate-article`, `/spec-coach`, `/spec-auto-tune` | Requires `gws` CLI and Google Workspace credentials |
