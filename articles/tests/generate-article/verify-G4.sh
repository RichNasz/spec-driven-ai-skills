#!/usr/bin/env bash
# Verify G4 — Overwrite Existing Tab
# Checks: exactly one "Generated Article" tab; sentinel text is gone.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

assert_tab_exists    "$ARTICLE_DOC" "Generated Article"                        || failed=$((failed + 1))
assert_tab_not_contains "$ARTICLE_DOC" "Generated Article" "OLD CONTENT — SHOULD BE REPLACED" || failed=$((failed + 1))

# Only one "Generated Article" tab — verify by checking total tab count is 2
# (default tab + Generated Article; reset_article_doc left the default tab)
actual_count=$(count_tabs "$ARTICLE_DOC")
if [[ "$actual_count" -eq 2 ]]; then
    _pass "doc has 2 tabs (no duplicate Generated Article)"
else
    _fail "doc has $actual_count tabs — possible duplicate or missing tab"
    failed=$((failed + 1))
fi

if [[ "$failed" -eq 0 ]]; then
    echo "ALL CHECKS PASSED"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
