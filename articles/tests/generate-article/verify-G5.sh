#!/usr/bin/env bash
# Verify G5 — Default Tab Name
# Checks: tab named exactly "Generated Article" exists (not a variant).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

assert_tab_exists "$ARTICLE_DOC" "Generated Article" || failed=$((failed + 1))
# Guard against common variants
assert_tab_absent "$ARTICLE_DOC" "Article"           || failed=$((failed + 1))
assert_tab_absent "$ARTICLE_DOC" "generated article" || failed=$((failed + 1))

if [[ "$failed" -eq 0 ]]; then
    echo "ALL CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
