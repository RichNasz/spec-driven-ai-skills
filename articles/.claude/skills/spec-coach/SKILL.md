---
name: spec-coach
description: Use after generate-article to evaluate how well a multi-tab Google Doc spec performed — scores the generated article against the spec's own criteria, analyzes semantic drift across the tab chain, and writes improvement recommendations to a "Spec Coach" tab in the article document
compatibility: "Requires gws CLI, Python 3, and the gws-utils skill"
metadata:
  requires: gws-utils
  suite: rh-skills-articles
---

# Spec Coach — Post-Generation Spec Evaluation

## Overview

Evaluates the quality of a generated article relative to the multi-tab spec that produced it. Reads both documents, scores the article using whatever rubric the spec itself defines, analyzes the tab chain for semantic drift (primacy bias, recency bias, lost-in-the-middle, ordering effects), and — when reference documents are provided — audits the article for factual accuracy by cross-referencing every verifiable claim against the source-of-truth documents. Writes all findings to a tab named "Spec Coach" in the article document.

## Usage

```
/spec-coach <spec_doc_url> <article_doc_url>
/spec-coach <config_yaml_path>
```

**Positional form:**
- `spec_doc_url` — Google Doc URL containing the spec tabs (the same source doc used by generate-article)
- `article_doc_url` — Google Doc URL containing the generated article

**YAML form:** Pass the path to a YAML config file instead of positional URLs. The file must contain:
```yaml
spec_doc_url: "https://docs.google.com/document/d/<SPEC_ID>/edit"
article_doc_url: "https://docs.google.com/document/d/<ARTICLE_ID>/edit"
reference_docs:              # optional — enables factual accuracy audit (Step 5)
  - url: "https://docs.google.com/document/d/<DOC_ID>/edit"
    description: "Short description of what this doc covers"
```
`reference_docs` is optional. When present, the skill performs a factual accuracy audit (Step 5) that cross-references article claims against these source-of-truth documents. When absent, Step 5 is skipped and Part 4 is omitted from the report.

Extract the document ID from a URL like `https://docs.google.com/document/d/<DOC_ID>/edit`.

## Hard Constraints (enforce before doing anything else)

1. **Spec doc is read-only.** Never call `batchUpdate` on the spec document ID. Only `documents.get` is permitted against it.
2. **Spec and article must be different docs.** Extract the document ID from both URLs and compare them. If they are identical, stop immediately and tell the user: "Spec and article cannot be the same document."
3. **All writes go to the "Spec Coach" tab only.** The only `batchUpdate` calls permitted target the article document, and only to create, clear, or write the "Spec Coach" tab.

## Step-by-Step Process

### 0. Validate inputs

**Resolve URLs from args or YAML.** If the argument ends in `.yaml` or `.yml`, load it; otherwise use positional args:
```python
import re, os

def doc_id(url):
    return re.search(r'/d/([a-zA-Z0-9_-]+)', url).group(1)

arg = "<first_argument>"
if arg.endswith(('.yaml', '.yml')):
    config = {'reference_docs': []}
    current_ref = None
    with open(os.path.expanduser(arg)) as f:
        for line in f:
            s = line.strip()
            if not s or s.startswith('#'):
                continue
            if s.startswith('- '):
                if current_ref is not None:
                    config['reference_docs'].append(current_ref)
                current_ref = {}
                s = s[2:].strip()
            elif not line[0:1].isspace() and current_ref is not None:
                config['reference_docs'].append(current_ref)
                current_ref = None
            if ':' in s:
                k, _, v = s.partition(':')
                k, v = k.strip(), v.strip().strip('"').strip("'")
                if current_ref is not None:
                    current_ref[k] = v
                elif v:
                    config[k] = v
    if current_ref is not None:
        config['reference_docs'].append(current_ref)
    spec_doc_url    = config.get('spec_doc_url', '')
    article_doc_url = config.get('article_doc_url', '')
    reference_docs  = config.get('reference_docs', [])  # list of {url, description}
else:
    spec_doc_url    = arg                # first positional
    article_doc_url = "<second_argument>"

spec    = doc_id(spec_doc_url)
article = doc_id(article_doc_url)
assert spec != article, "Spec and article cannot be the same document."
```
Stop and report the error if IDs match. Never proceed to Step 1 until this passes.

