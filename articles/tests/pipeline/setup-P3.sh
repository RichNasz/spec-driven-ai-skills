#!/usr/bin/env bash
# Setup for P3 — Non-Default Article Tab Name
# Resets Standard Article Doc. Verifies Standard Spec Doc is accessible.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
reset_article_doc "$ARTICLE_DOC"

SPEC_URL="https://docs.google.com/document/d/$(get_doc_id standard_spec_doc)/edit"
ARTICLE_URL="https://docs.google.com/document/d/$(get_doc_id standard_article_doc)/edit"

echo ""
echo "P3 setup complete."
echo ""
echo "Step 1 — write article to custom tab name:"
echo "  /generate-article $SPEC_URL $ARTICLE_URL \"Custom Article Tab\""
echo "  Then run: ./tests/pipeline/verify-P3-step1.sh"
echo ""
echo "Step 2 — spec-coach must find article despite non-default tab name:"
echo "  /spec-coach $SPEC_URL $ARTICLE_URL"
echo "  Then run: ./tests/pipeline/verify-P3-step2.sh"
