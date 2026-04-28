#!/usr/bin/env bash
# Setup for G5 — Default Tab Name
# Resets Standard Article Doc to empty state.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
reset_article_doc "$ARTICLE_DOC"

SPEC_URL="https://docs.google.com/document/d/$(get_doc_id standard_spec_doc)/edit"
ARTICLE_URL="https://docs.google.com/document/d/$(get_doc_id standard_article_doc)/edit"

echo ""
echo "Invocation (positional, no tab name argument):"
echo "  /generate-article $SPEC_URL $ARTICLE_URL"
