#!/usr/bin/env bash
# Reset the Standard Article Doc to an empty state.
# Deletes all tabs except the first, then clears the first tab's content.
# Run from project root: ./tests/reset-article-doc.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
if [[ -z "$ARTICLE_DOC" ]]; then
    echo "ERROR: could not find standard_article_doc in $FIXTURES_YAML"
    exit 1
fi

echo "Resetting Standard Article Doc ($ARTICLE_DOC)..."
reset_article_doc "$ARTICLE_DOC"
