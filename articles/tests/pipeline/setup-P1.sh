#!/usr/bin/env bash
# Setup for P1 — Full Linear Pipeline
# Resets Standard Article Doc; restores Standard Spec Doc to canonical state.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")

echo "Restoring Standard Spec Doc to canonical state..."
restore_spec_doc "$SPEC_DOC" "$CONTENT_DIR/standard-spec"

echo "Resetting Standard Article Doc..."
reset_article_doc "$ARTICLE_DOC"

echo ""
echo "P1 setup complete. Run the three steps in order:"
echo ""
echo "Step 1:"
echo "  /generate-article specs/fixtures/config-with-refs.yaml"
echo "  Then run: ./tests/pipeline/verify-P1-step1.sh"
echo ""
echo "Step 2:"
echo "  /spec-coach specs/fixtures/config-with-refs.yaml"
echo "  Then run: ./tests/pipeline/verify-P1-step2.sh"
echo ""
echo "Step 3:"
echo "  /spec-auto-tune specs/fixtures/config-with-refs.yaml"
echo "  Then run: ./tests/pipeline/verify-P1-step3.sh"
