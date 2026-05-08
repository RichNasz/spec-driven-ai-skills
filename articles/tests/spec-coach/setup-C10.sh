#!/usr/bin/env bash
# Setup for C10 — Empty Author Feedback Tab
# Prerequisite: Standard Article Doc must have a "Generated Article" tab.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")

require_tab "$ARTICLE_DOC" "Generated Article" \
    "Run setup-G2.sh then /generate-article specs/fixtures/config-standard.yaml first."

# Remove any existing Spec Coach tab
if python3 "$SCRIPTS_DIR/find_tab.py" "$ARTICLE_DOC" "Spec Coach" > /dev/null 2>&1; then
    TAB_INFO=$(python3 "$SCRIPTS_DIR/find_tab.py" "$ARTICLE_DOC" "Spec Coach")
    TAB_ID=$(echo "$TAB_INFO" | cut -d'|' -f1)
    python3 "$SCRIPTS_DIR/delete_tab.py" "$ARTICLE_DOC" "$TAB_ID" > /dev/null
    echo "Removed existing 'Spec Coach' tab."
fi

# Remove any existing Author Feedback tab, then create an empty one
if python3 "$SCRIPTS_DIR/find_tab.py" "$ARTICLE_DOC" "Author Feedback" > /dev/null 2>&1; then
    TAB_INFO=$(python3 "$SCRIPTS_DIR/find_tab.py" "$ARTICLE_DOC" "Author Feedback")
    TAB_ID=$(echo "$TAB_INFO" | cut -d'|' -f1)
    python3 "$SCRIPTS_DIR/delete_tab.py" "$ARTICLE_DOC" "$TAB_ID" > /dev/null
    echo "Removed existing 'Author Feedback' tab."
fi

# Create an empty Author Feedback tab (no content written)
python3 "$SCRIPTS_DIR/create_tab.py" "$ARTICLE_DOC" "Author Feedback" > /dev/null
echo "Created empty 'Author Feedback' tab."

echo "C10 setup complete."
echo ""
echo "Invocation:"
echo "  /spec-coach specs/fixtures/config-standard.yaml"
