# HOW: Shared YAML Config

## Purpose

Defines the shared YAML config file format accepted by all skills in this suite. A single config file can be passed to any skill — skills read only the keys they need and silently ignore the rest.

## Schema

```
spec_doc_url      required  Google Doc URL for the spec document
article_doc_url   required  Google Doc URL for the generated article document
dest_tab_name     optional  Name of the article tab (default: "Generated Article"). Used by generate-article as the write target and by spec-coach to locate the article tab for analysis.
reference_docs    optional  List of reference documents. generate-article reads them as supplementary context during generation; spec-coach uses them for the Part 4 factual accuracy audit; spec-auto-tune uses them to ground research-backed spec improvements.
```

Each entry in `reference_docs` has two fields:
```
url          required  Google Doc URL for the reference document
description  required  Short description of what the document covers
```

## Unknown Key Rule

Skills must silently ignore any YAML key they do not recognize. This is what allows a single config file to be shared across skills — a key used by one skill is simply ignored by skills that do not need it.

## Detection

A skill uses YAML config form when its first argument ends in `.yaml` or `.yml`. Otherwise it uses positional args. See `how-input-validation` for the full resolution logic.
