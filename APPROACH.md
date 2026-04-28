# The Approach: Spec-Driven Content Generation and the Reductive Protocol

## The Thesis

Most practitioners who use AI for content generation iterate on the output. The article comes back wrong, so they revise it — manually or by prompting again. The spec that produced the article stays the same.

This project inverts that assumption. The output is disposable. The spec is the artifact.

The claim is simple: spec quality is the binding constraint on AI output quality, not model capability. A well-designed spec consistently produces strong output. A poorly-designed spec produces unpredictable output regardless of how capable the model is. Improving the article by editing the article addresses the symptom. Improving the spec addresses the cause.

The second claim follows from the first: a better spec is usually a smaller spec. The failure mode for most specs isn't insufficient coverage — it's excessive coverage. When a spec accumulates too many constraints, the model cannot hold them all in productive tension. Instructions compete. Earlier ones fade. The output begins to trace the noise of the instruction set rather than the subject it was supposed to address. The discipline is not addition. It is removal.

These two claims — close the loop on the spec, not the output; and remove rather than accumulate — are what this pipeline is built to support.


## The Pipeline

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

Three skills. One loop.

`/generate-article` reads the spec as a sequential prompt chain — each tab in the Google Doc is a refinement pass applied in order. The result is written to a named tab in the article doc.

`/spec-coach` evaluates both documents and produces a structured report. The critical distinction: Spec Coach is not primarily asking "is this a good article?" It is asking "is this a well-designed spec?" The report has four parts: a constraint saturation analysis (is the spec over-constrained relative to the output budget?), a quality score using the rubric the spec itself defines, a semantic drift analysis (did the tab ordering or instruction density cause the output to drift from its subject?), and — when reference documents are provided — a factual accuracy audit. The feedback is about the spec's design, not the article's prose.

`/spec-auto-tune` reads the Spec Coach report and applies improvements directly to the spec. It prioritizes factual corrections first, then constraint removals, then content additions. Changes that add new constraints are blocked when the spec is already tight. The result is an improved spec — not a revised article.

Then regenerate and repeat. Each cycle leaves a measurably better spec. The article improves as a consequence.

Most AI writing tools (commercial and academic) iterate on output. Self-Refine, Reflexion, and similar frameworks generate output, critique it, and revise the output. This pipeline generates output, critiques the instruction set that produced it, and revises the instruction set. The article is a signal. The spec is the conclusion.


## Three Technical Concepts

### Constraint Saturation

A spec's constraints make demands on the output's word budget. A requirement for a dedicated paragraph costs roughly 70-100 words. A required substantive mention costs 30-40. Image suggestions, comparison tables, terminology definitions, and scoring logs all consume space. Add them up and compare against the target word count: if the minimum word budget for all required elements exceeds the ceiling, the spec is over-determined. It will produce output that satisfies some constraints at the expense of others — and iterative improvement cycles will produce declining scores, not improving ones, because removing constraints is the only thing that would actually help.

Spec Coach quantifies this as a pre-flight check before generation and reports one of three states:

- **HEALTHY** — the minimum budget is under 85% of target; no contradictory constraints; at most one scoring pass. There is room to execute well.
- **TIGHT** — the budget is 85-100% of target, or one contradictory constraint pair exists. The spec is feasible but leaves important elements at minimum viable depth.
- **OVER-DETERMINED** — the minimum budget exceeds target, or multiple contradictions exist, or three or more scoring passes are present. Iterative auto-tune will produce declining scores until constraints are reduced. The spec needs surgery, not polish.

This is a concept the research literature recognizes — prompt density and instruction overload are documented failure modes — but systematic tooling for detecting it does not appear to exist elsewhere. The saturation check is the part of this pipeline with the least obvious precedent.

### Semantic Drift

Semantic drift is what happens when a model's output drifts from its intended subject toward the spec's own noise. A spec full of vivid examples causes the model to write about the examples. A spec with dense structural scaffolding causes the model to trace the scaffolding. The spec becomes the content. The subject disappears.

This failure mode has a published foundation: Liu et al. (2024), "Lost in the Middle," documents that AI performance follows a U-shaped curve across the position of content in a prompt — highest at the beginning and end, with a deep valley in the middle. Instructions buried in the center of a long spec are systematically underweighted. Most practitioners bury their subject variable there.

Spec Coach's drift analysis (Part 3 of every report) goes further than the published research by applying this to spec design rather than RAG retrieval. It evaluates primacy bias (early tabs dominating the article's architecture even when later tabs give contradictory instructions), recency bias (late tabs overwriting nuance established earlier), lost-in-the-middle effects (middle tabs underrepresented in the final output), and tab ordering effects (whether the current sequence is the right sequence, or whether reordering tabs would change what the model prioritizes). These are not questions about whether the article is good. They are questions about whether the spec is designed well.

### The Self-Improving Spec Loop

The pipeline closes its feedback loop on the spec, not the output. This is the part of the design that is most different from how similar academic work frames the problem.