### 1. Read both documents

**Read all spec tabs:**
```bash
python3 .claude/skills/gws-utils/scripts/read_doc.py <SPEC_ID>
```

Save the full output. You will need every tab's title and content for both the scoring and drift analysis steps. Each tab is delimited by a `=== TAB N: title | ID: tabId | endIndex=n ===` header line.

**Read the generated article:**
```bash
python3 .claude/skills/gws-utils/scripts/read_doc.py <ARTICLE_ID>
```

Identify the tab that contains the generated article (typically named "Generated Article", "Claude Generated", or similar) by finding its `=== TAB N: ...` header. Save its full text for analysis.

**Read reference documents (if provided):**
If the YAML config includes `reference_docs`, read each one. For each reference doc, extract the document ID from the URL:
```bash
python3 .claude/skills/gws-utils/scripts/read_doc.py <REF_DOC_ID>
```
Save the full text of each reference document. These are the source of truth for the factual accuracy audit in Step 5. Reference documents are read-only — never call any write script against them.

### 2. Constraint Saturation Analysis

This step produces PART 1 of the Spec Coach report. Before scoring the article, assess whether the spec's requirements are mathematically satisfiable within the target word count. Over-determined specs — where constraints exceed the degrees of freedom in the output — produce declining scores across iterative cycles regardless of spec-coach recommendations.

**2a. Count hard coverage requirements.**
Scan every spec tab for items that require "dedicated paragraph," "substantive treatment," "at least one paragraph," or equivalent language. Categorize each:
- Tier 1: Items requiring a dedicated paragraph (typically ~60-80 words minimum each)
- Tier 2: Items requiring substantive mention (typically ~30-40 words minimum each)
- Uncategorized: Items where the spec does not specify the depth of treatment

**2b. Estimate the minimum word budget.**
Calculate: (Tier 1 count x 70) + (Tier 2 count x 35) + intro allocation + conclusion allocation + CTA + transition overhead (~100 words). Compare this to the spec's target word count or read-time target (convert to words at 250 words/minute).

**2c. Detect redundant scoring passes.**
Count how many tabs trigger a scoring threshold with a rewrite loop (e.g., "if below X, rewrite and re-score"). Multiple scoring-rewrite loops in sequence cause voice-flattening — each pass optimizes for checklist compliance at the cost of originality and natural flow. Flag any spec with more than one scoring-rewrite loop.

**2d. Detect contradictory constraints.**
Look for pairs of instructions across different tabs that cannot both be fully satisfied. Common patterns:
- "Dedicated paragraph for each item" in a content tab vs. a word-count limit in a parameters tab
- A compression/tiebreaker rule that permits condensing items that another tab requires as dedicated paragraphs
- Multiple tabs requiring the same scoring threshold (redundant rewrite loops)

**2e. Assess saturation level.**
Assign one of three levels:
- HEALTHY: Minimum word budget is under 85% of target. No contradictory constraints detected. Zero or one scoring pass.
- TIGHT: Minimum word budget is 85-100% of target, OR one contradictory constraint pair detected, OR two scoring passes.
- OVER-DETERMINED: Minimum word budget exceeds target, OR multiple contradictory constraint pairs, OR three or more scoring passes. Flag this prominently — iterative auto-tune cycles will produce declining scores until constraints are reduced.

### 3. Spec Quality Scoring

This step produces PART 2 of the Spec Coach report.

**3a. Discover the spec's own scoring rubric.**
Scan every spec tab for scoring criteria, rubrics, quality thresholds, or weighting percentages. The spec may define these explicitly (e.g., "readability 35%, clarity 35%, technical depth 30%, threshold 9.7") or implicitly through quality-related instructions.

If the spec defines explicit criteria and weights, use them exactly. If the spec has no explicit rubric, construct a reasonable one from the spec's own stated goals and priorities, and note that the rubric was inferred.

**3b. Score the generated article.**
Evaluate the generated article against each criterion in the rubric. For each criterion:
- Assign a score on the same scale the spec uses (e.g., 0-10)
- Provide a 2-3 sentence justification with specific evidence from the article
- Calculate the weighted composite score

