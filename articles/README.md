[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](../LICENSE)
![Built with Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-blueviolet)
![Spec-Driven](https://img.shields.io/badge/Approach-Spec--Driven-green)
![Google Docs](https://img.shields.io/badge/Google-Docs-4285F4)

# rh-skills/articles

Three Claude Code skills for spec-driven article generation from Google Docs.

## What this is

A skill pipeline that turns a structured Google Doc spec into a published article — and then uses that article to evaluate and improve the spec for the next iteration.

```
Spec Doc ──/generate-article──▶ Article Doc
                                      │
                              /spec-coach
                                      │
                                      ▼
                              Article Doc (+ "Spec Coach" tab)
                                      │
                              /spec-auto-tune
                                      │
                                      ▼
                              Spec Doc (improved)
```

Run the pipeline once to produce an article. Run it again to tighten the spec. Each cycle leaves a measurably better spec and a better article.

For the technical and philosophical rationale behind this design, see [APPROACH.md](../APPROACH.md). For the core concepts — constraint saturation, semantic drift, and the self-improving spec loop — see [docs/concepts.md](../docs/concepts.md).

## Prerequisites

- [Claude Code](https://claude.ai/code) CLI installed and authenticated
- [`gws`](https://github.com/stoe/gws) CLI configured with Google Workspace credentials that have read/write access to your Docs

## Quick start

```yaml
# my-article.yaml
spec_doc_url:    "https://docs.google.com/document/d/<YOUR_SPEC_ID>/edit"
article_doc_url: "https://docs.google.com/document/d/<YOUR_ARTICLE_ID>/edit"
reference_docs:
  - url: "https://docs.google.com/document/d/<SOURCE_OF_TRUTH_ID>/edit"
    description: "Source material — factual grounding for the article"
```

```bash
/generate-article my-article.yaml   # write the article
/spec-coach my-article.yaml         # evaluate spec and article
/spec-auto-tune my-article.yaml     # apply improvements to the spec
```

Then regenerate and repeat. The Spec Coach report tells you when to stop.

## Skills

| Skill | What it does | Docs |
|---|---|---|
| `/generate-article` | Reads spec tabs as a prompt chain; writes article to a named tab in the destination doc | [docs/generate-article.md](docs/generate-article.md) |
| `/spec-coach` | Scores the article against the spec's own rubric; analyzes semantic drift; audits factual accuracy; writes report to "Spec Coach" tab | [docs/spec-coach.md](docs/spec-coach.md) |
| `/spec-auto-tune` | Reads the Spec Coach report; applies improvements to the spec doc; reports changes and any required manual steps | [docs/spec-auto-tune.md](docs/spec-auto-tune.md) |

## Repo layout

```
.claude/skills/           Claude Code skill instruction sets (internal)
  generate-article/
  spec-coach/
  spec-auto-tune/
docs/                     User-facing skill documentation
specs/                    Spec-driven development artifacts (internal)
  common-how/             Shared implementation guides
  fixtures/               Test fixture configs and canonical content
  generate-article/       Per-skill what/how/test specs
  spec-coach/
  spec-auto-tune/
  pipeline/
```

`specs/` is an internal development artifact — it documents how the skills are built, not how to use them. Start with `docs/` if you are a user.
