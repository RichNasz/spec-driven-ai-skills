#!/usr/bin/env bash
# Setup for A3 — Happy Path (Instructional Changes Only, No Reference Docs)
# Prerequisites: Standard Spec Doc in canonical state; Standard Article Doc has
# a "Spec Coach" tab from a C2 run (no reference docs).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")

echo "Restoring Standard Spec Doc to canonical state..."
restore_spec_doc "$SPEC_DOC" "$CONTENT_DIR/standard-spec"

require_tab "$ARTICLE_DOC" "Spec Coach" \
    "Run setup-C2.sh then /spec-coach specs/fixtures/config-standard.yaml first."

echo "Snapshotting spec doc content before skill run..."
snapshot_tab_hashes "$SPEC_DOC" /tmp/spec-snap-before-A3.txt

echo "A3 setup complete."
echo ""
echo "Invocation:"
echo "  /spec-auto-tune specs/fixtures/config-standard.yaml"
echo ""
echo "After invocation: ./tests/spec-auto-tune/verify-A3.sh"
echo "Note: Reset Standard Spec Doc after this test before running other A-series tests."