**3c. Analyze the path to a theoretical 11/10.**
Go beyond the current ceiling. Recommendations must balance additions with removals — every suggestion to add a new instruction must be paired with what to simplify, merge, or remove to make room. A spec that only grows will eventually over-determine the output.

For each of these areas, provide concrete, actionable recommendations:

ADDITIONS (use sparingly):
- What instructions are missing from the spec entirely that would elevate the output?
- Are there quality dimensions the spec ignores completely (e.g., originality, emotional resonance, narrative arc, specificity of examples)?
- What new tabs should be added, and where in the sequence?

REMOVALS AND RELAXATIONS (prioritize these):
- Which existing instructions should be removed because they are consistently satisfied and no longer need enforcement?
- Which "dedicated paragraph" requirements should be downgraded to "substantive mention" to free word budget?
- Which tabs should be merged because they cover overlapping concerns?
- Which scoring/rewrite loops should be eliminated because they flatten the output?

CONFLICTS:
- Which existing instructions are too vague, too narrow, or working against each other?
- What refinements to existing tabs would have the highest leverage?

Frame this as "what would a spec need to consistently produce output that exceeds the maximum score" — not just hitting the ceiling but breaking through it. A spec that asks for fewer things with more room to execute will consistently outperform a spec that asks for everything precisely.

### 4. Semantic Drift Analysis

This step produces PART 3 of the Spec Coach report. Analyze the tab chain for evidence that sequential processing caused the final article to drift from what the full set of instructions intended.

**4a. Primacy bias analysis.**
Compare the article against Tab 0 and Tab 1 instructions versus later tabs. Look for:
- Patterns, tone, or framing from early tabs that persist even when later tabs explicitly request something different
- Structural choices established by early tabs that later tabs failed to override
- Assign a probability (Low / Moderate / High) that primacy bias affected the output, with specific evidence

**4b. Recency bias analysis.**
Compare the article against the last 2-3 tabs versus earlier tabs. Look for:
- Instructions from later tabs that are disproportionately represented in the output
- Earlier instructions that appear diluted or overwritten by later refinement passes
- Cases where a late-stage rewrite tab stripped nuance that an earlier tab introduced
- Assign a probability (Low / Moderate / High) with specific evidence

**4c. Lost-in-the-middle analysis.**
Identify the middle tabs (roughly tabs in the second and third quartiles of the sequence). For each middle tab:
- Assess whether its specific instructions are proportionally represented in the final article
- Flag any middle-tab instructions that appear underrepresented or missing from the output
- Assign a probability (Low / Moderate / High) with specific evidence

**4d. Tab ordering effects analysis.**
Consider the current tab sequence and reason about how reordering might change outcomes:
- Identify tabs whose effectiveness likely depends on their position in the chain
- Propose 1-2 alternative orderings and explain what would change
- Flag any tabs that would work better if split, merged, or repositioned
- Assess overall probability (Low / Moderate / High) that the current ordering is suboptimal

**4e. Composite drift assessment.**
Synthesize the four analyses into an overall semantic drift verdict:
- Overall drift probability with a confidence level
- The single highest-risk drift mechanism for this specific spec
- Top 3 concrete spec modifications to reduce drift risk (e.g., "Consolidate tabs 3 and 5 into a single tab because...", "Add a reinforcement instruction at the end of tab 6 that restates...", "Move tab 2 after tab 4 because...")

### 5. Factual Accuracy Audit (requires reference docs)

This step produces PART 4 of the Spec Coach report. Skip this step entirely if no `reference_docs` were provided in the YAML config. When skipped, note in the report header: "Factual accuracy audit: skipped (no reference documents provided)."

Reference documents are treated as the guaranteed source of truth. Every verifiable factual claim in the article must be checked against them.

**5a. Extract factual claims from the article.**
Identify every verifiable claim in the article. Focus on:
- Technology names and product names
- GA / preview / planned / in-development statuses and version numbers
- Capability descriptions (what a product does, how it works)
- Protocol support (which APIs are supported, in what form)
- Behavioral descriptions (how components interact, what gets blocked, what gets injected)
- Attribution (which companies converged on an approach, who built what)
- Concrete scenarios presented as real products or features (not hypothetical examples)

Do NOT flag narrative devices (the 6 AM incident scenario), editorial interpretations (consequences the reader should care about), or plain-English explanations of technical terms — these are article-writing choices, not factual claims.

