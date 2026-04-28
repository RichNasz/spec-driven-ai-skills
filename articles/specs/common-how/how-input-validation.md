# HOW: Input Validation

## Purpose

Defines the standard pattern for resolving skill inputs and validating document references. All skills that accept Google Doc URLs must follow this pattern before taking any other action.

## Input Forms

Skills may accept one of two input forms:

**Positional form:** URL arguments passed directly on the command line.

**YAML config form:** A single path to a `.yaml` or `.yml` file. Detect this by checking whether the first argument ends in `.yaml` or `.yml`. When detected, load the file and extract URLs from its keys. Unknown YAML keys must be silently ignored — skills share config files and should not fail on keys they don't use.

## Document ID Extraction

Extract the document ID from a Google Doc URL using the path segment between `/d/` and the next `/`. The ID consists of alphanumeric characters, underscores, and hyphens.

## Same-Document Guard

After extracting IDs from all required URLs, compare the IDs that must be distinct (e.g., source and destination, spec and article). If any required pair is identical, stop immediately and report the conflict to the user with a clear error message. Do not proceed to any read or write step.

## Validation Ordering

Input validation is always Step 0. No read or write operations may occur until validation passes. This ordering is non-negotiable across all skills.

## Optional Inputs

Optional inputs (e.g., `reference_docs`, `dest_tab_name`) must have defined defaults when absent. Skills must not fail when optional inputs are missing.
