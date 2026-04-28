# HOW: Fixture Governance

## Purpose

Defines how test fixture Google Docs are tracked, accessed, protected, and restored. All test runners must follow this spec before creating or using fixture docs.

## URL Registry

Fixture Google Doc URLs are tracked in `specs/fixtures/fixtures.yaml`. This file is version-controlled in the repository. It is the single source of truth for which Google Docs are the canonical test fixtures.

When fixture docs are first created, their URLs are written into `fixtures.yaml` immediately. The `_placeholder_` entries in `how-test-fixtures.md` are for reference only — `fixtures.yaml` is authoritative.

Format:

```yaml
minimal_spec_doc:     "https://docs.google.com/document/d/<ID>/edit"
standard_spec_doc:    "https://docs.google.com/document/d/<ID>/edit"
over_determined_spec: "https://docs.google.com/document/d/<ID>/edit"
standard_article_doc: "https://docs.google.com/document/d/<ID>/edit"
reference_doc:        "https://docs.google.com/document/d/<ID>/edit"
```

The YAML config files in `specs/fixtures/` (`config-standard.yaml`, `config-with-refs.yaml`, etc.) use the same URLs. When a URL changes, update both `fixtures.yaml` and any config files that reference it.

## Access Control

Fixture docs are stored in a dedicated Google Drive folder. Access is managed at the folder level:

- **Editor access:** Granted only to people who actively run the test suite.
- **Viewer access:** Everyone else in the organization who needs to inspect fixture content.
- **No access:** Default for anyone outside the organization.

The Drive folder URL is recorded at the bottom of this file once the folder is created.

Fixture docs are never shared via "anyone with the link can edit." Link sharing must be off or set to viewer-only. Edit access is granted by name or group only.

**Drive folder URL:** https://drive.google.com/drive/folders/19Iq24femqwC6ItAuu__kAS_4xZTkywBK

## Canonical Content Files

The authoritative content for each fixture doc tab is stored as plain text files in `specs/fixtures/content/`. These files are version-controlled in the repository. They serve as the source of truth for restoring fixture docs after a test run modifies them.

Directory structure:

```
specs/fixtures/content/
  minimal-spec/
    tab-0-context.txt
  standard-spec/
    tab-0-context.txt
    tab-1-parameters.txt
    tab-2-content.txt
    tab-3-style.txt
    tab-4-quality.txt
  over-determined-spec/
    tab-0-context.txt
    tab-1-parameters.txt
    tab-2-content.txt
    tab-3-style.txt
    tab-4-quality.txt
  reference-doc/
    tab-0.txt
```

The Standard Article Doc has no canonical content files — it is always reset to empty before tests, not to a specific content state.

When fixture doc content is intentionally changed (e.g., the seeded inaccuracy in the Reference Doc is updated), the corresponding content file in the repository must be updated in the same commit.

## Reset Procedure

To restore a fixture doc to its canonical state after a test modifies it:

1. Read the canonical content for each tab from `specs/fixtures/content/<fixture-name>/tab-N-<title>.txt`.
2. For each modified tab in the fixture doc:
   a. Clear the tab's content using `deleteContentRange`.
   b. Write the canonical content using `insertText`.
3. Verify the tab content matches the file after writing.

This procedure uses the same gws write pattern defined in `common-how/how-gws-document-write`. It can be executed manually by a test runner or via a dedicated reset skill.

## Recovery From Corruption

If a fixture doc is corrupted beyond what the reset procedure can restore (e.g., tabs were deleted or reordered), recover using the content files and the fixture catalog in `how-test-fixtures.md`:

1. Delete all tabs in the fixture doc except the first (default) tab.
2. Recreate each tab in order using `addDocumentTab` with the correct title.
3. Write canonical content to each tab from the corresponding content file.
4. Verify tab order, titles, and content against the fixture requirements in `how-test-fixtures.md`.

If the fixture doc URL itself becomes invalid (doc deleted), create a new Google Doc, update `fixtures.yaml` and all affected config files in the repository, and re-grant the correct access in Drive.