PromptWizard (Microsoft Research), SIPDO, FIPO, and similar tools implement generate → critique → improve cycles. Their framing is: improve the prompt to produce better outputs. The spec is a means; the output is the goal. Spec Coach's framing is different: the spec is a design artifact with its own quality dimensions — saturation level, drift risk, constraint contradictions, factual accuracy, tab ordering effects. A spec that reaches Logic Compression (where removing any constraint would degrade the output) is the goal. The article is evidence that you've reached it, not the goal itself.

In practice, this framing changes what gets improved. A tool optimizing for output quality will add instructions that nudge the output toward the target. A tool optimizing for spec quality will remove constraints that are redundant, resolve contradictions, and reorder tabs to reduce drift risk — changes that may produce a shorter, simpler spec that generates better output across regenerations.


## The Philosophical Roots

The demo article for this project ("Perfection Through Removal") draws on three writers: Elie Wiesel, Ernest Hemingway, and Antoine de Saint-Exupéry. They are not decorative metaphors. They describe how the pipeline works.

Wiesel wrote that the act of writing is the act of removal — that every book is already contained in the universe of possible texts, and the writer's task is to extract it, eliminating everything that is not the story. This is mechanically accurate for AI generation. The model already contains every possible article. The spec's job is subtraction: close the paths that lead away from the target, and what remains is the output you want.

Hemingway's Iceberg Theory holds that the dignity of movement of an iceberg is due to only one-eighth of it being above water. The visible output derives its authority from the hidden mass beneath — the spec's constraints, its rubric, its research anchors, its banned patterns. The reader experiences the output; they do not see what produced it. A well-designed spec is a Subsurface Mass. The article is its visible tip.

Saint-Exupéry: "Perfection is achieved not when there is nothing more to add, but when there is nothing left to take away." This is the goal state: Logic Compression. A spec reaches Logic Compression when removing any constraint would degrade the output. That is when the spec is ready. Not when it covers everything — when it covers only what is load-bearing.

The reductive philosophy is not an aesthetic preference. It is the engineering discipline that follows directly from constraint saturation analysis. An over-constrained spec produces declining scores across iterative cycles regardless of how good the output is. The correct direction is always removal first — Subtractive Logic before Additive Logic — because removal creates the space that makes addition effective.


## Where This Sits

This project draws on established concepts and formalizes some that are not yet standard.

**Established foundations this project applies:**

Multi-stage prompt chaining is mature tooling — LangChain, LangGraph, and related frameworks have production implementations and published performance data. The sequential-tab prompt chain in `/generate-article` is an instance of this pattern.

Self-refinement feedback loops have an academic record — Self-Refine (2023), Reflexion, and similar work demonstrates that LLMs can critique and improve their own outputs. The Spec Auto-Tune loop is related but distinct in what it refines.

The Lost-in-the-Middle positional phenomenon (Liu et al. 2024) is published and well-cited. Spec Coach's drift analysis builds on this foundation and extends it to spec design.

**Novel formalization this project contributes:**

Constraint Saturation as a named, operational pre-flight check with discrete states (HEALTHY / TIGHT / OVER-DETERMINED) does not appear to have existing tooling. The research literature recognizes over-constrained prompts as a failure mode but does not offer systematic detection before generation.

Spec design quality as a separate evaluation target from output quality is a framing difference with practical consequences. Evaluating whether the spec itself is well-designed — saturation level, drift risk, tab ordering effects, contradictory constraints — is distinct from evaluating whether the output is good. Tools that conflate the two converge on longer, more prescriptive specs. This pipeline converges on shorter ones.

The reductive philosophy as a named, staged methodology (Subtractive Logic first, then Additive Logic, with Logic Compression as the explicit goal state) is a coherent framework that does not appear under a single name in the existing literature, though its components are grounded in documented research.

One relevant external finding: a 2025 paper ("You Don't Need Prompt Engineering Anymore: The Prompting Inversion," arXiv 2510.22251) documents that on capable models, heavily constrained prompts are measurably detrimental — constraints that prevented errors in weaker models induce hyper-literalism in stronger ones. The paper calls this the Guardrail-to-Handcuff transition. This project builds tooling to help practitioners find and stay at the right constraint level. That is, increasingly, where the leverage is.


## Spec Authorship

A few principles that follow from the approach:

**Subtractive Logic before Additive Logic.** Before adding instructions about what the output should do, establish what it cannot do. Negative constraints (what is banned, what patterns to avoid, what failure modes to close) do more work per word than positive requirements. A constraint that says "do not use jargon" closes a vast space of violations with a single prohibition. A constraint that says "use plain language" leaves the definition of plain language to the model.

**Run the saturation check before generating.** A TIGHT or OVER-DETERMINED spec will produce compressed output where important elements are at minimum viable depth. The right response is to remove or relax constraints before adding more. Adding instructions to an over-determined spec accelerates the decline.

**Signal per constraint, not coverage.** The question is not "does the spec cover this topic?" It is "does this constraint carry weight that wouldn't be there without it?" A constraint that the model consistently satisfies without being told is a constraint that can be removed. The spec should contain only what is load-bearing.

**Logic Compression is the goal state.** A spec reaches Logic Compression when removing any constraint would degrade the output. That is the Perfection Gate. Not exhaustive coverage — the point where the spec can do no more work by growing, only by refining.

The pipeline's job is to help you get there.
