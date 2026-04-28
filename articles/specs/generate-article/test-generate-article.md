# TEST: Generate Article

## References

- `common-how/how-test-fixtures` — fixture catalog and reset protocol
- `common-how/how-test-verification` — Write-Target Fidelity and Idempotence checklists

## Before Each Test

Reset the Standard Article Doc to an empty state per the reset protocol in `how-test-fixtures`.

---

## G1 — Same-Doc Guard

**Setup:** `specs/fixtures/config-same-doc.yaml` (both URLs point to the same Google Doc).

**Invocation:**
```
/generate-article specs/fixtures/config-same-doc.yaml
```

**Expected outcome:**
- Claude emits exactly: "Source and destination cannot be the same document."
- No `gws` call is made — no read, no write.
- The fixture doc is not modified.

**Verification:**
- Confirm the error message matches exactly (case-sensitive).
- Open the fixture doc — no new tab was created.

---

## G2 — Happy Path (YAML form)

**Setup:** Standard Spec Doc (5 tabs). Standard Article Doc (reset — no tabs). `specs/fixtures/config-standard.yaml`.

**Invocation:**
```
/generate-article specs/fixtures/config-standard.yaml
```

**Expected outcome:**
- A tab named "Generated Article" is created in the Standard Article Doc.
- The tab contains a non-empty article.
- The Standard Spec Doc is unchanged.

**Verification:**
- Open Standard Article Doc — "Generated Article" tab exists and has content.
- Apply Write-Target Fidelity Checklist (generate-article).

---

## G3 — Happy Path (Positional form with custom tab name)

**Setup:** Standard Spec Doc. Standard Article Doc (reset).

**Invocation:**
```
/generate-article <standard-spec-doc-url> <standard-article-doc-url> "My Article"
```

**Expected outcome:**
- A tab named exactly "My Article" is created in the Standard Article Doc.
- The tab contains a non-empty article.
- No tab named "Generated Article" exists (the custom name was used).

**Verification:**
- Open Standard Article Doc — confirm tab title is "My Article", not "Generated Article".

---

## G4 — Overwrite Existing Tab

**Setup:** Standard Spec Doc. Standard Article Doc with a "Generated Article" tab already containing the text "OLD CONTENT — SHOULD BE REPLACED". (Manually add this tab and content before running.)

**Invocation:**
```
/generate-article <standard-spec-doc-url> <standard-article-doc-url>
```

**Expected outcome:**
- The "Generated Article" tab exists after the run — not duplicated.
- The tab does not contain "OLD CONTENT — SHOULD BE REPLACED" anywhere.
- The tab contains a new article.

**Verification:**
- Open the "Generated Article" tab. Search (Ctrl+F) for "OLD CONTENT". Confirm zero results.
- Confirm only one tab named "Generated Article" exists.

---

## G5 — Default Tab Name

**Setup:** Standard Spec Doc. Standard Article Doc (reset). Use positional args with no third argument.

**Invocation:**
```
/generate-article <standard-spec-doc-url> <standard-article-doc-url>
```

**Expected outcome:**
- A tab named exactly "Generated Article" is created — not "Article", not "generated article", not any other variant.

**Verification:**
- Open Standard Article Doc. Confirm tab title matches "Generated Article" exactly.

---

## G6 — Single-Tab Spec

**Setup:** Minimal Spec Doc (1 tab). Standard Article Doc (reset).

**Invocation:**
```
/generate-article <minimal-spec-doc-url> <standard-article-doc-url>
```

**Expected outcome:**
- Skill completes without error.
- "Generated Article" tab is created with non-empty content.

**Verification:**
- Open Standard Article Doc — "Generated Article" tab exists and has content.
- Apply Write-Target Fidelity Checklist (generate-article).

---

## G7 — Unknown YAML Keys Ignored

**Setup:** Standard Spec Doc. Standard Article Doc (reset). `specs/fixtures/config-with-refs.yaml` — this config contains `reference_docs` and `dest_tab_name` in addition to the required keys.

**Invocation:**
```
/generate-article specs/fixtures/config-with-refs.yaml
```

**Expected outcome:**
- Skill completes without error.
- Tab is created using the `dest_tab_name` value from the YAML.
- No error about unrecognized keys (`reference_docs`) is emitted.

**Verification:**
- Open Standard Article Doc — confirm the tab exists with the correct name from `dest_tab_name`.
- Confirm no error message about unknown keys appeared in the conversation.
