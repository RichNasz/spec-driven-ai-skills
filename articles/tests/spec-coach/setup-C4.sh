#!/usr/bin/env bash
# Setup for C4 — Overwrite Existing "Spec Coach" Tab
# Requires a "Generated Article" tab; creates a "Spec Coach" tab with sentinel text.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")

require_tab "$ARTICLE_DOC" "Generated Article" \
    "Run setup-G2.sh then /generate-article specs/fixtures/config-standard.yaml first."

# Remove any real Spec Coach tab, then create the sentinel one
if python3 "$SCRIPTS_DIR/find_tab.py" "$ARTICLE_DOC" "Spec Coach" > /dev/null 2>&1; then
    TAB_INFO=$(python3 "$SCRIPTS_DIR/find_tab.py" "$ARTICLE_DOC" "Spec Coach")
    TAB_ID=$(echo "$TAB_INFO" | cut -d'|' -f1)
    python3 "$SCRIPTS_DIR/delete_tab.py" "$ARTICLE_DOC" "$TAB_ID" > /dev/null
fi

create_sentinel_tab "$ARTICLE_DOC" "Spec Coach" "OLD REPORT — SHOULD BE REPLACED"

echo ""
echo "Invocation:"
echo "  /spec-coach specs/fixtures/config-standard.yaml"
