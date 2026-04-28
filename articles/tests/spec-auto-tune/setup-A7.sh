#!/usr/bin/env bash
# Setup for A7 — Idempotence
# Uses the Standard Spec Doc in its POST-A3 state (after A3 already ran).
# Do NOT restore to canonical state before this test.
# The same "Spec Coach" tab from A3 must still be present in the article doc.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")

echo "A7 requires the Standard Spec Doc to be in its post-A3 state (already modified)."
echo "Do NOT run reset-spec-doc.sh before this test."
echo ""

require_tab "$ARTICLE_DOC" "Spec Coach" \
    "The same Spec Coach tab from A3 must be present in the article doc."

echo "Snapshotting spec doc content before second skill run..."
snapshot_tab_hashes "$SPEC_DOC" /tmp/spec-snap-before-A7.txt

echo "A7 setup complete. Run immediately after A3 without resetting."
echo ""
echo "Invocation:"
echo "  /spec-auto-tune specs/fixtures/config-standard.yaml"
echo ""
echo "After invocation: ./tests/spec-auto-tune/verify-A7.sh"
