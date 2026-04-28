# HOW: Project-Level Documentation

## Constraints

- Project-level documents live at the repo root, not inside any skill-category subdirectory.
- Documents that apply only to one skill category belong in that subdirectory, not at root.
- Root-level documents must not duplicate content in subdirectory documents. They orient and point; subdirectories explain.
- LICENSE and CODE_OF_CONDUCT live at root and are not regenerated — they are edited directly.

## README.md

**Structure**
1. Title and one-sentence description
2. Skill categories table: columns are category directory (linked to its README), and a one-line description of what it does
3. Getting started: one or two sentences directing the reader to navigate to a skill category
4. Background: link to APPROACH.md with a one-line description

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
