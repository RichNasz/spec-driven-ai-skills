#!/usr/bin/env bash
# Setup for G6 — Single-Tab Spec
# Resets Standard Article Doc to empty state. Uses Minimal Spec Doc.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
reset_article_doc "$ARTICLE_DOC"

MINIMAL_SPEC_URL="https://docs.google.com/document/d/$(get_doc_id minimal_spec_doc)/edit"
ARTICLE_URL="https://docs.google.com/document/d/$(get_doc_id standard_article_doc)/edit"

echo ""
echo "Invocation:"
echo "  /generate-article $MINIMAL_SPEC_URL $ARTICLE_URL"
