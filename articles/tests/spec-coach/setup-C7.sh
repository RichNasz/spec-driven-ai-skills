#!/usr/bin/env bash
# Setup for C7 — Rubric Inference (No Explicit Rubric in Spec)
# Requires a modified spec doc variant with the Quality tab's rubric removed,
# and a "Generated Article" tab produced from that modified spec.
# This setup cannot fully automate the spec modification — see instructions below.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")

echo "C7 requires a spec doc variant with no explicit scoring rubric in its Quality tab."
echo ""
echo "Manual prerequisite (if not already done):"
echo "  1. Open the Standard Spec Doc in a browser."
echo "  2. Edit the Quality tab — remove all explicit weights and threshold text."
echo "  3. Run /generate-article against that modified spec to produce an article."
echo ""

require_tab "$ARTICLE_DOC" "Generated Article" \
    "Generate an article from the rubric-free spec variant first."

if python3 "$SCRIPTS_DIR/find_tab.py" "$ARTICLE_DOC" "Spec Coach" > /dev/null 2>&1; then
    TAB_INFO=$(python3 "$SCRIPTS_DIR/find_tab.py" "$ARTICLE_DOC" "Spec Coach")
    TAB_ID=$(echo "$TAB_INFO" | cut -d'|' -f1)
    python3 "$SCRIPTS_DIR/delete_tab.py" "$ARTICLE_DOC" "$TAB_ID" > /dev/null
    echo "Removed existing 'Spec Coach' tab."
fi

echo "C7 setup complete."
echo ""
echo "Invocation (use the URL of your rubric-free spec variant):"
echo "  /spec-coach <no-rubric-spec-url> <standard-article-doc-url>"
