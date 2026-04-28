#!/usr/bin/env bash
# Setup for C6 — Empty reference_docs List
# Same as C2 — ensure "Generated Article" tab exists, no "Spec Coach" tab.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")

require_tab "$ARTICLE_DOC" "Generated Article" \
    "Run setup-G2.sh then /generate-article specs/fixtures/config-standard.yaml first."

if python3 "$SCRIPTS_DIR/find_tab.py" "$ARTICLE_DOC" "Spec Coach" > /dev/null 2>&1; then
    TAB_INFO=$(python3 "$SCRIPTS_DIR/find_tab.py" "$ARTICLE_DOC" "Spec Coach")
    TAB_ID=$(echo "$TAB_INFO" | cut -d'|' -f1)
    python3 "$SCRIPTS_DIR/delete_tab.py" "$ARTICLE_DOC" "$TAB_ID" > /dev/null
    echo "Removed existing 'Spec Coach' tab."
fi

echo "C6 setup complete."
echo ""
echo "Invocation:"
echo "  /spec-coach specs/fixtures/config-empty-refs.yaml"
