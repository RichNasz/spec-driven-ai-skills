#!/usr/bin/env bash
# Setup for P2 — Second Iteration Cycle
# Immediately follows P1. The Standard Spec Doc is in its auto-tuned state.
# The Standard Article Doc has "Generated Article" and "Spec Coach" tabs from P1.
# No reset needed — P2 runs against the state left by P1.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

SPEC_DOC=$(get_doc_id "standard_spec_doc")
ARTICLE_DOC=$(get_doc_id "standard_article_doc")

require_tab "$ARTICLE_DOC" "Generated Article" \
    "P2 must follow P1. Run setup-P1.sh and all three P1 steps first."
require_tab "$ARTICLE_DOC" "Spec Coach" \
    "P2 must follow P1. 'Spec Coach' tab from P1 Step 2 must be present."

echo "P2 setup confirmed. Spec Doc is in auto-tuned state from P1."
echo ""
echo "Step 1 — regenerate article from improved spec:"
echo "  /generate-article specs/fixtures/config-with-refs.yaml"
echo "  Then run: ./tests/pipeline/verify-P2-step1.sh"
echo ""
echo "Step 2 — re-evaluate improved spec:"
echo "  /spec-coach specs/fixtures/config-with-refs.yaml"
echo "  Then run: ./tests/pipeline/verify-P2-step2.sh"
