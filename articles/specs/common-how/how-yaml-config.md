# HOW: Shared YAML Config

## Purpose

Defines the shared YAML config file format accepted by all skills in this suite. A single config file can be passed to any skill — skills read only the keys they need and silently ignore the rest.

## Schema

```
spec_doc_url      required  Google Doc URL for the spec document
article_doc_url   required  Google Doc URL for the generated article document
dest_tab_name     optional  Name of the tab to write into (generate-article only; default: "Generated Article")
reference_docs    optional  List of reference documents for factual grounding (spec-coach, spec-auto-tune)
```

Each entry in `reference_docs` has two fields:
```
url          required  Google Doc URL for the reference document
description  required  Short description of what the document covers
```

## Unknown Key Rule

Skills must silently ignore any YAML key they do not recognize. This is what allows a single config file to be shared across skills — a key used by spec-auto-tune (e.g., `reference_docs`) is simply ignored when the same file is passed to generate-article.

## Detection

A skill uses YAML config form when its first argument ends in `.yaml` or `.yml`. Otherwise it uses positional args. See `how-input-validation` for the full resolution logic.
