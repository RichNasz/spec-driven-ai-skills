#!/usr/bin/env bash
# Setup for A4 — Factual Correction With Reference Docs
# Prerequisites: Standard Spec Doc in canonical state (contains seeded inaccuracy
# in Content tab); Standard Article Doc has a "Spec Coach" tab from a C3 run
# (with reference docs — PART 4 shows the seeded inaccuracy as TAB_CORRECTION).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")

echo "Restoring Standard Spec Doc to canonical state (including seeded inaccuracy)..."
restore_spec_doc "$SPEC_DOC" "$CONTENT_DIR/standard-spec"

require_tab "$ARTICLE_DOC" "Spec Coach" \
    "Run setup-C3.sh then /spec-coach specs/fixtures/config-with-refs.yaml first."

echo "A4 setup complete."
echo ""
echo "Invocation:"
echo "  /spec-auto-tune specs/fixtures/config-with-refs.yaml"
echo ""
echo "Note: Reset Standard Spec Doc after this test before running other A-series tests."
