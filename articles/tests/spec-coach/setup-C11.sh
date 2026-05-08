#!/usr/bin/env bash
# Setup for C11 — Author Feedback Conflicts with Part 2 Recommendation
# The feedback explicitly praises an aspect that Part 2 is likely to recommend
# removing or relaxing (dedicated paragraphs for each topic).
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

# Remove any existing Author Feedback tab, then create one with conflict-inducing feedback
if python3 "$SCRIPTS_DIR/find_tab.py" "$ARTICLE_DOC" "Author Feedback" > /dev/null 2>&1; then
    TAB_INFO=$(python3 "$SCRIPTS_DIR/find_tab.py" "$ARTICLE_DOC" "Author Feedback")
    TAB_ID=$(echo "$TAB_INFO" | cut -d'|' -f1)
    python3 "$SCRIPTS_DIR/delete_tab.py" "$ARTICLE_DOC" "$TAB_ID" > /dev/null
    echo "Removed existing 'Author Feedback' tab."
fi

cat > /tmp/test_author_feedback_conflict.txt << 'FEEDBACK'
I love how every topic gets its own dedicated paragraph. This depth of coverage is essential — don't reduce this. Each section having its own space to breathe is what makes the article authoritative.

I also really appreciate the scoring loop that forces quality. The multiple passes of evaluation and rewriting are clearly producing a polished result.

The conclusion felt rushed though — it needs more space.
FEEDBACK

FEEDBACK_TAB_ID=$(python3 "$SCRIPTS_DIR/create_tab.py" "$ARTICLE_DOC" "Author Feedback")
python3 "$SCRIPTS_DIR/write_tab.py" "$ARTICLE_DOC" "$FEEDBACK_TAB_ID" /tmp/test_author_feedback_conflict.txt > /dev/null
echo "Created 'Author Feedback' tab with conflict-inducing feedback."

echo "C11 setup complete."
echo ""
echo "Invocation:"
echo "  /spec-coach specs/fixtures/config-standard.yaml"
