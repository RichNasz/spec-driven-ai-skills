# HOW: Test Fixtures

## Purpose

Defines the canonical set of Google Doc fixtures used across all skill test scenarios. All `test-*.md` files reference fixtures by name from this catalog rather than repeating their structure.

## Fixture Catalog

| Name | Purpose |
|---|---|
| Minimal Spec Doc | Edge case — single-tab spec |
| Standard Spec Doc | Happy path for all three skills |
| Over-Determined Spec Doc | Saturation detection and constraint-blocking tests |
| Standard Article Doc | Write target for all skills; reset before each test run |
| Reference Doc | Factual accuracy audit; contains one seeded inaccuracy |

Fixture Google Doc URLs are tracked in `specs/fixtures/fixtures.yaml` — that file is the authoritative URL registry. See `common-how/how-fixture-governance` for access control, URL tracking, and recovery procedures.

---

## Fixture Content Requirements

### Minimal Spec Doc

One tab. Tab title: "Context". Content: approximately 100 words of plain instructions about a factual, specific topic (e.g., "Explain in two paragraphs what consistent hashing is and why distributed systems use it"). The topic must be narrow enough that any reasonable article produced from it shares structural properties — an intro, a body, a close — even if the wording varies.

### Standard Spec Doc

Five tabs in this order:

1. **Context** — Persona and topic framing. ~150 words.
2. **Parameters** — Word target of exactly 800 words. Read time of 3 minutes. Target audience defined.
3. **Content** — At least 4 coverage items. Two must be marked "dedicated paragraph." Two must be marked "substantive mention."
4. **Style** — Tone and voice instructions. No scoring loop.
5. **Quality** — A scoring rubric with explicit weights totaling 100% and a threshold. Example: "readability 40%, technical accuracy 35%, clarity 25%, threshold 8.5/10." One scoring-rewrite loop triggered at the threshold.

This design makes saturation analysis deterministic: minimum word budget = (2 × 70) + (2 × 35) + 100 overhead = 450 words against an 800-word target = 56% utilization = HEALTHY verdict.

### Over-Determined Spec Doc

Five tabs. Word target of 600 words. Content tab requires 10 dedicated paragraphs (10 × 70 = 700 words minimum, exceeding the 600-word target). Three scoring-rewrite loops across tabs 3, 4, and 5. This guarantees an OVER-DETERMINED saturation verdict.

### Standard Article Doc

No required initial content. Before each test run, reset to known state (see Reset Protocol below). The doc must exist — do not delete and recreate it, as the URL must remain stable.

### Reference Doc

One tab. Content: 300–500 words covering the same topic as the Standard Spec Doc. Must include at least one specific verifiable claim that is seeded as incorrect in the Standard Spec Doc's Content tab. Example: Reference Doc says "Feature X is in preview as of Q2 2025." Standard Spec Doc's Content tab says "Feature X is generally available." This creates a reproducible INACCURACY finding for spec-coach's factual accuracy audit and a TAB_CORRECTION item for spec-auto-tune.

---

## Fixture Files (Local)

Two local YAML config files are also part of the fixture set. These live in the project directory alongside the specs, not in Google Drive.

**`specs/fixtures/config-standard.yaml`** — Points to Standard Spec Doc and Standard Article Doc. No reference docs.

**`specs/fixtures/config-with-refs.yaml`** — Points to Standard Spec Doc, Standard Article Doc, and Reference Doc. Includes `dest_tab_name: "Generated Article"`.

**`specs/fixtures/config-same-doc.yaml`** — Contains the same URL for both `spec_doc_url` and `article_doc_url`. Used to trigger the same-doc guard in all three skills.

**`specs/fixtures/config-over-determined.yaml`** — Points to Over-Determined Spec Doc and Standard Article Doc.

---

## Reset Protocol

### Standard Article Doc

Before each test scenario that writes to the Standard Article Doc, reset it to an empty state:

1. Open the Standard Article Doc in a browser.
2. Delete every tab except the first (default) tab.
3. Clear the content of the default tab if it has any.

The doc URL must not change. Do not delete and recreate the doc.

**Scripted reset:** Run `./tests/reset-article-doc.sh` from the project root. This executes the steps above via the gws-utils scripts.

### Standard Spec Doc (after spec-auto-tune tests)

Spec-auto-tune modifies the Standard Spec Doc. After running any A-series scenario, restore the spec doc using the canonical content files in `specs/fixtures/content/standard-spec/`. See `common-how/how-fixture-governance` for the full reset procedure.

**Scripted reset:** Run `./tests/reset-spec-doc.sh standard_spec_doc` from the project root.

### Over-Determined Spec Doc (after spec-auto-tune tests)

Same protocol as Standard Spec Doc. Canonical content files are in `specs/fixtures/content/over-determined-spec/`.

**Scripted reset:** Run `./tests/reset-spec-doc.sh over_determined_spec` from the project root.

---

## Fixture Ownership

See `common-how/how-fixture-governance` for the Drive folder URL, access control model, and procedures for adding new test runners.