**5b. Cross-reference each claim against the reference documents.**
For each factual claim, search the reference documents for supporting evidence. Categorize:
- VERIFIED: Claim is directly supported by reference docs (exact match or clear paraphrase)
- INACCURACY: Claim contradicts reference docs (wrong status, wrong version, wrong capability, wrong tense — e.g., "supports" when reference says "planned")
- UNSUPPORTED: Claim makes a specific factual assertion not found in any reference doc (potential hallucination — the claim may be true but cannot be verified from the provided sources)
- MINOR: Claim uses slightly different wording than reference docs but the substance is accurate (e.g., "proxy" vs "reverse proxy" for the same component)

**5c. Trace hallucination sources.**
For each INACCURACY or UNSUPPORTED finding, determine where the claim originated:
- SPEC: The spec instructed the model to include this claim (cite the tab and text)
- MODEL: The model generated this claim without support from spec or reference docs
- INFERENCE: The claim is a reasonable interpretation of verified facts but is not explicitly stated (e.g., naming Prometheus as the alerting system in OpenShift when reference docs say "alerts" without naming the system)

This source tracing is critical for spec-auto-tune: if the spec caused the hallucination, the spec needs correction. If the model hallucinated, the spec may need a constraint to prevent it.

**5d. Generate correction recommendations.**
For each INACCURACY or high-risk UNSUPPORTED finding, provide:
- The exact text in the article that should change
- What it should say instead, based on reference docs
- Whether the spec needs a correction (if the spec caused the issue, name the tab and the specific text to change)

### 6. Compose the Spec Coach report

