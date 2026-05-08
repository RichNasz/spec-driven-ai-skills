#!/usr/bin/env bash
# Setup for C8 — Happy Path with Author Feedback (No Reference Docs)
# Prerequisite: Standard Article Doc must have a "Generated Article" tab.
# Run ./tests/generate-article/setup-G2.sh then /generate-article first if needed.
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

# Remove any existing Author Feedback tab, then create a fresh one with sample feedback
if python3 "$SCRIPTS_DIR/find_tab.py" "$ARTICLE_DOC" "Author Feedback" > /dev/null 2>&1; then
    TAB_INFO=$(python3 "$SCRIPTS_DIR/find_tab.py" "$ARTICLE_DOC" "Author Feedback")
    TAB_ID=$(echo "$TAB_INFO" | cut -d'|' -f1)
    python3 "$SCRIPTS_DIR/delete_tab.py" "$ARTICLE_DOC" "$TAB_ID" > /dev/null
    echo "Removed existing 'Author Feedback' tab."
fi

cat > /tmp/test_author_feedback.txt << 'FEEDBACK'
I liked the conversational tone and the opening hook. The way the article draws the reader in with a concrete scenario works really well.

The middle section dragged — too many bullet points back to back without narrative flow. It felt like a list rather than an article.

The security section used too much jargon. Terms like "runtime attestation" and "supply chain provenance" need plain-language explanations or they'll lose non-specialist readers.

I wanted more concrete examples throughout. The abstract principles are solid but they need grounding in real scenarios the reader can relate to.
FEEDBACK

FEEDBACK_TAB_ID=$(python3 "$SCRIPTS_DIR/create_tab.py" "$ARTICLE_DOC" "Author Feedback")
python3 "$SCRIPTS_DIR/write_tab.py" "$ARTICLE_DOC" "$FEEDBACK_TAB_ID" /tmp/test_author_feedback.txt > /dev/null
echo "Created 'Author Feedback' tab with sample feedback."

echo "C8 setup complete."
echo ""
echo "Invocation:"
echo "  /spec-coach specs/fixtures/config-standard.yaml"
