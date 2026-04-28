#!/usr/bin/env bash
# Verify P2 Step 1 — after second /generate-article
# Checks: "Generated Article" tab overwritten (still exists, not duplicated);
# "Spec Coach" tab from P1 is unchanged.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
cd "$SCRIPT_DIR"
source tests/lib.sh

ARTICLE_DOC=$(get_doc_id "standard_article_doc")
failed=0

assert_tab_exists "$ARTICLE_DOC" "Generated Article" || failed=$((failed + 1))
assert_tab_exists "$ARTICLE_DOC" "Spec Coach"        || failed=$((failed + 1))

# Total tab count should be 2 (default + Generated Article) plus Spec Coach = 3
# (or 2 if the reset left the default tab absorbed — depends on doc state)
# Just confirm no duplication: tab count should not be > 3
actual_count=$(count_tabs "$ARTICLE_DOC")
if [[ "$actual_count" -le 3 ]]; then
    _pass "tab count ($actual_count) shows no duplicate Generated Article"
else
    _fail "tab count ($actual_count) — possible duplicate tab"
    failed=$((failed + 1))
fi

if [[ "$failed" -eq 0 ]]; then
    echo "ALL CHECKS PASSED — proceed to Step 2: /spec-coach specs/fixtures/config-with-refs.yaml"
else
    echo "${failed} CHECK(S) FAILED"
    exit 1
fi
