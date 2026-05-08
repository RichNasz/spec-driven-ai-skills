#!/usr/bin/env bash
# Setup for A9 — Author Feedback Recommendations Applied
# Prerequisites: Standard Spec Doc in canonical state; Standard Article Doc has
# a "Spec Coach" tab from a C8 run (with Part 5 author feedback analysis).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")

echo "Restoring Standard Spec Doc to canonical state..."
restore_spec_doc "$SPEC_DOC" "$CONTENT_DIR/standard-spec"

require_tab "$ARTICLE_DOC" "Spec Coach" \
    "Run setup-C8.sh then /spec-coach specs/fixtures/config-standard.yaml first."

# Verify the Spec Coach tab contains Part 5 (from a C8 run)
if ! python3 "$SCRIPTS_DIR/read_doc.py" "$ARTICLE_DOC" --tab "Spec Coach" 2>/dev/null | grep -q "PART 5"; then
    echo "WARNING: 'Spec Coach' tab does not contain PART 5."
    echo "  Run setup-C8.sh then /spec-coach first to generate a report with author feedback."
    exit 1
fi
echo "Prerequisite OK: 'Spec Coach' tab contains PART 5."

echo "Snapshotting spec doc content before skill run..."
snapshot_tab_hashes "$SPEC_DOC" /tmp/spec-snap-before-A9.txt

echo "A9 setup complete."
echo ""
echo "Invocation:"
echo "  /spec-auto-tune specs/fixtures/config-standard.yaml"
echo ""
echo "After invocation: ./tests/spec-auto-tune/verify-A9.sh"
echo "Note: Reset Standard Spec Doc after this test before running other A-series tests."
