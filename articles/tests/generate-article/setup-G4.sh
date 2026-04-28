#!/usr/bin/env bash
# Setup for G4 — Overwrite Existing Tab
# Resets Standard Article Doc, then creates a "Generated Article" tab
# containing sentinel text that must be gone after the skill runs.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
reset_article_doc "$ARTICLE_DOC"
create_sentinel_tab "$ARTICLE_DOC" "Generated Article" "OLD CONTENT — SHOULD BE REPLACED"

SPEC_URL="https://docs.google.com/document/d/$(get_doc_id standard_spec_doc)/edit"
ARTICLE_URL="https://docs.google.com/document/d/$(get_doc_id standard_article_doc)/edit"

echo ""
echo "Invocation:"
echo "  /generate-article $SPEC_URL $ARTICLE_URL"
