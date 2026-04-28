#!/usr/bin/env bash
# Setup for C5 — Over-Determined Saturation Detection
# Resets Standard Article Doc. Requires a "Generated Article" tab produced from
# the Over-Determined Spec Doc — run generate-article against it first.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
reset_article_doc "$ARTICLE_DOC"

OVER_DET_URL="https://docs.google.com/document/d/$(get_doc_id over_determined_spec)/edit"
ARTICLE_URL="https://docs.google.com/document/d/$(get_doc_id standard_article_doc)/edit"

echo "Standard Article Doc reset."
echo ""
echo "Step 1 — generate an article from the Over-Determined Spec Doc:"
echo "  /generate-article $OVER_DET_URL $ARTICLE_URL"
echo ""
echo "Step 2 — then run spec-coach:"
echo "  /spec-coach specs/fixtures/config-over-determined.yaml"
