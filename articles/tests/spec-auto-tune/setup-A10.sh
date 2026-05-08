#!/usr/bin/env bash
# Setup for A10 — PRESERVE Marker Blocks TAB_REMOVAL
# Prerequisites: Standard Spec Doc in canonical state; Standard Article Doc has
# a "Spec Coach" tab from a C11 run (with Part 5 PRESERVE markers that conflict
# with Part 2 TAB_REMOVAL recommendations).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")

echo "Restoring Standard Spec Doc to canonical state..."
restore_spec_doc "$SPEC_DOC" "$CONTENT_DIR/standard-spec"

require_tab "$ARTICLE_DOC" "Spec Coach" \
    "Run setup-C11.sh then /spec-coach specs/fixtures/config-standard.yaml first."

# Verify the Spec Coach tab contains PRESERVE markers (from a C11 run)
if ! python3 "$SCRIPTS_DIR/read_doc.py" "$ARTICLE_DOC" --tab "Spec Coach" 2>/dev/null | grep -q "PRESERVE"; then
    echo "WARNING: 'Spec Coach' tab does not contain PRESERVE markers."
    echo "  Run setup-C11.sh then /spec-coach first to generate a report with conflicting feedback."
    exit 1
fi
echo "Prerequisite OK: 'Spec Coach' tab contains PRESERVE markers."

echo "Snapshotting spec doc content before skill run..."
snapshot_tab_hashes "$SPEC_DOC" /tmp/spec-snap-before-A10.txt

echo "A10 setup complete."
echo ""
echo "Invocation:"
echo "  /spec-auto-tune specs/fixtures/config-standard.yaml"
echo ""
echo "After invocation: ./tests/spec-auto-tune/verify-A10.sh"
echo "Note: Reset Standard Spec Doc after this test before running other A-series tests."
