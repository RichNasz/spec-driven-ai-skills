# WHAT: Project-Level Documentation

## Vision

Establish the identity and purpose of spec-driven-ai-skills through project-level documents that orient users to the right skill category, give AI collaborators the context they need to work across the project, and articulate the philosophical foundations that apply to all skill categories.

## Documents Produced

| Document | Audience | Purpose |
|---|---|---|
| `README.md` | Users and contributors | Entry point — what the project is, what categories exist, where to start |
| `CLAUDE.md` | Claude Code | Project-level AI context — structure, conventions, navigation |
| `APPROACH.md` | Anyone wanting deeper context | Philosophy and technical rationale behind spec-driven AI workflows |

## User Stories

**As a new user**, I want to open the README and immediately understand what skill categories exist and which one addresses my use case, so I can navigate to the right subdirectory without reading everything.

**As a contributor adding a new skill category**, I want the README and CLAUDE.md to establish the conventions I need to follow, so my new category is consistent with existing ones.

**As Claude Code working anywhere in the project**, I want the root CLAUDE.md to orient me to the project structure and tell me where to look for deeper context, so I don't need to rediscover conventions from scratch each session.

**As someone evaluating the approach**, I want APPROACH.md to explain the philosophical and technical foundations of spec-driven AI workflows, so I can assess whether the approach applies to my problem.

## Success Criteria

### README.md
- A reader unfamiliar with the project can identify the available skill categories in under 30 seconds.
- Each category entry accurately describes what the category does and links to its subdirectory README.
- No implementation details that belong in subdirectory READMEs.

### CLAUDE.md
- Claude Code can determine the project structure and navigate to the correct subdirectory without reading any subdirectory files.
- Does not duplicate content already in subdirectory CLAUDE.mds.
- Stays accurate as new skill categories are added with minimal edits.

### APPROACH.md
- Explains the core thesis (spec quality is the binding constraint) and the three supporting concepts (constraint saturation, semantic drift, the self-improving spec loop) clearly enough for a technical reader with no prior context.
- Applicable to all skill categories, not just articles.
- Stands alone — no assumed familiarity with the codebase.
