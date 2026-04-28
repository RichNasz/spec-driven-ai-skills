# HOW: Project-Level Documentation

## Constraints

- Project-level documents live at the repo root, not inside any skill-category subdirectory.
- Documents that apply only to one skill category belong in that subdirectory, not at root.
- Root-level documents must not duplicate content in subdirectory documents. They orient and point; subdirectories explain.
- LICENSE and CODE_OF_CONDUCT live at root and are not regenerated — they are edited directly.

## docs/concepts.md

**Structure**
1. Constraint Saturation — the concept, the three verdicts (HEALTHY / TIGHT / OVER-DETERMINED), what each means for iteration
2. Semantic Drift — the four mechanisms (primacy bias, recency bias, lost-in-the-middle, tab ordering effects) and why they matter for spec design
3. The Self-Improving Spec Loop — how the evaluate-then-improve loop differs from output-iterating approaches
4. What Makes This Different — the framing distinction: optimizing spec quality vs. output quality

**Standards**
- Concept-level only. No skill-specific implementation details (those belong in skill category docs/).
- Does not duplicate APPROACH.md. APPROACH.md covers the philosophical and research foundations; concepts.md covers operational definitions a practitioner needs while building or evaluating a spec.
- Skill category docs/ files reference concepts.md for background rather than restating the definitions inline.
- When a new concept is established by any skill category that applies project-wide, add it here.

## Badge Convention

All README files open with a row of shields.io badges that illustrate the technologies used in that directory. Badges appear before the title, one line, no surrounding prose.

**Badge format**
```
[![Label](https://img.shields.io/badge/<Label>-<Message>-<Color>.svg)](<link>)   ← linked badge
![Label](https://img.shields.io/badge/<Label>-<Message>-<Color>)                 ← unlinked badge
```

**Root README badges** (in this order)

| Badge | Format |
|---|---|
| License | `[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)` |
| Built with Claude Code | `![Built with Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-blueviolet)` |
| Spec-Driven | `![Spec-Driven](https://img.shields.io/badge/Approach-Spec--Driven-green)` |

Subdirectory READMEs add badges for technologies specific to that category (e.g., `articles/` adds a Google Docs badge). The three root badges above appear in every README in the project.

## README.md

**Structure**
1. Badges
2. Title and one-sentence description
3. Skill categories table: columns are category directory (linked to its README), and a one-line description of what it does
4. Getting started: one or two sentences directing the reader to navigate to a skill category
5. Background: link to APPROACH.md with a one-line description

**Standards**
- No prerequisites or installation instructions at root level — those belong in subdirectory READMEs.
- Skill category descriptions must be accurate and current. When a new category is added, the table is the first thing to update.
- The categories table is the only place skill categories are enumerated at root level.

## CLAUDE.md

**Structure**
1. What this project is: one sentence
2. Structure section: directory layout with a one-line description per entry
3. Convention: the rule that subdirectory CLAUDE.mds take precedence when working inside a subdirectory
4. Current categories table: directory, skills it provides, any notable prerequisites

**Standards**
- Keep it minimal. Claude reads subdirectory CLAUDE.mds automatically when working inside them — root CLAUDE.md only needs to establish structure and navigation.
- Do not include skill-level implementation details (those live in subdirectory CLAUDE.mds and SKILL.mds).
- Current categories table must stay in sync with the README categories table.

## APPROACH.md

**Structure**
1. The Thesis: the two core claims (spec quality is the binding constraint; a better spec is usually a smaller spec)
2. The Pipeline: diagram and per-skill description
3. Three Technical Concepts: constraint saturation, semantic drift, the self-improving spec loop
4. The Philosophical Roots: Wiesel, Hemingway, Saint-Exupéry
5. Where This Sits: established foundations and novel contributions
6. Spec Authorship: practical principles

**Standards**
- APPROACH.md is a stable document. Update it when the pipeline or its concepts change, not on every iteration cycle.
- The thesis and philosophical roots sections are evergreen — revise only if the foundational claims change.
- "Where This Sits" citations must reference real publications with enough detail to locate them.
- Write for a technical reader who has not seen the codebase. No references to internal file paths or skill names without a brief explanation.
