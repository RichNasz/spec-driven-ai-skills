# /generate-article

Reads a multi-tab Google Doc spec and writes a generated article to a destination Google Doc. Each tab in the spec is a sequential refinement prompt applied in order — earlier tabs establish persona and content, later tabs handle tone, scoring, and style.

## Usage

```
/generate-article <spec_doc_url> <article_doc_url> [dest_tab_name]
/generate-article <config_yaml_path>
```

**Positional form** — pass URLs directly:

```
/generate-article "https://docs.google.com/document/d/<SPEC_ID>/edit" \
                  "https://docs.google.com/document/d/<ARTICLE_ID>/edit" \
                  "My Article"
```

**YAML form** — pass a path to a config file (recommended when sharing configs or using with spec-coach and spec-auto-tune):

```
/generate-article my-article.yaml
```

## YAML config

```yaml
spec_doc_url:    "https://docs.google.com/document/d/<SPEC_ID>/edit"   # required
article_doc_url: "https://docs.google.com/document/d/<ARTICLE_ID>/edit" # required
dest_tab_name:   "Generated Article"                                     # optional
```

| Field | Required | Default | Description |
|---|---|---|---|
| `spec_doc_url` | Yes | — | Google Doc containing the spec tabs |
| `article_doc_url` | Yes | — | Google Doc to write the article into |
| `dest_tab_name` | No | `Generated Article` | Tab name to create or overwrite in the article doc |

Any extra keys in the YAML (e.g., `reference_docs`) are silently ignored.

## What you get

- A tab named `dest_tab_name` is created in the article doc (or overwritten if it already exists).
- The tab contains the full generated article as plain text.
- The spec doc is not modified.

## Hard constraints

| Constraint | Effect |
|---|---|
| Spec and article are the same doc | Stops immediately: `"Source and destination cannot be the same document."` |
| Spec doc is read-only | The skill never calls `batchUpdate` on the spec doc |

## Example

```yaml
# blog-post.yaml
spec_doc_url:    "https://docs.google.com/document/d/1abc.../edit"
article_doc_url: "https://docs.google.com/document/d/1xyz.../edit"
dest_tab_name:   "Draft v1"
```

```
/generate-article blog-post.yaml
```

The skill reads all tabs from the spec doc in order, applies them as a cumulative prompt chain, and writes the result to the "Draft v1" tab in the article doc.

## Notes

- If the destination tab already contains content from a previous run, the skill clears it before writing.
- Tab index order is the order tabs appear in the Google Doc UI — leftmost tab is index 0.
- Running the skill twice on the same config produces the same tab content (idempotent on the tab state, not on the generated text — language model outputs vary).
