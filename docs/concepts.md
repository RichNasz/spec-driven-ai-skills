# Core Concepts

These concepts underpin every skill category in this project. Each one applies to any spec-driven AI workflow, not just article generation. For the philosophical and research foundations behind these ideas, see [APPROACH.md](../APPROACH.md).

---

## Constraint Saturation

A spec's constraints make demands on the output's budget — word count, token count, or any finite capacity. Each requirement consumes some of that budget. Add them up and compare against the target: if the minimum budget for all required elements exceeds the ceiling, the spec is over-determined. It will produce output that satisfies some constraints at the expense of others. Iterative improvement cycles will produce declining scores, not improving ones, because removing constraints is the only thing that would actually help.

Spec Coach quantifies this before generation and assigns one of three verdicts:

| Verdict | Meaning |
|---|---|
| **HEALTHY** | Minimum coverage needs are under 85% of the output budget; at most one scoring pass. There is room to execute well. |
| **TIGHT** | Minimum coverage is 85–100% of budget; or one contradictory constraint pair exists; or two scoring passes are present. Feasible but leaves elements at minimum viable depth. |
| **OVER-DETERMINED** | Minimum coverage exceeds budget; or multiple contradictions exist; or three or more scoring passes are present. Iterative auto-tune will produce declining scores until constraints are reduced. The spec needs surgery, not polish. |

When a spec is OVER-DETERMINED, the correct response is to remove or relax constraints — not to add more. Adding instructions to an over-determined spec accelerates the decline.

---

## Semantic Drift

Semantic drift is what happens when a model's output drifts from its intended subject toward the spec's own noise. A spec full of vivid examples causes the model to write about the examples. A spec with dense structural scaffolding causes the model to trace the scaffolding. The spec becomes the content. The subject disappears.

This failure mode has a research foundation: Liu et al. (2024), "Lost in the Middle," documents that AI performance follows a U-shaped curve across the position of content in a prompt — highest at the beginning and end, with a deep valley in the middle. Instructions buried in the center of a long spec are systematically underweighted.

Spec Coach's drift analysis evaluates four mechanisms:

| Mechanism | What it detects |
|---|---|
| **Primacy bias** | Early sections dominating the output's architecture, even when later sections give contradictory or refining instructions |
| **Recency bias** | Late sections overwriting nuance established earlier |
| **Lost-in-the-middle** | Middle sections underrepresented in the final output relative to their importance |
| **Tab ordering effects** | Whether the current sequence is the right sequence, or whether reordering would change what the model prioritizes |

These are not questions about whether the output is good. They are questions about whether the spec is designed well. The recommended fix is almost always a structural change to the spec — reordering, trimming, or repositioning content — not a revision of the output.

---

## The Self-Improving Spec Loop

Most AI generation tools iterate on output: generate, critique the output, revise the output. This project inverts that loop. The output is disposable. The spec is the artifact.

The pipeline generates output, evaluates how well the spec performed in producing it, then applies improvements to the spec — not the output. The next generation run starts from a better spec. The output improves as a consequence.

This framing changes what gets improved. A tool optimizing for output quality adds instructions that nudge the output toward the target. A tool optimizing for spec quality removes constraints that are redundant, resolves contradictions, and reorders sections to reduce drift risk. The result is a shorter, simpler spec that generates better output across regenerations — not a longer, more prescriptive one.

The goal state is **Logic Compression**: a spec reaches Logic Compression when removing any constraint would degrade the output. That is when the spec is ready.

---

## What Makes This Different

Most AI writing and generation tools — commercial and academic — frame the problem as: improve the output. Self-Refine, Reflexion, PromptWizard, SIPDO, and similar frameworks implement generate → critique → improve cycles targeted at the output. The spec is a means; the output is the goal.

This project's framing is different: **the spec is a design artifact with its own quality dimensions** — saturation level, drift risk, constraint contradictions, factual accuracy, structural ordering. Evaluating whether the spec itself is well-designed is distinct from evaluating whether the output is good. Tools that conflate the two converge on longer, more prescriptive specs. This pipeline converges on shorter ones.

In practice:

- Tools optimizing for output quality → longer, more constrained specs over time
- This pipeline → shorter, more load-bearing specs over time

A 2025 paper ("You Don't Need Prompt Engineering Anymore: The Prompting Inversion," arXiv 2510.22251) documents that on capable models, heavily constrained prompts are measurably detrimental. Constraints that prevented errors in weaker models induce hyper-literalism in stronger ones — what the paper calls the Guardrail-to-Handcuff transition. This project builds tooling to help practitioners find and stay at the right constraint level.
