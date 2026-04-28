#!/usr/bin/env bash
# Restore a spec doc to its canonical state from content files.
# Usage: ./tests/reset-spec-doc.sh <fixture_key>
#
# fixture_key is one of:
#   standard_spec_doc       — restores from specs/fixtures/content/standard-spec/
#   over_determined_spec    — restores from specs/fixtures/content/over-determined-spec/
#   minimal_spec_doc        — restores from specs/fixtures/content/minimal-spec/
#
# Example: ./tests/reset-spec-doc.sh standard_spec_doc
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
cd "$SCRIPT_DIR"
source tests/lib.sh

FIXTURE_KEY="${1:-}"
if [[ -z "$FIXTURE_KEY" ]]; then
    echo "Usage: $0 <fixture_key>"
    echo "  fixture_key: standard_spec_doc | over_determined_spec | minimal_spec_doc"
    exit 1
fi

DOC_ID=$(get_doc_id "$FIXTURE_KEY")
if [[ -z "$DOC_ID" ]]; then
    echo "ERROR: fixture '$FIXTURE_KEY' not found in $FIXTURES_YAML"
    exit 1
fi

case "$FIXTURE_KEY" in
    standard_spec_doc)    CONTENT_DIR="$CONTENT_DIR/standard-spec" ;;
    over_determined_spec) CONTENT_DIR="$CONTENT_DIR/over-determined-spec" ;;
    minimal_spec_doc)     CONTENT_DIR="$CONTENT_DIR/minimal-spec" ;;
    *)
        echo "ERROR: unknown fixture key '$FIXTURE_KEY'"
        echo "  Supported: standard_spec_doc | over_determined_spec | minimal_spec_doc"
        exit 1
        ;;
esac

if [[ ! -d "$CONTENT_DIR" ]]; then
    echo "ERROR: content directory not found: $CONTENT_DIR"
    exit 1
fi

echo "Restoring $FIXTURE_KEY ($DOC_ID) from $CONTENT_DIR ..."
restore_spec_doc "$DOC_ID" "$CONTENT_DIR"