Combine the outputs from Steps 2, 3, 4, and 5 (when applicable) into a single plain-text document. Do NOT use markdown formatting (no #, *, `, or - for bullets). Use plain text with ALL-CAPS headers, numbered lists, and indentation for structure.

Use this structure:

```
SPEC COACH REPORT
Generated: <current date>
Spec document: <spec_doc_url>
Article document: <article_doc_url>

================================================================================
PART 1: CONSTRAINT SATURATION ANALYSIS
================================================================================

COVERAGE REQUIREMENTS
  Tier 1 (dedicated paragraph): <count> items
  Tier 2 (substantive mention): <count> items
  Uncategorized: <count> items

WORD BUDGET
  Estimated minimum words needed: <number>
  Target word count: <number>
  Utilization: <percentage>%
  Assessment: <HEALTHY / TIGHT / OVER-DETERMINED>

SCORING PASSES
  Tabs with scoring-rewrite loops: <list of tab numbers and names>
  Total scoring passes: <count>
  Assessment: <0-1 is healthy, 2 is concerning, 3+ causes voice-flattening>

CONTRADICTORY CONSTRAINTS
  <List each pair of contradictory instructions with tab numbers, or "None detected">

SATURATION VERDICT: <HEALTHY / TIGHT / OVER-DETERMINED>
  <1-2 sentence explanation. If OVER-DETERMINED, state clearly: "Iterative
  auto-tune cycles will produce declining scores until constraints are reduced.">

================================================================================
PART 2: SPEC QUALITY SCORING
================================================================================

SCORING RUBRIC
<State the rubric used — whether it came from the spec or was inferred>

  Criterion 1 (<weight>%): <name>
  Criterion 2 (<weight>%): <name>
  ...

SCORES

  1. <Criterion name>: <score>/<max>
     <2-3 sentence justification with evidence>

  2. <Criterion name>: <score>/<max>
     <2-3 sentence justification with evidence>

  ...

  COMPOSITE SCORE: <weighted score>/<max> (threshold: <threshold if defined>)

BEYOND THE CEILING: PATH TO 11/10

  1. <Recommendation title>
     <Detailed explanation of what to add or change and why it would push past the current max>

  2. <Recommendation title>
     <Detailed explanation>

  ...

================================================================================
PART 3: SEMANTIC DRIFT ANALYSIS
================================================================================

PRIMACY BIAS
  Probability: <Low / Moderate / High>
  Evidence: <specific examples from the article and tabs>
  Affected tabs: <list>

RECENCY BIAS
  Probability: <Low / Moderate / High>
  Evidence: <specific examples from the article and tabs>
  Affected tabs: <list>

LOST IN THE MIDDLE
  Probability: <Low / Moderate / High>
  Evidence: <specific examples from the article and tabs>
  Affected tabs: <list>

TAB ORDERING EFFECTS
  Probability of suboptimal ordering: <Low / Moderate / High>
  Analysis: <reasoning about current order>
  Recommended reorderings:
    a) <proposed change and rationale>
    b) <proposed change and rationale>

COMPOSITE DRIFT ASSESSMENT
  Overall drift probability: <Low / Moderate / High> (confidence: <Low / Moderate / High>)
  Highest-risk mechanism: <which one and why>
  Top 3 spec modifications to reduce drift:
    1. <modification and rationale>
    2. <modification and rationale>
    3. <modification and rationale>

================================================================================
PART 4: FACTUAL ACCURACY AUDIT
(omit this section if no reference_docs were provided)
================================================================================

REFERENCE DOCUMENTS USED
  1. <doc description> (<url>)
  2. <doc description> (<url>)

CLAIMS CHECKED: <total count>
VERIFIED: <count>
INACCURACIES: <count>
UNSUPPORTED: <count>
MINOR: <count>

INACCURACIES (requires correction)

  1. Claim: "<exact text from article>"
     Article says: <what the article claims>
     Reference says: <what the reference doc actually says, with doc name>
     Source: <SPEC (tab N: "quoted text") / MODEL / INFERENCE>
     Correction: <what the article text should say instead>
     Spec change needed: <Yes/No. If yes: Tab N, change "X" to "Y">

  ...

UNSUPPORTED CLAIMS (potential hallucinations)

  1. Claim: "<exact text from article>"
     Not found in: <list of reference docs checked>
     Source: <SPEC (tab N: "quoted text") / MODEL / INFERENCE>
     Risk: <Low / Moderate / High>
     Recommendation: <verify externally, remove from article, or add to reference docs if confirmed>

  ...

MINOR WORDING DIFFERENCES
  <List each difference briefly, or "None">

ACCURACY VERDICT: <CLEAN / MINOR ISSUES / CORRECTIONS NEEDED>
  <1-2 sentence summary. If CORRECTIONS NEEDED, list the spec tabs that
  need changes so spec-auto-tune can act on them.>

================================================================================
END OF REPORT
================================================================================
```

Write the complete report text to `/tmp/spec_coach_report.txt`.

### 7. Find or create the "Spec Coach" tab

**Find the tab or create it:**
```bash
if TAB_INFO=$(python3 .claude/skills/gws-utils/scripts/find_tab.py <ARTICLE_ID> "Spec Coach"); then
    TAB_ID=$(echo "$TAB_INFO" | cut -d'|' -f1)
    END_INDEX=$(echo "$TAB_INFO" | cut -d'|' -f2)
    python3 .claude/skills/gws-utils/scripts/clear_tab.py <ARTICLE_ID> "$TAB_ID" "$END_INDEX"
else
    TAB_ID=$(python3 .claude/skills/gws-utils/scripts/create_tab.py <ARTICLE_ID> "Spec Coach")
fi
```
`find_tab.py` exits 0 with `tabId|endIndex` if found, exits 1 if not found. `clear_tab.py` silently skips if endIndex ≤ 2. `create_tab.py` prints the new tabId.

### 8. Write the report to the "Spec Coach" tab

```bash
python3 .claude/skills/gws-utils/scripts/write_tab.py <ARTICLE_ID> "$TAB_ID" /tmp/spec_coach_report.txt
```

## Key Notes

- **Never write to the spec doc or reference docs** — gws-utils write scripts are only ever called with the article document ID
- **Always validate IDs differ** before any API call — extract IDs from both URLs and compare
- All gws API calls, keyring-line stripping, and JSON encoding are handled by the gws-utils scripts — do not call gws directly
- Write the report text to `/tmp/spec_coach_report.txt` before calling `write_tab.py` — the script reads from a file to avoid shell quoting issues
- Use plain text formatting in the report, not markdown — Google Docs renders markdown syntax literally
- The scoring rubric must come from the spec itself whenever the spec defines one; only infer a rubric as a fallback
- If `read_doc.py` returns no tab output, verify the doc ID is correct
- The "Spec Coach" tab name is fixed and not user-configurable
